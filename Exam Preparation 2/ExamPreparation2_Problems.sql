CREATE DATABASE ColonialJourney
USE ColonialJourney

CREATE TABLE Planets
(
	Id	INT	PRIMARY KEY IDENTITY,
	[Name]	VARCHAR(30)	NOT NULL
)

CREATE TABLE Spaceports
(
	Id INT	PRIMARY KEY IDENTITY,
	[Name]	VARCHAR(50)	NOT NULL,
	PlanetId	INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)
)
CREATE TABLE Spaceships
(
	Id INT	PRIMARY KEY IDENTITY,
	[Name]	VARCHAR(50)	NOT NULL,
	Manufacturer VARCHAR(30)	NOT NULL,
	LightSpeedRate	INT	DEFAULT(0)
)

CREATE TABLE Colonists
(
	Id INT	PRIMARY KEY IDENTITY,
	FirstName	VARCHAR(20)	NOT NULL,
	LastName	VARCHAR(20)	NOT NULL,
	Ucn	VARCHAR(10)	NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)
CREATE TABLE Journeys
(
	Id INT	PRIMARY KEY IDENTITY,
	JourneyStart	DateTime NOT NULL,
	JourneyEnd	DateTime	NOT NULL,
	Purpose	VARCHAR(11)	CHECK(Purpose IN('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId	INT NOT NULL FOREIGN KEY REFERENCES SpacePorts(Id),
	SpaceshipId	INT NOT NULL FOREIGN KEY REFERENCES SpaceShips(Id)
)

CREATE TABLE TravelCards
(
	Id INT	PRIMARY KEY IDENTITY,
	CardNumber	CHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId	INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId	INT 
	NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)

INSERT INTO Planets VALUES
('Mars'), ('Earth'),('Jupiter'),('Saturn')

INSERT INTO Spaceships VALUES
('Golf',	'VW',	3         ),    
('WakaWaka',	'Wakanda',	4 ),  
('Falcon9'	,'SpaceX',	1 ), 
('Bed'	,'Vidolov',	6     )

UPDATE Spaceships 
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

DELETE FROM TravelCards
WHERE TravelCards.JourneyId <=3

DELETE FROM Journeys
WHERE Journeys.Id <=3

SELECT CardNumber,JobDuringJourney FROM TravelCards
ORDER BY CardNumber
 
SELECT Id,FirstName + ' ' + LastName AS FullName, Ucn FROM Colonists
ORDER by FirstName,LastName, Id 

SELECT Id,FORMAT(JourneyStart,'dd/MM/yyyy'),FORMAT(JourneyEnd,'dd/MM/yyyy') FROM Journeys
WHERE Journeys.Purpose = 'Military'
ORDER BY JourneyStart

SELECT Colonists.Id,Colonists.FirstName + ' ' + Colonists.LastName  FROM TravelCards
JOIN Colonists ON Colonists.Id = TravelCards.ColonistId
WHERE JobDuringJourney = 'Pilot'
GROUP BY Colonists.Id,Colonists.FirstName,Colonists.LastName
ORDER BY Colonists.Id
 
SELECT COUNT(*) FROM
(
SELECT DISTINCT(ColonistId) FROM Journeys
JOIN TravelCards ON Journeys.Id = TravelCards.JourneyId
WHERE Journeys.Purpose = 'Technical') AS dt

SELECT dt.Name,Spaceports.Name FROM
(SELECT *,DENSE_RANK() OVER (ORDER BY LightSpeedRate DESC) AS[Rank] FROM Spaceships) AS dt
JOIN Journeys ON dt.Id = Journeys.SpaceshipId
JOIN Spaceports ON Journeys.DestinationSpaceportId = Spaceports.Id
WHERE [Rank] = 1

SELECT Spaceships.Name,Manufacturer FROM Spaceships
JOIN Journeys ON Spaceships.Id = Journeys.SpaceshipId
JOIN TravelCards ON TravelCards.JourneyId = Journeys.Id
JOIN Colonists ON Colonists.Id = TravelCards.ColonistId
WHERE TravelCards.JobDuringJourney = 'Pilot' AND Colonists.BirthDate > '01/01/1989'
GROUP BY Spaceships.Name,Manufacturer
ORDER BY Spaceships.Name

SELECT Planets.Name,Spaceports.Name FROM Planets
JOIN Spaceports ON Planets.Id = Spaceports.PlanetId
JOIN Journeys ON Spaceports.Id = Journeys.DestinationSpaceportId
WHERE Purpose = 'Educational'
ORDER BY Spaceports.Name DESC

SELECT * FROM
(SELECT dt.Name,COUNT(dt.Id) AS [Count] FROM
(SELECT Planets.Name,Journeys.Id FROM Planets
LEFT JOIN Spaceports ON Planets.Id = Spaceports.PlanetId
LEFT JOIN Journeys ON Spaceports.Id = Journeys.DestinationSpaceportId) AS dt
GROUP BY dt.Name) AS dt2
WHERE [Count] <> 0
ORDER BY [Count] DESC,dt2.Name ASC

SELECT dt.Id,[Planets.Name],Name,Purpose FROM
(SELECT Journeys.Id,Planets.Name AS [Planets.Name],Spaceports.Name,Journeys.Purpose,DATEDIFF(MINUTE,JourneyStart,JourneyEnd) AS [Duration] 
, DENSE_RANK() OVER (ORDER BY DATEDIFF(MINUTE,JourneyStart,JourneyEnd)) AS [Rank]
FROM Journeys
JOIN Spaceports ON Journeys.DestinationSpaceportId = Spaceports.Id
JOIN Planets ON Planets.Id = Spaceports.PlanetId) AS dt
WHERE [Rank] = 1

SELECT JourneyId,JobDuringJourney FROM
(SELECT JobDuringJourney,dt2.JourneyId,COUNT(*) AS [COUNT],DENSE_RANK() OVER (ORDER BY COUNT(*)) AS[Rank] FROM
(SELECT dt.Id AS[JourneyId],TravelCards.Id,TravelCards.JobDuringJourney FROM
(SELECT Journeys.Id,Planets.Name AS [Planets.Name],Spaceports.Name,Journeys.Purpose,DATEDIFF(MINUTE,JourneyStart,JourneyEnd) AS [Duration] 
, DENSE_RANK() OVER (ORDER BY DATEDIFF(MINUTE,JourneyStart,JourneyEnd) DESC) AS [Rank]
FROM Journeys
JOIN Spaceports ON Journeys.DestinationSpaceportId = Spaceports.Id
JOIN Planets ON Planets.Id = Spaceports.PlanetId) AS dt
JOIN TravelCards ON TravelCards.JourneyId = dt.Id
WHERE [Rank] = 1) AS dt2
GROUP BY JobDuringJourney,dt2.JourneyId) AS dt3
WHERE [Rank] = 1

WITH JobsWithRank2 (JourneyId,JobTitle) AS (SELECT dt.Id,JobDuringJourney FROM
(SELECT Journeys.Id,JobDuringJourney, COUNT(*) AS [Count],
DENSE_RANK() OVER(PARTITION BY Journeys.Id ORDER BY COUNT(*)) AS [Rank] FROM Journeys
JOIN TravelCards ON Journeys.Id = TravelCards.JourneyId
GROUP BY Journeys.Id,JobDuringJourney) AS dt
WHERE [Rank] = 2)

SELECT dt2.JobDuringJourney,FirstName + ' ' + LastName AS [FullName],2 FROM
(
SELECT Journeys.Id AS [JourneyId],JobDuringJourney,Colonists.Id AS [Colonists.Id],FirstName,LastName,BirthDate
,DENSE_RANK() OVER (PARTITION BY JourneyId ORDER BY Colonists.BirthDate ASC) AS [Rank]
FROM Journeys
JOIN TravelCards ON Journeys.Id = TravelCards.JourneyId
JOIN Colonists ON TravelCards.ColonistId = Colonists.Id
WHERE EXISTS(SELECT * FROM JobsWithRank2 WHERE JobsWithRank2.JourneyId = Journeys.Id AND JobsWithRank2.JobTitle
= TravelCards.JobDuringJourney)
) AS dt2
WHERE [Rank] = 1
ORDER BY BirthDate

SELECT JobDuringJourney,COUNT(*) FROM TravelCards
GROUP BY JobDuringJourney
ORDER BY JobDuringJourney

SELECT * FROM 
(SELECT JobDuringJourney,FirstName + ' ' + LastName AS [FullName],DENSE_RANK() OVER (PARTITION BY JobDuringJourney ORDER BY BirthDate) AS [Rank] FROM TravelCards
JOIN Colonists ON TravelCards.ColonistId = Colonists.Id) AS dt
WHERE [Rank] = 2

SELECT Planets.Name,COUNT(Spaceports.Id) AS [Count] FROM Planets
LEFT JOIN Spaceports ON Planets.Id = Spaceports.PlanetId
GROUP BY Planets.Name
ORDER BY [Count] DESC,Planets.Name 
GO
CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(*)
	FROM
	(
		SELECT Colonists.Id FROM Planets 
		JOIN Spaceports ON Spaceports.PlanetId = Planets.Id
		JOIN Journeys ON Journeys.DestinationSpaceportId = Spaceports.Id
		JOIN TravelCards ON Journeys.Id = TravelCards.JourneyId 
		JOIN Colonists ON TravelCards.ColonistId = Colonists.Id
		WHERE Planets.Name = @PlanetName
	) AS dt)
END
GO
SELECT dbo.udf_GetColonistsCount('Otroyphus')
GO

Create procedure usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
	IF(NOT EXISTS(SELECT * FROM Journeys WHERE Id = @JourneyId))
	BEGIN
		RAISERROR('The journey does not exist!',16,1)
		RETURN
	END
	IF((SELECT Purpose FROM Journeys WHERE Id = @JourneyId) = @NewPurpose)
	BEGIN
		RAISERROR('You cannot change the purpose!',16,1)
		RETURN
	END
	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @JourneyId


Create table DeletedJourneys 
(
	Id INT	PRIMARY KEY IDENTITY,
	JourneyStart	DateTime NOT NULL,
	JourneyEnd	DateTime	NOT NULL,
	Purpose	VARCHAR(11)	CHECK(Purpose IN('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId	INT NOT NULL FOREIGN KEY REFERENCES SpacePorts(Id),
	SpaceshipId	INT NOT NULL FOREIGN KEY REFERENCES SpaceShips(Id)
)go
Create trigger tr_DeletedJourneys ON Journeys
FOR DELETE
AS
	INSERT INTO DeletedJourneys
	SELECT Id,JourneyStart, JourneyEnd, Purpose, DestinationSpaceportId, SpaceshipId
	FROM deleted

Note: Submit only your CREATE TRIGGER statement!
Example
Query
DELETE FROM TravelCards
WHERE JourneyId =  1

DELETE FROM Journeys
WHERE Id =  1
Response
(5 rows affected)
(1 rows affected)
(1 rows affected)
