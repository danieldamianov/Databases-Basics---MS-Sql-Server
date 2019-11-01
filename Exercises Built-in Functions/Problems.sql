USE SoftUni

SELECT * FROM Employees

SELECT FirstName,LastName
FROM Employees
WHERE FirstName LIKE 'Sa%' -- PROBLEM 1

SELECT FirstName,LastName
FROM Employees
WHERE LastName LIKE '%ei%' -- PROBLEM 2

SELECT FirstName
FROM Employees
WHERE DepartmentID IN(3,10)
AND DATEPART(YEAR,HireDate) BETWEEN 1995 AND 2005-- PROBLEM 3

SELECT FirstName,LastName
FROM Employees
WHERE NOT(JobTitle LIKE '%engineer%')-- PROBLEM 4

SELECT * FROM Towns

SELECT [Name]
FROM Towns
WHERE LEN([Name]) IN (6,5)
ORDER BY [Name]-- PROBLEM 5

SELECT TownId,[Name]
FROM Towns
WHERE LEFT([Name],1) IN ('M','K','B','E')
ORDER BY [Name]-- PROBLEM 6

SELECT TownId,[Name]
FROM Towns
WHERE LEFT([Name],1) NOT IN ('R','D','B')
ORDER BY [Name]-- PROBLEM 7
GO
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE YEAR(HireDate) > 2000 -- PRObLEM 8
GO
SELECT * FROM V_EmployeesHiredAfter2000

SELECT FirstName,LastName
FROM Employees
WHERE LEN(LastName) = 5 -- PROBLEM 9

USE SoftUni

SELECT * FROM
(
SELECT EmployeeID,FirstName,LastName,Salary
,DENSE_RANK() OVER(PARTITION BY Salary ORDER BY EmployeeId) AS [Rank]
FROM Employees
) AS [Table]
WHERE (Salary BETWEEN 10000 AND 50000)
AND [Rank] = 2
ORDER BY Salary DESC--PROBLEM 10 AND --PROBLEM 11


USE Geography

SELECT CountryName,IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode --PROBLEM 12

SELECT Peaks.PeakName,Rivers.RiverName, 
LOWER(Peaks.PeakName + SUBSTRING(Rivers.RiverName,2,LEN(Rivers.RiverName) - 1)) as [Mix]
FROM Peaks,Rivers
WHERE RIGHT(Peaks.PeakName,1) = LEFT(Rivers.RiverName,1)
ORDER BY Mix --PROBLEM 13

USE Diablo

SELECT * FROM Games

SELECT TOP(50) [Name],FORMAT([Start],'yyyy-MM-dd') AS [Start]
FROM Games
WHERE YEAR([Start]) IN (2011,2012)
ORDER BY [Start],[Name]--PROBLEM 14

SELECT * FROM Users

SELECT SUBSTRING('vlado@softuni.bg',CHARINDEX('vlado@softuni.bg','@') + 1, LEN('vlado@softuni.bg') - CHARINDEX('vlado@softuni.bg','@'))
SELECT CHARINDEX('vlado@softuni.bg','@')

SELECT Username,SUBSTRING(Email,CHARINDEX('@',Email) + 1, LEN(Email) - CHARINDEX('@',Email))  AS [Email Provider]
FROM Users
ORDER BY [Email Provider] , Username--PROBLEM 15

SELECT Username,IpAddress
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username,IpAddress ASC--PROBLEM 16

SELECT * FROM Games

SELECT [Name], 
CASE
	WHEN DATEPART(HOUR,[Start]) >= 0 AND DATEPART(HOUR,[Start]) < 12 THEN 'Morning'
	WHEN DATEPART(HOUR,[Start]) >= 12 AND DATEPART(HOUR,[Start]) < 18 THEN 'Afternoon'
	WHEN DATEPART(HOUR,[Start]) >= 18 AND DATEPART(HOUR,[Start]) < 24 THEN 'Evening'
END AS [Part of the day],
CASE
	WHEN Duration > 0 AND Duration <= 3 THEN 'Extra Short'
	WHEN Duration >= 4 AND Duration <= 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	WHEN Duration IS NULL THEN 'Extra Long'
END AS [Duration as string]
FROM Games
ORDER BY [Name],[Duration as string],[Part of the day]--PROBLEM 17

USE Orders

SELECT * FROM Orders

SELECT ProductName,OrderDate,DATEADD(DAY,3,OrderDate) AS [Pay Due],
DATEADD(MONTH,1,OrderDate) AS [Deliver Due] FROM Orders --PROBLEM 18

SELECT [Name],
DATEDIFF(YEAR,BirthDate,GETDATE()) AS [Age in Years],
DATEDIFF(MONTH,BirthDate,GETDATE()) AS [Age in Months],
DATEDIFF(DAY,BirthDate,GETDATE()) AS [Age in Days],
DATEDIFF(MINUTE,BirthDate,GETDATE()) AS [Age in Minutes]
FROM People --PROBLEM 19







