CREATE VIEW [dbo].[vyuSTGetHandheldScannerImportCount]
AS
SELECT IC.intHandheldScannerImportCountId
	, IC.intHandheldScannerId
	, HS.intStoreId
	, Store.intStoreNo
	, Store.intCompanyLocationId
	, IC.strUPCNo
	, IC.intItemId
	, Item.strItemNo
	, strDescription = CASE 
							WHEN ISNULL(IC.intItemId, '') != '' 
								THEN Item.strDescription 
							ELSE 'UPC Not Found!' 
					END
	--, ItemUOM.intItemUOMId
	, intItemUOMId = CASE
						WHEN ISNULL(ItemUOM.intItemUOMId, '') != ''
							THEN ItemUOM.intItemUOMId
						WHEN ISNULL(IC.intItemId, '') != '' AND ISNULL(ItemUOM.intItemUOMId, '') = ''
							THEN (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = IC.intItemId AND ysnStockUnit = CAST(1 AS BIT))
						ELSE NULL
					END
	--, strUnitMeasure = CASE WHEN ISNULL(ItemUOM.intItemUOMId, '') != '' THEN UOM.strUnitMeasure ELSE 'UPC Not Found!' END
	, strUnitMeasure = CASE 
							WHEN ISNULL(ItemUOM.intItemUOMId, '') != '' 
								THEN UOM.strUnitMeasure 
							WHEN ISNULL(IC.intItemId, '') != '' AND ISNULL(ItemUOM.intItemUOMId, '') = '' 
								THEN (
										SELECT strUnitMeasure 
										FROM tblICUnitMeasure 
										WHERE intUnitMeasureId = (
																	SELECT intUnitMeasureId
																	FROM tblICItemUOM
																	WHERE intItemId = IC.intItemId 
																	AND ysnStockUnit = CAST(1 AS BIT)
																 )
									 )
							ELSE 'UPC Not Found!' END
	, IC.dblCountQty
	, IL.intItemLocationId
FROM tblSTHandheldScannerImportCount IC
LEFT JOIN tblSTHandheldScanner HS 
	ON HS.intHandheldScannerId = IC.intHandheldScannerId
LEFT JOIN tblSTStore Store 
	ON Store.intStoreId = HS.intStoreId
LEFT JOIN tblICItem Item 
	ON Item.intItemId = IC.intItemId
LEFT JOIN tblICItemLocation IL
	ON Item.intItemId = IL.intItemId
	AND Store.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblICItemUOM ItemUOM 
	ON ItemUOM.intItemId = Item.intItemId 
	AND ItemUOM.strLongUPCCode = IC.strUPCNo
LEFT JOIN tblICUnitMeasure UOM 
	ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId