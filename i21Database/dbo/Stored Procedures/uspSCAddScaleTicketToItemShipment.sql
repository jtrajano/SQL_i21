CREATE PROCEDURE [dbo].[uspSCAddScaleTicketToItemShipment]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@Items ItemCostingTableType READONLY
	,@intEntityId AS INT
	,@intOrderType AS INT
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryShipment AS INT = 31;
DECLARE @ShipmentNumber AS NVARCHAR(20)

DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @strTicketNumber AS NVARCHAR(40)
DECLARE @dblTicketFees AS DECIMAL(7, 2)
DECLARE @checkContract AS INT
DECLARE @intContractDetailId AS INT,
		@intLoadContractId AS INT,
		@intLoadId AS INT,
		@intLoadCostId AS INT,
		@intHaulerId AS INT,
		@ysnAccrue AS BIT,
		@ysnPrice AS BIT;

DECLARE @SALES_CONTRACT AS INT = 1
		,@SALES_ORDER AS INT = 2
		,@TRANSFER_ORDER AS INT = 3

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT 

IF @ShipmentNumber IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	RAISERROR(50030, 11, 1);
	RETURN;
END 

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT,
		@intItemId INT,
		@intLotType INT
BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId, @intContractDetailId = SC.intContractId
	,@intItemId = SC.intItemId
	FROM	dbo.tblICItemUOM UM	
	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
END

DECLARE @ShipmentStagingTable AS ShipmentStagingTable,
		@ShipmentItemLotStagingTable AS ShipmentItemLotStagingTable,
		@ShipmentChargeStagingTable AS ShipmentChargeStagingTable, 
        @total as int,
		@intSurchargeItemId as int,
		@intFreightItemId as int;

BEGIN 
	INSERT INTO @ShipmentStagingTable(
		intOrderType
		,intEntityCustomerId
		,intCurrencyId
		,intShipFromLocationId
		,intShipToLocationId
		,intShipViaId
		,intFreightTermId
		,strBOLNumber
		,intDiscountSchedule
		
		,intItemId
		,intLineNo
		,intOwnershipType
		,dblQuantity
		,dblUnitPrice
		,intWeightUOMId
		,intSubLocationId
		,intStorageLocationId
		,intItemUOMId
		,intItemLotGroup
		
		,intOrderId
		,dtmShipDate
		,intSourceId
		,intSourceType
		,strSourceScreenName
		)
		SELECT
		intOrderType				= @intOrderType
		,intEntityCustomerId		= SC.intEntityId
		,intCurrencyId				= SC.intCurrencyId
		,intShipFromLocationId		= SC.intProcessingLocationId
		,intShipToLocationId		= (select top 1 intShipToId from tblARCustomer where intEntityCustomerId = @intEntityId)
		,intShipViaId				= SC.intFreightCarrierId
		,intFreightTermId			= 1
		,strBOLNumber				= SC.strTicketNumber
		,intDiscountSchedule		= SC.intDiscountId
		
		
		,intItemId					= LI.intItemId
		,intLineNo					= LI.intTransactionDetailId
		,intOwnershipType			= CASE
									  WHEN LI.ysnIsStorage = 0 THEN 1
									  WHEN LI.ysnIsStorage = 1 THEN 2
									  END
		,dblQuantity				= LI.dblQty
		,dblUnitPrice				= LI.dblCost
		,intWeightUOMId				= SC.intItemUOMIdFrom
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		,intItemUOMId				= LI.intItemUOMId
		,intItemLotGroup			= LI.intItemId
		
		,intOrderId					= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN (select top 1 intContractHeaderId from tblCTContractDetail where intContractDetailId = LI.intTransactionDetailId)
									  END
		,dtmShipDate				= SC.dtmTicketDateTime
		,intSourceId				= SC.intTicketId
		,intSourceType				= 1
		,strSourceScreenName		= 'Scale Ticket'
		FROM	@Items LI INNER JOIN  dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId
		INNER JOIN dbo.tblICItemUOM ItemUOM	ON ItemUOM.intItemId = SC.intItemId AND ItemUOM.intItemUOMId = @intTicketItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		LEFT JOIN dbo.tblCTContractDetail CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
		WHERE	SC.intTicketId = @intTicketId AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0)
--		INSERT INTO dbo.tblICInventoryShipment (
--				strShipmentNumber
--				,dtmShipDate
--				,intOrderType
--				,strReferenceNumber
--				,dtmRequestedArrivalDate
--				,intShipFromLocationId
--				,intEntityCustomerId
--				,intShipToLocationId
--				,intFreightTermId
--				,strBOLNumber
--				,intShipViaId
--				,strVessel
--				,strProNumber
--				,strDriverId
--				,strSealNumber
--				,strDeliveryInstruction
--				,dtmAppointmentTime
--				,dtmDepartureTime
--				,dtmArrivalTime
--				,dtmDeliveredDate
--				,dtmFreeTime
--				,strReceivedBy
--				,strComment
--				,ysnPosted
--				,intEntityId
--				,intCreatedUserId
--				,intConcurrencyId
--				,intSourceType
--		)
--		SELECT	strShipmentNumber			= @ShipmentNumber
--				,dtmShipDate				= SC.dtmTicketDateTime
--				,intOrderType				= @intOrderType
--				,strReferenceNumber			= SC.strCustomerReference
--				,dtmRequestedArrivalDate	= NULL -- TODO
--				,intShipFromLocationId		= SC.intProcessingLocationId
--				,intEntityCustomerId		= SC.intEntityId
--				,intShipToLocationId		= NULL -- TODO
--				,intFreightTermId			= 1 -- TODO
--				,strBOLNumber				= SC.strTicketNumber -- TODO
--				,intShipViaId				= NULL
--				,strVessel					= SC.strTruckName -- TODO
--				,strProNumber				= NULL 
--				,strDriverId				= SC.strDriverName
--				,strSealNumber				= NULL 
--				,strDeliveryInstruction		= NULL 
--				,dtmAppointmentTime			= NULL 
--				,dtmDepartureTime			= NULL 
--				,dtmArrivalTime				= NULL 
--				,dtmDeliveredDate			= NULL 
--				,dtmFreeTime				= NULL 
--				,strReceivedBy				= NULL 
--				,strComment					= SC.strTicketComment
--				,ysnPosted					= 0 
--				,intEntityId				= dbo.fnGetUserEntityId(@intUserId) 
--				,intCreatedUserId			= @intUserId
--				,intConcurrencyId			= 1
--				,intSourceType				= 1
--FROM	dbo.tblSCTicket SC
--WHERE	SC.intTicketId = @intTicketId
END 

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.
	RAISERROR(80029, 11, 1);
	RETURN;
END

-- Insert the Inventory Shipment detail items 
BEGIN 
	SELECT @intFreightItemId = SCSetup.intFreightItemId, @intHaulerId = SCTIicket.intHaulerId, @ysnDeductFreightFarmer = SCTIicket.ysnFarmerPaysFreight FROM tblSCScaleSetup SCSetup
	LEFT JOIN tblSCTicket SCTIicket ON SCSetup.intScaleSetupId = SCTIicket.intScaleSetupId
	WHERE intTicketId = @intTicketId

	INSERT INTO @ShipmentChargeStagingTable
	(
		[intOrderType]
		,[intSourceType]
		,[intEntityCustomerId]
		,[dtmShipDate]
		,[intShipFromLocationId]
		,[intShipToLocationId]
		,[intFreightTermId]

		-- Charges
		,[intContractId]
		,[intCurrency]
		,[intChargeId]
		,[strCostMethod]
		,[dblRate]
		,[intCostUOMId]
		,[intEntityVendorId]
		,[dblAmount]
		,[ysnAccrue]
		,[ysnPrice]
	)
	SELECT
	[intOrderType]						= SE.intOrderType
	,[intSourceType]					= SE.intSourceType
	,[intEntityCustomerId]				= SE.intEntityCustomerId
	,[dtmShipDate]						= SE.dtmShipDate
	,[intShipFromLocationId]			= SE.intShipFromLocationId
	,[intShipToLocationId]				= SE.intShipToLocationId
	,[intFreightTermId]					= SE.intFreightTermId
	--Charges
	,[intContractId]					= NULL
	,[intCurrencyId]  					= SE.intCurrencyId
	,[intChargeId]						= IC.intItemId
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE 
												WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
												WHEN QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
											END
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= @intTicketItemUOMId
	,[intOtherChargeEntityVendorId]		= NULL
	,[dblAmount]						= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 0
											WHEN IC.strCostMethod = 'Amount' THEN 
											CASE 
												WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
												WHEN QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
											END
										END
	,[ysnAccrue]						= CASE
											WHEN QM.dblDiscountAmount < 0 THEN 1
											WHEN QM.dblDiscountAmount > 0 THEN IC.ysnAccrue
										END
	,[ysnPrice]							= CASE
											WHEN QM.dblDiscountAmount < 0 THEN 1
											WHEN QM.dblDiscountAmount > 0 THEN IC.ysnPrice
										END
	FROM @ShipmentStagingTable SE
	INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SE.intSourceId
	INNER JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	WHERE SE.intSourceId = @intTicketId AND QM.dblDiscountAmount != 0

	--Insert record for fee
	INSERT INTO @ShipmentChargeStagingTable
	(
		[intOrderType]
		,[intSourceType]
		,[intEntityCustomerId]
		,[dtmShipDate]
		,[intShipFromLocationId]
		,[intShipToLocationId]
		,[intFreightTermId]

		-- Charges
		,[intContractId]
		,[intCurrency]
		,[intChargeId]
		,[strCostMethod]
		,[dblRate]
		,[intCostUOMId]
		,[intEntityVendorId]
		,[dblAmount]
		,[ysnAccrue]
		,[ysnPrice]
	)
	SELECT	
	[intOrderType]						= SE.intOrderType
	,[intSourceType]					= SE.intSourceType
	,[intEntityCustomerId]				= SE.intEntityCustomerId
	,[dtmShipDate]						= SE.dtmShipDate
	,[intShipFromLocationId]			= SE.intShipFromLocationId
	,[intShipToLocationId]				= SE.intShipToLocationId
	,[intFreightTermId]					= SE.intFreightTermId
	--Charges
	,[intContractId]					= NULL
	,[intCurrencyId]  					= SC.intCurrencyId
	,[intChargeId]						= IC.intItemId
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblTicketFees
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= @intTicketItemUOMId
	,[intOtherChargeEntityVendorId]		= SE.intEntityCustomerId
	,[dblAmount]						= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 0
											WHEN IC.strCostMethod = 'Amount' THEN SC.dblTicketFees
										END
	,[ysnAccrue]						= IC.ysnAccrue
	,[ysnPrice]							= IC.ysnPrice
	FROM @ShipmentStagingTable SE
	INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
	INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
	INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
	WHERE SE.intSourceId = @intTicketId AND SC.dblTicketFees > 0

IF  @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
	END
ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
		SET @ysnPrice = 1
	END
ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnPrice = 1
	END

IF @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnAccrue = 0
		SET @ysnPrice = 0
	END
ELSE
	BEGIN
		--Insert record for other charges
		INSERT INTO @ShipmentChargeStagingTable
		(
			[intOrderType]
			,[intSourceType]
			,[intEntityCustomerId]
			,[dtmShipDate]
			,[intShipFromLocationId]
			,[intShipToLocationId]
			,[intFreightTermId]

			-- Charges
			,[intContractId]
			,[intCurrency]
			,[intChargeId]
			,[strCostMethod]
			,[dblRate]
			,[intCostUOMId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnPrice]
		)
		SELECT	
		[intOrderType]						= SE.intOrderType
		,[intSourceType]					= SE.intSourceType
		,[intEntityCustomerId]				= SE.intEntityCustomerId
		,[dtmShipDate]						= SE.dtmShipDate
		,[intShipFromLocationId]			= SE.intShipFromLocationId
		,[intShipToLocationId]				= SE.intShipToLocationId
		,[intFreightTermId]					= SE.intFreightTermId
		--Charges
		,[intContractId]					= SE.intOrderId
		,[intCurrencyId]  					= SE.intCurrencyId
		,[intChargeId]						= @intFreightItemId
		,[strCostMethod]					= 'Per Unit'
		,[dblRate]							= SC.dblFreightRate
		,[intCostUOMId]						= @intTicketItemUOMId
		,[intOtherChargeEntityVendorId]		= @intHaulerId
		,[dblAmount]						= 0
		,[ysnAccrue]						= @ysnAccrue
		,[ysnPrice]							= @ysnPrice
		FROM @ShipmentStagingTable SE
		INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
		WHERE SE.intSourceId = @intTicketId AND SC.dblFreightRate > 0
	END
	--INSERT INTO dbo.tblICInventoryShipmentItem (
	--		intInventoryShipmentId
	--		,intSourceId
	--		,intLineNo
	--		,intOrderId
	--		,intItemId
	--		,intSubLocationId
	--		,dblQuantity
	--		,intItemUOMId
	--		,intWeightUOMId
	--		,dblUnitPrice
	--		,intDockDoorId
	--		,strNotes
	--		,intSort
	--		,intConcurrencyId
	--		,intOwnershipType
	--		,intStorageLocationId
	--		,intDiscountSchedule
	--)
	--SELECT			
	--		intInventoryShipmentId	= @InventoryShipmentId
	--		,intSourceId			= @intTicketId
	--		,intLineNo				= ISNULL (LI.intTransactionDetailId, 1)
	--		,intOrderId				= CNT.intContractHeaderId
	--		,intItemId				= SC.intItemId
	--		,intSubLocationId		= SC.intSubLocationId
	--		,dblQuantity			= LI.dblQty
	--		,intItemUOMId			= LI.intItemUOMId
	--		,intWeightUOMId			= (SELECT intUnitMeasureId from tblSCScaleSetup WHERE intScaleSetupId = SC.intScaleSetupId)
	--		--,dblUnitPrice			= LI.dblCost
	--		,dblUnitPrice			= SC.dblUnitPrice + SC.dblUnitBasis
	--		,intDockDoorId			= NULL
	--		,strNotes				= SC.strTicketComment
	--		,intSort				= 1
	--		,intConcurrencyId		= 1
	--		,intOwnershipType       = CASE
	--								  WHEN LI.ysnIsStorage = 0
	--								  THEN 1
	--								  WHEN LI.ysnIsStorage = 1
	--								  THEN 2
	--								  END
	--		,intStorageLocationId	= SC.intStorageLocationId
	--		,intDiscountSchedule	= SC.intDiscountId
	--FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId 
	--		INNER JOIN dbo.tblICItemUOM ItemUOM	ON ItemUOM.intItemId = SC.intItemId
	--		INNER JOIN dbo.tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--		LEFT JOIN dbo.tblCTContractDetail CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
	--WHERE	SC.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
END

SELECT @checkContract = COUNT(intOrderType) FROM @ShipmentStagingTable WHERE intOrderType = 1;
IF(@checkContract > 0)
	UPDATE @ShipmentStagingTable SET intOrderType = 1

SELECT @total = COUNT(*) FROM @ShipmentStagingTable;
IF (@total = 0)
	RETURN;

SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
IF @intLotType != 0
BEGIN 
	INSERT INTO @ShipmentItemLotStagingTable(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intItemLotGroup
		, intLotId
		, dblQuantityShipped
		, dblGrossWeight
		, dblTareWeight
		, dblWeightPerQty
		, strWarehouseCargoNumber)
	SELECT 
		intOrderType				= SE.intOrderType
		, intSourceType 			= SE.intSourceType
		, intEntityCustomerId		= SE.intEntityCustomerId
		, dtmShipDate				= SE.dtmShipDate
		, intShipFromLocationId		= SE.intShipFromLocationId
		, intShipToLocationId		= SE.intShipToLocationId
		, intFreightTermId			= SE.intFreightTermId
		, intItemLotGroup			= SE.intItemLotGroup
		, intLotId					= NULL
		, dblQuantityShipped		= SE.dblQuantity
		, dblGrossWeight			= SC.dblGrossWeight
		, dblTareWeight				= SC.dblTareWeight
		, dblWeightPerQty			= 0
		, strWarehouseCargoNumber	= SC.strTicketNumber
		FROM @ShipmentStagingTable SE INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
END

EXEC dbo.uspICAddItemShipment
		@ShipmentStagingTable
		,@ShipmentChargeStagingTable
		,@ShipmentItemLotStagingTable
		,@intUserId;

-- Insert into the reservation table. 
--BEGIN 
--    EXEC uspICReserveStockForInventoryShipment
--        @InventoryShipmentId
--END 
SELECT @InventoryShipmentId = intInventoryShipmentId  FROM tblICInventoryShipmentItem
where intSourceId = @intTicketId
ORDER BY intInventoryShipmentId DESC

UPDATE	SC
SET		SC.intInventoryShipmentId = addResult.intInventoryShipmentId
FROM	dbo.tblSCTicket SC INNER JOIN tblICInventoryShipmentItem addResult
			ON SC.intTicketId = addResult.intSourceId

BEGIN
	INSERT INTO [dbo].[tblQMTicketDiscount]
       ([intConcurrencyId]     
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
       ,[strSourceType]
	   ,[intSort]
	   ,[strDiscountChargeType])
	SELECT	DISTINCT [intConcurrencyId]= 1      
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
       ,[intTicketFileId]= ISH.intInventoryShipmentItemId
       ,[strSourceType]= 'Inventory Shipment'
	   ,[intSort]=SD.[intSort]
	   ,[strDiscountChargeType]=SD.[strDiscountChargeType]
	FROM dbo.tblICInventoryShipmentItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Scale' AND
	SD.intTicketFileId = @intTicketId WHERE	ISH.intSourceId = @intTicketId 
	AND ISH.intInventoryShipmentId = @InventoryShipmentId
END
GO
