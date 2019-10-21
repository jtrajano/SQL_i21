CREATE VIEW [dbo].[vyuICGetItemUOMByType]
AS

SELECT	intId = CAST(ROW_NUMBER() OVER(ORDER BY um.intUnitMeasureId, uom.intItemId) AS INT)
		, um.intUnitMeasureId
		, um.strUnitMeasure
		, um.strUnitType
		, um.strSymbol
		, uom.intItemId
FROM	tblICUnitMeasure um INNER JOIN tblICItemUOM uom 
			ON uom.intUnitMeasureId = um.intUnitMeasureId