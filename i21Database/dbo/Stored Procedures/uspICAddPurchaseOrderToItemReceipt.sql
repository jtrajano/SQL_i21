CREATE PROCEDURE [dbo].[uspICAddPurchaseOrderToItemReceipt]
	@ItemsToReceive AS ItemCostingTableType READONLY
	,@intSourceTransactionId AS INT
	,@intUserId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @Inventory_Receipt_Type AS NVARCHAR(100) = 'Inventory Receipt'
DECLARE @strReceiptNumber AS NVARCHAR(20)
DECLARE @intInventoryReceiptId AS INT


DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @Inventory_Receipt_Type, @strReceiptNumber OUTPUT 

IF ISNULL(@strReceiptNumber, '') = '' 
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
		,intWarehouseId
		,strVendorRefNo
		,strBillOfLading
		,intShipViaId
		,intReceiptSequenceNo
		,intBatchNo
		,intTermId
		,intProductOrigin
		,strReceiver
		,intCurrencyId
		,strVessel
		,strAPAccount
		,strBillingStatus
		,strOrderNumber
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
)
SELECT 	strReceiptNumber		= @strReceiptNumber
		,dtmReceiptDate			= GETDATE()
		,intVendorId			= PO.intVendorId
		,strReceiptType			= @ReceiptType_PurchaseOrder
		,intSourceId			= PO.intPurchaseId 
		,intBlanketRelease		= NULL
		,intLocationId			= PO.intShipToId
		,intWarehouseId			= NULL -- TODO Add logic for it when spec for sub-location is defined. 
		,strVendorRefNo			= PO.strReference
		,strBillOfLading		= NULL
		,intShipViaId			= PO.intShipViaId
		,intReceiptSequenceNo	= NULL  
		,intBatchNo				= NULL 
		,intTermId				= PO.intTermsId
		,intProductOrigin		= NULL 
		,strReceiver			= '' -- TODO See http://inet.irelyserver.com/display/INV/Inventory+Receipt+%28Detail%29+Tab?focusedCommentId=42272077#comment-42272077
		,intCurrencyId			= PO.intCurrencyId
		,strVessel				= NULL 
		,strAPAccount			= NULL -- TODO. I think we need to remove it. 
		,strBillingStatus		= NULL -- TODO. I think we need to remove it. 
		,strOrderNumber			= NULL -- TODO. I think we need to remove it. 
		,intFreightTermId		= PO.intFreightId
		,strDeliveryPoint		= NULL 
		,strAllocateFreight		= 'No' -- Default is No
		,strFreightBilledBy		= 'No' -- Default is No
		,intShiftNumber			= NULL 
		,strNotes				= NULL 
		,strCalculationBasis	= 'Per Unit' -- TODO. This is mandatory and default value is not defined. Need to change it to Nullable. 
		,dblUnitWeightMile		= 0 -- TODO Not sure where to get this from PO
		,dblFreightRate			= PO.dblShipping -- TODO
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
FROM	dbo.tblPOPurchase PO
WHERE	PO.intPurchaseId = @intSourceTransactionId

-- Get the identity value from tblICInventoryReceipt
SELECT @intInventoryReceiptId = SCOPE_IDENTITY()