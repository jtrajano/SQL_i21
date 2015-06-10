CREATE VIEW [dbo].[vyuTRRackItems]
WITH SCHEMABINDING
	AS 
SELECT Distinct
    A.intItemId,
	B.intSupplyPointId,
	A.strItemNo,
	A.strType,
	A.strDescription
	
FROM
     dbo.tblICItem  A
	LEFT JOIN dbo.tblTRSupplyPointRackPriceEquation B
		ON B.intItemId = A.intItemId
	