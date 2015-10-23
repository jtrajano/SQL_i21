﻿CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT R.intItemId
     , RI.intItemId AS intComponentItemId	 
	 , I.strItemNo
	 , I.strDescription	 
	 , RI.intUOMId AS intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , RI.dblQuantity
	 , dblPrice = 0.000000
	 , strItemType = (SELECT TOP 1 strType FROM tblICItem WHERE intItemId = RI.intItemId)
	 , strType = 'Finished Good'
FROM tblICItem I 
INNER JOIN (tblMFRecipe R INNER JOIN tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId) ON I.intItemId = RI.intItemId
INNER JOIN vyuARItemUOM UOM ON RI.intUOMId = UOM.intItemUOMId
  AND R.ysnActive = 1
  AND RI.intRecipeItemTypeId = 1  

UNION ALL

SELECT I.intItemId
     , IB.intBundleItemId AS intComponentItemId	 
	 , I.strItemNo
	 , IB.strDescription	 
	 , IB.intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , IB.dblQuantity
	 , IB.dblPrice
	 , strItemType = 'Inventory'
	 , strType = 'Bundle'
FROM tblICItemBundle IB
INNER JOIN tblICItem I ON IB.intItemId = I.intItemId
INNER JOIN vyuARItemUOM UOM ON IB.intItemUnitMeasureId = UOM.intItemUOMId