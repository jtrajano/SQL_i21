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
	 , dblAvailableQuantity		= CAST(ROUND(I.dblAvailable, 2, 0) AS NUMERIC(18,2))
	 , dblPrice					= I.dblReceiveSalePrice
	 , dblNewPrice				= I.dblReceiveSalePrice
	 , dblMaintenanceAmount		= CASE WHEN I.strType = 'Software' AND I.strMaintenanceCalculationMethod = 'Percentage' THEN I.dblReceiveSalePrice * (ISNULL(I.dblMaintenanceRate, 0) / 100) ELSE I.dblMaintenanceRate END
	 , strItemType				= I.strType
	 , strType					= 'Finished Good' COLLATE Latin1_General_CI_AS
	 , ysnAllowNegativeStock	= CASE WHEN I.intAllowNegativeInventory = 1 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END	 
	 , dblUnitQty				= UOM.dblUnitQty 
	 , strVFDDocumentNumber		= RECIPE.strDocumentNo
	 , ysnAddOn					= CONVERT(BIT, 0)
	 , dblMarkUpOrDown			= 0.00
	 , dtmBeginDate				= NULL
	 , dtmEndDate				= NULL
	 , intStorageLocationId 	= b.intStorageLocationId
	 , intSubLocationId 		= b.intSubLocationId
	 , strStorageUnit			= d.strSubLocationName
	 , strStorageLocation		= c.strName
	 , strRequired				= I.strRequired
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
LEFT JOIN tblICItemLocation b
	on I.intItemLocationId = b.intItemLocationId
LEFT JOIN tblICStorageLocation c
	on c.intStorageLocationId = b.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation d
	on d.intCompanyLocationSubLocationId = b.intSubLocationId

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
	 , dblAvailableQuantity		= CAST(ROUND(I.dblAvailable, 2, 0) AS NUMERIC(18,2))
	 , dblPrice					= ISNULL(dbo.fnICConvertUOMtoStockUnit(BUNDLE.intBundleItemId, BUNDLE.intItemUnitMeasureId, 1), 1) * I.dblSalePrice
	 , dblNewPrice				= ISNULL(dbo.fnICConvertUOMtoStockUnit(BUNDLE.intBundleItemId, BUNDLE.intItemUnitMeasureId, 1), 1) * I.dblSalePrice
	 , dblMaintenanceAmount		= CAST(0 AS NUMERIC(18, 6))
	 , strItemType				= 'Inventory'
	 , strType					= 'Bundle'
	 , ysnAllowNegativeStock	= CONVERT(BIT, 0)
	 , dblUnitQty				= UOM.dblUnitQty
	 , strVFDDocumentNumber		= NULL
	 , ysnAddOn					= CONVERT(BIT, BUNDLE.ysnAddOn)
	 , dblMarkUpOrDown			= ISNULL(BUNDLE.dblMarkUpOrDown, 0)
	 , dtmBeginDate				= BUNDLE.dtmBeginDate
	 , dtmEndDate				= BUNDLE.dtmEndDate
	 , intStorageLocationId 	= b.intStorageLocationId
	 , intSubLocationId 		= b.intSubLocationId
	 , strStorageUnit			= d.strSubLocationName
	 , strStorageLocation		= c.strName
	 , strRequired				= NULL
FROM dbo.tblICItemBundle BUNDLE WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , intLocationId
		 , intStockUOMId
		 , strItemNo
		 , dblAvailable
		 , dblSalePrice
		 , intItemLocationId
		 , intStorageLocationId
		 , intSubLocationId
	FROM dbo.vyuICGetItemStock WITH (NOLOCK)
) I ON BUNDLE.intBundleItemId = I.intItemId
INNER JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , strUnitMeasure
		 , dblUnitQty
	FROM dbo.vyuARItemUOM WITH (NOLOCK)
) UOM ON UOM.intItemUOMId = ISNULL(BUNDLE.intItemUnitMeasureId, I.intStockUOMId)
LEFT JOIN tblICItemLocation b
		on I.intItemLocationId = b.intItemLocationId
LEFT JOIN tblICStorageLocation c
	on c.intStorageLocationId = b.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation d
	on d.intCompanyLocationSubLocationId = b.intSubLocationId
INNER JOIN (
	SELECT intItemId
		 , strDescription
		 , strItemNo
		 , strType
		 , strLotTracking
		 , strBundleType
	FROM dbo.tblICItem WITH (NOLOCK)) ITEM 
	ON BUNDLE.intItemId = ITEM.intItemId
	AND ISNULL(ITEM.strBundleType, ''
) <> 'Option'

UNION ALL

SELECT intRecipeId				= NULL
	 , intItemId				= BUNDLE.intItemId
	 , intCompanyLocationId		= I.intLocationId
     , intComponentItemId		= BUNDLE.intBundleItemId
	 , strItemNo				= I.strItemNo
	 , strDescription			= I.strDescription	 
	 , intItemUnitMeasureId		= BUNDLE.intItemUnitMeasureId
	 , intUnitMeasureId			= I.intStockUOMId
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , dblQuantity				= BUNDLE.dblQuantity
	 , dblNewQuantity			= BUNDLE.dblQuantity
	 , dblAvailableQuantity		= CAST(ROUND(I.dblAvailable, 2, 0) AS NUMERIC(18,2))
	 , dblPrice					= I.dblSalePrice
	 , dblNewPrice				= I.dblSalePrice
	 , dblMaintenanceAmount		= CAST(0 AS NUMERIC(18, 6))
	 , strItemType				= 'Inventory'
	 , strType					= 'Bundle'
	 , ysnAllowNegativeStock	= CONVERT(BIT, 0)
	 , dblUnitQty				= UOM.dblUnitQty
	 , strVFDDocumentNumber		= NULL
	 , ysnAddOn					= CONVERT(BIT, BUNDLE.ysnAddOn)
	 , dblMarkUpOrDown			= ISNULL(BUNDLE.dblMarkUpOrDown, 0)
	 , dtmBeginDate				= BUNDLE.dtmBeginDate
	 , dtmEndDate				= BUNDLE.dtmEndDate
	 , intStorageLocationId 	= b.intStorageLocationId
	 , intSubLocationId 		= b.intSubLocationId
	 , strStorageUnit			= d.strSubLocationName
	 , strStorageLocation		= c.strName
	 , strRequired				= NULL
FROM dbo.tblICItemBundle BUNDLE WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , intLocationId
		 , intStockUOMId
		 , strItemNo
		 , dblAvailable
		 , dblSalePrice
		 , intItemLocationId
		 , intStorageLocationId
		 , intSubLocationId
		 , strDescription
	FROM dbo.vyuICGetItemStock WITH (NOLOCK)
) I ON BUNDLE.intBundleItemId = I.intItemId
INNER JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , strUnitMeasure
		 , dblUnitQty
	FROM dbo.vyuARItemUOM WITH (NOLOCK)
) UOM ON UOM.intItemUOMId = I.intStockUOMId
LEFT JOIN tblICItemLocation b
		on I.intItemLocationId = b.intItemLocationId
LEFT JOIN tblICStorageLocation c
	on c.intStorageLocationId = b.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation d
	on d.intCompanyLocationSubLocationId = b.intSubLocationId
INNER JOIN (
	SELECT intItemId
		 , strDescription
		 , strItemNo
		 , strType
		 , strLotTracking
		 , strBundleType
	FROM dbo.tblICItem WITH (NOLOCK)) ITEM 
	ON BUNDLE.intItemId = ITEM.intItemId
	AND ISNULL(ITEM.strBundleType, ''
) = 'Option'