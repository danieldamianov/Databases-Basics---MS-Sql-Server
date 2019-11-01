SELECT TOP(5) Employees.EmployeeID,Employees.JobTitle,Addresses.AddressID,Addresses.AddressText FROM Employees
JOIN Addresses ON Employees.AddressID = Addresses.AddressID
ORDER BY Addresses.AddressID --PROBLEM 1

SELECT TOP(50) Employees.FirstName,Employees.LastName,Towns.[Name],Addresses.AddressText FROM Employees
JOIN Addresses ON Employees.AddressID = Addresses.AddressID
JOIN Towns ON Addresses.TownID = Towns.TownID
ORDER BY FirstName ASC,LastName--PROBLEM 2

SELECT Employees.EmployeeID,Employees.FirstName,Employees.LastName,Departments.[Name]
FROM Employees
JOIN Departments ON Departments.DepartmentID = Employees.DepartmentID
WHERE Departments.[Name] = 'Sales'
ORDER BY EmployeeID--PROBLEM 3

SELECT TOP 5 Employees.EmployeeID,Employees.FirstName,Employees.Salary,Departments.[Name] AS DepartmentName
FROM Employees
JOIN Departments ON Departments.DepartmentID = Employees.DepartmentID
WHERE Employees.Salary > 15000
ORDER BY Departments.DepartmentID--PROBLEM 4

SELECT TOP 3 Employees.EmployeeID, Employees.FirstName 
FROM Employees
LEFT JOIN EmployeesProjects ON Employees.EmployeeID = EmployeesProjects.EmployeeID
WHERE EmployeesProjects.ProjectID IS NULL--PROBLEM 5

SELECT Employees.FirstName, Employees.LastName, Employees.HireDate,Departments.[Name] 
FROM Employees
JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID
WHERE Employees.HireDate > '1999-01-01' AND Departments.[Name] IN ('Sales','Finance')
ORDER BY HireDate--PROBLEM 6

SELECT TOP 5 Employees.EmployeeID ,Employees.FirstName,Projects.[Name]
FROM EmployeesProjects
JOIN Employees ON Employees.EmployeeID = EmployeesProjects.EmployeeID
JOIN Projects ON Projects.ProjectID = EmployeesProjects.ProjectID
WHERE Projects.StartDate > '2002-08-13' AND Projects.EndDate IS NULL
ORDER BY EmployeeID ASC--PROBLEM 7

SELECT Employees.EmployeeID,Employees.FirstName,
	CASE 
		WHEN Projects.StartDate < '2005-01-01' THEN Projects.[Name]
		WHEN Projects.StartDate >= '2005-01-01' THEN NULL
	END AS ProjectName
FROM EmployeesProjects
JOIN Employees ON EmployeesProjects.EmployeeID = Employees.EmployeeID
JOIN Projects ON Projects.ProjectID = EmployeesProjects.ProjectID
WHERE EmployeesProjects.EmployeeID = 24--PROBLEM 8

SELECT E1.EmployeeID,E1.FirstName,E1.ManagerID,E2.FirstName FROM Employees AS E1
JOIN Employees AS E2 ON E1.ManagerID = E2.EmployeeID
WHERE E1.ManagerID IN (3,7)
ORDER BY E1.EmployeeID ASC
SELECT * FROM Employees--PROBLEM 9

SELECT TOP 50 
E1.EmployeeID,
CONCAT(E1.FirstName,' ',E1.LastName) AS EmployeeName,
CONCAT(E2.FirstName,' ',E2.LastName) AS ManagerName,
Departments.[Name] FROM Employees AS E1
JOIN Employees AS E2 ON E1.ManagerID = E2.EmployeeID
JOIN Departments ON E1.DepartmentID = Departments.DepartmentID
ORDER BY E1.EmployeeID--PROBLEM 10

WITH DepartmentsGrouped (AverageSalaryOfEmployees,DepartmentID)
AS
(
	SELECT AVG(Salary),DepartmentID FROM Employees GROUP BY DepartmentID 
)
 
SELECT MIN(AverageSalaryOfEmployees) AS MinAverageSalary FROM DepartmentsGrouped--PROBLEM 11

USE Geography

SELECT Countries.CountryCode,Mountains.MountainRange,Peaks.PeakName,Peaks.Elevation FROM Peaks
JOIN Mountains ON Peaks.MountainId = Mountains.Id
JOIN MountainsCountries ON Mountains.Id = MountainsCountries.MountainId
JOIN Countries ON MountainsCountries.CountryCode = Countries.CountryCode
WHERE Countries.CountryName = 'Bulgaria' AND Peaks.Elevation > 2835
ORDER BY Peaks.Elevation DESC--PROBLEM 12

SELECT CountryCode,COUNT(*) AS MountainRanges FROM MountainsCountries
WHERE CountryCode IN ('US','RU','BG')
GROUP BY CountryCode--PROBLEM 13

SELECT TOP 5 Countries.CountryName, Rivers.RiverName FROM Countries
LEFT JOIN CountriesRivers ON CountriesRivers.CountryCode = Countries.CountryCode
LEFT JOIN Rivers ON CountriesRivers.RiverId = Rivers.Id
WHERE Countries.ContinentCode = 'AF'
ORDER BY CountryName--PROBLEM 14

SELECT ContinentCode,CurrencyCode,CountriesUsingThisCurrency AS CurrencyUsage FROM
(
SELECT *,DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CountriesUsingThisCurrency DESC) AS [RANK]
FROM 
(SELECT ContinentCode,CurrencyCode,COUNT(*) AS CountriesUsingThisCurrency
FROM Countries
WHERE CurrencyCode IS NOT NULL
GROUP BY ContinentCode,CurrencyCode
) AS dt
) AS dt2
WHERE [RANK] = 1 AND CountriesUsingThisCurrency <> 1
ORDER BY ContinentCode,CurrencyCode--PROBLEM 15

SELECT * FROM Countries
SELECT * FROM MountainsCountries

SELECT COUNT(*) AS CountryCode FROM
(SELECT MountainId FROM
(
SELECT Countries.CountryName,MountainsCountries.MountainId FROM Countries 
LEFT JOIN MountainsCountries ON Countries.CountryCode = MountainsCountries.CountryCode
) AS dt 
WHERE MountainId IS NULL) AS dt2--PROBLEM 16


WITH CountriesWithLongestRivers (CountryName,CountryCode,LongestRiverLength) AS
(SELECT CountryName,CountryCode,[Length] AS LongestRiverLength
FROM
(SELECT 
	Countries.CountryName,
	CountriesRivers.RiverId,
	CountriesRivers.CountryCode,
	RiverName,
	[Length],
	DENSE_RANK() OVER (PARTITION BY Countries.CountryName ORDER BY [Length] DESC) AS [RANK]
FROM Countries
LEFT JOIN CountriesRivers ON Countries.CountryCode = CountriesRivers.CountryCode
LEFT JOIN Rivers ON Rivers.Id = CountriesRivers.RiverId
) AS dt
WHERE [RANK] = 1
)
SELECT TOP 5 CountryName, Elevation AS HighestPeakElevation,LongestRiverLength FROM
(SELECT 
	CountriesWithLongestRivers.CountryName,CountriesWithLongestRivers.LongestRiverLength
	,Peaks.Elevation,DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY Elevation DESC) AS [Rank]
FROM CountriesWithLongestRivers
LEFT JOIN MountainsCountries ON CountriesWithLongestRivers.CountryCode = MountainsCountries.CountryCode
LEFT JOIN Mountains ON MountainsCountries.MountainId = Mountains.Id
LEFT JOIN Peaks ON Mountains.Id = Peaks.MountainId) AS dt
WHERE [Rank] = 1
ORDER BY Elevation DESC,LongestRiverLength DESC,CountryName ASC--PROBLEM 17

SELECT dt.CountryName, ISNULL(dt.PeakName,'(no highest peak)')
AS 'Highest Peak Name',ISNULL(Elevation,0)
AS 'Highest Peak Elevation',ISNULL(dt.MountainRange,'(no mountain)')
AS 'Mountain' FROM
(
SELECT Countries.CountryName,Peaks.PeakName,Peaks.Elevation,Mountains.MountainRange,
	DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY Elevation DESC) AS [Rank]
FROM Countries
LEFT JOIN MountainsCountries ON Countries.CountryCode = MountainsCountries.CountryCode
LEFT JOIN Mountains ON MountainsCountries.MountainId = Mountains.Id
LEFT JOIN Peaks ON Mountains.Id = Peaks.MountainId
) AS dt
WHERE [Rank] = 1
ORDER BY CountryName,[Highest Peak Name]--PROBLEM 18
