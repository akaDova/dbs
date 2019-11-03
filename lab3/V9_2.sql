-- task a
ALTER TABLE dbo.StateProvince
	ADD 
		TaxRate SMALLMONEY,
		CurrencyCode NCHAR(3),
		AverageRate MONEY,
		IntTaxRate AS CEILING(TaxRate)
-- task b
CREATE TABLE #StateProvince ( 
	StateProvinceID INT NOT NULL PRIMARY KEY,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag SMALLINT,
	Name NVARCHAR(50) NOT NULL,
	TerritoryID INT NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	TaxRate SMALLMONEY,
	CurrencyCode NCHAR(3),
	AverageRate MONEY
)
-- task c
;WITH Cr AS (
	SELECT MAX(AverageRate) AS AverageRate, ToCurrencyCode AS CurrencyCode
	FROM Sales.CurrencyRate 
	GROUP BY ToCurrencyCode
)
INSERT INTO #StateProvince (
	StateProvinceID,
	StateProvinceCode,
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate
) SELECT 
	StateProvince.StateProvinceID,
	StateProvince.StateProvinceCode,
	StateProvince.CountryRegionCode,
	IsOnlyStateProvinceFlag,
	StateProvince.Name,
	TerritoryID,
	StateProvince.ModifiedDate,
	CASE 
		WHEN TaxType IS NOT NULL THEN SalesTaxRate.TaxRate
		ELSE 0
	END,
	Crc.CurrencyCode,
	Cr.AverageRate
FROM dbo.StateProvince
INNER JOIN Sales.CountryRegionCurrency AS Crc
	ON StateProvince.CountryRegionCode = Crc.CountryRegionCode
INNER JOIN Sales.SalesTaxRate
	ON StateProvince.StateProvinceID = SalesTaxRate.StateProvinceID
INNER JOIN Cr
	ON Crc.CurrencyCode = Cr.CurrencyCode
WHERE TaxType = 1
-- task d
DELETE 
FROM dbo.StateProvince
WHERE CountryRegionCode = 'CA'
-- task e
MERGE dbo.StateProvince AS Sp USING #StateProvince AS SpTemp
ON Sp.StateProvinceID = SpTemp.StateProvinceID
	WHEN MATCHED
	THEN 
		UPDATE SET 
			Sp.TaxRate = SpTemp.TaxRate,
			Sp.CurrencyCode = SpTemp.CurrencyCode,
			Sp.AverageRate = SpTemp.AverageRate
	WHEN NOT MATCHED BY TARGET 
	THEN
		INSERT 
		VALUES (
			SpTemp.StateProvinceID,
			SpTemp.StateProvinceCode,
			SpTemp.CountryRegionCode,
			SpTemp.IsOnlyStateProvinceFlag,
			SpTemp.Name,
			SpTemp.TerritoryID,
			SpTemp.ModifiedDate,
			SpTemp.TaxRate,
			SpTemp.CurrencyCode,
			SpTemp.AverageRate
		)
	WHEN NOT MATCHED BY SOURCE
	THEN 
		DELETE;
