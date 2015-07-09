CREATE VIEW [dbo].[vyuTRRackItems]
	AS 
SELECT Distinct
    A.intItemId,
	B.intSupplyPointId,
	A.strItemNo,
	D.intLocationId,
	E.strLocationName,
	A.strType,
	A.strDescription,
	C.strEquation
	
FROM
     dbo.tblICItem  A
	LEFT JOIN dbo.tblTRSupplyPointRackPriceEquation B
		ON B.intItemId = A.intItemId
	LEFT JOIN dbo.vyuTRRackPriceEquation C
		ON C.intItemId = B.intItemId and C.intSupplyPointId = B.intSupplyPointId
    LEFT JOIN tblICItemLocation D
	    ON A.intItemId = D.intItemId
    LEFT JOIN tblSMCompanyLocation E
	    ON D.intLocationId = E.intCompanyLocationId
