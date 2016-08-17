CREATE VIEW dbo.vyuARItemUOM
AS
SELECT     
A.intItemUOMId, 
A.intUnitMeasureId,
A.intItemId, 
B.strUnitMeasure,
A.dblUnitQty 
FROM dbo.tblICItemUOM AS A INNER JOIN
dbo.tblICUnitMeasure AS B ON A.intUnitMeasureId = B.intUnitMeasureId