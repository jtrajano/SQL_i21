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
	, strDescription = CASE WHEN ISNULL(IC.intItemId, '') != '' THEN Item.strDescription ELSE 'UPC Not Found!' END
	, ItemUOM.intItemUOMId
	, strUnitMeasure = CASE WHEN ISNULL(ItemUOM.intItemUOMId, '') != '' THEN UOM.strUnitMeasure ELSE 'UPC Not Found!' END
	, IC.dblCountQty
FROM tblSTHandheldScannerImportCount IC
LEFT JOIN tblSTHandheldScanner HS ON HS.intHandheldScannerId = IC.intHandheldScannerId
LEFT JOIN tblSTStore Store ON Store.intStoreId = HS.intStoreId
LEFT JOIN tblICItem Item ON Item.intItemId = IC.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.strLongUPCCode = IC.strUPCNo
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId