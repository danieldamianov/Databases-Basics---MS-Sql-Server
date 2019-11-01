CREATE DATABASE School
USE School

CREATE TABLE Students
(
	Id	INT PRIMARY KEY IDENTITY,
	FirstName	NVARCHAR(30)	NOT NULL,
	MiddleName	NVARCHAR(25),
	LastName	NVARCHAR(30) NOT NULL,
	Age	INT CHECK(Age >= 5 AND Age <=100),--Integer from 5 to 100	Negative or zero numbers are not allowed
	Address	NVARCHAR(50),
	Phone	NCHAR(10),
)
CREATE TABLE Subjects
(
	Id	INT PRIMARY KEY IDENTITY,
	Name	NVARCHAR(20)	NOT NULL,
	Lessons	INT	NOT NULL CHECK(Lessons > 0)
)
CREATE TABLE StudentsSubjects
(
	Id	INT PRIMARY KEY IDENTITY,
	StudentId	INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	SubjectId	INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
	Grade	DECIMAL(15,2)	CHECK(Grade >= 2 AND Grade <= 6) NOT NULL
)
CREATE TABLE Exams
(
	Id	INT PRIMARY KEY IDENTITY,
	Date DateTime,
	SubjectId	INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
)
CREATE TABLE StudentsExams
(
	StudentId	INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	ExamId	INT NOT NULL FOREIGN KEY REFERENCES Exams(Id),
	Grade	DECIMAL(15,2)	CHECK(Grade >= 2 AND Grade <= 6) NOT NULL
	PRIMARY KEY(StudentId,ExamId)
)
CREATE TABLE Teachers
(
	Id	INT PRIMARY KEY IDENTITY,
	FirstName	NVARCHAR(20)	NOT NULL,
	LastName	NVARCHAR(20)	NOT NULL,
	Address	NVARCHAR(20)	NOT NULL,
	Phone	CHAR(10),
	SubjectId	INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE StudentsTeachers
(
	StudentId	INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	TeacherId	INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id),
	PRIMARY KEY (StudentId,TeacherId)
)

INSERT INTO Teachers
(FirstName,	LastName,	Address,	Phone	,SubjectId)
VALUES
('Ruthanne'	,'Bamb',	'84948 Mesta Junction',	3105500146,	6),
('Gerrard'	,'Lowin',	'370 Talisman Plaza',	3324874824,	2),
('Merrile'	,'Lambdin',	'81 Dahle Plaza',	4373065154,	5	 ),
('Bert' 	,'Ivie',	'2 Gateway Circle',	4409584510,	4	 )
INSERT INTO Subjects
(Name	,Lessons)
VALUES
('Geometry'	,12),
('Health'	,10),
('Drama'	,7 ),
('Sports'	,9 )

UPDATE StudentsSubjects
SET Grade = 6
WHERE StudentsSubjects.SubjectId IN (1,2) AND Grade >= 5.5

DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers
WHERE CHARINDEX('72',Phone) <> 0)
DELETE FROM Teachers
WHERE CHARINDEX('72',Phone) <> 0

Select FirstName,LastName,Age FROM Students WHERE Age >= 12
Order by FirstName , LastName  

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ',' ') + LastName AS FullName,Address FROM Students
WHERE CHARINDEX('road',Address) <> 0
Order by FirstName , LastName,Address

SELECT FirstName,Address,Phone FROM Students
WHERE MiddleName IS NOT NULL AND LEFT(Phone,2) = '42'
ORDER BY FirstName

SELECT Students.FirstName,LastName,COUNT(*) FROM Students
JOIN StudentsTeachers ON Students.Id = StudentsTeachers.StudentId
GROUP BY Students.Id,Students.FirstName,LastName
ORDER BY LastName

SELECT * FROM
(
SELECT FirstName + ' ' + LastName AS FullName,CONCAT(Subjects.Name,'-',Subjects.Lessons) as [subjects],COUNT(*) AS [count] FROM Teachers
JOIN Subjects ON Teachers.SubjectId = Subjects.Id
JOIN StudentsTeachers ON StudentsTeachers.TeacherId = Teachers.Id
GROUP BY Teachers.Id,FirstName,LastName,Subjects.Name,Subjects.Lessons
) AS dt
ORDER BY count DESC,FullName ASC,subjects ASC

SELECT FirstName + ' ' + LastName AS [FullName] FROM Students
LEFT JOIN StudentsExams ON Students.Id = StudentsExams.StudentId
WHERE ExamId IS NULL
ORDER BY FullName

SELECT top 10 FirstName,LastName,count FROM
(
SELECT FirstName , LastName ,CONCAT(Subjects.Name,'-',Subjects.Lessons) as [subjects],COUNT(*) AS [count] FROM Teachers
JOIN Subjects ON Teachers.SubjectId = Subjects.Id
JOIN StudentsTeachers ON StudentsTeachers.TeacherId = Teachers.Id
GROUP BY Teachers.Id,FirstName,LastName,Subjects.Name,Subjects.Lessons
) AS dt
ORDER BY count DESC,FirstName,LastName

SELECT TOP 10 FirstName,LastName,CAST(ROUND([avgGrade],2) AS decimal(15,2)) FROM
(
SELECT FirstName,LastName,AVG(Grade) AS [avgGrade] FROM Students
JOIN StudentsExams ON Students.Id = StudentsExams.StudentId
GROUP BY Students.Id,FirstName,LastName
) AS dt
ORDER BY [avgGrade] DESC,FirstName,LastName

SELECT FirstName,LastName,Grade FROM
(
SELECT FirstName,LastName,Grade,ROW_NUMBER() OVER (PARTITION BY StudentId ORDER BY Grade DESC) AS [rank]  FROM StudentsSubjects
JOIN Students ON StudentsSubjects.StudentId = Students.Id
) AS dt
WHERE rank = 2
GROUP BY FirstName,LastName,Grade
ORDER BY FirstName,LastName

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ','') + LastName AS FullName FROM Students
LEFT JOIN StudentsSubjects
ON StudentsSubjects.StudentId = Students.Id
WHERE StudentsSubjects.SubjectId IS NULL
ORDER BY FullName

SELECT dt.FirstName + ' ' + dt.LastName AS [FullName1],Subjects.Name,Students.FirstName + ' ' + Students.LastName AS [FullName],CAST(Avg AS decimal(15,2)) FROM
(
SELECT Teachers.Id , Teachers.FirstName,Teachers.LastName,Teachers.SubjectId,StudentsTeachers.StudentId,AVG(Grade) AS [Avg]
,DENSE_RANK() OVER (PARTITION BY Teachers.Id ORDER BY AVG(Grade) DESC) AS [rank] FROM Teachers
JOIN StudentsTeachers ON Teachers.Id = StudentsTeachers.TeacherId
JOIN StudentsSubjects ON StudentsTeachers.StudentId = StudentsSubjects.StudentId AND Teachers.SubjectId = StudentsSubjects.SubjectId
GROUP BY Teachers.Id , Teachers.FirstName,Teachers.LastName,StudentsTeachers.StudentId,Teachers.SubjectId
) AS dt
JOIN Subjects ON dt.SubjectId = Subjects.Id
JOIN Students ON dt.StudentId = Students.Id
WHERE [rank] = 1
ORDER BY Subjects.Name,FullName1,Avg DESC

SELECT Subjects.Name,AVG(Grade) FROM Subjects 
JOIN StudentsSubjects ON Subjects.Id = StudentsSubjects.SubjectId
GROUP BY Subjects.Id,Subjects.Name
ORDER BY Subjects.Id

SELECT [q],td.Name,COUNT(*) FROM
(
SELECT Exams.Id,ISNULL('Q' + CAST(DATEPART(QUARTER,[Date]) AS varchar(MAX)),'TBA') AS [q],Subjects.Name FROM Exams
JOIN Subjects ON Exams.SubjectId = Subjects.Id
JOIN StudentsExams ON StudentsExams.ExamId = Exams.Id
WHERE Grade >= 4.00
) AS td
GROUP BY [q],td.Name
ORDER BY td.q,td.Name 
go
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM StudentsExams WHERE StudentId = @studentId))
	BEGIN
		RETURN('The student with provided id does not exist in the school!')
	END
	IF(@grade > 6)
	BEGIN
		RETURN 'Grade cannot be above 6.00!'
	END
	DECLARE @gradesToUpdate INT = (SELECT COUNT(*) FROM(SELECT * FROM StudentsExams
	WHERE (StudentsExams.StudentId = @studentId) AND (Grade BETWEEN @grade AND @grade + 0.5)) AS dt)

	DECLARE @studentFirstName VARCHAR(MAX) = (SELECT top 1 FirstName
	FROM Students WHERE Students.Id = @studentId)

	RETURN CONCAT('You have to update ',@gradesToUpdate,' grades for the student ',@studentFirstName)
END
GO
CREATE PROC usp_ExcludeFromSchool(@StudentId INT)
AS
	IF(NOT EXISTS(SELECT * FROM Students WHERE Id = @studentId))
	BEGIN
		RAISERROR('This school has no student with the provided id!',16,1)
		RETURN
	END
	DELETE FROM StudentsExams
	WHERE StudentId = @StudentId
	DELETE FROM StudentsTeachers
	WHERE StudentId = @StudentId
	DELETE FROM StudentsSubjects
	WHERE StudentId = @StudentId
	DELETE FROM Students
	WHERE Id = @StudentId
	

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students
go
CREATE TRIGGER tr_ExcludedStudents
ON Students
AFTER DELETE
AS
	INSERT INTO ExcludedStudents
	SELECT Id, FirstName + ' ' + LastName
	FROM deleted