CREATE VIEW dbo.vyuARItemUOM
AS
SELECT     
A.intItemUOMId, 
A.intUnitMeasureId,
A.intItemId, 
B.strUnitMeasure,
A.dblUnitQty 
FROM 
	(SELECT intUnitMeasureId, intItemUOMId, intItemId, dblUnitQty FROM dbo.tblICItemUOM WITH (NOLOCK)) AS A 
INNER JOIN
	(SELECT intUnitMeasureId, strUnitMeasure FROM dbo.tblICUnitMeasure WITH (NOLOCK)) AS B ON A.intUnitMeasureId = B.intUnitMeasureId