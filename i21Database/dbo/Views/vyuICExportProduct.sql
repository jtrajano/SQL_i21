CREATE VIEW [dbo].[vyuICExportProduct]
	AS SELECT
	CAST(item.strItemNo AS NVARCHAR(16)) code
	, CAST(item.strDescription AS NVARCHAR(35)) name
	, CAST(item.intItemId AS VARCHAR(16)) itemID
	, CAST(0 AS NVARCHAR(16)) priceID
	, CAST(0 AS NVARCHAR(8)) taxCode
	, 0 aux1
	, 0 aux2
	, CAST(0 AS NVARCHAR(8)) fuelTypeCode
	, 0 preOp
	, 0 postOp
FROM tblICItem item