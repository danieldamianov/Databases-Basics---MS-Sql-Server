USE SoftUni

SELECT * FROM Departments -- PROBLEM 2
SELECT [Name] FROM Departments -- PROBLEM 3

SELECT FirstName , LastName,Salary FROM Employees -- PROBLEM 4

SELECT FirstName, MiddleName,LastName FROM Employees -- PROBLEM 5

SELECT FirstName + '.' + LastName + '@softuni.bg' AS 'Full Email Address' FROM Employees -- PROBLEM 6 

SELECT DISTINCT Salary FROM Employees -- PROBLEM 7

SELECT * FROM Employees WHERE JobTitle = 'Sales Representative' -- PROBLEM 8

SELECT FirstName, LastName, JobTitle 
FROM Employees
WHERE Salary BETWEEN 20000 AND 30000 -- PROBLEM 9

SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS 'Full Name' FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600) -- PROBLEM 10

SELECT FirstName, LastName FROM Employees
WHERE ManagerID IS NULL -- PROBLEM 11

SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC -- PROBLEM 12

SELECT TOP(5) FirstName, LastName
FROM Employees
ORDER BY Salary DESC -- PROBLEM 13

SELECT FirstName, LastName
FROM Employees
WHERE DepartmentID != 4 -- PROBLEM 14

SELECT * FROM Employees
ORDER BY Salary DESC,
FirstName ASC,
LastName DESC,
MiddleName ASC -- PROBLEM 15

GO

CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName, LastName, Salary
FROM Employees -- PROBLEM 16

GO

SELECT * FROM V_EmployeesSalaries

GO

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName AS 'Full Name',JobTitle
FROM Employees -- PROBLEM 17

GO

SELECT * FROM V_EmployeeNameJobTitle

SELECT DISTINCT JobTitle FROM Employees --PROBLEM 18

SELECT TOP(10) * 
FROM Projects
ORDER BY StartDate, [Name] --PROBLEM 19

SELECT TOP(7) FirstName,LastName,HireDate 
FROM Employees
ORDER BY HireDate DESC --PROBLEM 20

UPDATE Employees
SET Salary = Salary * 1.12
WHERE DepartmentID IN (1,2,4,11)--PROBLEM 21

SELECT Salary FROM Employees 

USE Geography

SELECT PeakName FROM Peaks
ORDER BY PeakName --PROBLEM 22

SELECT TOP(30) CountryName , [Population]
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC, CountryName--PROBLEM 23

SELECT CountryName,CountryCode,
CASE 
	WHEN CurrencyCode = 'EUR' THEN 'Euro'
	WHEN CurrencyCode != 'EUR' THEN 'Not Euro'
	WHEN CurrencyCode IS NULL THEN 'Not Euro'
END AS 'Currency'
FROM Countries
ORDER BY CountryName--PROBLEM 24

USE Diablo

SELECT [Name]
FROM Characters
ORDER BY [Name]



