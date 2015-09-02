﻿CREATE PROCEDURE [dbo].[uspICAddPurchaseOrderToInventoryReceipt]
	@PurchaseOrderId AS INT
	,@intUserId AS INT
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(20)

DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

IF @PurchaseOrderId IS NULL 
BEGIN 
    -- Raise the error:
    -- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
    RAISERROR(50031, 11, 1);
    GOTO _Exit
END

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intEntityVendorId
		,strReceiptType
		,intBlanketRelease
		,intLocationId
		,strVendorRefNo
		,strBillOfLading
		,intShipViaId
		,intShipFromId
		,intReceiverId
		,intCurrencyId
		,strVessel
		,intFreightTermId
		,strAllocateFreight
		,intShiftNumber
		,dblInvoiceAmount
		,ysnInvoicePaid
		,intCheckNo
		,dtmCheckDate
		,intTrailerTypeId
		,dtmTrailerArrivalDate
		,dtmTrailerArrivalTime
		,strSealNo
		,strSealStatus
		,dtmReceiveTime
		,dblActualTempReading
		,intConcurrencyId
		,intEntityId
		,intCreatedUserId
		,ysnPosted
)
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= PO.[intEntityVendorId]
		,strReceiptType			= @ReceiptType_PurchaseOrder
		,intBlanketRelease		= NULL
		,intLocationId			= PO.intShipToId
		,strVendorRefNo			= PO.strReference
		,strBillOfLading		= NULL
		,intShipViaId			= PO.intShipViaId
		,intShipFromId			= PO.intShipFromId 
		,intReceiverId			= @intUserId 
		,intCurrencyId			= PO.intCurrencyId
		,strVessel				= NULL
		,intFreightTermId		= PO.intFreightTermId
		,strAllocateFreight		= 'No' -- Default is No
		,intShiftNumber			= NULL 
		,dblInvoiceAmount		= PO.dblTotal
		,ysnInvoicePaid			= 0 
		,intCheckNo				= NULL 
		,dteCheckDate			= NULL 
		,intTrailerTypeId		= NULL 
		,dteTrailerArrivalDate	= NULL 
		,dteTrailerArrivalTime	= NULL 
		,strSealNo				= NULL 
		,strSealStatus			= NULL 
		,dteReceiveTime			= NULL 
		,dblActualTempReading	= NULL 
		,intConcurrencyId		= 1
		,intEntityId			= (SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WHERE intUserSecurityID = @intUserId)
		,intCreatedUserId		= @intUserId
		,ysnPosted				= 0
FROM	dbo.tblPOPurchase PO
WHERE	PO.intPurchaseId = @PurchaseOrderId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

--IF @InventoryReceiptId IS NULL 
--BEGIN 
--	-- Raise the error:
--	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
--	RAISERROR(50031, 11, 1);
--	GOTO _Exit
--END

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intOrderId
    ,intItemId
	,intSubLocationId
	,dblOrderQty
	,dblOpenReceive
	,dblReceived
    ,intUnitMeasureId
	,intWeightUOMId
    ,dblUnitCost
	,dblLineTotal
    ,intSort
    ,intConcurrencyId
)
SELECT	intInventoryReceiptId	= @InventoryReceiptId
		,intLineNo				= PODetail.intPurchaseDetailId
		,intOrderId				= @PurchaseOrderId
		,intItemId				= PODetail.intItemId
		,intSubLocationId		= PODetail.intSubLocationId
		,dblOrderQty			= ISNULL(PODetail.dblQtyOrdered, 0)
		,dblOpenReceive			= ISNULL(PODetail.dblQtyOrdered, 0) - ISNULL(PODetail.dblQtyReceived, 0)
		,dblReceived			= ISNULL(PODetail.dblQtyReceived, 0)
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = PODetail.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(PODetail.intItemId) IN (1,2)
									)
		,dblUnitCost			= PODetail.dblCost
		,dblLineTotal			= (ISNULL(PODetail.dblQtyOrdered, 0) - ISNULL(PODetail.dblQtyReceived, 0)) * PODetail.dblCost
		,intSort				= PODetail.intLineNo
		,intConcurrencyId		= 1
FROM	dbo.tblPOPurchaseDetail PODetail INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = PODetail.intItemId
			AND ItemUOM.intItemUOMId = PODetail.intUnitOfMeasureId
		INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE	PODetail.intPurchaseId = @PurchaseOrderId
		AND dbo.fnIsStockTrackingItem(PODetail.intItemId) = 1
		AND PODetail.dblQtyOrdered != PODetail.dblQtyReceived

INSERT INTO dbo.tblICInventoryReceiptItemTax (
		[intInventoryReceiptItemId]
		,[intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intSort]
		,[intConcurrencyId]
)
SELECT 
		[intInventoryReceiptItemId]		= ReceiptItem.intInventoryReceiptItemId
		,[intTaxGroupMasterId]			= PODetailTax.intTaxGroupMasterId
		,[intTaxGroupId]				= PODetailTax.intTaxGroupId
		,[intTaxCodeId]					= PODetailTax.intTaxCodeId
		,[intTaxClassId]				= PODetailTax.intTaxClassId
		,[strTaxableByOtherTaxes]		= PODetailTax.strTaxableByOtherTaxes
		,[strCalculationMethod]			= PODetailTax.strCalculationMethod
		,[dblRate]						= PODetailTax.dblRate
		,[dblTax]						= PODetailTax.dblTax
		,[dblAdjustedTax]				= PODetailTax.dblAdjustedTax
		,[intTaxAccountId]				= TaxCode.intPurchaseTaxAccountId
		,[ysnTaxAdjusted]				= PODetailTax.ysnTaxAdjusted
		,[ysnSeparateOnInvoice]			= PODetailTax.ysnSeparateOnBill
		,[ysnCheckoffTax]				= PODetailTax.ysnCheckOffTax
		,[strTaxCode]					= TaxCode.strTaxCode
		,[intSort]						= ReceiptItem.intSort
		,[intConcurrencyId]				= 1
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN dbo.tblPOPurchaseDetail PODetail
			ON PODetail.intPurchaseDetailId = ReceiptItem.intLineNo
			AND PODetail.intPurchaseId = ReceiptItem.intOrderId
		INNER JOIN dbo.tblPOPurchaseDetailTax PODetailTax
			ON PODetailTax.intPurchaseDetailId = PODetail.intPurchaseDetailId
		LEFT JOIN dbo.tblSMTaxCode TaxCode
			ON TaxCode.intTaxCodeId = PODetailTax.intTaxCodeId
WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

-- Calculate the tax per line item 
UPDATE	ReceiptItem 
SET		dblTax = ISNULL(Taxes.dblTaxPerLineItem, 0)
FROM	dbo.tblICInventoryReceiptItem ReceiptItem LEFT JOIN (
			SELECT	dblTaxPerLineItem = SUM(ReceiptItemTax.dblTax) 
					,ReceiptItemTax.intInventoryReceiptItemId
			FROM	dbo.tblICInventoryReceiptItemTax ReceiptItemTax INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
						ON ReceiptItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
			WHERE	ReceiptItem.intInventoryReceiptId = @InventoryReceiptId
			GROUP BY ReceiptItemTax.intInventoryReceiptItemId
		) Taxes
			ON ReceiptItem.intInventoryReceiptItemId = Taxes.intInventoryReceiptItemId
WHERE	ReceiptItem.intInventoryReceiptId = @InventoryReceiptId

-- Re-update the line total 
UPDATE	ReceiptItem 
SET		dblLineTotal = ISNULL(dblOpenReceive, 0) * ISNULL(dblUnitCost, 0) + ISNULL(dblTax, 0)
FROM	dbo.tblICInventoryReceiptItem ReceiptItem
WHERE	intInventoryReceiptId = @InventoryReceiptId

-- Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = Detail.dblTotal
FROM	dbo.tblICInventoryReceipt Receipt LEFT JOIN (
			SELECT	dblTotal = SUM(dblLineTotal) 
					,intInventoryReceiptId
			FROM	dbo.tblICInventoryReceiptItem 
			WHERE	intInventoryReceiptId = @InventoryReceiptId
			GROUP BY intInventoryReceiptId
		) Detail
			ON Receipt.intInventoryReceiptId = Detail.intInventoryReceiptId
WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

_Exit: 
