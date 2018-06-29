CREATE VIEW vyuSTPromotionItemLists
AS
SELECT       
intKey = CAST(ROW_NUMBER() OVER (ORDER BY UOM.intItemUOMId, IL.intLocationId) AS INT)
, CL.strLocationName
, UOM.strUpcCode
, UOM.strLongUPCCode
, UOM.intItemUOMId
, I.strItemNo
, I.strDescription AS strPumpItemDescription
, Cat.intCategoryId
, Cat.strCategoryCode
, Cat.strDescription AS categoryDesc
, I.ysnFuelItem
, IP.dblSalePrice AS dblPrice
, IL.intFamilyId
, IL.intClassId
, Family.strSubcategoryId AS strFamily
, Class.strSubcategoryId AS strClass
, CL.intCompanyLocationId
, I.strLotTracking
, I.strType
, I.strStatus
, ST.intStoreId
FROM tblICItemUOM UOM
JOIN tblICItemLocation IL 
	ON UOM.intItemId = IL.intItemId 
JOIN tblSTStore ST 
	ON IL.intLocationId = ST.intCompanyLocationId
LEFT JOIN tblSTSubcategory AS Family 
	ON Family.intSubcategoryId = IL.intFamilyId 
LEFT JOIN tblSTSubcategory AS Class 
	ON Class.intSubcategoryId = IL.intClassId 
JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = IL.intLocationId 
JOIN tblICItemPricing IP 
	ON IP.intItemLocationId = IL.intItemLocationId 
JOIN tblICItem I 
	ON I.intItemId = UOM.intItemId 
JOIN tblICCategory Cat 
	ON I.intCategoryId = Cat.intCategoryId
WHERE UOM.ysnStockUnit = CAST(1 AS BIT)