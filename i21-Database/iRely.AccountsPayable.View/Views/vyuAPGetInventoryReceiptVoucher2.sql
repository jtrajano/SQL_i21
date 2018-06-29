CREATE VIEW [dbo].[vyuAPGetInventoryReceiptVoucher2]
AS 

SELECT		
		t.intId
		,t.intInventoryRecordId
		,t.intInventoryRecordItemId
		,t.intInventoryRecordChargeId
		,t.dtmRecordDate
		,t.strVendor
		,t.strLocationName
		,t.strRecordNumber
		,t.strBillOfLading
		,t.strOrderType
		,t.strRecordType
		,t.strOrderNumber
		,t.strItemNo
		,t.strItemDescription
		,dblUnitCost = ROUND(t.dblUnitCost, 6)
		,dblRecordQty = ROUND(t.dblRecordQty, 6)
		,dblVoucherQty = ROUND(t.dblVoucherQty, 6)
		,dblRecordLineTotal = CAST( ROUND(t.dblRecordLineTotal, 6) AS NUMERIC(18, 6))
		,dblVoucherLineTotal = CAST( ROUND(t.dblVoucherLineTotal, 6) AS NUMERIC(18, 6))
		,dblRecordTax = ROUND(t.dblRecordTax, 6)
		,dblVoucherTax = ROUND(t.dblVoucherTax, 6)
		,dblOpenQty = ROUND(t.dblOpenQty, 6)
		,dblItemsPayable = CAST( ROUND(t.dblItemsPayable, 6) AS NUMERIC(18, 6))
		,dblTaxesPayable = CAST( ROUND(t.dblTaxesPayable, 6) AS NUMERIC(18, 6))
		,t.dtmLastVoucherDate
		,t.strAllVouchers
		,t.dtmCreated
		,t.intCurrencyId
		,t.strCurrency		
		,t.strContainerNumber 
		,t.intLoadContainerId
		,t.strItemUOM
		,t.intItemUOMId
		,t.strCostUOM
		,t.intCostUOMId
		,t.strFilterString
FROM	tblAPSearchRecordVoucher t
GO


