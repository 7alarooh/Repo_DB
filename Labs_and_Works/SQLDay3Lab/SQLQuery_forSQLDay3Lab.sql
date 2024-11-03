--      SQL Day3 Lab       --

--  Part 1:

-- [1] Display (Using Union Function)
 -- The name and the gender of the dependence 
 -- that's gender is Female and depending on Female Employee
 --  And the male dependence that depends on Male Employee.
select d.Dependent_name , d.sex
from Dependent d
where d.sex='F' and d.ESSN in (select SSN from Employee where Sex='F')

union

select d.Dependent_name , d.sex
from Dependent d left join Employee e on d.ESSN=e.SSN
where d.sex='M' and d.ESSN in (select SSN from Employee where Sex='M')


--[2] For each project, list the project name and the 
--total hours per week (for all employees) spent on that project.

select p.Pname, sum(w.Hours)
from Project p inner join Works_for w 
on p.Pnumber=w.Pno group by p.Pname

--[3] Display the data of the department which has 
-- the smallest employee ID over all employees' ID.
select *
from Departments
where Dnum=(select Dnum
            from Employee
			where SSN=(select min(ssn)
			           from Employee))
--[4] For each department, retrieve the department name 
-- and the max, min and average salary of its employees.
select d.Dname,
       (select max(e.Salary)
	    from Employee e
		where e.Dno=d.Dnum) as [Max Salary],
		(select min(e.Salary)
	    from Employee e
		where e.Dno=d.Dnum) as [Min Salary],
		(select avg(e.Salary)
	    from Employee e
		where e.Dno=d.Dnum) as [Average Salary]
from Departments d

-- [5] List the full name of all managers who have no dependents.
select Fname+' '+Lname as [Full Name]
from Employee e
where e.Superssn not in (select d.ESSN from Dependent d)

-- [6] For each department-- if its average salary is less than 
--the average salary of all employees-- display its number, 
--name and number of its employees.
select d.Dnum, d.Dname,(select count(*)
                        from Employee e
						where e.Dno=d.Dnum) As [number of Employees]
from Departments d
where (select avg(Salary)
       from Employee e
	   where e.Dno=d.Dnum)<(select avg(salary) from Employee )

-- [7] Retrieve a list of employees names and the projects names
-- they are working on ordered by department number and within 
-- each department, ordered alphabetically by last name, first name.

select e.Fname+' '+e.Lname As [Full Name],
       STRING_AGG( p.Pname, ' / ') as [Projects]
from Employee e 
join
Works_for w on e.SSN=w.ESSn
join
Project p on w.Pno=p.Pnumber
group by 
e.SSN, e.Fname,e.Lname
order by  e.Lname, e.Fname 


-- [8] Try to get the max 2 salaries using subquery
select salary
from employee
where salary = (select max(salary) 
                from employee) 
union
select salary
from employee
where salary = (select max(salary) 
                from employee 
				where salary < (select max(salary) 
				                from employee))  

--[9] Get the full name of employees that is similar to any dependent name
select  e.Fname+' '+ e.Lname AS FullName
from  employee e
where  e.Fname + ' ' + e.Lname = ( select  d.Dependent_name
                                    from dependent d 
									where d.Dependent_name like e.Fname + ' ' + e.Lname+'%')

--[10] Display the employee number and name if at least one of them 
-- have dependents (use exists keyword) self-search
select SSN, Fname+' '+Lname as [Full Name]
from Employee
where SSN in (select ESSN
              from Dependent)

-- [11] In the department table insert new department 
-- called "DEPT IT" , with id 100, employee with 
-- SSN = 112233 as a manager for this department.
-- The start date for this manager is '1-11-2006'
insert into Departments (Dnum,Dname,MGRSSN,[MGRStart Date])
       values(100,'DEPT IT',112233,'01-11-2006')

-- [12] Do what is required if you know that : Mrs.Noha 
-- Mohamed(SSN=968574)  moved to be the manager of the 
-- new department (id = 100), and they give you(your SSN =102672) 
-- her position (Dept. 20 manager) 
----------First try to update her record in the department table
----------Update your record to be department 20 manager.
----------Update the data of employee number=102660 to be 
------------in your teamwork (he will be supervised by you)
------------(your SSN =102672)

update Departments
set MGRSSN = 968574
where Dnum=100;

update Departments
set MGRSSN = 102672
where Dnum=20;

update Employee
set Superssn = 102672
where SSN=102660;

-- [13] Unfortunately the company ended the contract with 
-- Mr. Kamel Mohamed (SSN=223344) so try to delete his data 
-- from your database in case you know that you will be temporarily 
-- in his position.
--    Hint: (Check if Mr. Kamel has dependents, works as a 
--    department manager, supervises any employees or works 
--    in any projects and handle these cases).
delete from Dependent
where ESSN=223344;

update Departments
set MGRSSN=102672
where MGRSSN=223344

update Employee
set Superssn=102672
where Superssn=223344

update Works_for
set ESSn=102672
where ESSn=223344

delete from Employee
where SSN= 223344

-- [14] Try to update all salaries of employees who work 
-- in Project ‘Al Rabwah’ by 30%
update Employee
set Salary=Salary*1.30
where SSN in (select ESSn
               from Works_for 
			   where pno=(select Pnumber
			              from Project 
						  where Pname='Al Rabwah'))



--  Part 2:

--                 Note: Use ITI DB

-- [1] Create a view that displays student full name, course name 
-- if the student has a grade more than 50. 

create view Student_Course_View 
as
select s.St_Fname+ ' '+s.St_Lname as Full_Name, c.Crs_Name as Course_Name
from Student s
join stud_Course sc on s.St_Id = sc.St_Id   
join Course c on sc.Crs_Id = c.Crs_Id       
where sc.Grade > 50;     

-- [2]  Create an Encrypted view that displays manager 
-- names and the topics they teach. 

create view Encrypted_Manager_Topic_View
as
select d.Dept_Manager as Manager_Name,
    (select t.Top_Name
     from Course c
     JOIN Topic t on c.Top_Id = t.Top_Id
     JOIN Ins_course ic on c.Crs_Id = ic.Crs_Id
     where ic.Ins_Id IN ( select i.Ins_Id
	                      from Instructor i
                          where i.Dept_Id = d.Dept_Id
                         )
	) as Topic_Name
from Department d
where d.Dept_Manager IS NOT NULL;

--[3] Create a view that will display Instructor Name, 
--Department Name for the ‘SD’ or ‘Java’ Department  
use ITI

create view View_InstructorDepartment as
select Instructor.Ins_Name as InstructorName,
        Department.Dept_Name as DepartmentName
from  Instructor join 
    Department on Instructor.Dept_Id = Department.Dept_Id
where Department.Dept_Name IN ('SD', 'Java')

--Querying the view
select * from View_InstructorDepartment

--[4] Create a view “V1” that displays student data for student who lives 
--    in Alex or Cairo. 
--    Note: Prevent the users to run the following query 
--          Update V1 set st_address=’tanta’
--          Where st_address=’alex’;

create view V1
as
select St_Id,
       St_Fname,
       St_Lname,
       St_Address,
       St_Age,
       Dept_Id,
       St_super
from Student
WHERE St_Address IN ('Alex', 'Cairo')

update V1 set St_Address = 'Tanta' where St_Address = 'Alex'

--[5] Create a view that will display the project name and 
-- the number of employees work on it. “Use Company DB”
use Company_SD

create view ProjectEmployeeCount as
select Project.Pname AS ProjectName,
       count(Works_for.ESSN) AS EmployeeCount
from  Project LEFT JOIN 
      Works_for ON Project.Pnumber = Works_for.Pno
group by Project.Pname


SELECT * FROM ProjectEmployeeCount


--[6] Create the following schema and transfer the following 
--    tables to it (Self Search )
--    Company Schema 
--       Add  Department table and Project table 
--Human Resource Schema
--       Add  Employee table 

-- Create Company schema
CREATE SCHEMA Company

-- Create HumanResource schema
CREATE SCHEMA HumanResource

ALTER SCHEMA Company TRANSFER dbo.Department
ALTER SCHEMA Company TRANSFER dbo.Project
ALTER SCHEMA HumanResource TRANSFER dbo.Employee

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('Department', 'Project', 'Employee')

SELECT * FROM Company.Department
SELECT * FROM Company.Project
SELECT * FROM HumanResource.Employee

--[7] Try to generate script from DB ITI that describes
--    all tables and views in this DB 
-- Script to describe all tables in ITI DB

select TABLE_SCHEMA, TABLE_NAME,
       COLUMN_NAME,  DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH AS MaxLength,
       IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_CATALOG = 'ITI'
order by TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION



--  Part 3:

--           Note: Restore ITI and adventureworks2012 DBs to Server


--                              1): Use ITI DB
--[1] Display instructor Name and Department Name 
--    Note: display all the instructors if they are attached to a department or not
select i.Ins_Name as InstructorName,
      (select d.Dept_Name 
       from Department d 
       where d.Dept_Id = i.Dept_Id) as DepartmentName
from Instructor i


--[2] Display student full name and the name of the course he is taking
--    For only courses which have a grade  
select 
    (select s.St_Fname + ' ' + s.St_Lname 
     from Student s 
     where s.St_Id = sc.St_Id) as FullName,
    (select c.Crs_Name 
     from Course c 
     where c.Crs_Id = sc.Crs_Id) as CourseName
from  stud_Course sc
where sc.Grade IS NOT NULL


--[3] Display number of courses for each topic name
select t.Top_Name AS TopicName,
       (select COUNT(*) 
        from Course c 
        where c.Top_Id = t.Top_Id) as NumberOfCourses
from Topic t


--[4] Display max and min salary for instructors
select (select max(Salary) from Instructor) as MaxSalary,
      (select min(Salary) from Instructor) as MinSalary

--[5] Display the Department name that contains the instructor
--    who receives the minimum salary.
 select d.Dept_Name AS DepartmentName
from Instructor i join
     Department d on i.Dept_Id = d.Dept_Id
where i.Salary = (select min(Salary) from Instructor)

 
 --[6] Select instructor name and his salary but if there is
 --    no salary display instructor bonus keyword. “use coalesce Function” SELF Search

 select Ins_Name as InstructorName,
        COALESCE(CAST(Salary AS VARCHAR), 'Bonus') AS SalaryOrBonus
from Instructor

--[7] Write a query to select the highest two salaries in Each
--    Department for instructors who have salaries. “using one of Ranking Functions”
 select  Dept_Id,
         Ins_Name as InstructorName,
         Salary
from ( select 
        Dept_Id,
        Ins_Name,
        Salary,
        row_number() over (PARTITION BY Dept_Id order by Salary desc) as SalaryRank
       from Instructor
      where Salary is not null
) as RankedSalaries
where SalaryRank <= 2
order by Dept_Id, SalaryRank

 
 --[8] Write a query to select a random  student from each 
 --    department.  “using one of Ranking Functions”
 SELECT 
    Dept_Id,
    St_Fname + ' ' + St_Lname AS StudentName
FROM (
    SELECT 
        Dept_Id,
        St_Fname,
        St_Lname,
        ROW_NUMBER() OVER (PARTITION BY Dept_Id ORDER BY NEWID()) AS RandomRank
    FROM 
        Student
) AS RandomizedStudents
WHERE 
    RandomRank = 1;

