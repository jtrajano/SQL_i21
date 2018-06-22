CREATE PROCEDURE [dbo].[uspAPPopulateRecordVoucher]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmCreated AS DATETIME = GETDATE()

-- Clean the contents of temp table. 
BEGIN 
	TRUNCATE TABLE [tblAPSearchRecordVoucher]
END 

-- Insert fresh data to the temp table. 
BEGIN 
	INSERT INTO [tblAPSearchRecordVoucher] (
			intInventoryRecordId
			, intInventoryRecordItemId
			, intInventoryRecordChargeId
			, dtmRecordDate
			, strVendor
			, strLocationName
			, strRecordNumber
			, strBillOfLading
			, strOrderType
			, strRecordType
			, strOrderNumber
			, strItemNo
			, strItemDescription
			, dblUnitCost
			, dblRecordQty
			, dblVoucherQty
			, dblRecordLineTotal
			, dblVoucherLineTotal
			, dblRecordTax
			, dblVoucherTax
			, dblOpenQty
			, dblItemsPayable
			, dblTaxesPayable
			, dtmLastVoucherDate
			, strAllVouchers
			, dtmCreated
			, intCurrencyId
			, strCurrency
			, intLoadContainerId
			, strContainerNumber
			, intItemUOMId
			, strItemUOM
			, intCostUOMId
			, strCostUOM
			, strFilterString
	)
	-- Insert the items: 
	SELECT	
			intInventoryRecordId
			, intInventoryRecordItemId
			, intInventoryRecordChargeId
			, dtmRecordDate
			, strVendor = vendor.strVendorId + ' ' + entity.strName
			, strLocationName
			, strRecordNumber
			, strBillOfLading
			, strOrderType
			, strRecordType
			, strOrderNumber
			, strItemNo
			, strItemDescription
			, dblUnitCost
			, dblRecordQty
			, dblVoucherQty
			, dblRecordLineTotal
			, dblVoucherLineTotal
			, dblRecordTax
			, dblVoucherTax
			, dblOpenQty
			, dblItemsPayable
			, dblTaxesPayable
			, dtmLastVoucherDate
			, strAllVouchers
			, dtmCreated = @dtmCreated
			, receiptItem.intCurrencyId
			, receiptItem.strCurrency
			, receiptItem.intLoadContainerId
			, receiptItem.strContainerNumber
			, receiptItem.intItemUOMId
			, receiptItem.strItemUOM
			, receiptItem.intCostUOMId
			, receiptItem.strCostUOM
			, strFilterString
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuAPGetInventoryReceiptVoucherItems items
				WHERE	items.intEntityVendorId = vendor.intEntityId
			) receiptItem

	-- Insert the price down charges (against the receipt vendor)
	UNION ALL 
	SELECT	
			intInventoryRecordId
			, intInventoryRecordItemId
			, intInventoryRecordChargeId
			, dtmRecordDate
			, strVendor = vendor.strVendorId + ' ' + entity.strName
			, strLocationName
			, strRecordNumber
			, strBillOfLading
			, strOrderType
			, strRecordType
			, strOrderNumber
			, strItemNo
			, strItemDescription
			, dblUnitCost
			, dblRecordQty
			, dblVoucherQty
			, dblRecordLineTotal
			, dblVoucherLineTotal
			, dblRecordTax
			, dblVoucherTax
			, dblOpenQty
			, dblItemsPayable
			, dblTaxesPayable
			, dtmLastVoucherDate
			, strAllVouchers
			, dtmCreated = @dtmCreated
			, receiptPriceCharges.intCurrencyId
			, receiptPriceCharges.strCurrency
			, intLoadContainerId = CAST(NULL AS INT)
			, strContainerNumber = CAST(NULL AS NVARCHAR(100)) 
			, intItemUOMId = CAST(NULL AS INT)
			, strItemUOM = receiptPriceCharges.strItemUOM
			, intCostUOMId = CAST(NULL AS INT)
			, strCostUOM =  receiptPriceCharges.strCostUOM
			, strFilterString
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuAPGetInventoryReceiptVoucherPriceCharges prices
				WHERE	prices.intEntityVendorId = vendor.intEntityId
			) receiptPriceCharges

	-- Insert the accrue other charges. 
	UNION ALL 
	SELECT	
			intInventoryRecordId
			, intInventoryRecordItemId
			, intInventoryRecordChargeId
			, dtmRecordDate
			, strVendor = vendor.strVendorId + ' ' + entity.strName
			, strLocationName
			, strRecordNumber
			, strBillOfLading
			, strOrderType
			, strRecordType
			, strOrderNumber
			, strItemNo
			, strItemDescription
			, dblUnitCost
			, dblRecordQty
			, dblVoucherQty
			, dblRecordLineTotal
			, dblVoucherLineTotal
			, (CASE WHEN CT.ysnCheckoffTax = 0 THEN ABS(dblRecordTax) ELSE dblRecordTax END) AS dblRecordTax
			, (CASE WHEN CT.ysnCheckoffTax = 0 THEN ABS(dblVoucherTax) ELSE dblVoucherTax END) AS dblVoucherTax  
			, dblOpenQty
			, dblItemsPayable
			, (CASE WHEN CT.ysnCheckoffTax = 0 THEN ABS(dblTaxesPayable) ELSE dblTaxesPayable END) AS dblTaxesPayable
			, dtmLastVoucherDate
			, strAllVouchers
			, dtmCreated = @dtmCreated
			, receiptCharges.intCurrencyId
			, receiptCharges.strCurrency
			, intLoadContainerId = CAST(NULL AS INT)
			, strContainerNumber = CAST(NULL AS NVARCHAR(100)) 
			, intItemUOMId = CAST(NULL AS INT)
			, strItemUOM = receiptCharges.strItemUOM
			, intCostUOMId = CAST(NULL AS INT)
			, strCostUOM =  receiptCharges.strCostUOM
			, strFilterString
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuAPGetInventoryReceiptVoucherCharges charges
				WHERE	charges.intEntityVendorId = vendor.intEntityId
			) receiptCharges
			OUTER APPLY(
						SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax CT
						WHERE CT.intInventoryReceiptChargeId = receiptCharges.intInventoryRecordChargeId
			) CT 
	
	--Shipment with other charges
	UNION ALL 
	SELECT	
			intInventoryRecordId
			, intInventoryRecordItemId
			, intInventoryRecordChargeId
			, dtmRecordDate
			, strVendor = vendor.strVendorId + ' ' + entity.strName
			, strLocationName
			, strRecordNumber
			, strBillOfLading
			, strOrderType
			, strRecordType
			, strOrderNumber
			, strItemNo
			, strItemDescription
			, dblUnitCost
			, dblRecordQty
			, dblVoucherQty
			, dblRecordLineTotal
			, dblVoucherLineTotal
			, dblRecordTax
			, dblVoucherTax
			, dblOpenQty
			, dblItemsPayable
			, dblTaxesPayable
			, dtmLastVoucherDate
			, strAllVouchers
			, dtmCreated = @dtmCreated
			, shipmentCharges.intCurrencyId
			, shipmentCharges.strCurrency
			, intLoadContainerId = CAST(NULL AS INT)
			, strContainerNumber = CAST(NULL AS NVARCHAR(100)) 
			, intItemUOMId = CAST(NULL AS INT)
			, strItemUOM = shipmentCharges.strItemUOM
			, intCostUOMId = CAST(NULL AS INT)
			, strCostUOM =  shipmentCharges.strCostUOM
			, strFilterString
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuAPGetShipmentChargesForBilling prices
				WHERE	prices.intEntityVendorId = vendor.intEntityId
			) shipmentCharges
END
GO


