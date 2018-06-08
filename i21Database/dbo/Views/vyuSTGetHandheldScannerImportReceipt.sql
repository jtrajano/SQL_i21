CREATE VIEW [dbo].[vyuSTGetHandheldScannerImportReceipt]
	AS

SELECT IR.intHandheldScannerImportReceiptId
	, IR.intHandheldScannerId
	, HS.intStoreId
	, Store.intStoreNo
	, Store.intCompanyLocationId
	, IR.strVendorComment
	, IR.intVendorId
	, Vendor.strVendorId
	, Entity.strName
	, IR.strReceiptSequence
	, IR.strUPCNo
	, IR.intItemId
	, Item.strItemNo
	, strDescription = CASE WHEN ISNULL(IR.intItemId, '') != '' THEN Item.strDescription ELSE 'UPC Not Found!' END
	, ItemLoc.intItemLocationId
	, ItemUOM.intItemUOMId
	, strUnitMeasure = CASE WHEN ISNULL(ItemUOM.intItemUOMId, '') != '' THEN UOM.strUnitMeasure ELSE 'UPC Not Found!' END
	, IR.dtmReceiptDate
	, IR.dblReceivedQty
	, IR.dblCaseCost
	, IR.dblUnitRetail
	, IR.strCostChange
	, IR.strRetailChange
FROM tblSTHandheldScannerImportReceipt IR
LEFT JOIN tblSTHandheldScanner HS ON HS.intHandheldScannerId = IR.intHandheldScannerId
LEFT JOIN tblSTStore Store ON Store.intStoreId = HS.intStoreId
LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityId = IR.intVendorId
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = Vendor.intEntityId
LEFT JOIN tblICItem Item ON Item.intItemId = IR.intItemId
LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = IR.intItemId AND ItemLoc.intLocationId = Store.intCompanyLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = IR.intItemId AND ItemUOM.strLongUPCCode = strUPCNo
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId