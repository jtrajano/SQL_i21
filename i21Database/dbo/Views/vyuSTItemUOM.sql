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
	, CAST(CASE WHEN LEN(uom.strLongUPCCode) IN (10, 11, 12) 
				THEN RIGHT('0000' + dbo.fnSTRemoveCheckDigit(ISNULL(uom.strUPCA, uom.strLongUPCCode)), 11)
			WHEN LEN(uom.strLongUPCCode) IN (10, 11, 12, 13, 14, 15) 
				THEN RIGHT('0000' + dbo.fnSTRemoveCheckDigit(ISNULL(uom.strSCC14, uom.strLongUPCCode)), 13) 
			ELSE uom.strLongUPCCode
			END AS BIGINT)
		AS intUPCNoCheckDigit
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