--                           SQLServer Lab 5


-- [1] ⦁	Create a stored procedure without parameters to 
--     show the number of students per department name.
--     [use ITI DB] 
use ITI

create procedure getStudentCountPerDepartment
as 
begin
    select d.Dept_Name AS DepartmentName,
           COUNT(s.St_Id) AS StudentCount
	from Department d LEFT JOIN 
         Student s on d.Dept_Id = s.Dept_Id
    group by d.Dept_Name
    order by d.Dept_Name
end

exec getStudentCountPerDepartment

-- [2] ⦁	Create a stored procedure that will check for 
--     the # of employees in the project p1 if they are 
--     more than 3 print message to the user “'The number 
--     of employees in the project p1 is 3 or more'” if they 
--     are less display a message to the user “'The following
--     employees work for the project p1'” in addition to the
--     first name and last name of each one. [Company DB] 
 use Company_SD

 create procedure checkEmployeeCountForProjectP1
as 
begin
    declare @EmployeeCount int;

    -- Count the number of employees working on project 'p1'
    select @EmployeeCount = count(*)
    from Works_for wf
    join Project p on wf.Pno = p.Pnumber
    where p.Pname = 'p1'

    -- Check if the count is 3 or more
    if @EmployeeCount >= 3
    begin
        select 'The number of employees in the project p1 is 3 or more'
    end

    else
    begin
        select 'The following employees work for the project p1:'

        -- Select the first name and last name of each employee working on 'p1'
        select e.Fname, e.Lname
        from Employee e
        join Works_for wf on e.SSN = wf.ESSN
        join Project p on wf.Pno = p.Pnumber
        WHERE p.Pname = 'p1'
    end
end

exec checkEmployeeCountForProjectP1;

-- [3] ⦁	Create a stored procedure that will be used in case
--      there is an old employee has left the project and a new one 
--      become instead of him. The procedure should take 3 parameters 
--      (old Emp. number, new Emp. number and the project number) and 
--      it will be used to update works_on table. [Company DB]

use Company_SD

create procedure replaceEmployeeInProject
    @OldEmpNum int,
    @NewEmpNum int,
    @ProjectNum int
as 
begin
    if  exists (select 1 
	            from Works_for 
				where ESSN = @OldEmpNum and Pno = @ProjectNum)
    begin
        -- Remove the old employee from the project
        delete from Works_for
        where ESSN = @OldEmpNum and Pno = @ProjectNum;
        -- Insert the new employee into the project with the same project number
        insert into Works_for (ESSN, Pno, Hours)
        values (@NewEmpNum, @ProjectNum, 0)  -- Defaulting hours to 0; adjust as necessary

        select 'Employee has been successfully replaced in the project.'
    end
    else
    begin
        select 'The old employee was not found in the specified project.'
    end
end

exec replaceEmployeeInProject @OldEmpNum = 102672, @NewEmpNum = 521634, @ProjectNum = 100;

-- [4] ⦁	add column budget in project table and insert any draft values
--      in it then Create an Audit table with the following structure 
--      ProjectNo 	|UserName 	|ModifiedDate 	|Budget_Old 	|Budget_New 
--      p2 	        |Dbo 	    |2008-01-31	    |95000 	        |200000 
--    This table will be used to audit the update trials on the Budget column (Project table, Company DB)
-- Example:
--    If a user updated the budget column then the project number, 
--    user name that made that update, the date of the modification 
--    and the value of the old and the new budget will be inserted 
--    into the Audit table
--Note: This process will take place only if the user updated 
--      the budget column

alter table Project
add Budget  decimal(18, 2)

update Project
set Budget = 100000 

create table Audit (
    ProjectNo int,
    UserName  nvarchar(50),
    ModifiedDate  datetime,
    Budget_Old decimal(18, 2),
    Budget_New decimal(18, 2)
)

create trigger trg_AuditBudgetUpdates
on Project
after update
as 
begin
    set nocount on
    -- Check if the Budget column was updated
    if update(Budget)
    begin
        insert into Audit (ProjectNo, UserName, ModifiedDate, Budget_Old, Budget_New)
        select  i.Pnumber AS ProjectNo,
                suser_name() AS UserName,           
                getdate() AS ModifiedDate,
                d.Budget AS Budget_Old,
                i.Budget AS Budget_New
        FROM  Inserted i inner join 
              Deleted d ON i.Pnumber = d.Pnumber
    end
end

-- [5] ⦁	Create a trigger to prevent anyone from inserting a new record 
--      in the Department table [ITI DB]
-- “Print a message for user to tell him that he can’t insert 
-- a new record in that table”
use ITI

create trigger trg_PreventInsertOnDepartment
on Department
instead of insert
as
begin
    select 'You can’t insert a new record in the Department table'
end

insert into Department (Dept_Name, Dept_Desc) values ('Dep123', 'ITPart')

alter table Department disable trigger trg_PreventInsertOnDepartment
alter table Department enable trigger trg_PreventInsertOnDepartment

-- [6] ⦁	 Create a trigger that prevents the insertion Process for Employee 
--       table in March [Company DB].
use Company_SD
create trigger trg_PreventInsertInMarch
on Employee
instead of insert
as
begin
    if month(getdate()) = 3
    begin
        select 'Insertion is not allowed in the Employee table during the month of March.'
    end
    else
    begin
        -- If it's not March, allow the insertion
        insert into Employee (Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno)
        select Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno
        from Inserted
    end
end

insert into Employee (Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno) 
values ('John', 'Doe', 12352300, '1980-03-01', '123 Main St', 'f', 50000, NULL, 100)

-- [7] ⦁	Create a trigger on student table after insert to add Row 
--     in Student Audit table (Server User Name , Date, Note) where
--     note will be “[username] Insert New Row with Key=[Key Value]
--     in table [table name]”
--      Server User Name		| Date  |Note 
 use ITI
create trigger trg_AuditStudentInsert
on Student
after insert
as
begin
    set nocount on;

    declare @UserName nvarchar(50);
    declare @KeyValue int;  
    declare @Note nvarchar(255);

    -- Get the server username
    set @UserName = suser_name(); 

    -- Insert log for each row inserted
    declare inserted_cursor cursor for
    select St_Id from Inserted 

    open inserted_cursor
    fetch next from inserted_cursor into @KeyValue;

    while @@FETCH_STATUS = 0
    begin
        set @Note = @UserName + ' Insert New Row with Key=' + CAST(@KeyValue AS NVARCHAR(10)) + ' in table [Student]';
        
        insert into StudentAudit (ServerUserName, Date, Note)
        values (@UserName, GETDATE(), @Note);

        fetch next from inserted_cursor into @KeyValue;
    end

    close inserted_cursor;
    deallocate inserted_cursor
end

-- [8] Create a trigger on student table instead of delete to add Row 
--     in Student Audit table (Server User Name, Date, Note) where note will 
--     be“ try to delete Row with Key=[Key Value]”
create trigger trg_AuditStudentDelete
on Student
 instead of delete 
as
begin
    set nocount on

    declare @UserName nvarchar(50)
    declare @KeyValue int 
    declare @Note nvarchar(255)

    -- Get the server username
    set @UserName = SUSER_NAME() 

    -- Insert log for each row attempted to be deleted
    DECLARE deleted_cursor CURSOR FOR
    SELECT St_Id FROM Deleted 

    OPEN deleted_cursor;
    FETCH NEXT FROM deleted_cursor INTO @KeyValue;

    while @@FETCH_STATUS = 0
    begin
        set @Note = 'Try to delete Row with Key=' + CAST(@KeyValue AS NVARCHAR(10));

        INSERT INTO StudentAudit (ServerUserName, Date, Note)
        VALUES (@UserName, GETDATE(), @Note)

        FETCH NEXT FROM deleted_cursor INTO @KeyValue
    end

    close deleted_cursor;
    deallocate deleted_cursor;

     raiserror('Deletion is not allowed for the Student table.', 16, 1)
end







