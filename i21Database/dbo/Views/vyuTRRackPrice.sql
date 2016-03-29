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
	, RD.dblVendorRack
	, PriceEquation.strEquation
	, RD.dblJobberRack
FROM tblTRRackPriceHeader RH
LEFT JOIN tblTRRackPriceDetail RD ON RH.intRackPriceHeaderId = RD.intRackPriceHeaderId
LEFT JOIN vyuTRRackPriceEquation PriceEquation ON PriceEquation.intSupplyPointId = RH.intSupplyPointId AND PriceEquation.intItemId = RD.intItemId
INNER JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = RH.intSupplyPointId
INNER JOIN tblEntity Entity ON SupplyPoint.intEntityVendorId = Entity.intEntityId
INNER JOIN tblEntityLocation EntityLocation ON SupplyPoint.intEntityLocationId = EntityLocation.intEntityLocationId
