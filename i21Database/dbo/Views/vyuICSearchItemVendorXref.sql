CREATE VIEW [dbo].[vyuICSearchItemVendorXref]
AS
SELECT
	Item.intItemId,
	VendorXref.intItemVendorXrefId,
	Item.strItemNo,
	Item.strDescription,
	ItemLocation.strLocationName,
	Vendor.strName,
	VendorXref.strVendorProduct,
	VendorXref.strProductDescription,
	VendorXref.dblConversionFactor,
	UnitMeasure.strUnitMeasure
FROM tblICItemVendorXref VendorXref
INNER JOIN tblICItem Item
ON
VendorXref.intItemId = Item.intItemId
LEFT JOIN vyuICGetItemLocation ItemLocation
ON
VendorXref.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN vyuAPVendor Vendor
ON
VendorXref.intVendorId = Vendor.intEntityId
LEFT JOIN (
	tblICItemUOM ItemUOM 
	LEFT JOIN tblICUnitMeasure UnitMeasure
	ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
)
ON ItemUOM.intItemUOMId = VendorXref.intItemUnitMeasureId