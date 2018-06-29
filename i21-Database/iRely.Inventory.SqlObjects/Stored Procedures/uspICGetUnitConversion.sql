/*
	This sp returns the converion of a Unit Measure id to another Unit Measure Id. 
*/

CREATE PROCEDURE [dbo].[uspICGetUnitConversion]
	@fromUnitMeasureId AS INT 
	,@toUnitMeasureId AS INT 
	,@result AS NUMERIC(38,20) OUTPUT 
AS

SELECT	TOP 1 
		@result = dblConversionToStock 
FROM	tblICUnitMeasureConversion UOMConversion
WHERE	intUnitMeasureId = @fromUnitMeasureId
		AND intStockUnitMeasureId = @toUnitMeasureId
