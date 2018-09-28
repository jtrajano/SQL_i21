CREATE VIEW [dbo].[vyuICSearchItemUPC]
AS
SELECT intId = CAST(ROW_NUMBER() OVER(ORDER BY ItemLocation.intItemLocationId, ItemUOM.intItemUOMId, Item.intItemId) AS INT)
	, ItemUOM.intItemUOMId
	, Item.intItemId
	, Item.strItemNo
	, Item.strDescription
	, ItemUOM.intUnitMeasureId
	, UOM.strUnitMeasure
	, UOM.strSymbol
	, UOM.strUnitType
	, ItemUOM.strUpcCode
	, ItemUOM.strLongUPCCode
	, ItemUOM.dblUnitQty
	, ItemUOM.ysnStockUnit
	, ItemUOM.ysnAllowPurchase
	, ItemUOM.ysnAllowSale
	, ItemUOM.dblMaxQty
	, ItemLocation.intItemLocationId
	, ItemLocation.intLocationId
	, CompLoc.strLocationName
	, ItemUOM.intConcurrencyId
FROM tblICItemUOM ItemUOM
INNER JOIN tblICItem Item
	ON Item.intItemId = ItemUOM.intItemId
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN (
	tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation CompLoc
		ON ItemLocation.intLocationId = CompLoc.intCompanyLocationId
	) ON ItemLocation.intItemId = Item.intItemId