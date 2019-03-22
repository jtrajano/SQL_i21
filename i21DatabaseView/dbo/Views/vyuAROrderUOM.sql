CREATE VIEW dbo.vyuAROrderUOM
AS
SELECT     
A.intItemUOMId, 
A.intItemId, 
B.strUnitMeasure,
A.intItemUOMId AS intOrderUOMId
FROM dbo.tblICItemUOM AS A INNER JOIN
dbo.tblICUnitMeasure AS B ON A.intUnitMeasureId = B.intUnitMeasureId