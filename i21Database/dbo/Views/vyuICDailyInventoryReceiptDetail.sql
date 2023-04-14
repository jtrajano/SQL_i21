CREATE VIEW [dbo].[vyuICDailyInventoryReceiptDetail]
AS

SELECT 
	Receipt.intInventoryReceiptId
	, Receipt.strReceiptNumber
	, Receipt.strReceiptType
	, Receipt.strBook
	, Item.strItemNo
	, Item.strDescription
	, Category.strCategoryCode
	, Commodity.strCommodityCode
	, Commodity.intCommodityId
	, Category.intCategoryId	
	, ReceiptItemSource.strOrderNumber
	, ReceiptItemSource.strSourceNumber
	, Receipt.strCurrency
	, strReceiptUOM = UOM.strUnitMeasure
	, dblReceiptQty = ReceiptItem.dblOpenReceive
	, dblPendingVoucherQty = ISNULL(ReceiptItem.dblOpenReceive, 0) - ISNULL(ReceiptItem.dblBillQty, 0) 
	, strVoucherNo = voucher.strBillId
	, dblCost = ReceiptItem.dblUnitCost
	, dblTax = ReceiptItem.dblTax
	, dblLineTotal = ReceiptItem.dblLineTotal
	, strCostUOM = CostUOM.strUnitMeasure
	, Receipt.dtmReceiptDate
	, Receipt.strVendorName
	, Receipt.strLocationName
	, Receipt.strBillOfLading
	, Receipt.ysnPosted
	, Receipt.strVendorRefNo
	, Receipt.strSubBook
	, Receipt.strShipFromEntity
	, Receipt.strShipFrom
	, Receipt.strSourceType
	, strSubLocation = SubLocation.strSubLocationName
	, ReceiptItemSource.intContractSeq
	, ReceiptItemSource.strERPPONumber
	, ReceiptItemSource.strERPItemNumber
	, ReceiptItemSource.strOrigin
	, ReceiptItemSource.strContainer


FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN vyuICGetInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ReceiptItem.intSubLocationId	
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId	
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = ReceiptItem.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId	
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = Receipt.intCurrencyId	
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = Receipt.intLocationId AND ReceiptItem.intItemId = ItemLocation.intItemId
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
