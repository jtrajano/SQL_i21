CREATE PROCEDURE [dbo].[uspSCAddScaleTicketToItemReceipt]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@Items ItemCostingTableType READONLY
	,@intEntityId AS INT
	,@strReceiptType AS NVARCHAR(100)
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

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT


BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId
		FROM	dbo.tblICItemUOM UM	
	      JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.intUnitMeasureId =@intTicketUOM AND SC.intTicketId = @intTicketId
END

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
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= @intEntityId
		,strReceiptType			= @strReceiptType
		,intBlanketRelease		= NULL
		,intLocationId			= SC.intProcessingLocationId
		,strVendorRefNo			= SC.strCustomerReference
		,strBillOfLading		= NULL
		,intShipViaId			= NULL
		,intShipFromId			= NULL 
		,intReceiverId			= @intUserId 
		,intCurrencyId			= SC.intCurrencyId
		,strVessel				= SC.strTruckName
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
		,intSourceType          = 1
FROM	dbo.tblSCTicket SC
WHERE	SC.intTicketId = @intTicketId

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
SELECT	intInventoryReceiptId	= @InventoryReceiptId
		,intLineNo				= ISNULL (LI.intTransactionDetailId, 1)
		,intOrderId				= CNT.intContractHeaderId
		,intSourceId			= @intTicketId
		,intItemId				= SC.intItemId
		,intSubLocationId		= SC.intSubLocationId
		,dblOrderQty			= LI.dblQty
		,dblOpenReceive			= LI.dblQty
		,dblReceived			= LI.dblQty
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = SC.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(SC.intItemId) IN (1,2)
									)
		,dblUnitCost			= LI.dblCost
		,dblLineTotal			= LI.dblQty * LI.dblCost
		,intSort				= 1
		,intConcurrencyId		= 1
		,intOwnershipType       = CASE
								  WHEN LI.ysnIsCustody = 0
								  THEN 1
								  WHEN LI.ysnIsCustody = 1
								  THEN 2
								  END
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = SC.intItemId
			AND ItemUOM.intItemUOMId = @intTicketItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN dbo.tblCTContractDetail CNT
			ON CNT.intContractDetailId = LI.intTransactionDetailId
WHERE	SC.intTicketId = @intTicketId

INSERT INTO tblICInventoryReceiptCharge
(
		intInventoryReceiptId,
		intChargeId,
		ysnInventoryCost,
		strCostMethod,
		dblRate,
		intCostUOMId,
		intEntityVendorId,
		dblAmount,
		strAllocateCostBy,
		strCostBilledBy,
		intSort,
		intConcurrencyId
)
SELECT	@InventoryReceiptId, 
		SC.intItemId,
		0,
		SC.strCostMethod,
		SC.dblRate,
		SC.intItemUOMId,
		SC.intEntityVendorId,
		NULL,
		NULL,
		'Vendor',
		NULL,
		1
FROM	tblSCTicketCost SC
WHERE SC.intTicketId = @intTicketId
GROUP 
BY		SC.intItemId,
		SC.intEntityVendorId,
		SC.strCostMethod,
		SC.dblRate,
		SC.intItemUOMId

-- Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = (
			SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
			FROM	dbo.tblICInventoryReceiptItem ReceiptItem
			WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM	dbo.tblICInventoryReceipt Receipt 
WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

BEGIN
	INSERT INTO [dbo].[tblQMTicketDiscount]
       ([intConcurrencyId]
       ,[strDiscountCode]
       ,[strDiscountCodeDescription]
       ,[dblGradeReading]
       ,[strCalcMethod]
       ,[strShrinkWhat]
       ,[dblShrinkPercent]
       ,[dblDiscountAmount]
       ,[dblDiscountDue]
       ,[dblDiscountPaid]
       ,[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]
       ,[intTicketId]
       ,[intTicketFileId]
       ,[strSourceType])
	SELECT	DISTINCT [intConcurrencyId]= 1
       ,[strDiscountCode] = SD.[strDiscountCode]
       ,[strDiscountCodeDescription]= SD.[strDiscountCodeDescription]
       ,[dblGradeReading]= SD.[dblGradeReading]
       ,[strCalcMethod]= SD.[strCalcMethod]
       ,[strShrinkWhat]= SD.[strShrinkWhat]
       ,[dblShrinkPercent]= SD.[dblShrinkPercent]
       ,[dblDiscountAmount]= SD.[dblDiscountAmount]
       ,[dblDiscountDue]= SD.[dblDiscountDue]
       ,[dblDiscountPaid]= SD.[dblDiscountPaid]
       ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
       ,[intTicketId]= SD.[intTicketId]
       ,[intTicketFileId]= ISH.intInventoryReceiptItemId
       ,[strSourceType]= 'Inventory Receipt'
	FROM	dbo.tblICInventoryReceiptItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Scale' AND
	SD.intTicketFileId = @intTicketId  JOIN dbo.tblICInventoryReceipt IRH ON IRH.intInventoryReceiptId = @InventoryReceiptId AND IRH.strReceiptType = 'Scale' WHERE	
	ISH.intSourceId = @intTicketId AND ISH.intInventoryReceiptId = @InventoryReceiptId AND IRH.strReceiptType = 'Scale'
END
