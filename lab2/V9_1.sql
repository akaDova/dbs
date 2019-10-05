-- task 1
SELECT Employee.BusinessEntityID, JobTitle, AVG(Rate) AS AverageRate
FROM AdventureWorks2012.HumanResources.Employee
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory
	ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
GROUP BY Employee.BusinessEntityID, JobTitle
-- task 2
SELECT Employee.BusinessEntityID, JobTitle, Rate, RateReport =
	CASE 
		WHEN Rate <= 50 THEN 'Less or equal 50'
		WHEN Rate > 50 AND Rate <= 100 THEN 'More than 50 but less or equal 100'
		WHEN Rate > 100 THEN 'More than 100'
	END
FROM AdventureWorks2012.HumanResources.Employee
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory
	ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
-- task 3
SELECT Name, MAX(Rate) AS MaxRate
FROM AdventureWorks2012.HumanResources.Department
INNER JOIN AdventureWorks2012.HumanResources.EmployeeDepartmentHistory
	ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
INNER JOIN AdventureWorks2012.HumanResources.EmployeePayHistory
	ON EmployeeDepartmentHistory.BusinessEntityID = EmployeePayHistory.BusinessEntityID
WHERE EndDate IS NULL
GROUP BY Name
HAVING MAX(Rate) > 60
ORDER BY MaxRate
