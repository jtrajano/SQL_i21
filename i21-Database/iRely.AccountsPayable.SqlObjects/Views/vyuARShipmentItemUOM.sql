CREATE VIEW dbo.vyuARShipmentItemUOM
AS
SELECT     
A.intItemUOMId, 
A.intItemId, 
B.strUnitMeasure,
A.intItemUOMId AS intShipmentItemUOMId
FROM dbo.tblICItemUOM AS A INNER JOIN
dbo.tblICUnitMeasure AS B ON A.intUnitMeasureId = B.intUnitMeasureId