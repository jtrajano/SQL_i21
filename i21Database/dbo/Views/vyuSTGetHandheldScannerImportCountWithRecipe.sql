CREATE VIEW [dbo].[vyuSTGetHandheldScannerImportCountWithRecipe]
AS
SELECT IC.intHandheldScannerImportCountId
	, IC.intHandheldScannerId
	, HS.intStoreId
	, Store.intStoreNo
	, Store.intCompanyLocationId
	, IC.intItemId AS intHandheldItemId
	, ItemUOM.intUnitMeasureId

	--, IC.strUPCNo
	, ItemUOM.strLongUPCCode AS strUPCNo

	--, IC.intItemId
	, intItemId = CASE 
					WHEN RI.intItemId IS NOT NULL
						THEN RI.intItemId
					ELSE IC.intItemId
				  END

	--, Item.strItemNo
	, strItemNo = Item.strItemNo

	, strDescription = CASE 
						 WHEN ISNULL(IC.intItemId, '') != '' 
								THEN Item.strDescription 
							ELSE 'UPC Not Found!' 
					END

	, intItemUOMId = CASE
						WHEN ISNULL(ItemUOM.intItemUOMId, '') != ''
							THEN ItemUOM.intItemUOMId
						WHEN ISNULL(IC.intItemId, '') != '' AND ISNULL(ItemUOM.intItemUOMId, '') = ''
							THEN (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = IC.intItemId AND ysnStockUnit = CAST(1 AS BIT))
						ELSE NULL
					END

	, strUnitMeasure = CASE 
							WHEN UOM.intUnitMeasureId IS NOT NULL
								THEN UOM.strUnitMeasure
							ELSE 'UPC Not Found!' 
					END

	, IC.dblCountQty
	, IL.intItemLocationId

	-- Recipe
	, Recipe.intRecipeId
	, RI.intRecipeItemId
	, RI.dblCalculatedQuantity AS dblRecipeInputQty
	, RI.intRecipeItemTypeId
	, ISNULL(RI.dblCalculatedQuantity, 1) * ISNULL(IC.dblCountQty, 0) AS dblComputedCount
FROM tblSTHandheldScannerImportCount IC
INNER JOIN tblICItem HandheldItem
	ON IC.intItemId = HandheldItem.intItemId
LEFT JOIN tblSTHandheldScanner HS 
	ON HS.intHandheldScannerId = IC.intHandheldScannerId
LEFT JOIN tblSTStore Store 
	ON Store.intStoreId = HS.intStoreId

-- Recipe
LEFT JOIN tblMFRecipe Recipe
	ON Recipe.intItemId = CASE 
							WHEN HandheldItem.ysnAutoBlend = 1
								THEN IC.intItemId
							ELSE NULL
						END
LEFT JOIN tblMFRecipeItem RI
	ON Recipe.intRecipeId = RI.intRecipeId
LEFT JOIN tblICItem Item
	ON Item.intItemId = CASE 
						WHEN RI.intItemId IS NOT NULL
							THEN RI.intItemId
						ELSE IC.intItemId
					END
LEFT JOIN tblICItemLocation IL
	ON IL.intItemId = Item.intItemId
	AND Store.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblICItemUOM ItemUOM 
	ON ItemUOM.intItemId = Item.intItemId
	AND ItemUOM.ysnStockUnit = CAST(1 AS BIT)
	AND ItemUOM.intItemUOMId = CASE 
								WHEN RI.intItemUOMId IS NOT NULL
									THEN RI.intItemUOMId
								ELSE (
										SELECT intItemUOMId 
										FROM tblICItemUOM 
										WHERE strLongUPCCode COLLATE Latin1_General_CI_AS = ISNULL(IC.strUPCNo, '')
											OR CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT)) = IC.strUPCNo
									 )
							   END
LEFT JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
WHERE (RI.intRecipeItemTypeId = 1
	OR RI.intRecipeItemTypeId IS NULL)