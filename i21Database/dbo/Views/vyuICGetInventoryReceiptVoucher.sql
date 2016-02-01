﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher]
	AS 

SELECT strVendorId + ' ' + strVendorName strVendor
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
	, ((ReceiptItem.dblLineTotal/ReceiptItem.dblQtyToReceive)*(ReceiptItem.dblQtyToReceive - ISNULL(ReceiptItem.dblBillQty,0))) dblAmountToVoucher
FROM vyuICGetInventoryReceiptItem ReceiptItem
WHERE ReceiptItem.ysnPosted = 1 