CREATE VIEW vyuSTItemSearch
AS
SELECT DISTINCT
	it.intItemId
	, it.strItemNo
	, it.strDescription
	, it.strShortName
	, cat.strCategoryCode
	, it.strNACSCategory
	, um.strUnitMeasure
	, m.strManufacturer
	, CASE WHEN it.strStatus = 'Active'
		THEN CAST(1 AS BIT)
	  ELSE
		CAST(0 AS BIT)
	END AS ysnActive
FROM tblICItem AS it
JOIN tblICCategory cat
	ON it.intCategoryId = cat.intCategoryId
JOIN tblICItemUOM uom
	ON it.intItemId = uom.intItemId
	AND uom.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure um
	ON uom.intUnitMeasureId = um.intUnitMeasureId
LEFT JOIN tblICManufacturer m
	ON it.intManufacturerId = m.intManufacturerId