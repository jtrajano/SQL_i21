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
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemShipmentResult (
		intSourceId INT
		,intInventoryShipmentId INT
	)
END 

-- Insert Entries to Stagging table that needs to processed to Shipment Load
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
		,intForexRateTypeId
		,dblForexRate
		
		,intItemId
		,intLineNo
		,intOwnershipType
		,dblQuantity
		,dblUnitPrice
		,intWeightUOMId
		,intSubLocationId
		,intStorageLocationId
		,intStorageScheduleTypeId
		,intItemUOMId
		,intItemLotGroup
		,intDestinationGradeId
		,intDestinationWeightId
		
		,intOrderId
		,dtmShipDate
		,intSourceId
		,intSourceType
		,strSourceScreenName
		)
		SELECT
		intOrderType				= @intOrderType
		,intEntityCustomerId		= @intEntityId
		,intCurrencyId				= CASE
										WHEN ISNULL(CNT.intContractDetailId,0) = 0 THEN SC.intCurrencyId 
										WHEN ISNULL(CNT.intContractDetailId,0) > 0 THEN CNT.intCurrencyId
									END
		,intShipFromLocationId		= SC.intProcessingLocationId
		,intShipToLocationId		= (select top 1 intShipToId from tblARCustomer where intEntityCustomerId = @intEntityId)
		,intShipViaId				= SC.intFreightCarrierId
		,intFreightTermId			= 1
		,strBOLNumber				= SC.strTicketNumber
		,intDiscountSchedule		= SC.intDiscountId
		,intForexRateTypeId			= CASE
										WHEN ISNULL(SC.intContractId ,0) > 0 THEN CNT.intRateTypeId
										WHEN ISNULL(SC.intContractId ,0) = 0 THEN NULL
									END
		,dblForexRate				= CASE
										WHEN ISNULL(SC.intContractId ,0) > 0 THEN CNT.dblRate
										WHEN ISNULL(SC.intContractId ,0) = 0 THEN NULL
									END
		
		
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
		,intStorageScheduleTypeId	= CASE
									  WHEN LI.ysnIsStorage = 0 THEN NULL
									  WHEN LI.ysnIsStorage = 1 THEN 
										CASE 
											WHEN ISNULL(SC.intStorageScheduleTypeId,0) > 0 THEN SC.intStorageScheduleTypeId
											WHEN ISNULL(SC.intStorageScheduleTypeId,0) = 0 THEN (SELECT intDefaultStorageTypeId FROM	tblSCScaleSetup WHERE intScaleSetupId = SC.intScaleSetupId)
										END
									  END
		,intItemUOMId				= LI.intItemUOMId
		,intItemLotGroup			= LI.intItemId
		,intDestinationGradeId		= SC.intGradeId
		,intDestinationWeightId		= SC.intWeightId
		
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
		,[intForexRateTypeId]
		,[dblForexRate]

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
	,[intForexRateTypeId]				= SE.intForexRateTypeId
	,[dblForexRate]						= SE.dblForexRate

	--Charges
	,[intContractId]					= NULL
	,[intCurrencyId]  					= SE.intCurrencyId
	,[intChargeId]						= IC.intItemId
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN (QM.dblDiscountAmount * -1)
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= @intTicketItemUOMId
	,[intOtherChargeEntityVendorId]		= NULL
	,[dblAmount]						= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 0
											WHEN IC.strCostMethod = 'Amount' THEN (dbo.fnSCCalculateDiscount(SE.intSourceId,QM.intTicketDiscountId) * -1)
										END
	,[ysnAccrue]						= 0
	,[ysnPrice]							= 1
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
		,[intForexRateTypeId]
		,[dblForexRate]

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
	,[intForexRateTypeId]				= SE.intForexRateTypeId
	,[dblForexRate]						= SE.dblForexRate

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
			,[intForexRateTypeId]
			,[dblForexRate]

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
		,[intForexRateTypeId]				= SE.intForexRateTypeId
		,[dblForexRate]						= SE.dblForexRate

		--Charges
		,[intContractId]					= SE.intOrderId
		,[intCurrencyId]  					= SE.intCurrencyId
		,[intChargeId]						= @intFreightItemId
		,[strCostMethod]					= 'Per Unit'
		,[dblRate]							= SC.dblFreightRate
		,[intCostUOMId]						= @intTicketItemUOMId
		,[intOtherChargeEntityVendorId]		= CASE
												WHEN @intHaulerId > 0 THEN @intHaulerId
												WHEN @intHaulerId = 0 THEN NULL
											END
		,[dblAmount]						= 0
		,[ysnAccrue]						= @ysnAccrue
		,[ysnPrice]							= @ysnPrice
		FROM @ShipmentStagingTable SE
		INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
		WHERE SE.intSourceId = @intTicketId AND SC.dblFreightRate > 0
	END
END
SELECT @checkContract = COUNT(intTransactionDetailId) FROM @Items WHERE intTransactionDetailId > 0;
IF(@checkContract > 0)
	UPDATE @ShipmentStagingTable SET intOrderType = 1

SELECT @checkContract = COUNT(intOrderType) FROM @ShipmentStagingTable WHERE intOrderType = 1;
IF(@checkContract > 0)
	UPDATE @ShipmentStagingTable SET intOrderType = 1

SELECT @total = COUNT(*) FROM @ShipmentStagingTable;
IF (@total = 0)
	RETURN;

--SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
--IF @intLotType != 0
--BEGIN 
--	INSERT INTO @ShipmentItemLotStagingTable(
--		intOrderType
--		, intSourceType
--		, intEntityCustomerId
--		, dtmShipDate
--		, intShipFromLocationId
--		, intShipToLocationId
--		, intFreightTermId
--		, intItemLotGroup
--		, intLotId
--		, dblQuantityShipped
--		, dblGrossWeight
--		, dblTareWeight
--		, dblWeightPerQty
--		, strWarehouseCargoNumber)
--	SELECT 
--		intOrderType				= SE.intOrderType
--		, intSourceType 			= SE.intSourceType
--		, intEntityCustomerId		= SE.intEntityCustomerId
--		, dtmShipDate				= SE.dtmShipDate
--		, intShipFromLocationId		= SE.intShipFromLocationId
--		, intShipToLocationId		= SE.intShipToLocationId
--		, intFreightTermId			= SE.intFreightTermId
--		, intItemLotGroup			= SE.intItemLotGroup
--		, intLotId					= NULL
--		, dblQuantityShipped		= SE.dblQuantity
--		, dblGrossWeight			= SC.dblGrossWeight
--		, dblTareWeight				= SC.dblTareWeight
--		, dblWeightPerQty			= 0
--		, strWarehouseCargoNumber	= SC.strTicketNumber
--		FROM @ShipmentStagingTable SE INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
--END

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
DECLARE @ShipmentId INT
		,@strTransactionId NVARCHAR(50);
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemShipmentResult) 
BEGIN
	SELECT TOP 1 
			@ShipmentId = intInventoryShipmentId  
	FROM	#tmpAddItemShipmentResult 

	SET @InventoryShipmentId = @ShipmentId

	DELETE FROM #tmpAddItemShipmentResult 
	WHERE intInventoryShipmentId = @ShipmentId
END 

--SELECT @InventoryShipmentId = MAX(intInventoryShipmentId) from tblICInventoryShipmentItem
--WHERE intSourceId = @intTicketId

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
