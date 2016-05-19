CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher]
	AS 

SELECT 
	ReceiptItem.intInventoryReceiptId
	, ReceiptItem.intInventoryReceiptItemId
	, strVendorId + ' ' + strVendorName strVendor
	, ReceiptItem.strLocationName
	, ReceiptItem.strReceiptNumber
	, ReceiptItem.dtmReceiptDate
	, ReceiptItem.strBillOfLading
	, ReceiptItem.strReceiptType
	, ReceiptItem.strOrderNumber
	, ReceiptItem.strItemDescription
	, ReceiptItem.dblUnitCost
	, ReceiptItem.dblQtyToReceive
	, ReceiptItem.dblLineTotal
	, ISNULL(ReceiptItem.dblBillQty,0) dblQtyVouchered
	, ISNULL(ReceiptItem.dblBillQty,0) dblVoucherAmount
	, (ReceiptItem.dblQtyToReceive - ISNULL(ReceiptItem.dblBillQty,0)) dblQtyToVoucher
	, dblAmountToVoucher =
	  CASE
		WHEN ReceiptItem.dblQtyToReceive = 0
		THEN 0
		ELSE (ReceiptItem.dblLineTotal/ReceiptItem.dblQtyToReceive)*(ReceiptItem.dblQtyToReceive - ISNULL(ReceiptItem.dblBillQty,0))
	  END
	, strBillId = ISNULL(Bill.strBillId, 'New Voucher')
	, Bill.dtmBillDate
	, Bill.intBillId
FROM vyuICGetInventoryReceiptItem ReceiptItem
	LEFT JOIN (
		SELECT DISTINCT strBillId
			, dtmBillDate
			, intInventoryReceiptItemId
			, Detail.intBillId
		FROM tblAPBillDetail Detail
			LEFT JOIN tblAPBill Header ON Header.intBillId = Detail.intBillId
		WHERE ISNULL(intInventoryReceiptItemId, '') <> ''
	) Bill ON Bill.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
WHERE ReceiptItem.ysnPosted = 1 