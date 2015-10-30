﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptItem]
	AS

SELECT ReceiptItem.intInventoryReceiptId
	, ReceiptItem.intInventoryReceiptItemId
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
	, Item.strLotTracking
	, Item.intCommodityId
	, ReceiptItem.intTaxGroupId
	, TaxGroup.strTaxGroup
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
	, dblGrossMargin = (
		CASE WHEN ISNULL(dblUnitRetail, 0) = 0 THEN 0
			ELSE ((ISNULL(dblUnitRetail, 0) - ISNULL(dblUnitCost, 0)) / dblUnitRetail) * 100 END
	)
	, ReceiptItem.intGradeId
	, strGrade = Grade.strDescription
	, Item.intLifeTime
	, Item.strLifeTimeType
FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ReceiptItem.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ReceiptItem.intStorageLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = ReceiptItem.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ReceiptItem.intGradeId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ReceiptItem.intTaxGroupId