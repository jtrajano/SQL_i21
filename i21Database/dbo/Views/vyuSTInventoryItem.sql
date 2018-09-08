CREATE VIEW [dbo].[vyuSTInventoryItem]
AS 
SELECT I.intItemId
		, IL.intLocationId
		, UOM.intItemUOMId
		, ST.intStoreId
		, I.ysnFuelItem
		, I.strDescription
		, IL.intVendorId
		, IL.intFamilyId
		, IL.intClassId
		, IP.dblSalePrice
		, UM.strUnitMeasure
		, UOM.strUpcCode
		, UOM.strLongUPCCode
		, V.strVendorId
		, CL.strLocationName
FROM tblICItem I
JOIN tblICItemUOM UOM
	ON I.intItemId = UOM.intItemId
JOIN tblICUnitMeasure UM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
JOIN tblAPVendor V
	ON IL.intVendorId = V.intEntityId
JOIN tblSMCompanyLocation CL
	ON IL.intLocationId = CL.intCompanyLocationId
JOIN tblSTStore ST
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
JOIN tblICItemPricing IP
	ON I.intItemId = IP.intItemId
		AND IL.intItemLocationId = IP.intItemLocationId