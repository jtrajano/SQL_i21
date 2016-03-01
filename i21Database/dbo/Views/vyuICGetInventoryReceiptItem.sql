﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptItem]
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
	, ReceiptItem.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
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
	--, ReceiptItem.intCurrencyId
	--, Currency.strCurrency
	--, ReceiptItem.intCent
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
FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN vyuICGetInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
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
	--LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ReceiptItem.intCurrencyId