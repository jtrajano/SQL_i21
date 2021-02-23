CREATE VIEW [dbo].[vyuAGGetUOMConversion]
	AS 

SELECT 
	uc.intAGUnitMeasureConversionId
	,uc.intAGUnitMeasureId
	,fromUOM.strUnitMeasure 
	,intStockUnitMeasureId = toUOM.intAGUnitMeasureId
	,strStockUOM = toUOM.strUnitMeasure
	,uc.dblConversionToStock
	,uc.intConcurrencyId

FROM 
	tblAGUnitMeasureConversion uc LEFT JOIN tblAGUnitMeasure fromUOM 
		ON uc.intAGUnitMeasureId = fromUOM.intAGUnitMeasureId
	LEFT JOIN tblAGUnitMeasure toUOM
		ON toUOM.intAGUnitMeasureId = uc.intStockUnitMeasureId
