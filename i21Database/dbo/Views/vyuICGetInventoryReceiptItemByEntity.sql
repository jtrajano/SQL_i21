CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemByEntity]
AS
SELECT ReceiptItem.intInventoryReceiptId
	, ReceiptItem.intInventoryReceiptItemId
	, Receipt.strReceiptNumber
	, Receipt.strReceiptType
	, Receipt.strLocationName
	, Receipt.strSourceType
	, Receipt.dtmReceiptDate
	, Receipt.strVendorId
	, Receipt.strVendorName
	, Receipt.strBillOfLading
	, Receipt.ysnPosted
	, ReceiptItem.intLineNo
	, ReceiptItemSource.intOrderId
	, ReceiptItemSource.strOrderNumber
	, ReceiptItemSource.dtmDate
	, ReceiptItemSource.dblOrdered
	, ReceiptItemSource.dblReceived
	, ReceiptItem.intSourceId
	, ReceiptItemSource.strSourceNumber
	, ReceiptItem.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, dblQtyToReceive = ReceiptItem.dblOpenReceive
	, intLoadToReceive = ReceiptItem.intLoadReceive
	, ReceiptItem.dblUnitCost
	, ReceiptItem.dblTax
	, ReceiptItem.dblLineTotal
	, dblGrossWgt = ReceiptItem.dblGross
	, dblNetWgt = ReceiptItem.dblNet
	, Item.strLotTracking
	, Item.intCommodityId

	, ReceiptItem.intContainerId
	, ReceiptItemSource.strContainer
	, ReceiptItem.intSubLocationId
	, SubLocation.strSubLocationName
	, SubLocation.strSubLocationDescription
	, ReceiptItem.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, StorageUnitType.strStorageUnitType
	, strOrderUOM = ReceiptItemSource.strUnitMeasure
	, dblOrderUOMConvFactor = ISNULL(ReceiptItemSource.dblUnitQty, 0)
	, strUnitMeasure = UOM.strUnitMeasure
	, strUnitType = UOM.strUnitType
	, strWeightUOM = WeightUOM.strUnitMeasure
	, dblItemUOMConvFactor = ISNULL(ItemUOM.dblUnitQty, 0)
	, dblWeightUOMConvFactor = ISNULL(ItemWeightUOM.dblUnitQty, 0)
	, strCostUOM = CostUOM.strUnitMeasure
	, dblCostUOMConvFactor = ISNULL(ItemCostUOM.dblUnitQty, 0)
	, ReceiptItem.ysnSubCurrency
	, strSubCurrency = SubCurrency.strCurrency
	, dblGrossMargin = (
		CASE	WHEN ISNULL(dblUnitRetail, 0) = 0 THEN 0
				ELSE ((ISNULL(dblUnitRetail, 0) - ISNULL(dblUnitCost, 0)) / dblUnitRetail) * 100 END
	)
	, ReceiptItem.intGradeId
	, ReceiptItem.dblBillQty
	, strGrade = Grade.strDescription
	, Item.intLifeTime
	, Item.strLifeTimeType
	, ReceiptItemSource.ysnLoad
	, ReceiptItemSource.dblAvailableQty
	, ReceiptItem.intDiscountSchedule
	, strDiscountSchedule = DiscountSchedule.strDiscountId
	, ReceiptItem.ysnExported
	, ReceiptItem.dtmExportedDate
	, ReceiptItemSource.dblFranchise
	, ReceiptItemSource.dblContainerWeightPerQty
	, Receipt.strVendorRefNo
	, Receipt.strShipFromEntity
	, Receipt.strShipFrom
	, Receipt.intCurrencyId
	, Receipt.strCurrency 
	, Item.ysnLotWeightsRequired
	, ReceiptItemSource.strFieldNo
	, Receipt.strBook
	, Receipt.strSubBook
	, ItemLocation.ysnStorageUnitRequired
	, ItemLocation.intLocationId
	, intShipToLocationId = Receipt.intLocationId
	, ReceiptItemSource.intContractSeq
	, ReceiptItemSource.strERPPONumber
	, ReceiptItemSource.strERPItemNumber
	, ReceiptItemSource.strOrigin
	, ReceiptItemSource.strPurchasingGroup
	, ReceiptItemSource.strINCOShipTerm
	, Commodity.strCommodityCode
	, Commodity.strDescription strCommodity
	, Category.strCategoryCode
	, Category.strDescription strCategory
	, Category.intCategoryId
	, permission.intEntityContactId
	, dblPendingVoucherQty = ISNULL(ReceiptItem.dblOpenReceive, 0) - ISNULL(ReceiptItem.dblBillQty, 0) 
	, strVoucherNo = voucher.strBillId
	, Receipt.intBookId
	, Receipt.intSubBookId
FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN vyuICGetInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ReceiptItem.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ReceiptItem.intStorageLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = ReceiptItem.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = ReceiptItem.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ReceiptItem.intGradeId
	LEFT JOIN tblGRDiscountId DiscountSchedule ON DiscountSchedule.intDiscountId = ReceiptItem.intDiscountSchedule
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = Receipt.intCurrencyId
	LEFT JOIN tblICStorageUnitType StorageUnitType ON StorageUnitType.intStorageUnitTypeId = StorageLocation.intStorageUnitTypeId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = Receipt.intLocationId AND ReceiptItem.intItemId = ItemLocation.intItemId
	CROSS APPLY (
		SELECT ec.intEntityId, ec.intEntityContactId
		FROM tblEMEntityToContact ec
			INNER JOIN tblEMEntity e ON e.intEntityId = ec.intEntityContactId
			INNER JOIN tblEMEntityLocation el ON el.intEntityLocationId = ec.intEntityLocationId
				AND el.intEntityId = ec.intEntityId
		WHERE ec.ysnPortalAccess = 1
	) permission
	CROSS APPLY (
		SELECT TOP 1 sl.intCompanyLocationSubLocationId
		FROM tblSMCompanyLocationSubLocation sl
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intSubLocationId = sl.intCompanyLocationSubLocationId
				AND ri.intInventoryReceiptId = Receipt.intInventoryReceiptId
		WHERE sl.intCompanyLocationId = Receipt.intLocationId
			AND sl.intVendorId = permission.intEntityId
	) accessibleReceipts
	OUTER APPLY (
		SELECT TOP 1 
			b.strBillId
		FROM 
			tblAPBill b 
			INNER JOIN tblAPBillDetail bd
				ON b.intBillId = bd.intBillId
		WHERE
			bd.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId

	) voucher
WHERE Receipt.strReceiptType = 'Purchase Contract'
	AND Receipt.intSourceType = 2