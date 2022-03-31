CREATE VIEW vyuSTPromotionItemLists
AS
SELECT       
	intKey = CAST(ROW_NUMBER() OVER (ORDER BY UOM.intItemUOMId, IL.intLocationId) AS INT)
	, CL.strLocationName
	, CL.intCompanyLocationId
	, UOM.strUpcCode
	, UOM.strLongUPCCode
	, UOM.intItemUOMId
	, I.strItemNo
	, I.strDescription AS strPumpItemDescription
	, I.ysnFuelItem
	, I.strLotTracking
	, I.strType
	, I.strStatus
	, Cat.intCategoryId
	, Cat.strCategoryCode
	, Cat.strDescription AS categoryDesc
	, UM.strUnitMeasure AS strUnitMeasure
	, itemPricing.dblSalePrice AS dblPrice
	, IL.intFamilyId
	, IL.intClassId
	, IL.intVendorId
	, vendor.strVendorId AS strVendorID
	, Family.strSubcategoryId AS strFamily
	, Class.strSubcategoryId AS strClass
	, ST.intStoreId
	, I.intItemId
FROM tblICItemUOM UOM
JOIN tblICUnitMeasure UM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
JOIN tblICItemLocation IL 
	ON UOM.intItemId = IL.intItemId 
JOIN tblSTStore ST 
	ON IL.intLocationId = ST.intCompanyLocationId
LEFT JOIN tblSTSubcategory AS Family 
	ON Family.intSubcategoryId = IL.intFamilyId 
LEFT JOIN tblSTSubcategory AS Class 
	ON Class.intSubcategoryId = IL.intClassId 
LEFT JOIN tblAPVendor vendor
	ON IL.intVendorId = vendor.intEntityId
JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = IL.intLocationId 
JOIN tblICItem I 
	ON I.intItemId = UOM.intItemId 
JOIN tblICCategory Cat 
	ON I.intCategoryId = Cat.intCategoryId
JOIN vyuSTItemHierarchyPricing itemPricing
	ON I.intItemId = itemPricing.intItemId
	AND IL.intItemLocationId = itemPricing.intItemLocationId
	AND UOM.intItemUOMId = itemPricing.intItemUOMId