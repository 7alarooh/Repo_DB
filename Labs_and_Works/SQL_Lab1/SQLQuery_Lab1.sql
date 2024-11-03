create database SQL_Lab1 

use SQL_Lab1

create table Instructor 
(
    ID int primary key identity(1,1 ),
	First_Name nvarchar(20) not null,
	Last_Name nvarchar(20) not null,
	DB date Not null,
	OverTime int unique not null,
	Salary Decimal(10,2) CONSTRAINT CK_Employee_Salary check(Salary between 1000  and 5000) default 3000,
	NetSalary as (Salary+OverTime) persisted,
	Age as (year(getdate())-year(DB)) ,
	hiredate date default getdate(),
	Address nvarchar(100) 
)

create table Course 
(
    CID int primary key identity(1,1 ),
	CName nvarchar(20) not null,
	Duration int unique not null 
)

create table Lab 
(
    LID int primary key identity(1,1 ),
	Location nvarchar(100) not null,
	Capacity int check (capacity <20),
	CID int not null,
	foreign key (CID) references Course(CID)
)

create table Instructor_teach_Course 
(   ID int not null,
    CID int not null,
	Foreign key (ID) references Instructor(ID),
	Foreign key (CID) references Course(CID),
	primary key (ID, CID)
)

