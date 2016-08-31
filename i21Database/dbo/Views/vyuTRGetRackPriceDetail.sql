CREATE VIEW [dbo].[vyuTRGetRackPriceDetail]
	AS 

SELECT DISTINCT RackPriceDetail.intRackPriceDetailId
	, RackPriceDetail.intRackPriceHeaderId
	, RackPriceHeader.intSupplyPointId
	, RackPriceDetail.intItemId
	, Item.strItemNo
	, Item.strType
	, Item.strDescription
	, strEquation = ISNULL(PriceEquation.strEquation, '')
	, RackPriceHeader.dtmEffectiveDateTime
	, Entity.strName
	, strVendorLocationName = EntityLocation.strLocationName
	, RackPriceHeader.strComments
	, RackPriceDetail.dblVendorRack
	, RackPriceDetail.dblJobberRack
FROM tblTRRackPriceDetail RackPriceDetail
LEFT JOIN tblTRRackPriceHeader RackPriceHeader ON RackPriceHeader.intRackPriceHeaderId = RackPriceDetail.intRackPriceHeaderId
LEFT JOIN tblICItem Item ON Item.intItemId = RackPriceDetail.intItemId
LEFT JOIN vyuTRRackPriceEquation PriceEquation ON PriceEquation.intSupplyPointId = RackPriceHeader.intSupplyPointId AND PriceEquation.intItemId = RackPriceDetail.intItemId
INNER JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = RackPriceHeader.intSupplyPointId
INNER JOIN tblEMEntity Entity ON SupplyPoint.intEntityVendorId = Entity.intEntityId
INNER JOIN [tblEMEntityLocation] EntityLocation ON SupplyPoint.intEntityLocationId = EntityLocation.intEntityLocationId