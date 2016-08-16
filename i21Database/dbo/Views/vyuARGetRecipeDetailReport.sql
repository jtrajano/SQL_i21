CREATE VIEW [dbo].[vyuARGetRecipeDetailReport]
AS 
SELECT intOneLinePrintId = ISNULL(R.intOneLinePrintId, 1)
     , R.strName	 
	 , R.ysnActive
	 , SOD.*
	 , I.strItemNo
	 , UOM.strUnitMeasure 
FROM tblSOSalesOrderDetail SOD
	INNER JOIN tblMFRecipe R ON SOD.intRecipeId = R.intRecipeId
	LEFT JOIN tblICItem I ON SOD.intItemId = I.intItemId
	LEFT JOIN vyuARItemUOM UOM ON SOD.intItemUOMId = UOM.intItemUOMId AND SOD.intItemId = UOM.intItemId
WHERE ISNULL(SOD.intRecipeId, 0) <> 0