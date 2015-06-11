CREATE VIEW [dbo].[vyuICGetOtherCharges]
	AS

SELECT Item.intItemId
	, Item.strItemNo
	, Item.strDescription
	, Item.ysnInventoryCost
	, Item.ysnAccrue
	, Item.ysnMTM
	, Item.ysnPrice
	, Item.strCostMethod
	, Item.dblAmount
	, Item.intCostUOMId
	, strCostUOM = UOM.strUnitMeasure
	, UOM.strUnitType
	, Item.intOnCostTypeId
	, strOnCostType = OnCostType.strItemNo
FROM tblICItem Item
	LEFT JOIN tblICItem OnCostType ON OnCostType.intItemId = Item.intOnCostTypeId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = Item.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CostUOM.intUnitMeasureId
WHERE Item.strType = 'Other Charge'

