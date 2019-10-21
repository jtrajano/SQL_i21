CREATE VIEW [dbo].[vyuARGetSubstituteItems]
AS 
SELECT intItemId			= SUBSTITUTE.intItemId 
	 , intSubstituteItemId	= SUBSTITUTE.intSubstituteItemId
	 , intItemUOMId			= SUBSTITUTE.intItemUOMId
	 , strItemNo			= ITEM.strItemNo
	 , strDescription		= ITEM.strDescription
	 , strUnitMeasure		= UOM.strUnitMeasure
	 , dblQuantity			= SUBSTITUTE.dblQuantity
	 , dblMarkUpOrDown		= SUBSTITUTE.dblMarkUpOrDown
	 , dtmBeginDate			= SUBSTITUTE.dtmBeginDate
	 , dtmEndDate			= SUBSTITUTE.dtmEndDate
FROM tblICItemSubstitute SUBSTITUTE WITH (NOLOCK)
INNER JOIN (
	SELECT IC.intItemId
		 , strDescription
		 , strItemNo
		 , strType
		 , strLotTracking
		 , strBundleType
	FROM dbo.tblICItem IC WITH (NOLOCK)	
) ITEM ON SUBSTITUTE.intSubstituteItemId = ITEM.intItemId
INNER JOIN (
	SELECT intItemId
		 , intUnitMeasureId
		 , intItemUOMId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICUOM ON SUBSTITUTE.intSubstituteItemId = ICUOM.intItemId
       AND SUBSTITUTE.intItemUOMId = ICUOM.intItemUOMId
INNER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) UOM ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
