CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher2]
AS 

SELECT		
		intId
		,intInventoryReceiptId
		,intInventoryReceiptItemId
		,dtmReceiptDate
		,strVendor
		,strLocationName
		,strReceiptNumber
		,strBillOfLading
		,strReceiptType
		,strOrderNumber
		,strItemNo
		,strItemDescription
		,dblUnitCost = ROUND(dblUnitCost, 6)
		,dblReceiptQty = ROUND(dblReceiptQty, 6)
		,dblVoucherQty = ROUND(dblVoucherQty, 6)
		,dblReceiptLineTotal = CAST( ROUND(dblReceiptLineTotal, 6) AS NUMERIC(18, 6))
		,dblVoucherLineTotal = CAST( ROUND(dblVoucherLineTotal, 6) AS NUMERIC(18, 6))
		,dblReceiptTax = ROUND(dblReceiptTax, 6)
		,dblVoucherTax = ROUND(dblVoucherTax, 6)
		,dblOpenQty = ROUND(dblOpenQty, 6)
		,dblItemsPayable = CAST( ROUND(dblItemsPayable, 6) AS NUMERIC(18, 6))
		,dblTaxesPayable = CAST( ROUND(dblTaxesPayable, 6) AS NUMERIC(18, 6))
		,dtmLastVoucherDate
		,strAllVouchers
		,strFilterString
		,dtmCreated
		,intCurrencyId
		,strCurrency
FROM	tblICSearchReceiptVoucher	