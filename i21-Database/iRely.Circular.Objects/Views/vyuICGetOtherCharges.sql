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
	, Item.strCostType
	, Item.intOnCostTypeId
	, strOnCostType = OnCostType.strItemNo
	, Item.ysnBasisContract
	, Item.intM2MComputationId
	, M2M.strM2MComputation
FROM tblICItem Item
	LEFT JOIN tblICItem OnCostType ON OnCostType.intItemId = Item.intOnCostTypeId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = Item.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN tblICM2MComputation M2M ON M2M.intM2MComputationId = Item.intM2MComputationId
WHERE Item.strType = 'Other Charge'

