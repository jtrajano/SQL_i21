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
		,intSourceId
		,intBlanketRelease
		,intLocationId
		,strVendorRefNo
		,strBillOfLading
		,intShipViaId
		,intProductOrigin
		,intReceiverId
		,intCurrencyId
		,strVessel
		,intFreightTermId
		,strDeliveryPoint
		,strAllocateFreight
		,strFreightBilledBy
		,intShiftNumber
		,strNotes
		,strCalculationBasis
		,dblUnitWeightMile
		,dblFreightRate
		,dblFuelSurcharge
		,dblInvoiceAmount
		,ysnInvoicePaid
		,intCheckNo
		,dteCheckDate
		,intTrailerTypeId
		,dteTrailerArrivalDate
		,dteTrailerArrivalTime
		,strSealNo
		,strSealStatus
		,dteReceiveTime
		,dblActualTempReading
		,intConcurrencyId
		,intEntityId
		,intCreatedUserId
)
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intVendorId			= PO.intVendorId
		,strReceiptType			= @ReceiptType_PurchaseOrder
		,intSourceId			= PO.intPurchaseId 
		,intBlanketRelease		= NULL
		,intLocationId			= PO.intShipToId
		,strVendorRefNo			= PO.strReference
		,strBillOfLading		= NULL
		,intShipViaId			= PO.intShipViaId
		,intProductOrigin		= NULL 
		,intReceiverId			= NULL 
		,intCurrencyId			= PO.intCurrencyId
		,strVessel				= NULL
		,intFreightTermId		= PO.intFreightId
		,strDeliveryPoint		= NULL 
		,strAllocateFreight		= 'No' -- Default is No
		,strFreightBilledBy		= 'No' -- Default is No
		,intShiftNumber			= NULL 
		,strNotes				= NULL 
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
    ,intItemId
	,dblOrderQty
	,dblOpenReceive
	,dblReceived
    ,intUnitMeasureId
    ,intNoPackages
	,intPackTypeId
    ,dblExpPackageWeight
    ,dblUnitCost
	,dblLineTotal
    ,intSort
    ,intConcurrencyId
)
SELECT	intInventoryReceiptId = @InventoryReceiptId
		,intLineNo				= PODetail.intLineNo
		,intItemId				= PODetail.intItemId
		,dblOrderQty			= ISNULL(PODetail.dblQtyOrdered, 0)
		,dblOpenReceive			= ISNULL(PODetail.dblQtyOrdered, 0) - ISNULL(PODetail.dblQtyReceived, 0)
		,dblReceived			= 0 -- Default to zero. Received will be keyed-in by the end-user at the client-side. 
		,intUnitMeasureId		= PODetail.intUnitOfMeasureId
		,intNoPackages			= 0 -- None found from Purchase Order
		,intPackTypeId			= 0 -- None found from Purchase Order
		,dblExpPackageWeight	= 0 -- None found from Purchase Order
		,dblUnitCost			= PODetail.dblCost
		,dblLineTotal			= 0
		,intSort				= PODetail.intLineNo
		,intConcurrencyId		= 1
FROM	dbo.tblPOPurchaseDetail PODetail LEFT JOIN dbo.tblICUnitMeasure UOM
			ON PODetail.intUnitOfMeasureId = UOM.intUnitMeasureId
		INNER JOIN dbo.tblICItemUOM ItemUOM
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
WHERE	PODetail.intPurchaseId = @PurchaseOrderId