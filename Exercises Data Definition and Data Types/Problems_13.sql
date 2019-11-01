--Problem 13. Movies Database
--Using SQL queries create Movies database with the following entities:
-- Directors (Id, DirectorName, Notes)
-- Genres (Id, GenreName, Notes)
-- Categories (Id, CategoryName, Notes)
-- Movies (Id, Title, DirectorId, CopyrightYear, Length, GenreId, CategoryId, Rating, Notes)
--Set most appropriate data types for each column. Set primary key to each table. Populate each table with exactly 5
--records. Make sure the columns that are present in 2 tables would be of the same data type. Consider which fields
--are always required and which are optional. Submit your CREATE TABLE and INSERT statements as Run queries &amp;
--check DB.

CREATE DATABASE Movies
USE Movies

CREATE TABLE Directors(
Id INT PRIMARY KEY NOT NULL,
DirectorName NVARCHAR(50) NOT NULL,
Notes TEXT,
)

CREATE TABLE Genres(
Id INT PRIMARY KEY NOT NULL,
GenreName NVARCHAR(50) NOT NULL,
Notes TEXT,
)

CREATE TABLE Categories(
Id INT PRIMARY KEY NOT NULL,
CategoryName NVARCHAR(50) NOT NULL,
Notes TEXT,
)

CREATE TABLE Movies(
Id INT PRIMARY KEY NOT NULL,
Title NVARCHAR(50) NOT NULL,
DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
CopyrightYear INT NOT NULL CHECK(CopyrightYear <= 2019 AND CopyrightYear > 1900),
[Length] INT NOT NULL,
GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Rating REAL NOT NULL,
Notes TEXT
)

ALTER TABLE Movies
ADD CONSTRAINT CHK_Rating_Movies
CHECK(Rating >= 0 AND Rating <= 10)

INSERT INTO Directors(Id,DirectorName,Notes) VALUES
(1,'Daniel Damianov','Very good director'),
(2,'Christopher Nolen','Very good director2'),
(3,'Bradley cooper','Very good director3'),
(4,'Cameron','Very good director4'),
(5,'Peter lenkov','Very good director')
--SELECT * FROM Directors

INSERT INTO Genres(Id,GenreName) VALUES
(1,'Drama'),
(2,'Romance'),
(3,'Thriller'),
(4,'Horror'),
(5,'Comedy')
--SELECT * FROM Genres

INSERT INTO Categories(Id,CategoryName) VALUES
(1,'Catagory1'),
(2,'Catagory2'),
(3,'Catagory3'),
(4,'Catagory4'),
(5,'Catagory5')
--SELECT * FROM Categories

-- Directors (Id, DirectorName, Notes)
-- Genres (Id, GenreName, Notes)
-- Categories (Id, CategoryName, Notes)
-- Movies (Id, Title, DirectorId, CopyrightYear, Length, GenreId, CategoryId, Rating, Notes)

INSERT INTO Movies (Id, Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes)
VALUES
(1,'War',1,2019,135,3,1,10,'Very good film')

INSERT INTO Movies (Id, Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes)
VALUES
(2,'Film1',2,2018,135,1,2,10,'Very good film2'),
(3,'Film2',3,2017,135,2,3,10,'Very good film3'),
(4,'Film3',4,2016,135,4,4,10,'Very good film4'),
(5,'Film4',5,2015,135,5,5,10,'Very good film5')

--SELECT * FROM Movies