CREATE VIEW [dbo].[vyuAPGetInventoryReceiptVoucher2]
AS 

SELECT		
		t.intId
		,t.intInventoryRecordId
		,t.intInventoryRecordItemId
		,t.intInventoryRecordChargeId
		,t.dtmRecordDate
		,t.strVendor COLLATE Latin1_General_CI_AS AS strVendor
		,t.strLocationName COLLATE Latin1_General_CI_AS AS strLocationName
		,t.strRecordNumber COLLATE Latin1_General_CI_AS AS strRecordNumber
		,t.strBillOfLading COLLATE Latin1_General_CI_AS AS strBillOfLading
		,t.strOrderType COLLATE Latin1_General_CI_AS AS strOrderType
		,t.strRecordType COLLATE Latin1_General_CI_AS AS strRecordType
		,t.strOrderNumber COLLATE Latin1_General_CI_AS AS strOrderNumber
		,t.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo
		,t.strItemDescription COLLATE Latin1_General_CI_AS AS strItemDescription
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
		,t.strAllVouchers COLLATE Latin1_General_CI_AS AS strAllVouchers
		,t.dtmCreated
		,t.intCurrencyId
		,t.strCurrency COLLATE Latin1_General_CI_AS AS strCurrency		
		,t.strContainerNumber COLLATE Latin1_General_CI_AS AS strContainerNumber
		,t.intLoadContainerId
		,t.strItemUOM COLLATE Latin1_General_CI_AS AS strItemUOM
		,t.intItemUOMId
		,t.strCostUOM COLLATE Latin1_General_CI_AS AS strCostUOM
		,t.intCostUOMId
		,t.strFilterString COLLATE Latin1_General_CI_AS AS strFilterString
FROM	tblAPSearchRecordVoucher t
GO


