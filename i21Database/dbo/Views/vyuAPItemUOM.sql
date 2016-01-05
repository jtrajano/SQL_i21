CREATE VIEW [dbo].[vyuAPItemUOM]
AS
SELECT
	A.intItemUOMId
	,B.strUnitMeasure
	,B.strUnitType
	,A.dblUnitQty
	,A.ysnStockUnit
	,A.intUnitMeasureId
FROM tblICItemUOM A
INNER JOIN tblICUnitMeasure B ON A.intUnitMeasureId = B.intUnitMeasureId