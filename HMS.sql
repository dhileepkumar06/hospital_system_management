create database healthcare_management_system;
use healthcare_management_system;

create table patients(
pid int primary key,
p_name varchar(35),
age int,
gender varchar(10),
p_phone bigint unique);

create table doctors(
did int primary key,
d_name varchar(35),
specz varchar(35));

create table appointments(
aid int primary key,
pid int,
did int,
appointment_date datetime default current_timestamp,
status varchar(20),
foreign key (pid) references patients (pid),
foreign key (did) references doctors (did)
);

create table  treatments(
tid int primary key,
aid int,
diagnosis varchar(35),
cost decimal(10,2),
foreign key (aid) references appointments (aid));

create table billing(
bill_id int primary key,
pid int,
Total_amt decimal(10,2),
payment_status varchar(20),
foreign key (pid) references patients (pid)
);

INSERT INTO patients (pid, p_name, age, gender, p_phone) VALUES
(1, 'Ravi Kumar', 35, 'Male', 9876543210),
(2, 'Anita Sharma', 28, 'Female', 9123456789),
(3, 'Suresh Raj', 42, 'Male', 9988776655),
(4, 'Priya Nair', 31, 'Female', 9090909090),
(5, 'Arun Das', 50, 'Male', 9012345678);

INSERT INTO doctors (did, d_name, specz) VALUES
(101, 'Dr. Meena', 'Cardiology'),
(102, 'Dr. Arun', 'Orthopedics'),
(103, 'Dr. Priya', 'Dermatology'),
(104, 'Dr. Karthik', 'Neurology'),
(105, 'Dr. Sunitha', 'Gynecology');

INSERT INTO appointments (aid, pid, did, status) VALUES
(1001, 1, 101, 'Scheduled'),
(1002, 2, 102, 'Completed'),
(1003, 3, 103, 'Cancelled'),
(1004, 4, 104, 'Completed'),
(1005, 5, 105, 'Scheduled');

INSERT INTO treatments (tid, aid, diagnosis, cost) VALUES
(5001, 1001, 'Heart Checkup', 3500.00),
(5002, 1002, 'Knee Pain', 4800.00),
(5003, 1003, 'Skin Allergy', 2500.00),
(5004, 1004, 'Migraine', 6200.00),
(5005, 1005, 'Pregnancy Care', 8000.00);

INSERT INTO billing (bill_id, pid, Total_amt, payment_status) VALUES
(9001, 1, 3500.00, 'Pending'),
(9002, 2, 4800.00, 'Paid'),
(9003, 3, 2500.00, 'Pending'),
(9004, 4, 6200.00, 'Paid'),
(9005, 5, 8000.00, 'Pending');

select * from patients;
select * from doctors;
select * from appointments;
select * from treatments;
select * from billing;

-- Docctor wise Patient_count -- 
select d.d_name, count(a.pid) as patient_count from doctors d
inner join appointments a on d.did = a.did
group by d.d_name;

-- Month wise Revenue report --
select month(a.appointment_date) as monthwise, sum(b.Total_amt) as total_revenue from appointments a
inner join billing b on a.pid = b.pid
group by month(a.appointment_date);

create view Revenue_report_on_this_month as select month(a.appointment_date) as monthwise, sum(b.Total_amt) as total_revenue from appointments a
inner join billing b on a.pid = b.pid
group by month(a.appointment_date);

select * from revenue_report_on_this_month;

-- STORED PROCEDURE -- ADD APPOINTMENT--[ I used a Stored Procedure to insert new records, which helps avoid writing repetitive SQL queries each time.]
delimiter $$
create procedure add_appointment (in enter_aid int, in enter_pid int, in enter_did int, in enter_status varchar(20))
begin
insert into appointments(aid, pid, did, status)
values(enter_aid, enter_pid, enter_did, enter_status);
end $$
delimiter ;

call add_appointment(1006, 2, 103, "scheduled");
call add_appointment(1007, 4, 104, "scheduled");
call add_appointment(1008, 3, 103, "scheduled");

select * from appointments;
select * from treatments;

-- TRIGGER-- AUTO UPDATE On BILLING Tables --[ I used a Trigger to automatically update the corresponding child table whenever records are inserted or updated in the parent table. ]
delimiter $$
create trigger trg_updates_billing
after insert on treatments
for each row
begin
update billing set Total_amt  = Total_amt + new.cost where pid = (select pid from appointments where aid = new.aid);
end $$
delimiter ;

insert into treatments (tid, aid, diagnosis, cost) VALUES
(5007, 1007, 'ECG', 10000.00);
select * from billing;

-- 1. Display all patient details.-----
select * from patients;

-- 2. Display doctor name and specialization only.
select d_name, specz from doctors;

-- 3. List all appointments with status = 'Scheduled'.
select * from appointments where status = 'scheduled';

-- 4. Display patient names and phone numbers.
select p_name, p_phone from patients;

-- .5 Show all treatments with cost greater than 5,000.
select * from treatments where cost > 5000.00;

-- Level-- 2

-- 1.Find patients older than 40.
select * from patients where age > 40;

-- 2.List appointments sorted by appointment date (latest first).
select * from appointments order by appointment_date desc;

-- 3.Display top 3 most expensive treatments.---
select * from treatments order by cost desc limit 3;

-- 4.Find doctors whose specialization is Dermatology.-- 
select * from doctors where specz = 'Dermatology';

-- 5.Show bills with payment status = 'Pending' -- .
select * from billing where payment_status = 'Pending';

-- Level 3 :         GROUP BY & HAVING (Interview Favorite)+++++++++++

-- 1.Find total billing amount per patient.--
select b.bill_id, p.pid, p.p_name, p.age, p.gender, p.p_phone, b.Total_amt, b.payment_status from patients as p
inner join billing as b on p.pid = b.pid;

-- 2.Find doctors having more than 1 appointment.
desc appointments;
desc doctors;
select count(a.aid), a.pid, a.did, d.d_name, d.specz, a.appointment_date, a.status from appointments as a
inner join doctors as d on a.did = d.did
group by d.did, d.d_name, d.specz 
having count(a.aid) > 1;

SELECT 
    d.did,
    d.d_name,
    d.specz,
    COUNT(a.aid) AS appointment_count
FROM appointments a
JOIN doctors d ON a.did = d.did
GROUP BY d.did, d.d_name, d.specz
HAVING COUNT(a.aid) > 1;


-- 4.Display patients whose total bill exceeds ₹7,000.

desc patients;
desc billing;
select b.bill_id, b.pid, p.p_name, p.p_phone, b.Total_amt, b.payment_status from billing as b
inner join patients as p on b.pid = p.pid
where b.Total_amt > 7000.00;

-- 5.Find department/specialization-wise appointment count.--
SELECT
    d.d_name,
    d.specz,
    COUNT(a.aid) AS appointment_count
FROM appointments a
JOIN doctors d ON a.did = d.did
GROUP BY d.d_name, d.specz;

