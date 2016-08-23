CREATE VIEW [dbo].[vyuTRRackItems]
	AS 

SELECT DISTINCT Item.intItemId
	, SupplyPointEquation.intSupplyPointId
	, Item.strItemNo
	, ItemLocation.intLocationId
	, ItemLocation.strLocationName
	, Item.strType
	, Item.strDescription
	, strEquation = CASE WHEN RackPriceDetail.strEquation IS NOT NULL THEN RackPriceDetail.strEquation
						WHEN SupplyPointEquation.strEquation IS NOT NULL THEN SupplyPointEquation.strEquation
						ELSE '  0.000000' END
FROM tblICItem Item
LEFT JOIN vyuICGetItemLocation ItemLocation ON Item.intItemId = ItemLocation.intItemId
LEFT JOIN vyuTRRackPriceEquation SupplyPointEquation ON SupplyPointEquation.intItemId = Item.intItemId
LEFT JOIN vyuTRGetRackPriceDetail RackPriceDetail ON RackPriceDetail.intSupplyPointId = SupplyPointEquation.intSupplyPointId AND RackPriceDetail.intItemId = Item.intItemId