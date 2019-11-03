-- task a
CREATE TABLE Sales.SpecialOfferHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action CHAR(6) NOT NULL CHECK (Action IN ('insert', 'update', 'delete')),
	ModifiedDate DATETIME NOT NULL,
	SourceID INT NOT NULL,
	UserName NVARCHAR(128) NOT NULL
);
-- task b
CREATE TRIGGER Sales.InsertAction
ON Sales.SpecialOffer
AFTER INSERT
AS 
	INSERT INTO Sales.SpecialOfferHst (
		Action,
		ModifiedDate,
		SourceID,
		UserName
	)
	SELECT 
		'insert',
		GETDATE(),
		SpecialOfferID,
		USER_NAME()
	FROM inserted
GO

CREATE TRIGGER Sales.UpdateAction
ON Sales.SpecialOffer
AFTER UPDATE
AS 
	INSERT INTO Sales.SpecialOfferHst (
		Action,
		ModifiedDate,
		SourceID,
		UserName
	)
	SELECT 
		'update',
		GETDATE(),
		SpecialOfferID,
		USER_NAME()
	FROM inserted
GO

CREATE TRIGGER Sales.DeleteAction
ON Sales.SpecialOffer
AFTER DELETE
AS 
	INSERT INTO Sales.SpecialOfferHst (
		Action,
		ModifiedDate,
		SourceID,
		UserName
	)
	SELECT 
		'delete',
		GETDATE(),
		SpecialOfferID,
		USER_NAME()
	FROM deleted
GO
-- task c
CREATE VIEW Sales.vSpecialOffer
WITH ENCRYPTION
AS
SELECT *
FROM Sales.SpecialOffer
-- task d
INSERT INTO Sales.vSpecialOffer (
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	ModifiedDate
) VALUES (
	'insertAction',
	100,
	'insert',
	'Action',
	'2016-01-05',
	'2019-01-05',
	30,
	50,
	GETDATE()
)

UPDATE Sales.vSpecialOffer 
SET
	Description = 'updateAction',
	Type = 'update',
	ModifiedDate = GETDATE()
WHERE Description = 'insertAction'

DELETE 
FROM Sales.vSpecialOffer
WHERE Description = 'updateAction'