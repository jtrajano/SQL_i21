CREATE VIEW [dbo].[vyuARItemWUOM]
AS
SELECT     
A.intItemUOMId,  
A.intItemId, 
B.strUnitMeasure, 
A.intItemUOMId intItemWeightUOMId
FROM dbo.tblICItemUOM AS A 
INNER JOIN (SELECT intUnitMeasureId, strUnitMeasure 
			FROM dbo.tblICUnitMeasure) AS B ON A.intUnitMeasureId = B.intUnitMeasureId
