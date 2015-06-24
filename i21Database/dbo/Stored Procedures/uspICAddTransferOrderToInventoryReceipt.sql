CREATE PROCEDURE [dbo].[uspICAddTransferOrderToInventoryReceipt]
	@TransferOrderId AS INT
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

DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'

IF @TransferOrderId IS NULL 
BEGIN 
    -- Raise the error:
    -- Unable to generate the Inventory Receipt. An error stopped the process from Transfer Order to Inventory Receipt.
    RAISERROR(51148, 11, 1);
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
		,intEntityVendorId		= NULL
		,strReceiptType			= @ReceiptType_TransferOrder
		,intBlanketRelease		= NULL
		,intLocationId			= Transfer.intToLocationId
		,strVendorRefNo			= NULL
		,strBillOfLading		= NULL
		,intShipViaId			= Transfer.intShipViaId
		,intShipFromId			= NULL
		,intReceiverId			= @intUserId 
		,intCurrencyId			= NULL
		,strVessel				= NULL
		,intFreightTermId		= NULL
		,strAllocateFreight		= 'No' -- Default is No
		,intShiftNumber			= NULL 
		,dblInvoiceAmount		= 0
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
FROM	dbo.tblICInventoryTransfer Transfer
WHERE	Transfer.intInventoryTransferId = @TransferOrderId

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
		,intOrderId				= @TransferOrderId
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
WHERE	PODetail.intPurchaseId = @TransferOrderId
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

_Exit: 
