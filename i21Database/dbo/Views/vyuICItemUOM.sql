CREATE VIEW [dbo].[vyuICItemUOM]
AS
SELECT 
		uom.intItemUOMId
		, item.strItemNo
		, item.strDescription strItemDescription
		, item.strType
		, item.intItemId
		, cat.strCategoryCode
		, cat.strDescription strCategory
		, cat.intCategoryId
		, com.strDescription strCommodity
		, com.strCommodityCode
		, com.intCommodityId
		, stock.strUnitMeasure strStockUOM
		, uom.strUnitMeasure
		, uom.ysnStockUnit
		, uom.ysnAllowPurchase
		, uom.ysnAllowSale
		, CAST(uom.dblMaxQty AS NUMERIC(37, 18)) dblMaxQty
		, CAST(uom.dblUnitQty AS NUMERIC(37, 18)) dblUnitQty
		, CAST(uom.dblHeight AS NUMERIC(37, 18)) dblHeight
		, CAST(uom.dblLength AS NUMERIC(37, 18)) dblLength
		, CAST(uom.dblWeight AS NUMERIC(37, 18)) dblWeight
		, CAST(uom.dblVolume AS NUMERIC(37, 18)) dblVolume
		, uom.strUpcCode
		, uom.strLongUPCCode
FROM	vyuICGetItemUOM uom
		LEFT OUTER JOIN tblICItem item ON item.intItemId = uom.intItemId
		LEFT OUTER JOIN tblICCommodity com ON com.intCommodityId = item.intCommodityId
		LEFT OUTER JOIN tblICCategory cat ON cat.intCategoryId = item.intCategoryId
		LEFT OUTER JOIN vyuICGetItemUOM stock ON stock.intItemId = item.intItemId
		AND stock.ysnStockUnit = 1