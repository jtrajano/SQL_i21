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
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @intTicketNumber AS INT
DECLARE @dblTicketFees AS DECIMAL(7, 2)
DECLARE @intFeeItemId AS INT


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

BEGIN
    SELECT TOP 1 @dblTicketFreightRate = ST.dblFreightRate, @intScaleStationId = ST.intScaleSetupId,
	@ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight, @intTicketNumber = ST.intTicketNumber,
	@dblTicketFees = ST.dblTicketFees, @intFreightVendorId = ST.intFreightCarrierId
	FROM dbo.tblSCTicket ST WHERE
	ST.intTicketId = @intTicketId
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
		SUM(SC.dblRate),
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

IF (@dblTicketFreightRate > 0 AND (@intFreightVendorId != null OR @ysnDeductFreightFarmer = 1))
BEGIN
SELECT	@intFreightItemId = ST.intFreightItemId
FROM	dbo.tblSCScaleSetup ST	        
WHERE	ST.intScaleSetupId = @intScaleStationId
IF @intFreightItemId IS NULL 
BEGIN 
	-- Raise the error:
	RAISERROR('Invalid Default Freight Item in Scale Setup - uspSCProcessToItemReceipt', 16, 1);
	RETURN;
END
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
		@intFreightItemId,
		0,
		'Per Unit',
		@dblTicketFreightRate,
		@intTicketItemUOMId,
		CASE
		WHEN SS.ysnFarmerPaysFreight = 1 THEN NULL
		WHEN SS.ysnFarmerPaysFreight = 0 THEN SS.intFreightCarrierId
		END,
		NULL,
		NULL,
		CASE
		WHEN SS.ysnFarmerPaysFreight = 1 THEN 'Vendor'
		WHEN SS.ysnFarmerPaysFreight = 0 THEN 'Third Party'
		END,
		NULL,
		1
FROM	tblSCTicket SS WHERE SS.intTicketId = @intTicketId
END

IF @dblTicketFees > 0
BEGIN
SELECT	@intFeeItemId = ST.intDefaultFeeItemId
FROM	dbo.tblSCScaleSetup ST	        
WHERE	ST.intScaleSetupId = @intScaleStationId
IF @intFeeItemId IS NULL 
BEGIN 
	-- Raise the error:
	RAISERROR('Invalid Default Fee Item in Scale Setup - uspSCProcessToItemReceipt', 16, 1);
	RETURN;
END
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
		@intFeeItemId,
		0,
		'Amount',
		0,
		NULL,
		NULL,
		@dblTicketFees * -1,
		NULL,
		'None',
		NULL,
		1
FROM	tblSCTicket SS WHERE SS.intTicketId = @intTicketId
END

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
       ,[intTicketId]= NULL
       ,[intTicketFileId]= ISH.intInventoryReceiptItemId
       ,[strSourceType]= 'Inventory Receipt'
	FROM	dbo.tblICInventoryReceiptItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Scale' AND
	SD.intTicketFileId = @intTicketId WHERE	ISH.intSourceId = @intTicketId AND ISH.intInventoryReceiptId = @InventoryReceiptId
END

DECLARE @intLoopReceiptItemId INT;
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT  IRI.intInventoryReceiptItemId
FROM tblICInventoryReceiptItem IRI WHERE 
IRI.intInventoryReceiptId = @InventoryReceiptId AND dbo.fnGetItemLotType(IRI.intItemId) IN (@LotType_Manual, @LotType_Serial);

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;

WHILE @@FETCH_STATUS = 0
BEGIN
   -- Here we do some kind of action that requires us to 
   -- process the table variable row-by-row. This example simply
   -- uses a PRINT statement as that action (not a very good
   -- example).
   IF	ISNULL(@intLoopReceiptItemId,0) != 0
   BEGIN
   INSERT INTO [dbo].[tblICInventoryReceiptItemLot]
           ([intInventoryReceiptItemId]
           ,[intLotId]
           ,[strLotNumber]
           ,[strLotAlias]
           ,[intSubLocationId]
           ,[intStorageLocationId]
           ,[intItemUnitMeasureId]
           ,[dblQuantity]
           ,[dblGrossWeight]
           ,[dblTareWeight]
           ,[dblCost]
           ,[intUnitPallet]
           ,[dblStatedGrossPerUnit]
           ,[dblStatedTarePerUnit]
           ,[strContainerNo]
           ,[intEntityVendorId]
           ,[intVendorLocationId]
           ,[strMarkings]
           ,[intOriginId]
           ,[intSeasonCropYear]
           ,[strVendorLotId]
           ,[dtmManufacturedDate]
           ,[strRemarks]
           ,[strCondition]
           ,[dtmCertified]
           ,[dtmExpiryDate]
           ,[intSort]
           ,[intConcurrencyId])
     SELECT
            [intInventoryReceiptItemId] = @intLoopReceiptItemId
           ,[intLotId] = NULL
           ,[strLotNumber]  = 'SC-' + CAST(@intTicketNumber  AS VARCHAR(20)) 
           ,[strLotAlias] = @intTicketNumber 
           ,[intSubLocationId] = RCT.intSubLocationId
           ,[intStorageLocationId] = RCT.intStorageLocationId
           ,[intItemUnitMeasureId] = @intTicketItemUOMId
           ,[dblQuantity] = RCT.dblReceived
           ,[dblGrossWeight] = NULL
           ,[dblTareWeight] = NULL
           ,[dblCost] = RCT.dblUnitCost
           ,[intUnitPallet] = NULL
           ,[dblStatedGrossPerUnit] = NULL
           ,[dblStatedTarePerUnit] = NULL
           ,[strContainerNo] = NULL
           ,[intEntityVendorId] = NULL
           ,[intVendorLocationId] = NULL
           ,[strMarkings] = NULL 
           ,[intOriginId] = NULL
           ,[intSeasonCropYear] = NULL
           ,[strVendorLotId] = NULL
           ,[dtmManufacturedDate] = NULL
           ,[strRemarks] = NULL
           ,[strCondition] = NULL
           ,[dtmCertified] = NULL
           ,[dtmExpiryDate] = NULL
           ,[intSort] = NULL
           ,[intConcurrencyId] = 1
		   FROM	dbo.tblICInventoryReceiptItem RCT WHERE RCT.intInventoryReceiptItemId = @intLoopReceiptItemId
   END

   -- Attempt to fetch next row from cursor
   FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;