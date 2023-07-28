--liquibase formatted sql

-- changeset Von:vyuICGetPackedUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetPackedUOM]
	AS

SELECT
	UOMConvert.intUnitMeasureConversionId,
	UOM.intUnitMeasureId,
	UOM.strUnitMeasure,
	UOM.strUnitType,
	UOM.strSymbol,
	UOMConvert.intStockUnitMeasureId,
	strConversionUOM = (SELECT strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = UOMConvert.intStockUnitMeasureId),
	UOMConvert.dblConversionToStock
FROM tblICUnitMeasureConversion UOMConvert
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = UOMConvert.intUnitMeasureId



