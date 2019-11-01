USE SoftUni
GO
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
	SELECT FirstName,LastName FROM Employees
	WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000--PROBLEM 1

GO
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber @AboveNumber DECIMAL(18,4)
AS
	SELECT FirstName,LastName FROM Employees
	WHERE Salary >= @AboveNumber
GO
EXEC usp_GetEmployeesSalaryAboveNumber 48100--PROBLEM 2

GO
CREATE OR ALTER PROCEDURE usp_GetTownsStartingWith @StartingWithString VARCHAR(20)
AS
	SELECT [Name] FROM Towns
	WHERE LEFT([Name],LEN(@StartingWithString)) = @StartingWithString
GO

EXEC usp_GetTownsStartingWith 'b'--PROBLEM 3
GO
CREATE PROCEDURE usp_GetEmployeesFromTown @TownName VARCHAR(20)
AS
	SELECT FirstName AS 'First Name',LastName AS 'Last Name' FROM Employees
	JOIN Addresses ON Employees.AddressID = Addresses.AddressID
	JOIN Towns ON Addresses.TownID = Towns.TownID
	WHERE Towns.[Name] = @TownName

EXEC usp_GetEmployeesFromTown 'Sofia'--PROBLEM 4
GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(10);
	IF(@salary < 30000)
	 BEGIN
		SET @salaryLevel = 'Low'
	 END
	ELSE IF(@salary <= 50000)
	 BEGIN
		SET @salaryLevel = 'Average'
	 END
	ELSE
	 BEGIN
		SET @salaryLevel = 'High'
	 END
	RETURN @salaryLevel
END
GO
SELECT *,dbo.ufn_GetSalaryLevel(Salary) FROM Employees --PROBLEM 5
GO
CREATE PROC usp_EmployeesBySalaryLevel (@SalaryLevel VARCHAR(10))
AS 
	SELECT FirstName AS 'First Name',LastName AS 'Last Name' FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel

EXECUTE usp_EmployeesBySalaryLevel 'High' --PROBLEM 6
GO
CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @isComprised BIT = 1;
	DECLARE @positionInTheWord INT = 1;
	WHILE @positionInTheWord <= LEN(@word)
	BEGIN
		DECLARE @characterAtGivenPosition CHAR(1);
		SET @characterAtGivenPosition = SUBSTRING(@word,@positionInTheWord,1)
		IF(CHARINDEX(@characterAtGivenPosition,@setOfLetters) = 0)
		BEGIN
		 SET @isComprised = 0
		END
		SET @positionInTheWord = @positionInTheWord + 1
	END
	RETURN @isComprised
END
GO 

DECLARE @x BIT
SET @x = dbo.ufn_IsWordComprised('123','31231231231231231')
SELECT @x --PROBLEM 7
GO
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN
	(SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)
	UPDATE Employees
	SET ManagerId = NULL
	WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)
	ALTER TABLE Departments
	ALTER COLUMN ManagerId INT NULL
	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)
	DELETE FROM Employees WHERE DepartmentID = @departmentId
	DELETE FROM Departments WHERE DepartmentID = @departmentId
	SELECT COUNT(*) FROM Employees WHERE DepartmentID = @departmentId
GO
EXEC usp_DeleteEmployeesFromDepartment 7 --PROBLEM 8
USE Bank
GO
CREATE PROC usp_GetHoldersFullName
AS
SELECT FirstName + ' ' + LastName as 'Full Name' FROM AccountHolders
GO
EXEC usp_GetHoldersFullName--PROBLEM 9
GO
CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan @Money MONEY
AS
	SELECT FirstName,LastName FROM
	(SELECT FirstName,LastName,SUM(Balance) AS [MoneySum] FROM AccountHolders 
	JOIN Accounts ON AccountHolders.Id = Accounts.AccountHolderId
	GROUP BY AccountHolders.Id,AccountHolders.FirstName,AccountHolders.LastName
	) as dt
	WHERE [MoneySum] > @Money
	ORDER BY FirstName,LastName--PROBLEM 10
GO
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue (@sumAmount decimal(15,4), @yearlyInterestRate float , @numberOfYears int)
RETURNS DECIMAL(15,4)
AS
BEGIN
	DECLARE @Multiplier float = 1 + @yearlyInterestRate
	DECLARE @YearsCounter int = 1;
	WHILE @YearsCounter <= @numberOfYears
	BEGIN
		SET @sumAmount = @sumAmount * @Multiplier
		SET @YearsCounter = @YearsCounter + 1
	END
	RETURN @sumAmount
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000,0.1,5) --PROBLEM 11
GO
CREATE PROC usp_CalculateFutureValueForAccount @AccountId INT, @yearlyInterestRate FLOAT
AS
	SELECT Accounts.Id,FirstName,LastName,Balance,dbo.ufn_CalculateFutureValue(Balance,@yearlyInterestRate,5)
	AS 'Balance in 5 years' FROM Accounts
	JOIN AccountHolders ON Accounts.AccountHolderId = AccountHolders.Id
	WHERE @AccountId = Accounts.Id--PROBLEM 12
GO

EXEC usp_CalculateFutureValueForAccount 1,0.1

USE Diablo
GO
CREATE OR ALTER FUNCTION ufn_CashInUsersGames (@GameName VARCHAR(50))
RETURNS TABLE
AS
RETURN
SELECT SUM(Cash) AS SumCash FROM
(SELECT TOP (100000) UsersGames.GameId,Games.Name,UsersGames.Cash,ROW_NUMBER() OVER(ORDER BY Cash DESC) AS [RowNumber] FROM UsersGames 
JOIN Games ON UsersGames.GameId = Games.Id
WHERE Games.[Name] = @GameName
ORDER BY Cash DESC) AS dt
WHERE [RowNumber] % 2 = 1
go

SELECT * FROM ufn_CashInUsersGames('Love in a mist')--PROBLEM 13
GO
USE Bank
SELECT * FROM Logs
GO
CREATE TABLE Logs
(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum MONEY,
	NewSum MONEY
)go
CREATE TRIGGER tr_LogChangesInBalance ON Accounts 
INSTEAD OF UPDATE
AS
	INSERT INTO Logs 
	SELECT Accounts.Id,Accounts.Balance,inserted.Balance FROM Accounts JOIN inserted ON Accounts.Id = inserted.Id
	UPDATE Accounts
	SET Balance = (SELECT Balance FROM inserted WHERE Accounts.Id = inserted.Id)
	WHERE Accounts.Id IN (SELECT Id FROM inserted)

UPDATE Accounts
SET Balance = 9
WHERE Accounts.Id = 1--PROBLEM 14

CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
	[Subject] VARCHAR(50),
	Body TEXT
)
GO
CREATE TRIGGER tr_NotificationEmails ON Logs
FOR INSERT
AS
	INSERT INTO NotificationEmails
	SELECT AccountId,CONCAT('Balance change for account: ' ,'1')
	,CONCAT('On ' , GETDATE() , ' your balance was changed from ' , inserted.OldSum , ' to ' , inserted.NewSum , '.')
	FROM inserted--PROBLEM 15
	
select * from Accounts
GO
CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
	IF(@MoneyAmount < 0)
	BEGIN
		RETURN
	END
	DECLARE @AccountsCount INT = (SELECT COUNT(*) FROM
	(SELECT * FROM Accounts WHERE Id = @AccountId) as d)
	IF(@AccountsCount = 0)
	BEGIN
		RETURN
	END
	UPDATE Accounts
	SET Balance = Balance + @MoneyAmount
	WHERE Accounts.Id = @AccountId--PROBLEM 16

EXEC usp_DepositMoney 1,10
SELECT * FROM Accounts 
GO
CREATE PROC usp_WithDrawMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
	BEGIN TRANSACTION
	IF(@MoneyAmount < 0)
	BEGIN
		ROLLBACK
		RETURN
	END
	DECLARE @AccountsCount INT = (SELECT COUNT(*) FROM
	(SELECT * FROM Accounts WHERE Id = @AccountId) as d)
	IF(@AccountsCount = 0)
	BEGIN
		ROLLBACK
		RETURN
	END
	UPDATE Accounts
	SET Balance = Balance - @MoneyAmount
	WHERE Accounts.Id = @AccountId
	IF((SELECT Balance FROM Accounts WHERE Accounts.Id = @AccountId) < 0)
	BEGIN
		ROLLBACK
		RAISERROR('cant withdraw inexistent money',16,1)
		RETURN
	END
	COMMIT--PROBLEM 17

EXEC usp_WithDrawMoney 1,50
go
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,4))
AS
	--EXEC usp_WithDrawMoney 1,50
	--EXEC usp_DepositMoney 1,10
	BEGIN TRANSACTION
	IF(@Amount < 0)
	BEGIN
		ROLLBACK
		RETURN
	END
	DECLARE @AccountsCount INT = (SELECT COUNT(*) FROM
	(SELECT * FROM Accounts WHERE Id IN(@SenderId,@ReceiverId)) as d)
	IF(@AccountsCount <> 2)
	BEGIN
		ROLLBACK
		RETURN
	END
	UPDATE Accounts
	SET Balance = Balance - @Amount
	WHERE Accounts.Id = @SenderId
	IF((SELECT Balance FROM Accounts WHERE Accounts.Id = @SenderId) < 0)
	BEGIN
		ROLLBACK
		RAISERROR('cant withdraw inexistent money',16,1)
		RETURN
	END
	UPDATE Accounts
	SET Balance = Balance + @Amount
	WHERE Accounts.Id = @ReceiverId
	COMMIT--PROBLEM 18
	
EXEC usp_TransferMoney 200,2,50

SELECT * FROM Accounts

USE Diablo
GO
SELECT * FROM UserGameItems
GO
USE Diablo
GO
CREATE FUNCTION udf_CheckLevels(@itemId INT, @UserGameId INT)
RETURNS BIT
AS
BEGIN
	DECLARE @ItemMinLevel INT = (SELECT Items.MinLevel FROM Items WHERE Items.Id = @itemId)
	DECLARE @UserGameLevel INT = (SELECT UsersGames.Level FROM UsersGames WHERE UsersGames.Id = @UserGameId)
	IF(@ItemMinLevel <= @UserGameLevel)
	RETURN 1
	ELSE
	RETURN 0
	return 100
END
GO
CREATE TRIGGER tr_CheckLevels ON UserGameItems
INSTEAD OF INSERT
AS
	INSERT INTO UserGameItems SELECT * FROM inserted
	WHERE [dbo].udf_CheckLevels(inserted.ItemId,inserted.UserGameId) = 1
GO--PROBLEM 19_1
INSERT INTO UserGameItems
VALUES(5,5),(2,2),(6,6)



SELECT * FROM Games
SELECT * FROM UsersGames
ORDER BY GameId
SELECT * FROM UserGameItems
ORDER BY UserGameId
SELECT * FROM Users
ORDER BY Username

UPDATE UsersGames
SET Cash = Cash + 50000
--SELECT * FROM UsersGames
WHERE UsersGames.GameId = (SELECT Id FROM Games WHERE Games.[Name] = 'Bali')
AND UsersGames.UserId IN 
(SELECT Id FROM Users WHERE Users.Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))--PROBLEM 19_2
GO
CREATE TABLE #temp
(
	userId INT,
	itemId INT
)
GO
TRUNCATE TABLE #temp
SELECT * FROM #temp
USE Diablo
Go
CREATE FUNCTION udf_HasBoughtTheItem(@UserGameId INT, @ItemId INT)
RETURNS BIT
AS
BEGIN
	DECLARE @count INT = (SELECT COUNT(*) FROM
	(SELECT * FROM UserGameItems WHERE ItemId = @ItemId AND UserGameId = @UserGameId) as dt)
	IF(@count = 1)
	RETURN 1
	RETURN 0
END
GO
CREATE PROC Buy_UsersItems
AS
	DECLARE @ItemIdCounter INT = 251
	WHILE @ItemIdCounter <= 539
	BEGIN 
	INSERT INTO UserGameItems
	SELECT @ItemIdCounter,Id FROM UsersGames WHERE UsersGames.UserId IN
	(SELECT Id FROM Users WHERE Users.[UserName] IN 
	('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
	AND UsersGames.GameId = (SELECT Id FROM Games WHERE Games.[Name] = 'Bali')
	
	UPDATE UsersGames
	SET Cash = Cash - (SELECT Price FROM Items WHERE Id = @ItemIdCounter)
	--SELECT * FROM UsersGames 
	WHERE UsersGames.UserId IN
	(SELECT Id FROM Users WHERE Users.[UserName] IN 
	('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
	AND 
	UsersGames.GameId = (SELECT Id FROM Games WHERE Games.[Name] = 'Bali')
	AND [dbo].udf_HasBoughtTheItem(UsersGames.Id,@ItemIdCounter) = 1

	IF(@ItemIdCounter = 299)
		SET @ItemIdCounter = 501
	ELSE
		SET @ItemIdCounter = @ItemIdCounter + 1
	END--PROBLEM 19_3
SELECT * FROM UsersGames JOIN Users ON UsersGames.UserId = Users.Id JOIN Games ON Games.Id = UsersGames.GameId
WHERE UsersGames.Id = 110
	SELECT * FROM UserGameItems
ORDER BY UserGameId
SELECT * FROM Items
ORDER BY Items.Id
DROP TRIGGER tr_CheckLevels
EXEC Buy_UsersItems

SELECT Users.Username,Games.Name,UsersGames.Cash,Items.Name FROM UserGameItems 
JOIN UsersGames ON UserGameItems.UserGameId = UsersGames.Id
JOIN Users ON Users.Id = UsersGames.UserId
JOIN Games ON UsersGames.GameId = Games.Id
JOIN Items ON UserGameItems.ItemId = Items.Id
WHERE Games.Name = 'Bali'
ORDER BY Users.Username ASC,Items.Name ASC --PROBLEM 19_4



go
	DECLARE @StamatSfflowerId INT = 
	(SELECT Id FROM UsersGames WHERE UsersGames.UserId = (SELECT Id FROM Users WHERE Users.Username = 'Stamat')
	AND UsersGames.GameId = (SELECT Id FROM Games WHERE Games.Name = 'Safflower'))

	CREATE TABLE #ItemIds4
	(
		Id INT IDENTITY,
		ItemId INT,
		level int
	)
	--SELECT * from #ItemIds2
	INSERT INTO #ItemIds4
	SELECT Items.Id,Items.MinLevel FROM Items WHERE Items.MinLevel IN (11,12,19,20,21) ORDER BY Items.MinLevel
	DECLARE @ItemIdCounter INT = 1
	DECLARE @ItemsCount INT = (SELECT COUNT(*) FROM #ItemIds4 WHERE #ItemIds4.level IN (11,12))
	DECLARE @hasBeenAMistake BIT = 0
	BEGIN TRANSACTION
	WHILE(@ItemIdCounter <= @ItemsCount)
	BEGIN
		DECLARE @CurrentItemId INT = (SELECT ItemId FROM #ItemIds4 WHERE Id = @ItemIdCounter)
		INSERT INTO UserGameItems VALUES(@CurrentItemId,@StamatSfflowerId)
		DECLARE @CurrentCashOfStamatSfflowerId MONEY = (SELECT Cash FROM UsersGames WHERE Id = @StamatSfflowerId)
		DECLARE @CurrentItemCost MONEY = (SELECT Price FROM Items WHERE Id = @CurrentItemId)
		IF(@CurrentCashOfStamatSfflowerId < @CurrentItemCost)
		BEGIN
		    SET @hasBeenAMistake = 1
			ROLLBACK 
			BREAK
		END
		UPDATE UsersGames
		SET Cash = Cash - @CurrentItemCost
		WHERE UsersGames.Id = @StamatSfflowerId
		SET @ItemIdCounter = @ItemIdCounter + 1
	END
	IF(@hasBeenAMistake = 0)
	BEGIN
		COMMIT
		SET @ItemsCount = (SELECT COUNT(*) FROM #ItemIds4)

		BEGIN TRANSACTION
		WHILE(@ItemIdCounter <= @ItemsCount)
		BEGIN
			SET @CurrentItemId = (SELECT ItemId FROM #ItemIds4 WHERE Id = @ItemIdCounter)
			INSERT INTO UserGameItems VALUES(@CurrentItemId,@StamatSfflowerId)
			SET @CurrentCashOfStamatSfflowerId = (SELECT Cash FROM UsersGames WHERE Id = @StamatSfflowerId)
			SET @CurrentItemCost = (SELECT Price FROM Items WHERE Id = @CurrentItemId)
			IF(@CurrentCashOfStamatSfflowerId < @CurrentItemCost)
			BEGIN
			    SET @hasBeenAMistake = 1
				ROLLBACK 
				BREAK
			END
			UPDATE UsersGames
			SET Cash = Cash - @CurrentItemCost
			WHERE UsersGames.Id = @StamatSfflowerId
			SET @ItemIdCounter = @ItemIdCounter + 1
		END
		IF(@hasBeenAMistake = 0)
			COMMIT
	END
	

SELECT Items.[Name] as [Item Name] FROM UserGameItems JOIN Items ON UserGameItems.ItemId = Items.Id
WHERE UserGameItems.UserGameId IN 
(SELECT Id FROM UsersGames WHERE UsersGames.UserId = (SELECT Id FROM Users WHERE Users.Username = 'Stamat')
	AND UsersGames.GameId = (SELECT Id FROM Games WHERE Games.[Name] = 'Safflower'))
	ORDER BY Items.[Name]
	--PROBLEM 20

DECLARE @gameName NVARCHAR(50) = 'Safflower'
DECLARE @username NVARCHAR(50) = 'Stamat'

DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName)

DECLARE @userGameLevel INT = (SELECT Level
                              FROM UsersGames
                              WHERE Id = @userGameId)
DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT

SET @minLevel = 11
SET @maxLevel = 12
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId
    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK;
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SET @minLevel = 19
SET @maxLevel = 21
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SELECT i.Name,i.MinLevel AS [Item Name],Cash
FROM UserGameItems AS ugi
  JOIN Items AS i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
    ON ug.Id = ugi.UserGameId
  JOIN Games AS g
    ON g.Id = ug.GameId
WHERE g.Name = 'Safflower'
ORDER BY [Item Name]--PROBLEM 20_OtherSolution

USE SoftUni
GO
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
	BEGIN TRANSACTION
	INSERT INTO EmployeesProjects VALUES(@emloyeeId,@projectID)
	DECLARE @countOfEmployyeProjects INT = (SELECT COUNT(*) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)
	IF(@countOfEmployyeProjects > 3)
	BEGIN
		RAISERROR('The employee has too many projects!',16,1)
		ROLLBACK
		RETURN
	END
	COMMIT

SELECT * FROM EmployeesProjects ORDER BY EmployeeID

EXEC usp_AssignProject 4,1--PROBLEM 21

CREATE TABLE Deleted_Employees
(
	EmployeeId INT PRIMARY KEY, 
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	MiddleName VARCHAR(50),
	JobTitle VARCHAR(50),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId),
	Salary MONEY
)
SELECT * FROM Employees go
CREATE TRIGGER tr_DeletedEmployees ON Employees
FOR DELETE
AS
	INSERT INTO Deleted_Employees
	SELECT EmployeeId , FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary FROM deleted--PROBLEM 22
	