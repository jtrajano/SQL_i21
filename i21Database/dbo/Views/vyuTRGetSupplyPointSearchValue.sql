CREATE VIEW [dbo].[vyuTRGetSupplyPointSearchValue]
	AS 

SELECT intKeyId = Detail.intSupplyPointProductSearchHeaderId 
	, SupplyPoint.intSupplyPointId
	, intSupplierId = SupplyPoint.intEntityVendorId
	, strSupplier = Supplier.strName
	, EntityLocation.intEntityLocationId
	, strLocation = EntityLocation.strLocationName
	, Header.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, strSearchValue
FROM tblTRSupplyPointProductSearchHeader Header
LEFT JOIN tblTRSupplyPointProductSearchDetail Detail ON Detail.intSupplyPointProductSearchHeaderId = Header.intSupplyPointProductSearchHeaderId
LEFT JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = Header.intSupplyPointId
LEFT JOIN vyuEMEntity Supplier ON Supplier.intEntityId = SupplyPoint.intEntityVendorId AND Supplier.strType = 'Vendor'
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = SupplyPoint.intEntityLocationId
LEFT JOIN tblICItem Item ON Item.intItemId = Header.intItemId
WHERE ISNULL(strSearchValue, '') <> ''