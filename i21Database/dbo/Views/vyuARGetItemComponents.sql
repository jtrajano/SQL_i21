CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT R.intRecipeId
	 , R.intItemId
     , intComponentItemId		= RI.intItemId
	 , I.strItemNo
	 , I.strDescription	 
	 , intItemUnitMeasureId		= RI.intItemUOMId
	 , strUnitMeasure			= UM.strUnitMeasure
	 , RI.dblQuantity
	 , dblNewQuantity			= RI.dblQuantity
	 , dblAvailableQuantity		= I.dblAvailable
	 , dblPrice					= dbo.fnICConvertUOMtoStockUnit(RI.intItemId, RI.intItemUOMId, RI.dblQuantity) * I.dblSalePrice
	 , dblNewPrice				= dbo.fnICConvertUOMtoStockUnit(RI.intItemId, RI.intItemUOMId, RI.dblQuantity) * I.dblSalePrice 
	 , strItemType				= I.strType
	 , strType					= 'Finished Good'
	 , ysnAllowNegativeStock	= CASE WHEN I.intAllowNegativeInventory = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM vyuICGetItemStock I 
INNER JOIN (tblMFRecipe R INNER JOIN tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId) ON I.intItemId = RI.intItemId
INNER JOIN vyuARItemUOM UM ON RI.[intItemUOMId] = UM.intItemUOMId
  AND R.ysnActive = 1
  AND RI.intRecipeItemTypeId = 1          

UNION ALL

SELECT intRecipeId			= NULL
	 , IB.intItemId
     , intComponentItemId	= IB.intBundleItemId
	 , I.strItemNo
	 , IB.strDescription	 
	 , IB.intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , IB.dblQuantity
	 , dblNewQuantity		= IB.dblQuantity
	 , dblAvailableQuantity = 0.000000
	 , dblPrice				= 0
	 , dblNewPrice			= 0
	 , strItemType			= 'Inventory'
	 , strType				= 'Bundle'
	 , ysnAllowNegativeStock = CONVERT(BIT, 0)
FROM tblICItemBundle IB
INNER JOIN vyuICGetItemStock I ON IB.intBundleItemId = I.intItemId
INNER JOIN vyuARItemUOM UOM ON IB.intItemUnitMeasureId = UOM.intItemUOMId