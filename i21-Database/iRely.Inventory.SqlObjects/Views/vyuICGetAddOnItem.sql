CREATE VIEW [dbo].[vyuICGetAddOnItem]
AS

SELECT	ItemAddOn.intItemAddOnId
		,ItemAddOn.intItemId
		,Item.strItemNo
		,ItemAddOn.intAddOnItemId
		,strAddOnItemNo = AddOnComponent.strItemNo
		,strDescription = AddOnComponent.strDescription
		,ItemAddOn.dblQuantity
		,ItemAddOn.intItemUOMId
		,UOM.strUnitMeasure
		,ItemAddOn.ysnAutoAdd
FROM	tblICItemAddOn ItemAddOn
		LEFT JOIN tblICItem Item ON Item.intItemId = ItemAddOn.intItemId
		LEFT JOIN tblICItem AddOnComponent ON AddOnComponent.intItemId = ItemAddOn.intAddOnItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemAddOn.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId