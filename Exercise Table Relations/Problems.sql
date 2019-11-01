CREATE TABLE Persons(
	PersonId INT,
	FirstName VARCHAR(20),
	Salary DECIMAL,
	PassportId INT,
)

INSERT INTO Persons (PersonId,FirstName,Salary,PassportId)
VALUES(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3 ,'Yana', 60200.00 ,101)

CREATE TABLE Passports(
	PassportId INT,
	PassportNumber VARCHAR(20),
)

INSERT INTO Passports VALUES(101 ,'N34FG21B'),(102 ,'K65LO4R7'),(103 ,'ZE657QP2')

ALTER TABLE Passports
ALTER COLUMN PassportId INT NOT NULL

ALTER TABLE Passports
ADD CONSTRAINT PK_Passports
PRIMARY KEY(PassportId)

ALTER TABLE Persons
ADD CONSTRAINT FK_Person_Passports
FOREIGN KEY(PassportId) REFERENCES Passports(PassportId)

ALTER TABLE Persons
ALTER COLUMN PersonId INT NOT NULL

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons
PRIMARY KEY(PersonId)

ALTER TABLE Persons
ADD CONSTRAINT Unique_Persons
UNIQUE(PassportId)

SELECT * FROM Persons
JOIN Passports ON Persons.PassportId = Passports.PassportId --PROBLEM 1

CREATE TABLE Manufacturers
(
	ManufacturerID INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	EstablishedOn DATETIME NOT NULL
)

CREATE TABLE Models
(
	ModelID INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID) NOT NULL
)

INSERT INTO Manufacturers VALUES(1 ,'BMW' ,'07/03/1916'),
(2 ,'Tesla' ,'01/01/2003'),
(3 ,'Lada' ,'01/05/1966')

INSERT INTO Models VALUES(101, 'X1', 1),
(102, 'Model S', 2),
(103, 'i6', 1),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

SELECT * FROM Manufacturers 
JOIN Models ON Models.ManufacturerID = Manufacturers.ManufacturerID -- PROBLEM 2

CREATE TABLE Students(
	StudentID INT PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL
)

CREATE TABLE Exams(
	ExamID INT PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID),
	PRIMARY KEY(StudentID,ExamID)
)

INSERT INTO Students VALUES
(1,'Mila'),
(2,'Toni'),
(3,'Ron')

INSERT INTO Exams VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g')

INSERT INTO StudentsExams VALUES 
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103)

SELECT * FROM StudentsExams
JOIN Students ON StudentsExams.StudentID = Students.StudentID
JOIN Exams ON StudentsExams.ExamID = Exams.ExamID --PROBLEM 3

CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)

SELECT * FROM Teachers

SELECT * FROM Teachers AS t1
JOIN Teachers AS t2 ON t1.TeacherID = t2.ManagerID--PROBLEM 4

SELECT Mountains.MountainRange,Peaks.PeakName,Peaks.Elevation FROM Mountains 
JOIN Peaks ON Mountains.Id = Peaks.MountainId
WHERE Mountains.MountainRange = 'Rila'
ORDER BY Elevation DESC--PROBLEM 9
