CREATE VIEW [dbo].[vyuICGetSubstituteComponentStock]
	AS
SELECT	intParentKey = CAST(ROW_NUMBER() OVER(ORDER BY ItemSubstitute.intItemSubstituteId, ItemSubstitute.intSubstituteItemId, ItemSubstituteComponent.intLocationId) AS INT),
		ItemSubstitute.intItemSubstituteId,
		intParentItemSubstituteId = ItemHeader.intItemId,
		strParentItemSubstitute = ItemHeader.strItemNo,
		strParentItemSubstituteDesc = ItemHeader.strDescription,
		intSubstituteItemUOMId = ItemSubstitute.intItemUOMId,
		dblSubstituteItemUOMId = ItemSubstituteUOM.dblUnitQty,
		strSubstituteItemUOM = subUOM.strUnitMeasure,
		intSubstituteComponent = ItemSubstitute.intSubstituteItemId,
		dblSubstituteComponentQty = ItemSubstitute.dblQuantity,
		dblSubstituteMarkUpOrDown = ItemSubstitute.dblMarkUpOrDown,
		dtmSubstituteBeginDate = ItemSubstitute.dtmBeginDate,
		dtmSubstituteEndDate = ItemSubstitute.dtmEndDate,
		ItemSubstituteComponent.*
FROM tblICItemSubstitute ItemSubstitute
INNER JOIN tblICItem ItemSubstituteDetail ON ItemSubstituteDetail.intItemId = ItemSubstitute.intSubstituteItemId
INNER JOIN tblICItem ItemHeader ON ItemHeader.intItemId = ItemSubstitute.intItemId
LEFT JOIN (
	tblICItemUOM ItemSubstituteUOM INNER JOIN tblICUnitMeasure subUOM
		ON ItemSubstituteUOM.intUnitMeasureId = subUOM.intUnitMeasureId
) ON ItemSubstituteUOM.intItemUOMId = ItemSubstitute.intItemUOMId
INNER JOIN vyuICGetItemStock ItemSubstituteComponent ON ItemSubstituteComponent.intItemId = ItemSubstitute.intSubstituteItemId