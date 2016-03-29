CREATE VIEW [dbo].[vyuTRRackItems]
	AS 

SELECT DISTINCT A.intItemId
	, B.intSupplyPointId
	, A.strItemNo
	, D.intLocationId
	, D.strLocationName
	, A.strType
	, A.strDescription
	, intRackPriceDetailId = RackPriceDetail.intRackPriceDetailId
	, strEquation = ISNULL(RackPriceDetail.strEquation, '')
FROM dbo.tblICItem A
LEFT JOIN dbo.tblTRSupplyPointRackPriceEquation B ON B.intItemId = A.intItemId
LEFT JOIN vyuTRRackPrice RackPriceDetail ON RackPriceDetail.intSupplyPointId = B.intSupplyPointId AND RackPriceDetail.intItemId = A.intItemId
LEFT JOIN vyuICGetItemLocation D ON A.intItemId = D.intItemId