-- task a
ALTER TABLE dbo.StateProvince
	ADD  AddressType NVARCHAR(50)
-- task b
DECLARE @StateProvince TABLE (
	StateProvinceID INT NOT NULL,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag SMALLINT,
	Name Name NOT NULL,
	TerritoryID INT NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	AddressType NVARCHAR(50)
)

INSERT INTO @StateProvince
SELECT 
	StateProvince.StateProvinceID,
	StateProvince.StateProvinceCode,
	StateProvince.CountryRegionCode,
	StateProvince.IsOnlyStateProvinceFlag,
	StateProvince.Name,
	StateProvince.TerritoryID,
	StateProvince.ModifiedDate,
	AddressType.Name
FROM dbo.StateProvince
INNER JOIN AdventureWorks2012.Person.Address
	ON StateProvince.StateProvinceID = Address.StateProvinceID
INNER JOIN AdventureWorks2012.Person.BusinessEntityAddress
	ON Address.AddressID = BusinessEntityAddress.AddressID
INNER JOIN AdventureWorks2012.Person.AddressType
	ON AddressType.AddressTypeID = BusinessEntityAddress.AddressTypeID
-- task c
UPDATE dbo.StateProvince
SET 
	Name = CONCAT(CountryRegion.Name, ' ', StateProvince.Name),
	AddressType = Sp.AddressType
FROM @StateProvince AS Sp
INNER JOIN Person.CountryRegion
	ON Sp.CountryRegionCode = CountryRegion.CountryRegionCode
WHERE StateProvince.StateProvinceID = Sp.StateProvinceID
-- task d 
WITH Sp AS (
	SELECT 
		*, 
		RANK() OVER (PARTITION BY AddressType ORDER BY StateProvinceID DESC) AS RankNum
	FROM dbo.StateProvince
)
DELETE
FROM Sp
WHERE RankNum > 1
-- task e
ALTER TABLE dbo.StateProvince
	DROP COLUMN AddressType
ALTER TABLE dbo.StateProvince
	DROP CONSTRAINT PK_StateProvince
ALTER TABLE dbo.StateProvince
	DROP CONSTRAINT CK_TerritoryID
-- task f
DROP TABLE dbo.StateProvince



