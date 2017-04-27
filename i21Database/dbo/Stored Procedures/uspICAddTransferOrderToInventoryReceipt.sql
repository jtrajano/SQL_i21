CREATE PROCEDURE [dbo].[uspICAddTransferOrderToInventoryReceipt]
	@TransferOrderId AS INT
	,@intEntityUserSecurityId AS INT
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
    RAISERROR('Unable to generate the Inventory Receipt. An error stopped the process from Transfer Order to Inventory Receipt.', 11, 1);
    GOTO _Exit
END

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intEntityVendorId
		,intTransferorId
		,strReceiptType
		,intSourceType
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
		,ysnPosted
)
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= NULL
		,intTransferorId		= Transfer.intFromLocationId
		,strReceiptType			= @ReceiptType_TransferOrder
		,intSourceType			= 0
		,intBlanketRelease		= NULL
		,intLocationId			= Transfer.intToLocationId
		,strVendorRefNo			= NULL
		,strBillOfLading		= NULL
		,intShipViaId			= Transfer.intShipViaId
		,intShipFromId			= NULL
		,intReceiverId			= @intEntityUserSecurityId 
		,intCurrencyId			= NULL
		,strVessel				= NULL
		,intFreightTermId		= NULL
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
		,intEntityId			= @intEntityUserSecurityId
		,ysnPosted				= 0
FROM	dbo.tblICInventoryTransfer Transfer
WHERE	Transfer.intInventoryTransferId = @TransferOrderId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

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
		,intLineNo				= TransferDetail.intInventoryTransferDetailId
		,intOrderId				= @TransferOrderId
		,intItemId				= TransferDetail.intItemId
		,intSubLocationId		= TransferDetail.intToSubLocationId
		,dblOrderQty			= TransferDetail.dblQuantity
		,dblOpenReceive			= TransferDetail.dblQuantity
		,dblReceived			= 0
		,intUnitMeasureId		= TransferDetail.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = TransferDetail.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(TransferDetail.intItemId) <> 0 
									)
		,dblUnitCost			= TransferDetail.dblCost
		,dblLineTotal			= ISNULL(TransferDetail.dblQuantity, 0) * TransferDetail.dblCost
		,intSort				= NULL
		,intConcurrencyId		= 1
FROM	tblICInventoryTransferDetail TransferDetail
		LEFT JOIN vyuICGetInventoryTransferDetail Detail ON Detail.intInventoryTransferDetailId = TransferDetail.intInventoryTransferDetailId
WHERE	TransferDetail.intInventoryTransferId = @TransferOrderId
		AND dbo.fnIsStockTrackingItem(TransferDetail.intItemId) = 1

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
