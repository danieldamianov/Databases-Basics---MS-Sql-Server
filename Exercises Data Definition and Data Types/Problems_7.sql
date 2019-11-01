CREATE TABLE People(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(200) NOT NULL,
Picture VARBINARY(MAX) CHECK(DATALENGTH(Picture) < 2 * 1024 * 1024),
Height DECIMAL(5,2),
Weight DECIMAL(5,2),
Gender CHAR(1) CHECK(Gender = 'm' OR Gender = 'f') NOT NULL,
BirthDate DATE NOT NULL,
Biography NVARCHAR(MAX)
)

INSERT INTO People VALUES
('Daniel Cvetanov Damyanov',NULL,180.99,61.22,'m','2002-06-29','Very good programmer'),
('Daniel Cvetanov Damyanov',NULL,180.99,61.22,'m','2002-06-29','Very good programmer'),
('Daniel Cvetanov Damyanov',NULL,180.99,61.22,'m','2002-06-29','Very good programmer'),
('Daniel Cvetanov Damyanov',NULL,180.99,61.22,'m','2002-06-29','Very good programmer'),
('Daniel Cvetanov Damyanov',NULL,180.99,61.22,'m','2002-06-29','Very good programmer')
