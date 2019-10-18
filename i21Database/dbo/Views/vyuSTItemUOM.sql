CREATE VIEW [dbo].[vyuSTItemUOM]
	AS
SELECT 
	item.strItemNo
	, item.strDescription AS strItemDescription 
	, category.intCategoryId
	, category.strCategoryCode
	, companyLoc.intCompanyLocationId
	, companyLoc.strLocationName
	, unit.strUnitMeasure
	, item.strStatus
	, item.strLotTracking
	, item.ysnFuelItem
	, st.intStoreId
	, st.intStoreNo
	, uom.*
FROM tblICItemUOM uom
INNER JOIN tblICItem item
	ON uom.intItemId = item.intItemId
INNER JOIN tblICItemLocation itemLoc
	ON item.intItemId = itemLoc.intItemId
INNER JOIN tblSTStore st
	ON itemLoc.intLocationId = st.intCompanyLocationId
INNER JOIN tblICCategory category
	ON item.intCategoryId = category.intCategoryId
INNER JOIN tblSMCompanyLocation companyLoc
	ON st.intCompanyLocationId = companyLoc.intCompanyLocationId
INNER JOIN tblICUnitMeasure unit
	ON uom.intUnitMeasureId = unit.intUnitMeasureId