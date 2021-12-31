-- Question 113
-- Question 98
-- The Trips table holds all taxi trips. Each trip has a unique Id, while Client_Id and Driver_Id are both foreign keys to the Users_Id at the Users table. Status is an ENUM type of ('completed', 'cancelled_by_driver', 'cancelled_by_client').

-- +----+-----------+-----------+---------+--------------------+----------+
-- | Id | Client_Id | Driver_Id | City_Id |        Status      |Request_at|
-- +----+-----------+-----------+---------+--------------------+----------+
-- | 1  |     1     |    10     |    1    |     completed      |2013-10-01|
-- | 2  |     2     |    11     |    1    | cancelled_by_driver|2013-10-01|
-- | 3  |     3     |    12     |    6    |     completed      |2013-10-01|
-- | 4  |     4     |    13     |    6    | cancelled_by_client|2013-10-01|
-- | 5  |     1     |    10     |    1    |     completed      |2013-10-02|
-- | 6  |     2     |    11     |    6    |     completed      |2013-10-02|
-- | 7  |     3     |    12     |    6    |     completed      |2013-10-02|
-- | 8  |     2     |    12     |    12   |     completed      |2013-10-03|
-- | 9  |     3     |    10     |    12   |     completed      |2013-10-03| 
-- | 10 |     4     |    13     |    12   | cancelled_by_driver|2013-10-03|
-- +----+-----------+-----------+---------+--------------------+----------+
-- The Users table holds all users. Each user has an unique Users_Id, and Role is an ENUM type of ('client', 'driver', 'partner').

-- +----------+--------+--------+
-- | Users_Id | Banned |  Role  |
-- +----------+--------+--------+
-- |    1     |   No   | client |
-- |    2     |   Yes  | client |
-- |    3     |   No   | client |
-- |    4     |   No   | client |
-- |    10    |   No   | driver |
-- |    11    |   No   | driver |
-- |    12    |   No   | driver |
-- |    13    |   No   | driver |
-- +----------+--------+--------+
-- Write a SQL query to find the cancellation rate of requests made by unbanned users (both client and driver must be unbanned) between Oct 1, 2013 and Oct 3, 2013. The cancellation rate is computed by dividing the number of canceled (by client or driver) requests made by unbanned users by the total number of requests made by unbanned users.

-- For the above tables, your SQL query should return the following rows with the cancellation rate being rounded to two decimal places.

-- +------------+-------------------+
-- |     Day    | Cancellation Rate |
-- +------------+-------------------+
-- | 2013-10-01 |       0.33        |
-- | 2013-10-02 |       0.00        |
-- | 2013-10-03 |       0.50        |
-- +------------+-------------------+
-- Credits:
-- Special thanks to @cak1erlizhou for contributing this question, writing the problem description and adding part of the test cases.

-- Solution


CREATE TABLE #p 
(
  Id       INT,
  Client_Id  int,
  Driver_Id  int,
  City_Id  int,
  Status  varchar(60),
  Request_at   DATE
);

INSERT INTO #p
VALUES
( 1 , 1 , 10 , 1 , 'completed' ,'2013-10-01'),
( 2 , 2 , 11 , 1 , 'cancelled_by_driver','2013-10-01'),
( 3 , 3 , 12 , 6 , 'completed' ,'2013-10-01'),
( 4 , 4 , 13 , 6 , 'cancelled_by_client','2013-10-01'),
( 5 , 1 , 10 , 1 , 'completed' ,'2013-10-02'),
( 6 , 2 , 11 , 6 , 'completed' ,'2013-10-02'),
( 7 , 3 , 12 , 6 , 'completed' ,'2013-10-02'),
( 8 , 2 , 12 , 12 , 'completed' ,'2013-10-03'),
( 9 , 3 , 10 , 12 , 'completed' ,'2013-10-03'), 
( 10 , 4 , 13 , 12 , 'cancelled_by_driver','2013-10-03');

select * from #q;
CREATE TABLE #q 
(
  Users_Id        INT,
  Banned   int,
  Role    varchar(60)

);

insert into #q values
(1,0,'client'),
(2,1,'client'),
(3,0,'client'),
(4,0,'client'),
(10,0,'driver'),
(11,0,'driver'),
(12,0,'driver'),
(13,0,'driver');


select * from #q;

select p.*,q.banned c_role,q.banned d_role from #p p left join #q q on p.client_id=q.users_id;

with a as (
select * from #p where client_id in (select users_id from #q where banned = 0) and driver_id in (select users_id from #q where banned = 0)
)
,b as 
(
select request_at,case when status in ('cancelled_by_driver','cancelled_by_client' ) then 'cancelled' else status end as status,count(1) as cn from a group by 1,2
)--select * from b;
,c as
(
select request_at,coalesce(sum(case when status = 'cancelled' then cn end),0) as cancelled,
coalesce(sum(case when status = 'completed' then cn end),0) as completed from b group by 1
)select request_at,cancelled::decimal(10,2)/(cancelled+completed ::decimal(10,2)) from c;


-- +------------+-------------------+
-- |     Day    | Cancellation Rate |
-- +------------+-------------------+
-- | 2013-10-01 |       0.33        |
-- | 2013-10-02 |       0.00        |
-- | 2013-10-03 |       0.50        |
-- +------------+-------------------+

