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
		, uom.dblMaxQty
		, uom.dblUnitQty
		, uom.dblHeight
		, uom.dblLength
		, uom.dblWeight
		, uom.dblVolume
		, uom.strUpcCode
		, uom.strLongUPCCode
FROM	vyuICGetItemUOM uom
		LEFT OUTER JOIN tblICItem item ON item.intItemId = uom.intItemId
		LEFT OUTER JOIN tblICCommodity com ON com.intCommodityId = item.intCommodityId
		LEFT OUTER JOIN tblICCategory cat ON cat.intCategoryId = item.intCategoryId
		LEFT OUTER JOIN vyuICGetItemUOM stock ON stock.intItemId = item.intItemId
		AND stock.ysnStockUnit = 1