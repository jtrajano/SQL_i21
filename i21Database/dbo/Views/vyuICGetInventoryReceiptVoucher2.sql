CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher2]
AS 

SELECT		
		t.intId
		,t.intInventoryReceiptId
		,t.intInventoryReceiptItemId
		,t.dtmReceiptDate
		,t.strVendor
		,t.strLocationName
		,t.strReceiptNumber
		,t.strBillOfLading
		,t.strReceiptType
		,t.strOrderNumber
		,t.strItemNo
		,t.strItemDescription
		,dblUnitCost = ROUND(t.dblUnitCost, 6)
		,dblReceiptQty = ROUND(t.dblReceiptQty, 6)
		,dblVoucherQty = ROUND(t.dblVoucherQty, 6)
		,dblReceiptLineTotal = CAST( ROUND(t.dblReceiptLineTotal, 6) AS NUMERIC(18, 6))
		,dblVoucherLineTotal = CAST( ROUND(t.dblVoucherLineTotal, 6) AS NUMERIC(18, 6))
		,dblReceiptTax = ROUND(t.dblReceiptTax, 6)
		,dblVoucherTax = ROUND(t.dblVoucherTax, 6)
		,dblOpenQty = ROUND(t.dblOpenQty, 6)
		,dblItemsPayable = CAST( ROUND(t.dblItemsPayable, 6) AS NUMERIC(18, 6))
		,dblTaxesPayable = CAST( ROUND(t.dblTaxesPayable, 6) AS NUMERIC(18, 6))
		,t.dtmLastVoucherDate
		,t.strAllVouchers
		,t.strFilterString
		,t.dtmCreated
		,t.intCurrencyId
		,t.strCurrency		
		,t.strContainerNumber 
		,t.intLoadContainerId
		,t.strItemUOM
		,t.intItemUOMId
		,t.strCostUOM
		,t.intCostUOMId
FROM	tblICSearchReceiptVoucher t 
