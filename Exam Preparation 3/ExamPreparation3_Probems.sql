CREATE DATABASE TripService
USE TripService

CREATE TABLE Cities
(
	Id INT PRIMARY KEY IDENTITY,
	[Name]	NVARCHAR(20) NOT NULL,
	CountryCode	CHAR(2) NOT NULL
)
CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name]	NVARCHAR(30) NOT NULL,
	CityId	INT NOT	NULL FOREIGN KEY REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15,2)	
)
CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(15,2) NOT NULL,
	[Type]	NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId	INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
)
CREATE TABLE Trips
(
	Id INT PRIMARY KEY IDENTITY,
	RoomId	INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id),
	BookDate Date NOT NULL ,
	ArrivalDate	Date NOT NULL ,
	ReturnDate Date	NOT NULL,
	CancelDate Date,
	CHECK(BookDate < ArrivalDate),
	CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName	NVARCHAR(50)	NOT NULL,
	MiddleName	NVARCHAR(20) ,	
	LastName	NVARCHAR(50)	NOT NULL,
	CityId	INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	BirthDate Date NOT NULL,
	Email	VARCHAR(100)	NOT NULL Unique
)
CREATE TABLE AccountsTrips
(
	AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	TripId	INT NOT NULL FOREIGN KEY REFERENCES Trips(Id),
	Luggage	INT NOT NULL CHECK(Luggage >= 0),
	PRIMARY KEY(AccountId,TripId)
)


INSERT INTO Accounts
(FirstName,	MiddleName,	LastName,	CityId,	BirthDate,	Email)
VALUES
('John','Smith','Smith',34,'1975-07-21','j_smith@gmail.com'),  
('Gosho',	NULL,	'Petrov',	11,	'1978-05-16',	'g_petrov@gmail.com'),     
('Ivan',	'Petrovich',	'Pavlov',	59,	'1849-09-26','i_pavlov@softuni.bg'),      
('Friedrich',	'Wilhelm',	'Nietzsche',	2	,'1844-10-15'	,'f_nietzsche@softuni.bg')   

INSERT INTO Trips
(RoomId	,BookDate	,ArrivalDate	,ReturnDate,	CancelDate)
VALUES
(101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02'),
(102,	'2015-07-07',	'2015-07-15',	'2015-07-22',	'2015-04-29'),
(103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL		),
(104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10'),
(109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL		)

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN(5,7,9)

DELETE FROM AccountsTrips
WHERE AccountId = 47

SELECT Id,Name FROM Cities
WHERE CountryCode = 'BG'
ORDER BY Name

SELECT CONCAT(FirstName,' ',ISNULL(MiddleName + ' ',''),LastName),YEAR(BirthDate) AS [Year] FROM Accounts
WHERE YEAR(BirthDate) > 1991
ORDER BY [Year] DESC,FirstName

SELECT FirstName,LastName,FORMAT(BirthDate,'MM-dd-yyyy') ,Cities.Name,Email FROM Accounts
JOIN Cities ON Cities.Id = Accounts.CityId
WHERE LEFT(Email,1) = 'e'
ORDER BY Cities.Name DESC

SELECT * FROM 
(
SELECT Cities.Name,COUNT(Hotels.Id) AS [Count] FROM Cities
LEFT JOIN Hotels ON Hotels.CityId = Cities.Id
GROUP BY Cities.Name,Cities.Id) AS dt
ORDER BY [Count] DESC,dt.Name

SELECT Rooms.Id,Price,Hotels.Name,Cities.Name FROM Rooms
JOIN Hotels ON Rooms.HotelId = Hotels.Id
JOIN Cities ON Hotels.CityId = Cities.Id
WHERE Type = 'First Class'
ORDER BY Price DESC,Rooms.Id

SELECT * FROM
(
SELECT Id, FullName,MAX(Duration) AS [max],MIN(Duration)AS [min] FROM
(
SELECT Accounts.Id,FirstName + ' ' + LastName AS [FullName],DATEDIFF(DAY,ArrivalDate,ReturnDate) AS [Duration],DENSE_RANK() OVER (PARTITION BY Accounts.Id ORDER BY DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS [RankShortestToLongest],DENSE_RANK() OVER (PARTITION BY Accounts.Id ORDER BY DATEDIFF(DAY,ArrivalDate,ReturnDate) DESC) AS [RankLongestToShortest] FROM Accounts
JOIN AccountsTrips ON Accounts.Id = AccountsTrips.AccountId
JOIN Trips ON AccountsTrips.TripId = Trips.Id
WHERE MiddleName IS NULL AND CancelDate IS NULL
) AS dt
WHERE [RankLongestToShortest] = 1 OR [RankShortestToLongest] = 1
GROUP BY FullName,Id
) AS dt2
ORDER BY [max] DESC,Id

SELECT TOP 5 * FROM
(
SELECT Cities.Id,Cities.Name,Cities.CountryCode,COUNT(*) AS [count] FROM Cities
JOIN Accounts ON Cities.Id = Accounts.CityId
GROUP BY Cities.Id,Cities.Name,Cities.CountryCode
) AS dt
ORDER BY [count] DESC

SELECT Accounts.Id,	Email,	Cities.Name,COUNT(*) AS [Count] FROM Accounts
JOIN AccountsTrips ON Accounts.Id = AccountsTrips.AccountId
JOIN Trips ON AccountsTrips.TripId = Trips.Id
JOIN Rooms ON Rooms.Id = Trips.RoomId
JOIN Hotels ON Hotels.Id = Rooms.HotelId AND Hotels.CityId = Accounts.CityId
JOIN Cities ON Hotels.CityId = Cities.Id
GROUP BY Accounts.Id,	Email,	Cities.Name
ORDER BY [Count] DESC,Accounts.Id

SELECT TOP 10 Cities.Id,Cities.Name,SUM(Price + BaseRate) AS [tr],COUNT(*)AS[ct] FROM Cities
JOIN Hotels ON Cities.Id = Hotels.CityId
JOIN Rooms ON Rooms.HotelId = Hotels.Id
JOIN Trips ON Rooms.Id = Trips.RoomId
WHERE YEAR(Trips.BookDate) = 2016
GROUP BY Cities.Id,Cities.Name
ORDER BY [tr] DESC,[ct] DESC

SELECT Id,Name,Type,SUM([Revenue]) FROM
(
SELECT Trips.Id,Hotels.Name,Rooms.Type,	
CASE
	WHEN CancelDate IS NOT NULL THEN 0
	WHEN CancelDate IS NULL THEN Price + BaseRate
END AS [Revenue]
FROM Trips
JOIN AccountsTrips ON AccountsTrips.TripId = Trips.Id
JOIN Rooms ON Rooms.Id = Trips.RoomId
JOIN Hotels ON Rooms.HotelId = Hotels.Id
) AS dt
GROUP BY Id,Name,Type
ORDER BY Type,Id

SELECT Id,Email,CountryCode,[count] FROM
(
SELECT *,DENSE_RANK() OVER(PARTITION BY CountryCode ORDER BY [count] DESC,Id) AS [Rank] FROM
(
SELECT CountryCode,Accounts.Id,Accounts.Email,COUNT(*) AS [count] FROM Cities
JOIN Hotels ON Cities.Id = Hotels.CityId
JOIN Rooms ON Hotels.Id = Rooms.HotelId
JOIN Trips ON Trips.RoomId = Rooms.Id
JOIN AccountsTrips ON AccountsTrips.TripId = Trips.Id
JOIN Accounts ON Accounts.Id = AccountsTrips.AccountId
GROUP BY CountryCode,Accounts.Id,Accounts.Email
) AS dt
) AS dt2
WHERE [Rank] = 1
ORDER BY [count] DESC,Id

SELECT * FROM
(
SELECT TripId,SUM(Luggage) AS [Lug],
CASE
	WHEN SUM(Luggage) > 5 THEN CONCAT('$', 5 * SUM(Luggage))
	WHEN SUM(Luggage) <= 5 THEN '$0'
END AS [Fee]
FROM AccountsTrips
GROUP BY TripId
) AS dt
WHERE [Lug] > 0
ORDER BY [Lug] DESC

SELECT AccountsTrips.TripId,CONCAT(FirstName,' ',ISNULL(MiddleName + ' ',''),LastName) AS [FullName] ,
homeCity.Name,destCity.Name,
CASE
	WHEN CancelDate IS NULL THEN CONCAT(DATEDIFF(DAY,ArrivalDate,ReturnDate),' days')
	WHEN CancelDate IS NOT NULL THEN 'Canceled'
END AS [Duration]
FROM AccountsTrips
JOIN Accounts ON AccountsTrips.AccountId = Accounts.Id
JOIN Cities AS [homeCity] ON Accounts.CityId = [homeCity].Id
JOIN Trips ON Trips.Id = AccountsTrips.TripId
JOIN Rooms ON Rooms.Id = Trips.RoomId
JOIN Hotels ON Rooms.HotelId = Hotels.Id
JOIN Cities AS [destCity] ON Hotels.CityId = [destCity].Id
ORDER BY FullName,Trips.Id
go
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	--DECLARE @HotelId INT = 112
	--DECLARE @Date DATE = '2011-12-17'
	--DECLARE @People INT = 2
	DECLARE @RoomsInTheHotelWithBedsEnough TABLE 
	(
		Id INT,
		Price DECIMAL(15,2) NOT NULL,
		[Type]	NVARCHAR(20) NOT NULL,
		Beds INT NOT NULL,
		HotelId	INT NOT NULL
	)
	DECLARE @RoomsInTheHotelWithBedsEnoughAndFreeFromTrips TABLE 
	(
		Id INT,
		Price DECIMAL(15,2) NOT NULL,
		[Type]	NVARCHAR(20) NOT NULL,
		Beds INT NOT NULL,
		HotelId	INT NOT NULL
	)
	INSERT INTO @RoomsInTheHotelWithBedsEnough
		SELECT * FROM Rooms WHERE Rooms.HotelId = @HotelId AND Beds >= @People

	--SELECT COUNT(*) FROM @RoomsInTheHotelWithBedsEnough
	INSERT INTO @RoomsInTheHotelWithBedsEnoughAndFreeFromTrips SELECT * 
	FROM
	(
	SELECT r.Id,r.Price,Type,Beds,HotelId FROM @RoomsInTheHotelWithBedsEnough AS [r]
	WHERE NOT EXISTS
	(
		SELECT * FROM Trips WHERE Trips.RoomId = r.Id AND @Date BETWEEN Trips.ArrivalDate AND Trips.ReturnDate 
		AND CancelDate IS NULL
	)
	--JOIN Trips ON r.Id = Trips.RoomId
	--WHERE (@Date NOT BETWEEN Trips.ArrivalDate AND Trips.ReturnDate) OR CancelDate IS NOT NULL 
	) AS dt
	
	IF((SELECT COUNT(*) FROM (SELECT * FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTrips) AS dt) = 0)
	BEGIN
	 RETURN 'No rooms available'
	END
	DECLARE @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice TABLE 
	(
		Id INT,
		Price DECIMAL(15,2) NOT NULL,
		[Type]	NVARCHAR(20) NOT NULL,
		Beds INT NOT NULL,
		HotelId	INT NOT NULL,
		[Rank] INT
	)
	INSERT INTO @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice
	SELECT *,DENSE_RANK() OVER (ORDER BY Price DESC) AS [Rank] FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTrips

	DECLARE @RoomId INT = (SELECT TOP 1 Id FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice WHERE [Rank] = 1)

	DECLARE @RoomType VARCHAR(MAX) = (SELECT TOP 1 Type FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice WHERE [Rank] = 1)

	DECLARE @Beds INT = (SELECT TOP 1 Beds FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice WHERE [Rank] = 1)

	DECLARE @TotalPrice DECIMAL(15,2) = (SELECT TOP 1 Price FROM @RoomsInTheHotelWithBedsEnoughAndFreeFromTripsRankedByPrice WHERE [Rank] = 1)

	DECLARE @HotelBaseRate DECIMAL(15,2) = (SELECT BaseRate FROM Hotels WHERE Hotels.Id = @HotelId)

	RETURN (CONCAT('Room ',@RoomId,': ',@RoomType,' (',@Beds,' beds) - $',((@HotelBaseRate + @TotalPrice) * @People)))
END
go
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)
SELECT * FROM Trips WHERE RoomId = 175
go
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
	DECLARE @HotelIdOfTheTrip INT = (SELECT HotelId FROM Trips
	JOIN Rooms ON Trips.RoomId = Rooms.Id
	WHERE Trips.Id = @TripId)

	DECLARE @HotelIdOfTheTargerRoom INT =
	(SELECT HotelId FROM Rooms WHERE Rooms.Id = @TargetRoomId)

	IF(@HotelIdOfTheTargerRoom <> @HotelIdOfTheTrip)
	BEGIN
	 RAISERROR('Target room is in another hotel!',16,1)
	 RETURN
	END

	DECLARE @TripAccouts INT = (SELECT COUNT(*) FROM(SELECT * FROM AccountsTrips WHERE TripId = @TripId) AS dt)
	DECLARE @RoomBeds INT = (SELECT Beds FROM Rooms WHERE Rooms.Id = @TargetRoomId)

	IF(@TripAccouts > @RoomBeds)
	BEGIN
	 RAISERROR('Not enough beds in target room!',16,1)
	 RETURN
	END

	UPDATE Trips
	SET RoomId = @TargetRoomId
	WHERE Id = @TripId
	go
CREATE TRIGGER tr_DeletedTrips
ON Trips
INSTEAD OF DELETE
AS
	UPDATE Trips
	SET CancelDate = GETDATE()
	WHERE Trips.Id IN (SELECT Id FROM deleted) AND CancelDate IS NULL

	DELETE FROM Trips
WHERE Id IN (48, 49, 50)

go
	EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10