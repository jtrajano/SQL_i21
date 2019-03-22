CREATE VIEW [dbo].[vyuICGetUOMConversion]
	AS 

SELECT 
	uc.intUnitMeasureConversionId
	,uc.intUnitMeasureId
	,fromUOM.strUnitMeasure 
	,intStockUnitMeasureId = toUOM.intUnitMeasureId
	,strStockUOM = toUOM.strUnitMeasure
	,uc.dblConversionToStock
	,uc.intConcurrencyId
	,uc.intSort
FROM 
	tblICUnitMeasureConversion uc LEFT JOIN tblICUnitMeasure fromUOM 
		ON uc.intUnitMeasureId = fromUOM.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure toUOM
		ON toUOM.intUnitMeasureId = uc.intStockUnitMeasureId
