CREATE PROCEDURE [dbo].[uspICPopulateReceiptVoucher]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmCreated AS DATETIME = GETDATE()

-- Clean the contents of temp table. 
BEGIN 
	TRUNCATE TABLE [tblICSearchReceiptVoucher]
END 

-- Insert fresh data to the temp table. 
BEGIN 
	INSERT INTO [tblICSearchReceiptVoucher] (
			intInventoryReceiptId
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
			,dblUnitCost
			,dblReceiptQty
			,dblVoucherQty
			,dblReceiptLineTotal
			,dblVoucherLineTotal
			,dblReceiptTax
			,dblVoucherTax
			,dblOpenQty
			,dblItemsPayable
			,dblTaxesPayable
			,dtmLastVoucherDate
			,strAllVouchers
			,strFilterString
			,dtmCreated
			,intCurrencyId
			,strCurrency
			,intLoadContainerId
			,strContainerNumber
			,intItemUOMId
			,strItemUOM
			,intCostUOMId
			,strCostUOM
	)
	-- Insert the items: 
	SELECT	
			intInventoryReceiptId
			,intInventoryReceiptItemId
			,dtmReceiptDate
			,strVendor = vendor.strVendorId + ' ' + entity.strName
			,strLocationName
			,strReceiptNumber
			,strBillOfLading
			,strReceiptType
			,strOrderNumber
			,strItemNo
			,strItemDescription
			,dblUnitCost
			,dblReceiptQty
			,dblVoucherQty
			,dblReceiptLineTotal
			,dblVoucherLineTotal
			,dblReceiptTax
			,dblVoucherTax
			,dblOpenQty
			,dblItemsPayable
			,dblTaxesPayable
			,dtmLastVoucherDate
			,strAllVouchers
			,strFilterString
			,dtmCreated = @dtmCreated
			,receiptItem.intCurrencyId
			,receiptItem.strCurrency
			,receiptItem.intLoadContainerId
			,receiptItem.strContainerNumber
			,receiptItem.intItemUOMId
			,receiptItem.strItemUOM
			,receiptItem.intCostUOMId
			,receiptItem.strCostUOM
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityVendorId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherItems items
				WHERE	items.intEntityVendorId = vendor.intEntityVendorId
			) receiptItem

	-- Insert the price down charges (against the receipt vendor)
	UNION ALL 
	SELECT	
			intInventoryReceiptId
			,intInventoryReceiptChargeId
			,dtmReceiptDate
			,strVendor = vendor.strVendorId + ' ' + entity.strName
			,strLocationName
			,strReceiptNumber
			,strBillOfLading
			,strReceiptType
			,strOrderNumber
			,strItemNo
			,strItemDescription
			,dblUnitCost
			,dblReceiptQty
			,dblVoucherQty
			,dblReceiptLineTotal
			,dblVoucherLineTotal
			,dblReceiptTax
			,dblVoucherTax
			,dblOpenQty
			,dblItemsPayable
			,dblTaxesPayable
			,dtmLastVoucherDate
			,strAllVouchers
			,strFilterString
			,dtmCreated = @dtmCreated
			,receiptPriceCharges.intCurrencyId
			,receiptPriceCharges.strCurrency
			,intLoadContainerId = CAST(NULL AS INT)
			,strContainerNumber = CAST(NULL AS NVARCHAR(100)) 
			,intItemUOMId = CAST(NULL AS INT)
			,strItemUOM = CAST(NULL AS NVARCHAR(50)) 
			,intCostUOMId = CAST(NULL AS INT)
			,strCostUOM = CAST(NULL AS NVARCHAR(50)) 
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityVendorId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherPriceCharges prices
				WHERE	prices.intEntityVendorId = vendor.intEntityVendorId
			) receiptPriceCharges

	-- Insert the accrue other charges. 
	UNION ALL 
	SELECT	
			intInventoryReceiptId
			,intInventoryReceiptChargeId
			,dtmReceiptDate
			,strVendor = vendor.strVendorId + ' ' + entity.strName
			,strLocationName
			,strReceiptNumber
			,strBillOfLading
			,strReceiptType
			,strOrderNumber
			,strItemNo
			,strItemDescription
			,dblUnitCost
			,dblReceiptQty
			,dblVoucherQty
			,dblReceiptLineTotal
			,dblVoucherLineTotal
			,dblReceiptTax
			,dblVoucherTax
			,dblOpenQty
			,dblItemsPayable
			,dblTaxesPayable
			,dtmLastVoucherDate
			,strAllVouchers
			,strFilterString
			,dtmCreated = @dtmCreated
			,receiptCharges.intCurrencyId
			,receiptCharges.strCurrency
			,intLoadContainerId = CAST(NULL AS INT)
			,strContainerNumber = CAST(NULL AS NVARCHAR(100)) 
			,intItemUOMId = CAST(NULL AS INT)
			,strItemUOM = CAST(NULL AS NVARCHAR(50)) 
			,intCostUOMId = CAST(NULL AS INT)
			,strCostUOM = CAST(NULL AS NVARCHAR(50)) 
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityVendorId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherCharges charges
				WHERE	charges.intEntityVendorId = vendor.intEntityVendorId
			) receiptCharges
END 