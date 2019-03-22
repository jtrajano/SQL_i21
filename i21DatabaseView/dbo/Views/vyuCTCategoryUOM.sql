CREATE VIEW [dbo].[vyuCTCategoryUOM]
AS 
	SELECT	DISTINCT
			C.intUnitMeasureId,
			U.strUnitMeasure
	FROM	tblICCategoryUOM	C
	JOIN	tblICUnitMeasure	U	ON	U.intUnitMeasureId = C.intUnitMeasureId
