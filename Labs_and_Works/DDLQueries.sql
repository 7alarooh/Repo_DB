 CREATE TABLE Employee (
    Ssn INT PRIMARY KEY, 
    FName VARCHAR(50) NOT NULL, 
	Minit VARCHAR(50) NOT NULL, 
    LName VARCHAR(50) NOT NULL, 
	Bdate date,
	Sex char(1),
	Address VARCHAR(50),
    Salary DECIMAL(10, 2) CHECK (Salary > 0) 
);

 CREATE TABLE DEPARTMENT (
    Dnumber INT PRIMARY KEY, 
    Dname VARCHAR(50) NOT NULL, 
	Mgr_start_date date,
	);


 CREATE TABLE DEPT_LOCATIONS (
    Dnumber INT, 
    Dlocation VARCHAR(50) NOT NULL,
	PRIMARY KEY (Dnumber,Dlocation),
	FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber) 
	);
CREATE TABLE PROJECT (
    Pnumber INT, 
    Pname VARCHAR(50) NOT NULL,
	Plocation VARCHAR(50) NOT NULL,
	Dnum INT,
	PRIMARY KEY (Pnumber),
	FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber) 
	);

CREATE TABLE WORKS_ON (
    Essn INT, 
	Pno int,
	HoursP int,
	PRIMARY KEY (Essn,Pno),
	FOREIGN KEY (Essn) REFERENCES Employee(Ssn) ,
	FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber) 
	);

CREATE TABLE DEPENDENT_ (
    Essn INT, 
	Dependent_name VARCHAR(50) NOT NULL,
	Sex char(1),
	Bdate date,
	Relationship VARCHAR(50) NOT NULL,
	PRIMARY KEY (Essn,Dependent_name),
	FOREIGN KEY (Essn) REFERENCES Employee(Ssn) 
	);

	ALTER TABLE Employee
    ADD  Dno int
   FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber);


   ALTER TABLE Employee
    ADD  Super_ssn int
   FOREIGN KEY (Super_ssn) REFERENCES Employee(Ssn);

