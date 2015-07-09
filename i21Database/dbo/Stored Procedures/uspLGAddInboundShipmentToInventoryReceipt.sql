CREATE PROCEDURE [dbo].[uspLGAddInboundShipmentToInventoryReceipt]
	@ShipmentId AS INT
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

DECLARE @ReceiptType_PurchaseContract AS NVARCHAR(100) = 'Purchase Contract'

IF @ShipmentId IS NULL 
BEGIN 
    -- Raise the error:
    -- Unable to generate the Inventory Receipt. An error stopped the process from Inbound Shipment to Inventory Receipt.
    RAISERROR(51151, 11, 1);
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
		,intEntityVendorId		= Shipment.intVendorEntityId
		,strReceiptType			= @ReceiptType_PurchaseContract
		,intSourceType			= 2
		,intBlanketRelease		= NULL
		,intLocationId			= Shipment.intCompanyLocationId
		,strVendorRefNo			= NULL
		,strBillOfLading		= NULL
		,intShipViaId			= NULL
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
FROM	dbo.tblLGShipment Shipment
WHERE	Shipment.intShipmentId = @ShipmentId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intOrderId
	,intSourceId
    ,intItemId
	,intContainerId
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
		,intLineNo				= ShipmentDetail.intShipmentContractQtyId
		,intOrderId				= ShipmentDetail.intContractHeaderId
		,intSourceId			= ShipmentDetail.intShipmentContractQtyId
		,intItemId				= ShipmentDetail.intItemId
		,intContainerId			= ShipmentDetail.intShipmentBLContainerId
		,intSubLocationId		= ShipmentDetail.intSubLocationId
		,dblOrderQty			= ShipmentDetail.dblQuantity
		,dblOpenReceive			= (ISNULL(ShipmentDetail.dblQuantity, 0) - ISNULL(ShipmentDetail.dblReceivedQty, 0))
		,dblReceived			= ShipmentDetail.dblReceivedQty
		,intUnitMeasureId		= ShipmentDetail.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = ShipmentDetail.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(ShipmentDetail.intItemId) IN (1,2)
									)
		,dblUnitCost			= ShipmentDetail.dblCost
		,dblLineTotal			= ISNULL(ShipmentDetail.dblQuantity, 0) * ShipmentDetail.dblCost
		,intSort				= NULL
		,intConcurrencyId		= 1
FROM	vyuLGShipmentContainerReceiptContracts ShipmentDetail
WHERE	ShipmentDetail.intShipmentContractQtyId = @ShipmentId
		AND dbo.fnIsStockTrackingItem(ShipmentDetail.intItemId) = 1

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
