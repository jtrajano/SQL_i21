CREATE PROCEDURE uspICUpdateInventoryReceiptDetail (
	@ReceiptId INT = NULL,
	@ForceRecalc BIT = 0
)
AS

-- Delete missing IR link
DELETE s
FROM tblICInventoryReceiptDetailSearch s
	LEFT OUTER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = s.intInventoryReceiptId
WHERE r.intInventoryReceiptId IS NULL

-- Delete outdated IRs
DELETE s
FROM tblICInventoryReceiptDetailSearch s
	INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = s.intInventoryReceiptId
WHERE COALESCE(r.dtmLastCalculateTotals, r.dtmDateModified, r.dtmDateCreated) > COALESCE(s.dtmDateModified, s.dtmDateCreated)

-- Insert missing IRs
INSERT INTO tblICInventoryReceiptDetailSearch
SELECT
      GETUTCDATE()
    , GETUTCDATE()
	, ReceiptItem.intInventoryReceiptId
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
	, ReceiptItem.intSourceId
	, ReceiptItem.intSubLocationId
	, SubLocation.strSubLocationName
	, SubLocation.strSubLocationDescription
	, ReceiptItem.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, StorageUnitType.strStorageUnitType
	, strUnitMeasure = UOM.strUnitMeasure
	, strUnitType = UOM.strUnitType
	, strWeightUOM = ''--WeightUOM.strUnitMeasure
	, dblItemUOMConvFactor = NULL--ISNULL(ItemUOM.dblUnitQty, 0)
	, dblWeightUOMConvFactor = NULL--ISNULL(ItemWeightUOM.dblUnitQty, 0)
	, strCostUOM = CostUOM.strUnitMeasure
	, dblCostUOMConvFactor = NULL--ISNULL(ItemCostUOM.dblUnitQty, 0)
	, ReceiptItem.ysnSubCurrency
	, strSubCurrency = SubCurrency.strCurrency
	, dblGrossMargin = 0
	, ReceiptItem.intGradeId
	, ReceiptItem.dblBillQty
	, strGrade = NULL --Grade.strDescription
	, Item.intLifeTime
	, Item.strLifeTimeType
	, intDiscountSchedule = NULL
	, strDiscountSchedule = NULL --DiscountSchedule.strDiscountId
	, ReceiptItem.ysnExported
	, ReceiptItem.dtmExportedDate
	, Receipt.strVendorRefNo
	, Receipt.strShipFromEntity
	, Receipt.strShipFrom
	, Receipt.intCurrencyId
	, Receipt.strCurrency 
	, Item.ysnLotWeightsRequired
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
	, dblFranchise = NULL
	, dblContainerWeightPerQty = NULL
	, ysnLoad = NULL
	, dblAvailableQty = NULL
	, strOrderUOM = ReceiptItemSource.strUnitMeasure
	, dblOrderUOMConvFactor = NULL--ISNULL(ReceiptItemSource.dblUnitQty, 0)
	, ReceiptItemSource.strContainer
	, intOrderId = NULL
	, ReceiptItemSource.strOrderNumber
	, dtmDate = NULL
	, dblOrdered = NULL
	, dblReceived = NULL
	, ReceiptItemSource.strSourceNumber
	, ReceiptItemSource.strFieldNo
	, Commodity.strCommodityCode
	, Commodity.strDescription strCommodity
	, Category.strCategoryCode
	, Category.strDescription strCategory
	, Category.intCategoryId
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM tblICInventoryReceiptItem ReceiptItem
	INNER JOIN vyuICGetInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = Receipt.intInventoryReceiptId
	LEFT JOIN vyuICGetReceiptItemSourceSearch ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	INNER JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
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
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = Receipt.intCurrencyId
	LEFT JOIN tblICStorageUnitType StorageUnitType ON StorageUnitType.intStorageUnitTypeId = StorageLocation.intStorageUnitTypeId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = Receipt.intLocationId AND ReceiptItem.intItemId = ItemLocation.intItemId
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = Receipt.intLocationId
WHERE NOT EXISTS(
	SElECT * 
	FROM tblICInventoryReceiptDetailSearch
	WHERE intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
)