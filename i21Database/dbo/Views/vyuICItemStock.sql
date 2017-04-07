CREATE VIEW [dbo].[vyuICItemStock]
AS 

SELECT	s.*
		,stockUOM.strUnitMeasure 
FROM	tblICItemStock s 
		OUTER APPLY (
			SELECT	TOP 1 
					UOM.strUnitMeasure
			FROM	tblICItemUOM iUOM INNER JOIN tblICUnitMeasure UOM
						ON iUOM.intUnitMeasureId = UOM.intUnitMeasureId
			WHERE	iUOM.intItemId = s.intItemId
					AND iUOM.ysnStockUnit = 1
		) stockUOM
