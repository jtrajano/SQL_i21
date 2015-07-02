CREATE PROCEDURE [dbo].[uspICAddItemReceipt]
	 @ReceiptEntries ReceiptStagingTable READONLY	
	,@intUserId AS INT	
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;

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
SELECT 	 strReceiptNumber       = 1
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= RE.intEntityVendorId
		,strReceiptType			= min(RE.strReceiptType)
		,intBlanketRelease		= NULL
		,intLocationId			= min(RE.intLocationId)
		,strVendorRefNo			= NULL
		,strBillOfLading		= RE.strBillOfLadding
		,intShipViaId			= min(RE.intShipViaId)
		,intShipFromId			= min(RE.intShipFromId) 
		,intReceiverId			= @intUserId 
		,intCurrencyId			= min(RE.intCurrencyId)
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
FROM	@ReceiptEntries RE
        group by  RE.intEntityVendorId,RE.strBillOfLadding

-- Get the identity value from tblICInventoryReceipt to check if the insert was with no errors 
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
	,intOrderId
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
	,intOwnershipType
)
SELECT	intInventoryReceiptId	= (select TOP 1 IR.intInventoryReceiptId from tblICInventoryReceipt IR 
                                   where RE.intEntityVendorId = IR.intEntityVendorId 
								     and RE.strBillOfLadding = IR.strBillOfLading
								   )
		,intLineNo				= RE.intSourceId
		,intOrderId				= RE.intContractDetailId
		,intSourceId			= RE.intSourceId
		,intItemId				= RE.intItemId
		,intSubLocationId		= NUll
		,dblOrderQty			= RE.dblQty
		,dblOpenReceive			= RE.dblQty
		,dblReceived			= RE.dblQty
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = RE.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(RE.intItemId) IN (1,2)
									)
		,dblUnitCost			= RE.dblCost
		,dblLineTotal			= RE.dblQty * RE.dblCost
		,intSort				= 1
		,intConcurrencyId		= 1
		,intOwnershipType       = CASE
								  WHEN RE.ysnIsCustody = 0
								  THEN 1
								  WHEN RE.ysnIsCustody = 1
								  THEN 2
								  END
FROM	@ReceiptEntries RE
        INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = RE.intItemId  AND ItemUOM.intItemUOMId = RE.intItemUOMId			
		INNER JOIN dbo.tblICUnitMeasure UOM
		    ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	

-- Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = (
			SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
			FROM	dbo.tblICInventoryReceiptItem ReceiptItem
			WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM	dbo.tblICInventoryReceipt Receipt 
        JOIN @ReceiptEntries RE 
             ON RE.intEntityVendorId = Receipt.intEntityVendorId 
			  and RE.strBillOfLadding = Receipt.strBillOfLading

