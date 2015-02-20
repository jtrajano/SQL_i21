CREATE VIEW [dbo].[vyuICGetUOMConversion]
	AS 

SELECT 
	UOMConvert.intUnitMeasureConversionId,
	UOMConvert.intUnitMeasureId,
	strUnitMeasure = (SELECT strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = UOMConvert.intUnitMeasureId),
	UOMConvert.intStockUnitMeasureId,
	strStockUOM = (SELECT strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = UOMConvert.intStockUnitMeasureId),
	UOMConvert.dblConversionToStock
FROM tblICUnitMeasureConversion UOMConvert
