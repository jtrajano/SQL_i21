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
		,@ysnDeductFeesCusVen AS BIT;
DECLARE @strTicketNumber AS NVARCHAR(40)
DECLARE @dblTicketFees AS DECIMAL(7, 2)
DECLARE @checkContract AS INT
DECLARE @intContractDetailId AS INT,
		@intLoadContractId AS INT,
		@intLoadId AS INT,
		@intLoadCostId AS INT,
		@intHaulerId AS INT,
		@ysnAccrue AS BIT,
		@ysnPrice AS BIT,
		@splitDistribution AS NVARCHAR(40);

DECLARE @SALES_CONTRACT AS INT = 1
		,@SALES_ORDER AS INT = 2
		,@TRANSFER_ORDER AS INT = 3

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT 

IF @ShipmentNumber IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	RAISERROR('Unable to generate the Transaction Id. Please ask your local administrator to check the starting numbers setup.', 11, 1);
	RETURN;
END 

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT,
		@intItemId INT,
		@intLotType INT
BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId, @splitDistribution = SC.strDistributionOption
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
		,intShipToLocationId		= AR.intShipToId
		,intShipViaId				= SC.intFreightCarrierId
		,intFreightTermId			= (select top 1 intFreightTermId from tblEMEntityLocation where intEntityLocationId = AR.intShipToId)
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
		LEFT JOIN tblARCustomer AR ON AR.intEntityCustomerId = SC.intEntityId
		WHERE	SC.intTicketId = @intTicketId AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0)
END 

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.
	EXEC uspICRaiseError 80029; 
	RETURN;
END

-- Insert the Inventory Shipment detail items 
BEGIN 
	SELECT @intFreightItemId = SCSetup.intFreightItemId, @intHaulerId = SCTicket.intHaulerId
	, @ysnDeductFreightFarmer = SCTicket.ysnFarmerPaysFreight 
	, @ysnDeductFeesCusVen = SCTicket.ysnCusVenPaysFees
	FROM tblSCScaleSetup SCSetup
	LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId
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
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE
												WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SE.intSourceId, SE.intEntityCustomerId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId) * -1)
												ELSE (QM.dblDiscountAmount * -1)
											END 
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END

	,[intCostUOMId]						= CASE
											WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, @intTicketItemUOMId)
											WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
										END
	,[intOtherChargeEntityVendorId]		= NULL
	,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SE.intSourceId, SE.intEntityCustomerId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId) * -1)
													ELSE (dbo.fnSCCalculateDiscount(SE.intSourceId,QM.intTicketDiscountId, GR.intUnitMeasureId) * -1)
												END 
											END
	,[ysnAccrue]						= 0
	,[ysnPrice]							= 1
	FROM @ShipmentStagingTable SE
	LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = SE.intSourceId
	LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
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
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE
												WHEN @ysnDeductFeesCusVen = 1 THEN SC.dblTicketFees
												WHEN @ysnDeductFeesCusVen = 0 THEN (SC.dblTicketFees * -1)
											END
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= @intTicketItemUOMId
	,[intOtherChargeEntityVendorId]		= SE.intEntityCustomerId
	,[dblAmount]						= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 0
											WHEN IC.strCostMethod = 'Amount' THEN 
											CASE
												WHEN @ysnDeductFeesCusVen = 1 THEN SC.dblTicketFees
												WHEN @ysnDeductFeesCusVen = 0 THEN (SC.dblTicketFees * -1)
											END
										END
	,[ysnAccrue]						= 0
	,[ysnPrice]							= 1
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
IF ISNULL(@intFreightItemId,0) = 0
	SET @intFreightItemId = 0

	BEGIN
		IF	ISNULL(@intLoadId,0) != 0 
			BEGIN
				SELECT @intLoadContractId = LGLD.intPContractDetailId, @intLoadCostId = LGCOST.intLoadCostId FROM tblLGLoad LGL
				INNER JOIN tblLGLoadDetail LGLD
				ON LGL.intLoadId = LGLD.intLoadId
				INNER JOIN tblLGLoadCost LGCOST
				ON LGCOST.intLoadId = LGCOST.intLoadId  
				WHERE LGL.intLoadId = @intLoadId

				IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) != 0
					BEGIN
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
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= @intHaulerId
								,[dblAmount]						=  0
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice

								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
								WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND SC.dblFreightRate != 0 
						IF ISNULL(@intLoadCostId,0) != 0
							BEGIN
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
								,[intChargeId]						= LoadCost.intItemId
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= LoadCost.dblRate
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						=  0
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM @ShipmentStagingTable SE
								LEFT JOIN tblLGLoadDetail LoadDetail ON (SE.intLineNo = LoadDetail.intPContractDetailId AND SE.intOrderId = @intLoadContractId)
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadCost.dblRate != 0;
							END
						ELSE
							BEGIN
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
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= ContractCost.dblRate
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						=  0
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.intItemId != @intFreightItemId AND ContractCost.dblRate != 0
							END
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) = 0 AND @ysnDeductFreightFarmer = 1
					BEGIN
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
						,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
						,[intOtherChargeEntityVendorId]		= @intHaulerId
						,[dblAmount]						=  0
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= @ysnPrice
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
						WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND SC.dblFreightRate != 0 
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
						IF ISNULL(@intLoadCostId,0) != 0
							BEGIN
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
								,[intChargeId]						= LoadCost.intItemId
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END	
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0

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
								,[intChargeId]						= LoadCost.intItemId
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END	
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
							END
						ELSE
							BEGIN
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
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END	
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0

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
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END	
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0
							END
					END
				ELSE
					BEGIN
						IF ISNULL(@intLoadCostId,0) != 0
							BEGIN
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
								,[intChargeId]						= LoadCost.intItemId
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END	
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0

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
								,[intChargeId]						= LoadCost.intItemId
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END	
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
							END
						ELSE
							BEGIN
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
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END	
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId 
								WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0

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
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END	
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(ContractCost.intItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END	
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0
							END
					END
			END
		ELSE
			BEGIN
				IF ISNULL(@intContractDetailId,0) = 0 
					BEGIN
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
						,[intChargeId]						= @intFreightItemId
						,[strCostMethod]					= 'Per Unit'
						,[dblRate]							= SC.dblFreightRate
						,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SE.intItemUOMId)
						,[intOtherChargeEntityVendorId]		= CASE
																WHEN @intHaulerId > 0 THEN @intHaulerId
																WHEN @intHaulerId = 0 THEN NULL
															END
						,[dblAmount]						= 0
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= @ysnPrice
						FROM @ShipmentStagingTable SE 
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
						WHERE SC.dblFreightRate > 0
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) != 0
					BEGIN
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
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN SC.dblFreightRate
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
															END
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= @intHaulerId
						,[dblAmount]						=  CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																WHEN ContractCost.strCostMethod = 'Amount' THEN SC.dblFreightRate
															END	
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= @ysnPrice
						FROM tblCTContractCost ContractCost 
						LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
						WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND SC.dblFreightRate != 0 
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) = 0 AND @ysnDeductFreightFarmer = 1
					BEGIN
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
						,[intChargeId]						= ContractCost.intItemId
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN SC.dblFreightRate
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
															END
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						=  CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																WHEN ContractCost.strCostMethod = 'Amount' THEN SC.dblFreightRate
															END	
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= @ysnPrice
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
						WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND SC.dblFreightRate != 0 
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
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
						,[intChargeId]						= ContractCost.intItemId
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
															END
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						=  CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
															END	
						,[ysnAccrue]						= ContractCost.ysnAccrue
						,[ysnPrice]							= ContractCost.ysnPrice
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
						WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND ContractCost.dblRate != 0
					END
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
				,[intChargeId]						= ContractCost.intItemId
				,[strCostMethod]					= ContractCost.strCostMethod
				,[dblRate]							= CASE
														WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
														WHEN ContractCost.strCostMethod = 'Amount' THEN 0
													END
				,[intCostUOMId]						= ContractCost.intItemUOMId
				,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
				,[dblAmount]						=  CASE
														WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
														WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
													END	
				,[ysnAccrue]						= ContractCost.ysnAccrue
				,[ysnPrice]							= ContractCost.ysnPrice
				FROM tblCTContractCost ContractCost
				LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
				WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId IS NOT NULL AND ContractCost.dblRate != 0
			END
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
