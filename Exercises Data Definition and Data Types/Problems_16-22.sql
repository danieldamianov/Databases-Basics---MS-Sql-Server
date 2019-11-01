CREATE DATABASE SoftUni

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
AddressText NVARCHAR(100) NOT NULL,
TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(50) NOT NULL,
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
JobTitle NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
HireDate DATE NOT NULL,
Salary DECIMAL NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
)
ALTER TABLE Employees ALTER COLUMN AddressId INT NULL

INSERT INTO Towns VALUES ('Sofia'),('Ploviv'),('Varna'),('Burgas')
INSERT INTO Departments VALUES ('Engineering'),('Sales'),('Marketing'),('Software Development'),('Quality Assurance')
INSERT INTO Employees VALUES
('Ivan','Ivanov','Ivanov','.NET Developer',4,'2013-02-01',3500.00,NULL),
('Petar','Petrov','Petrov','Senior Engineer',1,'2004-03-02',4000.00,NULL),
('Maria','Petrova','Ivanova','Intern',5,'2016-08-28',525.25,NULL),
('Georgi','Teziev','Ivanov','CEO',2,'2007-12-09',3000.00,NULL),
('Peter','Pan','Pan','Intern',3,'2016-08-28',599.88,NULL)

SELECT [Name] FROM Towns ORDER BY Name ASC
SELECT [Name] FROM Departments ORDER BY Name ASC
SELECT [FirstName], [LastName], [JobTitle], [Salary] FROM Employees ORDER BY Salary DESC

UPDATE Employees
SET Salary = Salary * 1.1
SELECT Salary FROM Employees --ORDER BY Salary DESC

