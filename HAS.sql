use hospital_analytics_system;
-- Basic Level
-- Write a query to find all patients whose age is above 65.
select * from patients where age>65;
-- Retrieve all appointments scheduled for today.
select * from  appointments where AppointmentDate=now();
-- Find the total number of patients available in each city.
select city,count(patientID) CP from patients group by city;
-- Display all doctors working in the Cardiology department.
select d.DoctorID,d.DoctorName,dept.DepartmentName from doctors d inner join departments dept on d.departmentid=dept.DepartmentID where dept.DepartmentName="Cardiology";
-- Find the total number of appointments handled by each doctor.
select DoctorID,count(appointmentID) as NoOfAppointments from appointments group by doctorID;
-- Retrieve patients who do not have insurance records.
select p.PatientID,p.PatientName from patients p left join insurance i on p.PatientID=i.PatientID where i.PatientID is null; 
-- Find all bills where the total amount exceeds ₹50,000.
select * from bills where totalamount>50000;
-- Display the top 10 highest payment amounts.
select * from payments order by amountpaid desc limit 10;
-- Find the total number of rooms available floor-wise.
select Floor,count(RoomID) No_of_Rooms_Available from rooms where AvailabilityStatus="Available" group by floor; 
-- Retrieve all appointments with status = 'Cancelled'.
select * from appointments where status="Cancelled";
-- Find the average patient age grouped by gender.
select Gender, avg(age) GenderAvg from patients group by gender;
-- Retrieve doctors having more than 10 years of experience.
select DoctorID,DoctorName,ExperienceYears from doctors where ExperienceYears>10;
-- Find the total number of lab tests conducted for each patient.
select patientID,count(labtestID) LabtestCount from labtests group by PatientID;
-- Display all medicines with stock quantity below 100.
select MedicineID,MedicineName from pharmacy where StockQuantity<100;
-- Find all patients who visited more than once.
select a.patientID,p.PatientName, count(a.AppointmentID) visitedCount from appointments a inner join patients p on a.PatientID=p.PatientID where status ="Completed" group by PatientID having count(AppointmentID)>1;
-- Retrieve departments having more than 20 doctors.
select d.DepartmentID,dept.DepartmentName, count(d.DoctorID) as DoctorsCount from doctors d inner join departments dept on d.DepartmentID=dept.DepartmentID group by d.DepartmentID,dept.DepartmentName having count(d.DoctorID)>20;
-- Find all feedback ratings below 3.
select f.patientId,f.DoctorID,d.DoctorName,f.Rating from feedback f inner join doctors d on f.DoctorID=d.DoctorID where f.rating<3;
-- Display the latest 20 admission records.[Admission Date column missing]
select * from admissions order by AdmissionID desc limit 20;
-- Find the total hospital revenue generated through bills.
select sum(AmountPaid) Tot_Revenue from payments;
-- Retrieve the count of appointments month-wise.
select year(AppointmentDate) as Year,month(appointmentDate) as Month, count(AppointmentID) as AppointmentCount from appointments group by year(AppointmentDate),month(appointmentDate) order by year(appointmentDate),month(appointmentDate);



-- Intermediate Level
-- Find the top 5 doctors who handled the highest number of appointments.
select a.doctorID,d.DoctorName, count(a.appointmentID) NoOfAppointments from appointments a inner join doctors d on a.DoctorID=d.DoctorID group by a.DoctorID order by count(a.appointmentID) desc limit 5;
-- Retrieve patients who have appointments in multiple departments.
select p.patientID, p.patientName, count(distinct dept.departmentID) as Tot_Department from patients p inner join appointments a on p.PatientID=a.PatientID
inner join doctors d on a.DoctorID=d.DoctorID
inner join departments dept on d.DepartmentID=dept.DepartmentID group by p.PatientID,p.PatientName having count(dept.departmentID)>1;
-- Find the department generating the maximum revenue.
select dept.departmentID,dept.departmentName, sum(b.totalamount) DeptRevenue from bills b inner join appointments a on b.PatientID=a.PatientID
inner join doctors d on a.DoctorID=d.DoctorID
inner join departments dept on d.DepartmentID=dept.DepartmentID 
group by dept.DepartmentID,dept.DepartmentName order by sum(b.TotalAmount) desc limit 1;
-- Display patients who underwent more than 3 lab tests.
select l.patientID,p.PatientName,count(l.labtestID) as CountOfLabTests from labtests l inner join patients p on l.PatientID=p.PatientID 
group  by l.PatientID,p.PatientName 
having count(l.labtestID)>3;
-- Find the most prescribed medicine in the hospital.
select medicineID,count(medicineID) as Mostly_Prescribed from prescriptions group by MedicineID order by count(MedicineID) desc limit 1;
-- Retrieve doctors whose average feedback rating is above 4.5.
select doctorID, avg(rating) RatingAvg from feedback group by DoctorID having avg(rating)>4.5;
-- Retrieve the second highest billed patient.
select b.billID,p.PatientID,p.PatientName,b.TotalAmount from bills b inner join patients p on b.PatientID=p.PatientID order by TotalAmount desc limit 1 offset 1;
-- Find doctors whose appointments are mostly cancelled.
with OverallAppointment as (select doctorID, count(status) totalAppointments from appointments group by DoctorID),
CancelledAppointment as (select doctorID, count(status) totalAppointmentCancelled from appointments where status="Cancelled" group by DoctorID)
select o.doctorID,o.totalAppointments,c.totalAppointmentCancelled,round((c.totalAppointmentCancelled/o.totalAppointments)*100,2) Cancelled_Percent from OverallAppointment o inner join CancelledAppointment c on o.doctorID=c.doctorID 
where round((c.totalAppointmentCancelled/o.totalAppointments)*100,2)>50.0 order by round((c.totalAppointmentCancelled/o.totalAppointments)*100,2) desc;
-- Retrieve the average bill amount generated by each department.
select dept.departmentID,dept.departmentName, round(avg(b.TotalAmount),2) Avg_Revenue from bills b inner join appointments a on b.PatientID=a.PatientID
inner join doctors d on a.DoctorID=d.DoctorID 
inner join departments dept on d.DepartmentID=dept.DepartmentID group by dept.DepartmentID,dept.DepartmentName;
-- Find the top 10 cities generating maximum hospital revenue.
select p.city,sum(b.TotalAmount) Tot_Revenue from patients p inner join bills b on p.PatientID=b.PatientID group by p.city order by sum(b.TotalAmount) desc limit 10;
-- Display medicines that are prescribed by more than 5 doctors.
with CTE as (select AppointmentID,PatientID,DoctorID from appointments where status="Completed"),
CTE2 as (select p.MedicineID, c.DoctorID from prescriptions p inner join CTE c on p.AppointmentID=c.AppointmentID)
select MedicineID,count(distinct doctorID) DPC from CTE2 group by MedicineID having count(distinct doctorID)>5 order by count(doctorID) desc;
-- Find patients who never provided feedback after appointments.
select distinct a.PatientID,p.patientName from appointments a left join feedback f on a.PatientID=f.PatientID
inner join patients p on a.PatientID=p.PatientID where a.Status="Completed" and f.PatientID is null;
-- Retrieve all duplicate patient records based on name and phone number.
with CTE as (select * , row_number()over(partition by PatientName,PhNo order by PatientName) as RN from patients)
select * from CTE where RN>=2;
-- Find the percentage contribution of each doctor to total hospital revenue.
with CTE as (select distinct a.DoctorID, sum(b.TotalAmount) RevenuePerDoctor from appointments a inner join bills b on a.PatientID=b.PatientID where a.status = "Completed" group by a.DoctorID),
CTE2 as (select sum(TotalAmount) TotRevenue from bills)
select DoctorID,(RevenuePerDoctor/TotRevenue)*100 as RevenuePercent from CTE c1,CTE2 c2;
-- Find the percentage contribution of each department to total hospital revenue.
with CTE as (select distinct dept.departmentID, sum(b.TotalAmount) deptRevenue from bills b inner join appointments a on b.PatientID=a.PatientID
inner join doctors d on a.DoctorID=d.DoctorID
inner join departments dept on d.DepartmentID=dept.DepartmentID group by dept.DepartmentID),
CTE2 as (select sum(TotalAmount) TotRevenue from bills)
select departmentID, (deptRevenue/TotRevenue)*100 deptRevenuePercent from CTE c,CTE2 c2;
-- Display doctor performance rank using: Total appointments, Revenue generated, Average feedback rating
with Tot_Appointments as (select a.doctorID, count(a.appointmentID) TotAppointments,sum(b.TotalAmount) TotAmount from appointments a inner join bills b on a.PatientID=b.PatientID group by a.DoctorID),
AvgRating as (select DoctorID, Round(avg(Rating),2) Avg_Rating from feedback group by DoctorID)
select dense_rank()over(order by TA.TotAppointments desc,TA.TotAmount desc,AR.Avg_Rating desc) as RN,TA.DoctorID,TA.TotAppointments,TA.TotAmount as Revenue,AR.Avg_Rating from Tot_Appointments TA inner join AvgRating AR 
on TA.DoctorID=AR.DoctorID;


-- Advanced SQL (Stored Procedure, Triggers)
-- Write a query to identify suspicious payments where payment amount exceeds bill amount.
select b.billID, b.TotalAmount as TotalAmount, sum(p.AmountPaid) as AmountPaid from bills b inner join payments p on b.BillID=p.BillID group by b.billID having sum(p.AmountPaid)>b.TotalAmount;

-- Find patients who revisit the hospital within 7 days for the same disease.
with CTE as (select distinct a.appointmentDate,p.PatientID,p.PatientName,d.Disease from appointments a inner join diagnosis d on a.appointmentID=d.AppointmentID 
inner join patients p on a.PatientID=p.PatientID order by p.PatientID,p.PatientName),
Pre_CTE as (select *, lag(appointmentDate)over(partition by patientID,Disease order by appointmentDate) as Pre_appointmentDate from CTE)

select patientID,PatientName,appointmentDate,Pre_appointmentDate,datediff(appointmentDate,pre_appointmentDate) as DayBetVisit from Pre_CTE 
where datediff(appointmentDate,pre_appointmentDate)<=7 and pre_appointmentDate is not null order by patientID;

-- Detect duplicate insurance claims for the same patient and diagnosis.
select i.patientID, d.Disease,count(distinct i.insuranceID) CountInsurance from insurance i inner join appointments a on i.PatientID=a.PatientID
inner join diagnosis d on a.AppointmentID=d.AppointmentID group by i.PatientID,d.Disease having count(distinct i.InsuranceID)>1;

-- Payment status automation
delimiter //
create trigger paymentAutomation
after insert on payments
for each row
begin

declare totalAmt int;
declare paidAmt int;
 
select totalAmount into totalAmt
from bills where billID=new.BillID;

select coalesce(sum(amountPaid),0) into paidAmt
from payments where billID=new.BillID;

if TotalAmt = paidamt then 
	update bills set status="Paid" where billId=new.BillID;
elseif TotalAmt<paidAmt then
	update bills set status="suspicious" where billId=new.BillID;
else
	update bills set status="Partially paid" where billId=new.BillID;
end if;

end //
delimiter ;

-- Duplicate insurance prevention 
drop procedure if exists DIP;

delimiter //
create procedure DIP
(IN p_InsuranceID int,
IN p_PatientID int,
IN p_Disease text,
IN p_Provider text)
begin
declare CountInsurance int;

select count(i.insuranceID) into CountInsurance 
from insurance i inner join  appointments a on i.patientID=a.patientID
inner join diagnosis d on a.appointmentID=d.appointmentID
where i.patientID=p_PatientID and d.disease=p_Disease;

if countInsurance>1 then
	signal SQLState '45000'
    SET MESSAGE_TEXT = 'Prohibited: Duplicate Entry';
else 
	insert into insurance(insuranceID,patientID,Provider) values(p_InsuranceID,p_PatientID,p_Provider);
end if;

end//
delimiter ;
call DIP(1,3597,'Allergy','LIC');

-- show procedure status like 'DIP';

-- Room Booking
drop procedure if exists ARB;
delimiter //
create procedure RB(in p_roomID int)
begin 
declare rStatus text;
declare rID int;

select roomID, AvailabilityStatus into rID, rStatus from rooms where roomID=p_roomID;

if rID is null then 
	signal sqlstate '45000'
    set MESSAGE_TEXT ='Room Not Available';
elseif rStatus='Available' then
	update rooms set AvailabilityStatus='Occupied' where roomID=p_roomID;
else 
	signal SQLState '45000'
    SET MESSAGE_TEXT = 'Prohibited: Duplicate Entry';
end if;

end //
delimiter ;








