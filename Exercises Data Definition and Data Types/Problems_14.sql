--Using SQL queries create CarRental database with the following entities:
-- Categories (Id, CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
-- Cars (Id, PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
-- Employees (Id, FirstName, LastName, Title, Notes)
-- Customers (Id, DriverLicenceNumber, FullName, Address, City, ZIPCode, Notes)
-- RentalOrders (Id, EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd,
--TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
--Set most appropriate data types for each column. Set primary key to each table. Populate each table with only 3
--records. Make sure the columns that are present in 2 tables would be of the same data type. Consider which fields
--are always required and which are optional. Submit your CREATE TABLE and INSERT statements as Run queries &amp;
--check DB.
CREATE DATABASE CarRental
USE CarRental

