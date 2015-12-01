CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT R.intRecipeId
	 , R.intItemId
     , RI.intItemId				AS intComponentItemId	 
	 , I.strItemNo
	 , I.strDescription	 
	 , RI.intUOMId				AS intItemUnitMeasureId
	 , UM.strUnitMeasure		AS strUnitMeasure
	 , RI.dblQuantity
	 , RI.dblQuantity			AS dblNewQuantity
	 , I.dblAvailable			AS dblAvailableQuantity
	 , RI.dblQuantity * I.dblSalePrice			AS dblPrice
	 , RI.dblQuantity * I.dblSalePrice			AS dblNewPrice
	 , I.strType				AS strItemType
	 , 'Finished Good'			AS strType
	 , ysnAllowNegativeStock	= CASE WHEN I.intAllowNegativeInventory = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM vyuICGetItemStock I 
INNER JOIN (tblMFRecipe R INNER JOIN tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId) ON I.intItemId = RI.intItemId
INNER JOIN tblICUnitMeasure UM ON RI.intUOMId = UM.intUnitMeasureId
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
INNER JOIN tblICUnitMeasure UOM ON IB.intItemUnitMeasureId = UOM.intUnitMeasureId