CREATE VIEW [dbo].[vyuICGetAssemblyItem]
	AS

SELECT Assembly.intItemAssemblyId
	, Assembly.intItemId
	, Assembly.intAssemblyItemId
	, ComponentPricing.intItemLocationId
	, ComponentLocation.intLocationId
	, strComponentItem = Component.strItemNo
	, strComponentDescription = Component.strDescription
	, strComponentType = Component.strType
	, strComponentLotTracking = Component.strLotTracking
	, Assembly.dblQuantity
	, Assembly.intItemUnitMeasureId
	, strComponentUOM = UOM.strUnitMeasure
	, dblComponentUOMCF = ISNULL(ComponentUOM.dblUnitQty, 0)
	, Assembly.dblUnit
	, Assembly.dblCost
	, dblUnitLastCost = ISNULL(ComponentPricing.dblLastCost, 0)
	, dblLastCost = ISNULL(ComponentUOM.dblUnitQty, 0) * ISNULL(ComponentPricing.dblLastCost, 0)
FROM tblICItemAssembly Assembly
LEFT JOIN tblICItem Component ON Component.intItemId = Assembly.intAssemblyItemId
LEFT JOIN tblICItemUOM ComponentUOM ON ComponentUOM.intItemUOMId = Assembly.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ComponentUOM.intUnitMeasureId
LEFT JOIN tblICItemPricing ComponentPricing ON ComponentPricing.intItemId = Component.intItemId
LEFT JOIN tblICItemLocation ComponentLocation ON ComponentLocation.intItemLocationId = ComponentPricing.intItemLocationId
