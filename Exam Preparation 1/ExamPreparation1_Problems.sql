CREATE DATABASE Supermarket
USE Supermarket

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)
CREATE TABLE Items
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	Price DECIMAL(15,2) NOT NULL,
	CategoryId INT	NOT NULL FOREIGN KEY REFERENCES Categories(Id)
)
CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,
	Salary DECIMAL(15,2) NOT NULL
)

CREATE TABLE Orders
(
	Id INT PRIMARY KEY IDENTITY,
	[DateTime] DATETIME NOT NULL,
	EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(Id)
)

CREATE TABLE OrderItems
(
	OrderId	INT NOT NULL FOREIGN KEY REFERENCES Orders(Id),
	ItemId	INT NOT NULL FOREIGN KEY REFERENCES Items(Id),
	Quantity INT NOT NULL CHECK (Quantity >= 1),
	PRIMARY KEY(OrderId,ItemId)
)
CREATE TABLE Shifts
(
	Id INT IDENTITY,
	EmployeeId	INT NOT NULL FOREIGN KEY REFERENCES Employees(Id),
	CheckIn	DATETIME NOT NULL,
	CheckOut	DATETIME NOT NULL,
	PRIMARY KEY(Id,EmployeeId),
	CHECK(CheckIn < CheckOut)
)

INSERT INTO Employees
VALUES
--FirstName	LastName	Phone	Salary
('Stoyan'	,'Petrov'	,'888-785-8573',	500.25		),
('Stamat'	,'Nikolov'	,'789-613-1122',	999995.25	),
('Evgeni'	,'Petkov'	,'645-369-9517',	1234.51		),
('Krasimir'	,'Vidolov'	,'321-471-9982',	50.25	)
INSERT INTO Items
--Name	Price	CategoryId
VALUES
('Tesla battery',154.25,	8),
('Chess'	,30.25,	8		 ),
('Juice'	,5.32,	1		 ),
('Glasses'	,10,	8			 ),
('Bottle of water'	,1,	1	 )

UPDATE Items
SET Price = Price * 1.27
WHERE categoryID IN(1, 2 , 3)

DELETE FROM OrderItems WHERE OrderId = 48

SELECT Id,FirstName FROM Employees WHERE Salary > 6500
ORDER BY FirstName

SELECT FirstName + ' ' + LastName as [Full Name],Phone as [Phone Number] FROM Employees 
WHERE LEFT(Phone,1) = 3
ORDER BY FirstName,[Phone Number]

SELECT FirstName,LastName ,Count(*) as [Count] FROM Orders JOIN Employees ON Orders.EmployeeId = Employees.Id
GROUP BY Employees.Id,FirstName,LastName
ORDER BY [Count] DESC,FirstName
SELECT * FROM Employees

SELECT FirstName,LastName,[Work hours] FROM
(SELECT FirstName,LastName, AVG([Work hours1]) AS [Work hours],dt1.Id FROM
(SELECT FirstName,LastName,Employees.Id,DATEDIFF(HOUR,CheckIN,CheckOut)AS[Work hours1],CheckIn,CheckOut 
FROM Employees JOIN Shifts ON Employees.Id = Shifts.EmployeeId --ORDER BY FirstName
) AS dt1 
GROUP BY dt1.Id,dt1.FirstName,dt1.LastName
) as dt2
WHERE [Work hours] > 7
ORDER BY [Work hours] DESC,dt2.Id

SELECT TOP 1 OrderId,SUM([Total Item Price]) AS[TotalPrice] FROM 
(SELECT OrderId,Quantity * Price AS[Total Item Price] FROM OrderItems
JOIN Items ON OrderItems.ItemId = Items.Id) as dt
GROUP BY [OrderId]
ORDER BY [TotalPrice] DESC

SELECT TOP 10 OrderId,MAX(Price) AS ExpensivePrice,MIN(Price) AS CheapPrice FROM
(SELECT OrderId,Price FROM OrderItems
JOIN Items ON OrderItems.ItemId = Items.Id) as dt
GROUP BY OrderId 
ORDER BY ExpensivePrice DESC,OrderId

SELECT Employees.Id,Employees.FirstName,Employees.LastName FROM Employees
JOIN Orders ON Employees.Id = Orders.EmployeeId
GROUP BY Employees.Id,Employees.FirstName,Employees.LastName
ORDER BY Employees.Id

SELECT Id,FirstName + ' ' + LastName AS [Full Name] FROM
(SELECT  dt.Id,dt.FirstName,dt.LastName,MIN([Work hours]) AS[MinWork] FROM
(SELECT Employees.Id,FirstName,LastName,DATEDIFF(HOUR,CheckIN,CheckOut)AS[Work hours] FROM Shifts 
JOIN Employees ON Shifts.EmployeeId = Employees.Id) as dt
GROUP BY dt.Id,dt.FirstName,dt.LastName) AS dt1
WHERE [MinWork] < 4
ORDER BY dt1.Id

SELECT FirstName + ' ' + LastName AS [Full Name],SUM(Quantity * Price) AS [Total Price],SUM(Quantity) AS [Items] FROM OrderItems
JOIN Orders ON OrderItems.OrderId = Orders.Id
JOIN Items ON OrderItems.ItemId = Items.Id
JOIN Employees ON Employees.Id = Orders.EmployeeId
WHERE Orders.DateTime < '2018-06-15'
GROUP BY EmployeeId,FirstName,LastName
ORDER BY [Total Price] DESC,[Items] DESC

SELECT FirstName + ' ' + LastName AS [Full Name],DATENAME(weekday,CheckOut) AS [Day of week] FROM Employees
LEFT JOIN Orders ON Employees.Id = Orders.EmployeeId
JOIN Shifts ON Shifts.EmployeeId = Employees.Id
WHERE Orders.Id IS NULL AND DATEDIFF(HOUR,CheckIn,CheckOut) > 12
ORDER BY Employees.Id

--SELECT Shifts.Id AS [Shifts.Id],
--Employees.Id AS[Employees.Id],DAY(CheckIn) AS [DayOfMonth] FROM Shifts
--JOIN Employees ON Shifts.EmployeeId = Employees.Id

SELECT DAY(DateTime) AS [Day],CAST(AVG(Quantity * Price) AS DECIMAL(15,2)) AS [Total profit] FROM Orders
JOIN OrderItems ON Orders.Id = OrderItems.OrderId
JOIN Items ON OrderItems.ItemId = Items.Id
GROUP BY DAY(DateTime)
ORDER BY DAY(DateTime)

SELECT Items.[Name] AS[Item],Categories.Name,SUM(Quantity) AS [Count],SUM(Quantity * Price) AS [TotalPrice] FROM Items
JOIN Categories ON Items.CategoryId = Categories.Id
JOIN OrderItems ON Items.Id = OrderItems.ItemId
GROUP BY Items.Id,Items.[Name],Categories.Name
ORDER BY SUM(Quantity * Price) DESC,SUM(Quantity) DESC

SELECT Items.[Name] AS[Item],Categories.Name,SUM(Quantity) AS [Count],SUM(Quantity * Price) AS [TotalPrice] FROM Items
JOIN Categories ON Items.CategoryId = Categories.Id
LEFT JOIN OrderItems ON Items.Id = OrderItems.ItemId
GROUP BY Items.Id,Items.[Name],Categories.Name
ORDER BY SUM(Quantity * Price) DESC,SUM(Quantity) DESC

SELECT dt.Id,FirstName,LastName,MAX(TotalPrice) FROM
(SELECT Employees.Id,FirstName,LastName,OrderId,SUM(Quantity * Price) AS TotalPrice FROM Employees 
JOIN Orders ON Employees.Id = Orders.EmployeeId
JOIN OrderItems ON Orders.Id = OrderItems.OrderId
JOIN Items ON OrderItems.ItemId = Items.Id
GROUP BY Employees.Id,FirstName,LastName,OrderId) AS dt
GROUP BY dt.Id,FirstName,LastName
ORDER BY FirstName

SELECT * FROM Shifts JOIN Employees ON Shifts.EmployeeId = Employees.Id
WHERE FirstName = 'Adaline'

SELECT * FROM Employees LEFT JOIN Orders ON Employees.Id = Orders.EmployeeId ORDER BY FirstName
--ORDER BY FirstName
--WITH dataSet(FullName,TotalPrice) AS
--(SELECT dt3.[Full Name], MAX(MaxPricePerDay) FROM(
--SELECT dt2.Id,dt2.[Full Name],MAX(TotalPrice) AS MaxPricePerDay,dt2.workingHours FROM
--(
--SELECT dt.Id,FirstName + ' ' + LastName AS [Full Name],TotalPrice,DATEDIFF(HOUR,CheckIn,CheckOut) AS [workingHours] FROM
--(
--SELECT Employees.Id,FirstName,LastName,OrderId,SUM(Quantity * Price) AS TotalPrice FROM Employees 
--JOIN Orders ON Employees.Id = Orders.EmployeeId
--JOIN OrderItems ON Orders.Id = OrderItems.OrderId
--JOIN Items ON OrderItems.ItemId = Items.Id
--GROUP BY Employees.Id,FirstName,LastName,OrderId
--) AS dt
--JOIN Orders ON Orders.Id = dt.OrderId
--JOIN Shifts ON Shifts.EmployeeId = dt.Id AND DAY(Shifts.CheckIn) = DAY(Orders.DateTime)
--) AS dt2
--GROUP BY dt2.Id,dt2.[Full Name],dt2.workingHours) AS dt3
--GROUP BY [Full Name])

--SELECT dataSet.FullName AS [Full Name],dataSet2.workingHours AS [WorkHours],dataSet.TotalPrice AS [TotalPrice] FROM
--(SELECT dt2.Id,dt2.[Full Name],MAX(TotalPrice) AS MaxPricePerDay,dt2.workingHours FROM
--(
--SELECT dt.Id,FirstName + ' ' + LastName AS [Full Name],TotalPrice,DATEDIFF(HOUR,CheckIn,CheckOut) AS [workingHours] FROM
--(
--SELECT Employees.Id,FirstName,LastName,OrderId,SUM(Quantity * Price) AS TotalPrice FROM Employees 
--JOIN Orders ON Employees.Id = Orders.EmployeeId
--JOIN OrderItems ON Orders.Id = OrderItems.OrderId
--JOIN Items ON OrderItems.ItemId = Items.Id
--GROUP BY Employees.Id,FirstName,LastName,OrderId
--) AS dt
--JOIN Orders ON Orders.Id = dt.OrderId
--JOIN Shifts ON Shifts.EmployeeId = dt.Id AND DAY(Shifts.CheckIn) = DAY(Orders.DateTime)
--) AS dt2
--GROUP BY dt2.Id,dt2.[Full Name],dt2.workingHours) AS dataSet2
--JOIN dataSet ON dataSet.TotalPrice =  dataSet2.MaxPricePerDay
--ORDER BY FullName,workingHours DESC,TotalPrice DESC
----WHERE DAY(Shifts.CheckIn) = DAY(Orders.DateTime)



--SELECT dt2.Id,dt2.[Full Name],MAX(TotalPrice) AS MaxPricePerDay,dt2.workingHours FROM
--(
--SELECT dt.Id,FirstName + ' ' + LastName AS [Full Name],TotalPrice,DATEDIFF(HOUR,CheckIn,CheckOut) AS [workingHours] FROM
--(
--SELECT Employees.Id,FirstName,LastName,OrderId,SUM(Quantity * Price) AS TotalPrice FROM Employees 
--JOIN Orders ON Employees.Id = Orders.EmployeeId
--JOIN OrderItems ON Orders.Id = OrderItems.OrderId
--JOIN Items ON OrderItems.ItemId = Items.Id
--GROUP BY Employees.Id,FirstName,LastName,OrderId
--) AS dt
--JOIN Orders ON Orders.Id = dt.OrderId
--JOIN Shifts ON Shifts.EmployeeId = dt.Id AND DAY(Shifts.CheckIn) = DAY(Orders.DateTime)
--) AS dt2
--GROUP BY dt2.Id,dt2.[Full Name],dt2.workingHours

SELECT FirstName + ' ' + LastName AS [Full Name],DATEDIFF(HOUR,CheckIn,CheckOut)
AS WorkHours,TotalSum AS [TotalPrice] FROM
(
SELECT *,DENSE_RANK() OVER(PARTITION BY dt.[Employees.Id] ORDER BY [TotalSum] DESC) AS [Rank] FROM
(
SELECT Employees.Id AS [Employees.Id],FirstName,LastName,Orders.Id AS [Orders.Id],SUM(Items.Price * Quantity) 
AS [TotalSum]
FROM Employees
JOIN Orders ON Employees.Id = Orders.EmployeeId
JOIN OrderItems ON Orders.Id = OrderItems.OrderId
JOIN Items ON OrderItems.ItemId = Items.Id
GROUP BY Employees.Id ,FirstName,LastName,Orders.Id 
) AS dt
) AS dt2
JOIN Shifts ON dt2.[Employees.Id] = Shifts.EmployeeId
WHERE [Rank] = 1
AND (SELECT [DateTime] FROM Orders WHERE Id = [Orders.Id]) > Shifts.CheckIn 
AND (SELECT [DateTime] FROM Orders WHERE Id = [Orders.Id]) < Shifts.CheckOut
ORDER BY [Full Name] ASC, [WorkHours] DESC, TotalPrice DESC
GO
CREATE FUNCTION udf_GetPromotedProducts
(@CurrentDate DateTime, @StartDate DateTime, @EndDate DateTime , @Discount DECIMAL(15,2), @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM Items WHERE @FirstItemId = Items.Id))
	BEGIN
	 RETURN 'One of the items does not exists!'
	END
	IF(NOT EXISTS(SELECT * FROM Items WHERE @SecondItemId = Items.Id))
	BEGIN
	 RETURN 'One of the items does not exists!'
	END
	IF(NOT EXISTS(SELECT * FROM Items WHERE @ThirdItemId = Items.Id))
	BEGIN
	 RETURN 'One of the items does not exists!'
	END
	IF(@CurrentDate NOT BETWEEN @StartDate AND @EndDate)
	BEGIN
	 RETURN 'The current date is not within the promotion dates!'
	END
	DECLARE @FirstItemName VARCHAR(50) = (SELECT Name FROM Items WHERE @FirstItemId = Items.Id)
	DECLARE @SecondItemName VARCHAR(50) = (SELECT Name FROM Items WHERE @SecondItemId = Items.Id)
	DECLARE @ThirdItemName VARCHAR(50) = (SELECT Name FROM Items WHERE @ThirdItemId = Items.Id)

	DECLARE @Multiplier DECIMAL(15,2) = (100 - @Discount) / CAST(100 AS decimal(15,2))

	DECLARE @FirstItemValue DECIMAL(15,2) = (SELECT Price FROM Items WHERE @FirstItemId = Items.Id) * @Multiplier
	DECLARE @SecondItemValue DECIMAL(15,2) = (SELECT Price FROM Items WHERE @SecondItemId = Items.Id) * @Multiplier
	DECLARE @ThirdItemValue DECIMAL(15,2) = (SELECT Price FROM Items WHERE @ThirdItemId = Items.Id) * @Multiplier

	RETURN CONCAT(@FirstItemName,' price: ',@FirstItemValue,
	' <-> ',@SecondItemName,' price: ',@SecondItemValue,' <-> ',@ThirdItemName,' price: ',@ThirdItemValue)
END
SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 100000,4,5)
SELECT dbo.udf_GetPromotedProducts('2018-08-01', '2018-08-02', '2018-08-03',13,100000 ,4,5)


SELECT * FROM Orders

CREATE PROC usp_CancelOrder(@OrderId INT, @CancelDate DATE)
AS
	IF(NOT EXISTS(SELECT * FROM Orders WHERE Orders.Id  = @OrderId))
	BEGIN
		RAISERROR('The order does not exist!',16,1)
		RETURN
	END
	IF(DATEDIFF(DAY,(SELECT DateTime FROM Orders WHERE Orders.Id  = @OrderId),@CancelDate) >= 3)
	BEGIN
		RAISERROR('You cannot cancel the order!',16,1)
		RETURN
	END
	DELETE FROM OrderItems WHERE @OrderId = OrderItems.OrderId
	DELETE FROM Orders WHERE @OrderId = Orders.Id

	EXEC usp_CancelOrder 1, '2018-06-15'

CREATE TABLE DeletedOrders 
(
	OrderId INT FOREIGN KEY REFERENCES Orders(Id),
	ItemId INT FOREIGN KEY REFERENCES Items(Id),
	ItemQuantity INT
)
GO
CREATE TRIGGER tr_DeletedOrders ON OrderItems
FOR DELETE
AS
	INSERT INTO DeletedOrders
	SELECT * FROM deleted

