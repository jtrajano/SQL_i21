CREATE VIEW [dbo].[vyuTRRackPriceDetail]
	AS 

SELECT DISTINCT intRackPriceDetailId = RackPriceDetail.intRackPriceDetailId
	, RackPriceDetail.intRackPriceHeaderId
	, RackPriceHeader.intSupplyPointId
	, RackPriceDetail.intItemId
	, Item.strItemNo
	, Item.strType
	, Item.strDescription
	, ItemLocation.intLocationId
	, ItemLocation.strLocationName
	, strEquation = ISNULL(RackPriceEquation.strEquation, '')
FROM tblTRRackPriceDetail RackPriceDetail
LEFT JOIN tblTRRackPriceHeader RackPriceHeader ON RackPriceHeader.intRackPriceHeaderId = RackPriceDetail.intRackPriceHeaderId
LEFT JOIN vyuTRRackPrice RackPriceEquation ON RackPriceEquation.intSupplyPointId = RackPriceHeader.intSupplyPointId AND RackPriceEquation.intItemId = RackPriceDetail.intItemId
LEFT JOIN tblICItem Item ON Item.intItemId = RackPriceDetail.intItemId
LEFT JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.intItemId = RackPriceDetail.intItemId