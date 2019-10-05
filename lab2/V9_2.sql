-- task a
CREATE TABLE dbo.StateProvince (
	StateProvinceID INT NOT NULL,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag Flag NOT NULL,
	Name Name NOT NULL,
	TerritoryID INT NOT NULL, 
	ModifiedDate DATETIME NOT NULL
)
-- task b
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT PK_StateProvince PRIMARY KEY (StateProvinceID, StateProvinceCode)
-- task c
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT CK_TerritoryID CHECK (TerritoryID % 2 = 0)
-- task d
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT DF_TerritoryID DEFAULT 2 FOR TerritoryID
-- task e
INSERT INTO dbo.StateProvince (
	StateProvinceID,
	StateProvinceCode,
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	ModifiedDate
) SELECT 
	Province.StateProvinceID,
	Province.StateProvinceCode,
	Province.CountryRegionCode,
	Province.IsOnlyStateProvinceFlag,
	Province.Name, 
	Province.ModifiedDate
FROM (
	SELECT  
		StateProvince.StateProvinceID,
		StateProvinceCode,
		CountryRegionCode,
		IsOnlyStateProvinceFlag,
		StateProvince.Name, 
		StateProvince.ModifiedDate,
		RANK() OVER (PARTITION BY StateProvince.StateProvinceID, StateProvince.StateProvinceCode ORDER BY Address.AddressID DESC) AS AddressIDNumber
	FROM Person.StateProvince
	INNER JOIN Person.Address 
		ON StateProvince.StateProvinceID = Address.StateProvinceID
	INNER JOIN Person.BusinessEntityAddress
		ON Address.AddressID = BusinessEntityAddress.AddressID
	INNER JOIN Person.AddressType
		ON BusinessEntityAddress.AddressTypeID = AddressType.AddressTypeID
	WHERE AddressType.Name = 'Shipping'
) AS Province
WHERE AddressIDNumber = 1
-- task f
ALTER TABLE dbo.StateProvince
	ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT
