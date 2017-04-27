CREATE VIEW [dbo].[vyuTRGetRackPriceHeader]
	AS

SELECT RackPriceHeader.intRackPriceHeaderId
	, RackPriceHeader.intSupplyPointId
	, Vendor.strVendorId
	, strVendorName = Vendor.strName
	, Vendor.intEntityId AS intEntityVendorId
	, EntityLocation.strLocationName
	, EntityLocation.intEntityLocationId
	, RackPriceHeader.dtmEffectiveDateTime
	, RackPriceHeader.strComments
FROM tblTRRackPriceHeader RackPriceHeader
LEFT JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = RackPriceHeader.intSupplyPointId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = SupplyPoint.intEntityLocationId
LEFT JOIN vyuAPVendor Vendor ON Vendor.intEntityId = SupplyPoint.intEntityVendorId