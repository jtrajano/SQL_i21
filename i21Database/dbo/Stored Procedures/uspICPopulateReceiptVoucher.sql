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
	)
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
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityVendorId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherItems items
				WHERE	items.intEntityVendorId = vendor.intEntityVendorId
			) receiptItem
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
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityVendorId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherCharges charges
				WHERE	charges.intEntityVendorId = vendor.intEntityVendorId
			) receiptCharges
END 