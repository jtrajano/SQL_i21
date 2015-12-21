CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT R.intRecipeId
	 , R.intItemId
     , RI.intItemId AS intComponentItemId	 
	 , I.strItemNo
	 , I.strDescription	 
	 , RI.intItemUOMId AS intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , RI.dblQuantity
	 , dblPrice = ISNULL(dbo.fnARGetItemPrice(RI.intItemId, R.intCustomerId, R.intLocationId, RI.intItemUOMId, NULL, RI.dblQuantity, NULL, NULL, NULL, NULL, RI.dblQuantity, 0, NULL, NULL, NULL, NULL, NULL), 0)
	 , strItemType = (SELECT TOP 1 strType FROM tblICItem WHERE intItemId = RI.intItemId)
	 , strType = 'Finished Good'
FROM tblICItem I 
INNER JOIN (tblMFRecipe R INNER JOIN tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId) ON I.intItemId = RI.intItemId
INNER JOIN vyuARItemUOM UOM ON RI.intItemUOMId = UOM.intItemUOMId
  AND R.ysnActive = 1
  AND RI.intRecipeItemTypeId = 1  

UNION ALL

SELECT intRecipeId = NULL
	 , I.intItemId
     , IB.intBundleItemId AS intComponentItemId	 
	 , I.strItemNo
	 , IB.strDescription	 
	 , IB.intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , IB.dblQuantity
	 , dblPrice = 0 -- Removed Price field from Bundle Components
	 , strItemType = 'Inventory'
	 , strType = 'Bundle'
FROM tblICItemBundle IB
INNER JOIN tblICItem I ON IB.intItemId = I.intItemId
INNER JOIN vyuARItemUOM UOM ON IB.intItemUnitMeasureId = UOM.intItemUOMId