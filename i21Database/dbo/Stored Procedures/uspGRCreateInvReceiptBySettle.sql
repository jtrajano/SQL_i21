CREATE PROCEDURE [dbo].[uspGRCreateInvReceiptBySettle]
 @intUserId AS INT --User
	,@Items ItemCostingTableType READONLY --item
	,@intEntityId AS INT ---Entity
	,@InventoryStockUOM AS INT--Stock UOM
	,@strReceiptType AS NVARCHAR(100)--SourceType
	,@InventoryReceiptId AS INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(20)


DECLARE @intItemId INT
SELECT @intItemId=intItemId FROM @Items

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt,@ReceiptNumber OUTPUT

IF @ReceiptNumber IS NULL
BEGIN
	RAISERROR (50030,11,1);
	RETURN;
END

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt 
(
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
	,intSourceType
	)
SELECT
	 @ReceiptNumber
	,dbo.fnRemoveTimeOnDate(GETDATE())
	,@intEntityId
	,@strReceiptType
	,NULL
	,intItemLocationId
	,NULL--strVendorRefNo = SC.strCustomerReference
	,NULL 
	,NULL
	, NULL
	,@intUserId
	,intCurrencyId
	,NULL--strVessel = SC.strTruckName
	, NULL
	,'No' -- Default is No
	,NULL
	,0
	,0
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	, NULL
	, 1
	,@intEntityId
	,@intUserId
	,0
	,4
FROM @Items


SELECT @InventoryReceiptId = SCOPE_IDENTITY()

IF @InventoryReceiptId IS NULL
BEGIN
	RAISERROR (50031,11,1);
	RETURN;
END

INSERT INTO dbo.tblICInventoryReceiptItem 
(
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
SELECT  
	 @InventoryReceiptId
	,ISNULL(LI.intTransactionDetailId, 1)
	,CNT.intContractHeaderId
	,LI.intTransactionId
	,LI.intItemId
	,NULL
	,LI.dblQty
	,LI.dblQty
	,LI.dblQty
	,@InventoryStockUOM
	,intWeightUOMId = (
		SELECT TOP 1 tblICItemUOM.intItemUOMId
		FROM dbo.tblICItemUOM
		INNER JOIN dbo.tblICUnitMeasure ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
		WHERE tblICItemUOM.intItemId = @intItemId
			AND tblICItemUOM.ysnStockUnit = 1
			AND tblICUnitMeasure.strUnitType = 'Weight'
			AND dbo.fnGetItemLotType(@intItemId) IN (
				1
				,2
				)
		)
	,LI.dblCost
	,dblLineTotal = LI.dblQty * LI.dblCost
	,intSort = 1
	,intConcurrencyId = 1
	,1---Need to check
FROM @Items LI
LEFT JOIN dbo.tblCTContractDetail CNT ON CNT.intContractDetailId = LI.intTransactionDetailId


-- Re-update the total cost 
UPDATE Receipt
SET dblInvoiceAmount = (
		SELECT ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)), 0)
		FROM dbo.tblICInventoryReceiptItem ReceiptItem
		WHERE ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM dbo.tblICInventoryReceipt Receipt
WHERE Receipt.intInventoryReceiptId = @InventoryReceiptId


