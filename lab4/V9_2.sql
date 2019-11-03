-- task a
CREATE VIEW Sales.vSpecialOfferAndProduct (
	SpecialOfferID,
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	rowguid,
	ModifiedDate,
	ProductID,
	Name
)
WITH SCHEMABINDING
AS
SELECT 
	So.SpecialOfferID,
	So.Description,
	So.DiscountPct,
	So.Type,
	So.Category,
	So.StartDate,
	So.EndDate,
	So.MinQty,
	So.MaxQty,
	So.rowguid,
	So.ModifiedDate,
	Sop.ProductID,
	P.Name
FROM Sales.SpecialOffer So
INNER JOIN Sales.SpecialOfferProduct Sop
	ON So.SpecialOfferID = Sop.SpecialOfferID
INNER JOIN Production.Product P
	ON Sop.ProductID = P.ProductID

CREATE UNIQUE CLUSTERED INDEX idx_SpecialOfferAndProduct
	ON Sales.vSpecialOfferAndProduct (ProductID, SpecialOfferID)
-- task b
CREATE TRIGGER Sales.vSpecialOfferAndProductModify
ON Sales.vSpecialOfferAndProduct
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		-- update
		IF EXISTS (
			SELECT * 
			FROM inserted
			JOIN deleted 
			ON inserted.ProductID = deleted.ProductID AND inserted.SpecialOfferID = deleted.SpecialOfferID
		)
		BEGIN 
			UPDATE Sales.SpecialOffer
			SET
				Description = inserted.Description,
				DiscountPct = inserted.DiscountPct,
				Type = inserted.Type,
				Category = inserted.Category,
				StartDate = inserted.StartDate,
				EndDate = inserted.EndDate,
				MinQty = inserted.MinQty,
				MaxQty = inserted.MaxQty,
				rowguid = inserted.rowguid,
				ModifiedDate = inserted.ModifiedDate
			FROM inserted
			WHERE SpecialOffer.SpecialOfferID = inserted.SpecialOfferID
		END
		-- insert
		ELSE
		BEGIN
			INSERT INTO Sales.SpecialOffer (
				Description,
				DiscountPct,
				Type,
				Category,
				StartDate,
				EndDate,
				MinQty,
				MaxQty,
				rowguid,
				ModifiedDate
			)
			SELECT 
				Description,
				DiscountPct,
				Type,
				Category,
				StartDate,
				EndDate,
				MinQty,
				MaxQty,
				rowguid,
				ModifiedDate
			FROM inserted

			INSERT INTO Sales.SpecialOfferProduct (
				So.SpecialOfferID,
				ProductID,
				ModifiedDate,
				rowguid
			)
			SELECT
				So.SpecialOfferID,
				ProductID,
				inserted.ModifiedDate,
				inserted.rowguid
			FROM inserted
			JOIN SpecialOffer AS So
			ON inserted.rowguid = So.rowguid
		END
	END
	-- delete
	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
	BEGIN
		DELETE FROM Sales.SpecialOfferProduct
		WHERE ProductID IN (SELECT ProductID FROM deleted)
		
		DELETE FROM Sales.SpecialOffer
		WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted) 
			AND SpecialOfferID NOT IN (SELECT SpecialOfferID FROM Sales.SpecialOfferProduct)
	END
END
GO
-- task c
INSERT INTO Sales.vSpecialOfferAndProduct (
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	rowguid,
	ModifiedDate,
	ProductID,
	Name
)
VALUES (
	'insertActionVP',
	30,
	'insert',
	'action',
	'2011-2-2',
	'2014-2-2',
	20,
	40,
	NEWID(),
	GETDATE(),
	1,
	'Adjustable Race'
)

UPDATE Sales.vSpecialOfferAndProduct 
SET
	Description = 'updateActionVP',
	Type = 'update',
	ModifiedDate = GETDATE()
WHERE Description = 'insertActionVP'

DELETE Sales.vSpecialOfferAndProduct
WHERE Description = 'updateActionVP'