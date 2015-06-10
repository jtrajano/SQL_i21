CREATE VIEW [dbo].[vyuTRRackItems]
WITH SCHEMABINDING
	AS 
SELECT Distinct
    A.intItemId,
	B.intSupplyPointId,
	A.strItemNo,
	A.strType,
	A.strDescription,
	C.strEquation
	
FROM
     dbo.tblICItem  A
	LEFT JOIN dbo.tblTRSupplyPointRackPriceEquation B
		ON B.intItemId = A.intItemId
	LEFT JOIN dbo.vyuTRRackPriceEquation C
		ON C.intItemId = B.intItemId and C.intSupplyPointId = B.intSupplyPointId
