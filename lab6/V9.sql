CREATE PROCEDURE dbo.MaxDiscountPctByCategory (
	@categoryList NVARCHAR(250)
)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = '
		SELECT Name, ' + @categoryList + ' 
		FROM (
			SELECT 
				P.Name,
				DiscountPct,
				Category
			FROM Sales.SpecialOffer So
			INNER JOIN Sales.SpecialOfferProduct Sop
				ON So.SpecialOfferID = Sop.SpecialOfferID
			INNER JOIN Production.Product P
				ON Sop.ProductID = P.ProductID
		) SourceTable 
		PIVOT (
			MAX(DiscountPct)
			FOR Category IN (' + @categoryList + ')
		) PivotTable;';
	EXECUTE sp_executesql @sql;
END;

EXECUTE dbo.MaxDiscountPctByCategory '[Reseller],[No Discount],[Customer]'