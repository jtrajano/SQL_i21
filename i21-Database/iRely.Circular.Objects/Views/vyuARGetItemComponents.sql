CREATE VIEW [dbo].[vyuARGetItemComponents]
AS
SELECT intRecipeId				= RECIPE.intRecipeId
	 , intItemId				= RECIPE.intItemId
	 , intCompanyLocationId		= I.intLocationId
     , intComponentItemId		= RECIPE.intComponentId
	 , strItemNo				= I.strItemNo
	 , strDescription			= I.strDescription
	 , intItemUnitMeasureId		= RECIPE.intItemUOMId
	 , intUnitMeasureId			= UOM.intUnitMeasureId
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , dblQuantity				= RECIPE.dblQuantity
	 , dblNewQuantity			= RECIPE.dblQuantity
	 , dblAvailableQuantity		= I.dblAvailable	 
	 , dblPrice					= dbo.fnICConvertUOMtoStockUnit(RECIPE.intComponentId, RECIPE.intItemUOMId, 1) * I.dblSalePrice
	 , dblNewPrice				= dbo.fnICConvertUOMtoStockUnit(RECIPE.intComponentId, RECIPE.intItemUOMId, 1) * I.dblSalePrice	 
	 , strItemType				= I.strType
	 , strType					= 'Finished Good'
	 , ysnAllowNegativeStock	= CASE WHEN I.intAllowNegativeInventory = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	 
	 , dblUnitQty				= UOM.dblUnitQty 
	 , strVFDDocumentNumber		= RECIPE.strDocumentNo
	 , ysnAddOn					= CONVERT(BIT, 0)
	 , dblMarkUpOrDown			= 0.00
	 , dtmBeginDate				= NULL
	 , dtmEndDate				= NULL
FROM vyuICGetItemStock I WITH (NOLOCK)
INNER JOIN (
	SELECT RI.*
		 , R.intItemId
	FROM dbo.tblMFRecipe R WITH (NOLOCK)
	INNER JOIN (
		SELECT intRecipeId
			 , intComponentId = intItemId
			 , intItemUOMId
			 , strDocumentNo
			 , dblQuantity
		FROM dbo.tblMFRecipeItem WITH (NOLOCK)
		WHERE intRecipeItemTypeId = 1
	) RI ON R.intRecipeId = RI.intRecipeId
	WHERE R.ysnActive = 1
) RECIPE ON I.intItemId = RECIPE.intComponentId
INNER JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , strUnitMeasure
		 , dblUnitQty
	FROM dbo.vyuARItemUOM
) UOM ON RECIPE.intItemUOMId = UOM.intItemUOMId

UNION ALL

SELECT intRecipeId				= NULL
	 , intItemId				= BUNDLE.intItemId
	 , intCompanyLocationId		= I.intLocationId
     , intComponentItemId		= BUNDLE.intBundleItemId
	 , strItemNo				= I.strItemNo
	 , strDescription			= BUNDLE.strDescription	 
	 , intItemUnitMeasureId		= BUNDLE.intItemUnitMeasureId
	 , intUnitMeasureId			= UOM.intUnitMeasureId
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , dblQuantity				= BUNDLE.dblQuantity
	 , dblNewQuantity			= BUNDLE.dblQuantity
	 , dblAvailableQuantity		= I.dblAvailable
	 , dblPrice					= dbo.fnICConvertUOMtoStockUnit(BUNDLE.intBundleItemId, BUNDLE.intItemUnitMeasureId, 1) * I.dblSalePrice
	 , dblNewPrice				= dbo.fnICConvertUOMtoStockUnit(BUNDLE.intBundleItemId, BUNDLE.intItemUnitMeasureId, 1) * I.dblSalePrice
	 , strItemType				= 'Inventory'
	 , strType					= 'Bundle'
	 , ysnAllowNegativeStock	= CONVERT(BIT, 0)
	 , dblUnitQty				= UOM.dblUnitQty
	 , strVFDDocumentNumber		= NULL
	 , ysnAddOn					= CONVERT(BIT, BUNDLE.ysnAddOn)
	 , dblMarkUpOrDown			= ISNULL(BUNDLE.dblMarkUpOrDown, 0)
	 , dtmBeginDate				= BUNDLE.dtmBeginDate
	 , dtmEndDate				= BUNDLE.dtmEndDate
FROM dbo.tblICItemBundle BUNDLE WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , intLocationId
		 , strItemNo
		 , dblAvailable
		 , dblSalePrice
	FROM dbo.vyuICGetItemStock WITH (NOLOCK)
) I ON BUNDLE.intBundleItemId = I.intItemId
INNER JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , strUnitMeasure
		 , dblUnitQty
	FROM dbo.vyuARItemUOM WITH (NOLOCK)
) UOM ON BUNDLE.intItemUnitMeasureId = UOM.intItemUOMId