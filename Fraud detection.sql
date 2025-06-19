create table users (
user_id varchar(10) primary key,
name varchar(50),
created_at date,
account_status varchar(20),
age int,
gender char(1)
);

create table transactions (
transaction_id varchar(10) primary key,
user_id varchar(10),
amount decimal(18, 2),
transaction_type varchar (20),
transaction_time datetime,
location varchar(50),
device_id varchar(10),
foreign key (user_id) references users (user_id)
);

create table logins (
login_id varchar(10) primary key,
user_id varchar(10),
login_time datetime,
ip_address varchar(50),
location varchar(50),
device_id varchar(10),
foreign key (user_id) references users (user_id)
);

-- Detect Dormant Users Suddenly Transacting
select t.user_id, u.account_status,
count(*) as transaction_count,
max(t.transaction_time) as last_transaction_time
from transactions t
join users u on t.user_id = u.user_id
where u.account_status = 'dormant'
group by t.user_id, u.account_status
having count(*) > 0


-- Multiple logins from different locations/devices in one day
select user_id,
cast(login_time as date) as login_date,
count(distinct location) as unique_locations,
count(distinct device_id) as unique_devices
from logins
group by user_id, cast(login_time as date)
having count(distinct location) > 1 or count(distinct device_id) > 1


-- Unusually large transactions
select 
    user_id,
    transaction_id,
    amount,
    transaction_time,
    location
from transactions
where amount > 150000


--  Login Location ? Transaction Location (Recent Mismatch)
select 
    t.user_id,
    t.transaction_time,
    t.location AS transaction_location,
    l.login_time,
    l.location AS login_location
from transactions t
JOIN logins l ON t.user_id = l.user_id
where DATEDIFF(MINUTE, l.login_time, t.transaction_time) BETWEEN 0 AND 60
  AND t.location <> l.location

 -- Frequent transactions within a short period
 select 
    user_id,
    COUNT(*) AS txn_count,
    MIN(transaction_time) AS first_time,
    MAX(transaction_time) AS last_time,
    DATEDIFF(MINUTE, MIN(transaction_time), MAX(transaction_time)) AS time_diff_minutes
from transactions
group by user_id
having COUNT(*) >= 5 AND DATEDIFF(MINUTE, MIN(transaction_time), MAX(transaction_time)) <= 10