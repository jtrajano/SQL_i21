CREATE VIEW [dbo].[vyuICGetSubstituteItem]
AS

SELECT	ItemSubstitute.intItemSubstituteId
		,ItemSubstitute.intItemId
		,Item.strItemNo
		,ItemSubstitute.intSubstituteItemId
		,strSubstituteItemNo = SubstituteComponent.strItemNo
		,strDescription = SubstituteComponent.strDescription
		,ItemSubstitute.dblQuantity
		,ItemSubstitute.dblMarkUpOrDown
		,ItemSubstitute.dtmBeginDate
		,ItemSubstitute.dtmEndDate
		,ItemSubstitute.intItemUOMId
		,UOM.strUnitMeasure
FROM	tblICItemSubstitute ItemSubstitute
		LEFT JOIN tblICItem Item ON Item.intItemId = ItemSubstitute.intItemId
		LEFT JOIN tblICItem SubstituteComponent ON SubstituteComponent.intItemId = ItemSubstitute.intSubstituteItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemSubstitute.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId