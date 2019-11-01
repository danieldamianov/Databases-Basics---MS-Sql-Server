SELECT COUNT(Id) AS [Count]
FROM WizzardDeposits --PROBLEM 1

SELECT * FROM WizzardDeposits

SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits --PROBLEM 2

SELECT 
	DepositGroup
	,MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup -- PROBLEM 3

SELECT TOP(2) DepositGroup FROM
(SELECT
	DepositGroup
	,AVG(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup) AS dt
ORDER BY LongestMagicWand-- PROBLEM 4

SELECT 
	DepositGroup
	,SUM(WizzardDeposits.DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup-- PROBLEM 5

SELECT 
	DepositGroup
	,SUM(WizzardDeposits.DepositAmount)
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup-- PROBLEM 6

SELECT 
	DepositGroup
	,SUM(WizzardDeposits.DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(WizzardDeposits.DepositAmount) < 150000
ORDER BY TotalSum DESC-- PROBLEM 7

SELECT 
	DepositGroup
	,MagicWandCreator
	,MIN(WizzardDeposits.DepositCharge) AS [MinDepositCharge]
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
ORDER BY MagicWandCreator,DepositGroup-- PROBLEM 8

SELECT
	AgeGroup,COUNT(Age) AS WizardCount
FROM
(SELECT 
	CASE 
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN Age BETWEEN 61 AND 100 THEN '[61+]'
	END
	AS [AgeGroup],Age
FROM WizzardDeposits) AS dt
GROUP BY [AgeGroup]-- PROBLEM 9

SELECT 
	LEFT(WizzardDeposits.FirstName,1)
FROM WizzardDeposits
WHERE WizzardDeposits.DepositGroup = 'Troll Chest'
GROUP BY LEFT(WizzardDeposits.FirstName,1)-- PROBLEM 10

SELECT
	DepositGroup,IsDepositExpired
	,AVG(WizzardDeposits.DepositInterest)
FROM WizzardDeposits
WHERE DepositStartDate > '1985/01/01'
GROUP BY DepositGroup,IsDepositExpired 
ORDER BY DepositGroup DESC,IsDepositExpired-- PROBLEM 11

SELECT SUM([Difference]) FROM
(SELECT 
	w.Id,w.DepositAmount,
	CASE 
		WHEN Id != 162 THEN (
		w.DepositAmount -
		(SELECT TOP(1) DepositAmount FROM WizzardDeposits WHERE Id = w.Id + 1)
		)
		WHEN Id = 162 THEN 0
	END AS [Difference]
FROM WizzardDeposits AS w) AS f-- PROBLEM 12

USE SoftUni

SELECT * FROM Employees

SELECT DepartmentID,SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID 
ORDER BY DepartmentID --PROBLEM 13

SELECT DepartmentID,MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN(2,5,7) AND HireDate > '01/01/2000'
GROUP BY DepartmentID
ORDER BY DepartmentID -- PROBLEM 14

SELECT DepartmentID,AVG(SalaryChanged) AS AverageSalary FROM
(SELECT DepartmentID,
CASE
	WHEN DepartmentID = 1 THEN Salary + 5000
	WHEN DepartmentID != 1 THEN Salary
END AS SalaryChanged
FROM Employees 
WHERE Salary > 30000 AND (ManagerID IS NULL OR ManagerID != 42)) AS f
GROUP BY DepartmentID
 --PROBLEM 15

SELECT * FROM Employees
WHERE DepartmentID = 16

SELECT DepartmentId,MAX(Salary)
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000 -- PROBLEM 16

SELECT COUNT(Salary) 
FROM Employees
WHERE ManagerID IS NULL -- PROBLEM 17

SELECT DISTINCT DepartmentID,Salary AS ThirdHighestSalary FROM
(SELECT DepartmentId,Salary,DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS [RANK]
FROM Employees) AS f
WHERE [RANK] = 3-- PROBLEM 18

SELECT TOP(10) FirstName,LastName,E.DepartmentID
--(SELECT DepartmentID,AVG(Salary) AS AverageSalary
--FROM Employees
--GROUP BY DepartmentID) AS dt,Employees
FROM Employees AS E
WHERE E.Salary >
(SELECT AVG(Salary) FROM Employees WHERE DepartmentID = E.DepartmentID GROUP BY DepartmentID)
ORDER BY DepartmentID








