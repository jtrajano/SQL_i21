CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT R.intRecipeId
	 , R.intItemId
	 , intCompanyLocationId		= I.intLocationId
     , intComponentItemId		= RI.intItemId
	 , I.strItemNo
	 , I.strDescription	 
	 , intItemUnitMeasureId		= RI.intItemUOMId
	 , strUnitMeasure			= UM.strUnitMeasure
	 , RI.dblQuantity
	 , dblNewQuantity			= RI.dblQuantity
	 , dblAvailableQuantity		= I.dblAvailable	 
	 , dblPrice					= dbo.fnICConvertUOMtoStockUnit(RI.intItemId, RI.intItemUOMId, 1) * I.dblSalePrice
	 , dblNewPrice				= dbo.fnICConvertUOMtoStockUnit(RI.intItemId, RI.intItemUOMId, 1) * I.dblSalePrice	 
	 , strItemType				= I.strType
	 , strType					= 'Finished Good'
	 , ysnAllowNegativeStock	= CASE WHEN I.intAllowNegativeInventory = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	 
	 , dblUnitQty				= UM.dblUnitQty 
FROM 
	(SELECT intLocationId, intItemId, strItemNo, strType, strDescription, dblAvailable, intAllowNegativeInventory, dblSalePrice FROM vyuICGetItemStock WITH (NOLOCK)) I 
INNER JOIN (
			(SELECT intItemId, intRecipeId, ysnActive FROM tblMFRecipe WITH (NOLOCK)) R 
			INNER JOIN 
				(SELECT intItemId, intRecipeId, dblQuantity, intItemUOMId, intRecipeItemTypeId FROM tblMFRecipeItem  WITH (NOLOCK)) RI ON R.intRecipeId = RI.intRecipeId) ON I.intItemId = RI.intItemId
INNER JOIN (SELECT intItemUOMId, strUnitMeasure, dblUnitQty FROM vyuARItemUOM WITH (NOLOCK)) UM ON RI.[intItemUOMId] = UM.intItemUOMId
  AND R.ysnActive = 1
  AND RI.intRecipeItemTypeId = 1          

UNION ALL

SELECT intRecipeId				= NULL
	 , IB.intItemId
	 , intCompanyLocationId		= I.intLocationId
     , intComponentItemId		= IB.intBundleItemId
	 , I.strItemNo
	 , IB.strDescription	 
	 , IB.intItemUnitMeasureId
	 , UOM.strUnitMeasure
	 , IB.dblQuantity
	 , dblNewQuantity			= IB.dblQuantity
	 , dblAvailableQuantity		= I.dblAvailable
	 , dblPrice					= dbo.fnICConvertUOMtoStockUnit(IB.intBundleItemId, IB.intItemUnitMeasureId, 1) * I.dblSalePrice
	 , dblNewPrice				= dbo.fnICConvertUOMtoStockUnit(IB.intBundleItemId, IB.intItemUnitMeasureId, 1) * I.dblSalePrice
	 , strItemType				= 'Inventory'
	 , strType					= 'Bundle'
	 , ysnAllowNegativeStock	= CONVERT(BIT, 0)
	 , dblUnitQty				= UOM.dblUnitQty
FROM 
	(SELECT intBundleItemId, intItemId, strDescription, intItemUnitMeasureId, dblQuantity FROM tblICItemBundle WITH (NOLOCK)) IB
INNER JOIN 
	(SELECT intItemId, strItemNo, intLocationId, dblSalePrice, dblAvailable FROM vyuICGetItemStock WITH (NOLOCK)) I ON IB.intBundleItemId = I.intItemId
INNER JOIN 
	(SELECT intItemUOMId, strUnitMeasure, dblUnitQty FROM vyuARItemUOM  WITH (NOLOCK)) UOM ON IB.intItemUnitMeasureId = UOM.intItemUOMId