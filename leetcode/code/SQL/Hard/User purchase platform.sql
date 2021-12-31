-- Question 113
-- Table: Spending

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | user_id     | int     |
-- | spend_date  | date    |
-- | platform    | enum    | 
-- | amount      | int     |
-- +-------------+---------+
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop and a mobile application.
-- (user_id, spend_date, platform) is the primary key of this table.
-- The platform column is an ENUM type of ('desktop', 'mobile').
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date.

-- The query result format is in the following example:

-- Spending table:
-- +---------+------------+----------+--------+
-- | user_id | spend_date | platform | amount |
-- +---------+------------+----------+--------+
-- | 1       | 2019-07-01 | mobile   | 100    |
-- | 1       | 2019-07-01 | desktop  | 100    |
-- | 2       | 2019-07-01 | mobile   | 100    |
-- | 2       | 2019-07-02 | mobile   | 100    |
-- | 3       | 2019-07-01 | desktop  | 100    |
-- | 3       | 2019-07-02 | desktop  | 100    |
-- +---------+------------+----------+--------+

-- Result table:
-- +------------+----------+--------------+-------------+
-- | spend_date | platform | total_amount | total_users |
-- +------------+----------+--------------+-------------+
-- | 2019-07-01 | desktop  | 100          | 1           |
-- | 2019-07-01 | mobile   | 100          | 1           |
-- | 2019-07-01 | both     | 200          | 1           |
-- | 2019-07-02 | desktop  | 100          | 1           |
-- | 2019-07-02 | mobile   | 100          | 1           |
-- | 2019-07-02 | both     | 0            | 0           |
-- +------------+----------+--------------+-------------+ 
-- On 2019-07-01, user 1 purchased using both desktop and mobile, user 2 purchased using mobile only and user 3 purchased using desktop only.
-- On 2019-07-02, user 2 purchased using mobile only, user 3 purchased using desktop only and no one purchased using both platforms.

-- Solution



CREATE TABLE #p 
(
  user_id      INT,
  spend_date   DATE,
  platform     VARCHAR(50),
  amount       INT
);

INSERT INTO #p
VALUES
(
  1,
  '2019-07-01',
  'mobile',
  100
),
(
  1,
  '2019-07-01',
  'desktop',
  100
),
(
  2,
  '2019-07-01',
  'mobile',
  100
),
(
  2,
  '2019-07-02',
  'mobile',
  100
),
(
  3,
  '2019-07-01',
  'desktop',
  100
),
(
  3,
  '2019-07-02',
  'desktop',
  100
);

SELECT user_id,
       spend_date,
       SUM(CASE WHEN platform = 'mobile' THEN amount ELSE 0 END) AS mobile,
       SUM(CASE WHEN platform = 'desktop' THEN amount ELSE 0 END) AS desktop INTO #p1
FROM #p
GROUP BY 1,
         2;

SELECT *
FROM #p1;

WITH tb AS
(
  SELECT spend_date,
         CASE
           WHEN mobile > 0 AND desktop > 0 THEN 'both'
           WHEN mobile > 0 AND desktop = 0 THEN 'mobile'
           WHEN mobile = 0 AND desktop > 0 THEN 'desktop'
         END AS platform,
         COUNT(*) AS usr,
         SUM(mobile + desktop) AS am
  FROM #p1
  GROUP BY 1,
           2
  ORDER BY 1,
           2
),
get_rows AS
(
  SELECT DISTINCT spend_date,
         t.platform
  FROM tb
    JOIN (SELECT DISTINCT platform FROM tb) t ON 1 = 1
)
SELECT a.spend_date,
       a.platform,
       COALESCE(tb.usr,0),
       COALESCE(tb.am,0)
FROM get_rows a
  LEFT JOIN tb
         ON a.spend_date = tb.spend_date
        AND a.platform = tb.platform
ORDER BY 1;

