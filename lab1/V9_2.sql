-- task 1
SELECT BusinessEntityID, JobTitle, BirthDate, HireDate
FROM AdventureWorks2012.HumanResources.Employee
WHERE CAST(BirthDate AS DATE) >= CAST('19810101' AS DATE) AND CAST(HireDate AS DATE) > CAST('20030401' AS DATE)
-- task 2
SELECT SUM(VacationHours) AS SumVacationHours, SUM(SickLeaveHours) AS SumSickLeaveHours
FROM AdventureWorks2012.HumanResources.Employee
--task 3
SELECT TOP 3 BusinessEntityID, JobTitle, Gender, BirthDate, HireDate
FROM AdventureWorks2012.HumanResources.Employee
ORDER BY HireDate 
