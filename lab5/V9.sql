CREATE FUNCTION Sales.startDateToStr (
	@SpecialOfferID INT
) 
RETURNS NVARCHAR(50)
AS
BEGIN
	RETURN (SELECT FORMAT(StartDate, 'MMMM, d. dddd')
		FROM Sales.SpecialOffer
		WHERE SpecialOfferID = @SpecialOfferID)
END;

CREATE FUNCTION Sales.getSpecialOfferProducts (
	@SpecialOfferID INT
)
RETURNS TABLE
AS
RETURN 
	SELECT 
		P.ProductID,
		P.Name,
		ProductNumber,
		MakeFlag,
		FinishedGoodsFlag,
		Color,
		SafetyStockLevel,
		ReorderPoint,
		StandardCost,
		ListPrice,
		Size,
		SizeUnitMeasureCode,
		WeightUnitMeasureCode,
		Weight,
		DaysToManufacture,
		ProductLine,
		Class,
		Style,
		ProductSubcategoryID,
		ProductModelID,
		SellStartDate,
		SellEndDate,
		DiscontinuedDate,
		P.rowguid,
		P.ModifiedDate
	FROM SpecialOffer So
	INNER JOIN SpecialOfferProduct Sop
		ON So.SpecialOfferID = Sop.SpecialOfferID
	INNER JOIN Production.Product P
		ON Sop.ProductID = P.ProductID
	WHERE So.SpecialOfferID = @SpecialOfferID

SELECT * FROM Sales.SpecialOffer So
CROSS APPLY Sales.getSpecialOfferProducts(SpecialOfferID)
ORDER BY So.SpecialOfferID

SELECT * FROM Sales.SpecialOffer So
OUTER APPLY Sales.getSpecialOfferProducts(SpecialOfferID)
ORDER BY So.SpecialOfferID

DROP FUNCTION IF EXISTS Sales.getSpecialOfferProducts

CREATE FUNCTION Sales.getSpecialOfferProducts (
	@SpecialOfferID INT
)
RETURNS @products TABLE (
	ProductID INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	ProductNumber NVARCHAR(25) NOT NULL,
	MakeFlag BIT NOT NULL,
	FinishedGoodsFlag BIT NOT NULL,
	Color NVARCHAR(15),
	SafetyStockLevel SMALLINT NOT NULL,
	ReorderPoint SMALLINT NOT NULL,
	StandardCost MONEY NOT NULL,
	ListPrice MONEY NOT NULL,
	Size NVARCHAR(5),
	SizeUnitMeasureCode NCHAR(3),
	WeightUnitMeasureCode NCHAR(3),
	Weight DECIMAL(8, 2),
	DaysToManufacture INT NOT NULL,
	ProductLine NCHAR(2),
	Class NCHAR(2),
	Style NCHAR(2),
	ProductSubcategoryID INT,
	ProductModelID INT,
	SellStartDate DATETIME NOT NULL,
	SellEndDate DATETIME,
	DiscontinuedDate DATETIME,
	rowguid UNIQUEIDENTIFIER NOT NULL,
	ModifiedDate DATETIME NOT NULL
)
AS
BEGIN
	INSERT INTO @products
	SELECT 
		P.ProductID,
		P.Name,
		ProductNumber,
		MakeFlag,
		FinishedGoodsFlag,
		Color,
		SafetyStockLevel,
		ReorderPoint,
		StandardCost,
		ListPrice,
		Size,
		SizeUnitMeasureCode,
		WeightUnitMeasureCode,
		Weight,
		DaysToManufacture,
		ProductLine,
		Class,
		Style,
		ProductSubcategoryID,
		ProductModelID,
		SellStartDate,
		SellEndDate,
		DiscontinuedDate,
		P.rowguid,
		P.ModifiedDate
	FROM SpecialOffer So
	INNER JOIN SpecialOfferProduct Sop
		ON So.SpecialOfferID = Sop.SpecialOfferID
	INNER JOIN Production.Product P
		ON Sop.ProductID = P.ProductID
	WHERE So.SpecialOfferID = @SpecialOfferID
	RETURN
END;
