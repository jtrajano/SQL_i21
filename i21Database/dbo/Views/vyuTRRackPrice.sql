CREATE VIEW [dbo].[vyuTRRackPrice]
	AS 

SELECT RH.intRackPriceHeaderId
	, RD.intRackPriceDetailId
	, RH.dtmEffectiveDateTime
	, RH.intSupplyPointId
	, Entity.strName
	, EntityLocation.strLocationName
	, RH.strComments
	, RD.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, RD.dblVendorRack
	, PriceEquation.strEquation
	, RD.dblJobberRack
FROM tblTRRackPriceHeader RH
LEFT JOIN tblTRRackPriceDetail RD ON RH.intRackPriceHeaderId = RD.intRackPriceHeaderId
LEFT JOIN tblICItem Item ON Item.intItemId = RD.intItemId
LEFT JOIN vyuTRRackPriceEquation PriceEquation ON PriceEquation.intSupplyPointId = RH.intSupplyPointId AND PriceEquation.intItemId = RD.intItemId
INNER JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = RH.intSupplyPointId
INNER JOIN tblEMEntity Entity ON SupplyPoint.intEntityVendorId = Entity.intEntityId
INNER JOIN [tblEMEntityLocation] EntityLocation ON SupplyPoint.intEntityLocationId = EntityLocation.intEntityLocationId
