﻿CREATE VIEW vyuSTPromotionItemLists
AS
SELECT        
intKey = CAST(ROW_NUMBER() OVER (ORDER BY UOM.intItemUOMId, IL.intLocationId) AS INT)
, CL.strLocationName
, UOM.strUpcCode
, UOM.strLongUPCCode
, UOM.intItemUOMId
, I.strItemNo 
, I.strDescription AS strPumpItemDescription
, adj6.intCategoryId
, adj6.strCategoryCode
, adj6.strDescription AS categoryDesc
, I.ysnFuelItem
, IP.dblSalePrice AS dblPrice
, IL.intFamilyId
, IL.intClassId
, Family.strSubcategoryId AS strFamily
, Class.strSubcategoryId AS strClass
, CL.intCompanyLocationId
FROM            
tblICItemUOM UOM JOIN
tblICItemLocation IL ON UOM.intItemId = IL.intItemId LEFT JOIN
tblSTSubcategory AS Family ON Family.intSubcategoryId = IL.intFamilyId LEFT JOIN
tblSTSubcategory AS Class ON Class.intSubcategoryId = IL.intClassId JOIN
tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId JOIN
tblICItemPricing IP ON IP.intItemLocationId = IL.intItemLocationId JOIN
tblICItem I ON I.intItemId = UOM.intItemId JOIN
tblICCategory adj6 ON I.intCategoryId = adj6.intCategoryId
WHERE I.strType = 'Inventory' AND I.strStatus = 'Active'

