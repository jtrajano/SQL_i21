CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher]
	AS 

SELECT strVendorId + ' ' + strVendorName "Vendor"
	, ReceiptItem.strLocationName Destination
	, ReceiptItem.strReceiptNumber "Receipt No"
	, ReceiptItem.dtmReceiptDate "Receipt Date"
	, ReceiptItem.strBillOfLading BOL
	, ReceiptItem.strReceiptType "Receipt Type"
	, ReceiptItem.strOrderNumber "Order No"
	, ReceiptItem.strItemDescription Product
	, ReceiptItem.dblUnitCost "Unit Cost"
	, ReceiptItem.dblQtyToReceive "Qty Received"
	, ReceiptItem.dblLineTotal "Receipt Amount"
	, ISNULL(ReceiptItem.dblBillQty,0) "Qty Vouchered"
	, ISNULL(ReceiptItem.dblBillQty,0) "Voucher Amount"
	, (ReceiptItem.dblQtyToReceive - ISNULL(ReceiptItem.dblBillQty,0)) "Qty to Voucher"
	, ((ReceiptItem.dblLineTotal/ReceiptItem.dblQtyToReceive)*(ReceiptItem.dblQtyToReceive - ISNULL(ReceiptItem.dblBillQty,0))) "Amount to Voucher"
FROM vyuICGetInventoryReceiptItem ReceiptItem
WHERE ReceiptItem.ysnPosted = 1 