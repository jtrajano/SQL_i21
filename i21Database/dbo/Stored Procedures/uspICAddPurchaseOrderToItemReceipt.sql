CREATE PROCEDURE [dbo].[uspICAddPurchaseOrderToItemReceipt]
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

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

IF @ReceiptNumber IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	RAISERROR(50030, 11, 1);
	RETURN;
END 

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intVendorId
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
		,strCalculationBasis
		,dblUnitWeightMile
		,dblFreightRate
		,dblFuelSurcharge
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
		,intVendorId			= PO.intVendorId
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
		,strCalculationBasis	= NULL 
		,dblUnitWeightMile		= 0 -- TODO Not sure where to get this from PO
		,dblFreightRate			= PO.dblShipping -- TODO I assume dblShipping is the Freight Rate. 
		,dblFuelSurcharge		= 0 
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

IF @InventoryReceiptId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	RAISERROR(50031, 11, 1);
	RETURN;
END

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intSourceId
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
		,intSourceId			= @PurchaseOrderId
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

-- Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = (
			SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
			FROM	dbo.tblICInventoryReceiptItem ReceiptItem
			WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM	dbo.tblICInventoryReceipt Receipt 
WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId
