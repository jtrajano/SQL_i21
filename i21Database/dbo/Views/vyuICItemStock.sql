CREATE VIEW [dbo].[vyuICItemStock]
AS 

SELECT	s.*
		,stockUOM.strUnitMeasure 
		,locationName.strLocationName 
FROM	tblICItemStock s 
		OUTER APPLY (
			SELECT	TOP 1 
					UOM.strUnitMeasure
			FROM	tblICItemUOM iUOM INNER JOIN tblICUnitMeasure UOM
						ON iUOM.intUnitMeasureId = UOM.intUnitMeasureId
			WHERE	iUOM.intItemId = s.intItemId
					AND iUOM.ysnStockUnit = 1
		) stockUOM
		OUTER APPLY (
			SELECT	TOP 1 
					cl.strLocationName
			FROM	tblICItemLocation l INNER JOIN tblSMCompanyLocation cl
						ON l.intLocationId = cl.intCompanyLocationId
			WHERE	l.intItemLocationId = s.intItemLocationId
					AND l.intItemId = s.intItemId
		) locationName

