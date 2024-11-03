use Company_SD


--⦁	Restore Company DB then create the following Queries:


--⦁	Display all the employees Data
select *
from Employee

--⦁	Display the employee First name, last name, Salary and Department number.
select Fname, Lname, Salary, Dno 
from Employee

--⦁	Display all the projects names, locations and the department which is responsible about it.
SELECT Dnum, Pname, Plocation
FROM Project

--⦁	If you know that the company policy is to pay an annual commission for 
-- each employee with specific percent equals 10% of his/her annual salary .
-- Display each employee full name and his annual commission in an ANNUAL COMM column (alias).
select  Fname + ' '+ Lname as [full name], 
(Salary *12*0.10) As ANNUAL_COMM
from Employee

--⦁	Display the employees Id, name who earns more than 1000 LE monthly.
select SSN ,Fname + ' '+ Lname as [full name]
from Employee
where Salary>1000

--⦁	Display the employees Id, name who earns more than 10000 LE annually.
select SSN ,Fname + ' '+ Lname as [full name]
from Employee
where Salary*12>10000

--⦁	Display the names and salaries of the female employees 
select Fname + ' '+ Lname as [full name],salary 
from Employee
where sex='f'

--⦁	Display each department id, name which managed by a manager with id equals 968574
select Dnum,Dname,MGRSSN 
from Departments
where MGRSSN=968574

--⦁	Dispaly the ids, names and locations of  the pojects which controled with department 10.
SELECT       Pnumber,  Pname, Plocation
FROM            Project
where Dnum=10

--⦁	Insert your personal data to the employee table as a new employee in department 
-- number 30, SSN = 102672, Superssn = 112233, salary=3000.
insert into Employee (SSN,Fname,Lname,Dno,Superssn,Salary,Sex,Bdate)
values (102672,'Khalid', 'Salim', 30,112233,3000,'M','1997-03-04')

--⦁	Insert another employee with personal data your friend as new employee in 
-- department number 30, SSN = 102660, but don’t enter any value for salary 
-- or supervisor number to him.
insert into Employee (SSN,Fname,Lname,Dno,Sex,Bdate)
values (102660,'Aziza', 'Khalid', 30,'F','2003-03-04')

--⦁	Upgrade your salary by 20 % of its last value.
update employee
set Salary =salary * 1.20 
where SSN =102660

-----
--⦁	Joins
--⦁	Display the Department id, name and id and the name of its manager.
SELECT d.Dnum, d.Dname, d.MGRSSN, e.Fname+' '+ e.Lname as [full name]
FROM Departments d INNER JOIN
     Employee e ON d.MGRSSN =  e.SSN 

-- ⦁	Display the name of the departments and the name of 
-- the projects under its control

SELECT  d.Dname, p.Pname
FROM Departments d INNER JOIN
     Project p ON d.Dnum=p.Dnum

--⦁	Display the full data about all the dependence 
-- associated with the name of the employee they depend on him/her.
SELECT d.*, e.Fname+' '+ e.Lname as [Employee Name]
FROM            Employee e INNER JOIN
                Dependent d ON e.SSN = d.ESSN

--⦁	Display the Id, name and location of the projects in Cairo 
-- or Alex city.
SELECT Pnumber,Pname, Plocation 
FROM Project
where city ='Cairo' OR city ='Alex'

--⦁	Display the Projects full data of the projects with 
-- a name starts with "a" letter.
SELECT *
FROM Project
where Pname LIKE'a%' 

--⦁	display all the employees in department 30 whose 
-- salary from 1000 to 2000 LE monthly
select *
from Employee
where Dno=30 AND Salary between  1000 and 2000

--⦁	Retrieve the names of all employees in department 10 
-- who works more than or equal10 hours per week 
-- on "AL Rabwah" project.
SELECT e.Fname+' '+ e.Lname as [Employee Name]
FROM Employee e ,
     Works_for w ,
	 Project p
	 WHERE e.SSN = w.ESSn AND w.Pno=p.Pnumber AND e.Dno=10 AND p.Pname='AL Rabwah'
	       AND w.Hours > 9

--⦁	Find the names of the employees who directly supervised
-- with Kamel Mohamed.
select e.Fname+' '+ e.Lname as [Employee Name]
from Employee e join Employee s on e.Superssn=s.SSN
where s.Fname='Kamel' AND s.Lname='Mohamed'

--⦁	Retrieve the names of all employees and 
-- the names of the projects they are working on,
-- sorted by the project name.
select e.Fname+' '+ e.Lname as [Employee Name], p.Pname
from Employee e
join Works_for w on e.SSN = w.ESSn
join Project p on w.Pno = p.Dnum
order by p.Pname





