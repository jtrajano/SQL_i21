CREATE VIEW dbo.vyuARItemUOM
AS
SELECT     
A.intItemUOMId, 
A.intItemId, 
B.strUnitMeasure
FROM dbo.tblICItemUOM AS A INNER JOIN
dbo.tblICUnitMeasure AS B ON A.intUnitMeasureId = B.intUnitMeasureId