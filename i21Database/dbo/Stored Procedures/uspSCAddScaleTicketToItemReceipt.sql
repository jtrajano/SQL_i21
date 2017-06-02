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

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @dblTicketGross AS DECIMAL (38, 20)
DECLARE @dblTicketTare AS DECIMAL (38, 20)
DECLARE @intScaleStationId AS INT
--DECLARE @intFreightItemId AS INT
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
		@intFutureMarketId AS INT,
		@batchId AS NVARCHAR(40),
		@ticketBatchId AS NVARCHAR(40),
		@splitDistribution AS NVARCHAR(40);
		
BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId, @intFutureMarketId = IC.intFutureMarketId, @splitDistribution = SC.strDistributionOption
	FROM	dbo.tblSCTicket SC 
	LEFT JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	LEFT JOIN dbo.tblICCommodity IC On SC.intCommodityId = IC.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId, @intContractDetailId = SC.intContractId
	FROM	dbo.tblICItemUOM UM	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
END

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int,
		@intSurchargeItemId as int,
		@intFreightItemId as int;

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemReceiptResult (
		intSourceId INT
		,intInventoryReceiptId INT
	)
END 

--IF(@batchId IS NULL)
--	EXEC uspSMGetStartingNumber 105, @batchId OUT

--SET @ticketBatchId = @batchId

-- Insert Entries to Stagging table that needs to processed to Transport Load
INSERT into @ReceiptStagingTable(
		-- Header
		strReceiptType
		,intEntityVendorId
		,strBillOfLadding
		,intCurrencyId
		,intLocationId
		,intShipFromId
		,intShipViaId
		,intDiscountSchedule
		,strVendorRefNo
		,intForexRateTypeId
		,dblForexRate
				
		-- Detail				
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,intGrossNetUOMId
		,intCostUOMId				
		,intContractHeaderId
		,intContractDetailId
		,dtmDate				
		,dblQty
		,dblCost				
		,dblExchangeRate
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,ysnIsStorage
		,dblFreightRate
		,intSourceId
		,intSourceType	
		,strSourceScreenName
)	
SELECT 
		strReceiptType				= CASE 
										WHEN LI.strSourceTransactionId = 'SPT' THEN 'Purchase Contract'
										WHEN LI.strSourceTransactionId = 'CNT' THEN 'Purchase Contract'
										WHEN LI.strSourceTransactionId = 'LOD' THEN 'Purchase Contract'
										WHEN @strReceiptType = 'Delayed Price' THEN 'Purchase Contract' 
										ELSE 'Direct'
									  END
		,intEntityVendorId			= @intEntityId
		,strBillOfLadding			= NULL
		,intCurrencyId				= CASE
										WHEN ISNULL(CNT.intContractDetailId,0) = 0 THEN SC.intCurrencyId 
										WHEN ISNULL(CNT.intContractDetailId,0) > 0 THEN CNT.intCurrencyId
									END
		,intLocationId				= SC.intProcessingLocationId
		,intShipFromId                = (select top 1 intShipFromId from tblAPVendor where intEntityId = @intEntityId)
		,intShipViaId				= SC.intFreightCarrierId
		,intDiscountSchedule		= SC.intDiscountId
		,strVendorRefNo				= 'TKT-' + SC.strTicketNumber
		,intForexRateTypeId			= CASE
										WHEN ISNULL(SC.intContractId ,0) > 0 THEN CNT.intRateTypeId
										WHEN ISNULL(SC.intContractId ,0) = 0 THEN NULL
									END
		,dblForexRate				= CASE
										WHEN ISNULL(SC.intContractId ,0) > 0 THEN CNT.dblRate
										WHEN ISNULL(SC.intContractId ,0) = 0 THEN NULL
									END
		--Detail
		,intItemId					= SC.intItemId
		,intItemLocationId			= SC.intProcessingLocationId
		,intItemUOMId				= LI.intItemUOMId
		,intGrossNetUOMId			= NULL
		--,intGrossNetUOMId			= ( SELECT TOP 1 ItemUOM.intItemUOMId
		--									FROM dbo.tblICItemUOM ItemUOM INNER JOIN tblSCScaleSetup SCSetup 
		--										ON ItemUOM.intUnitMeasureId = SCSetup.intUnitMeasureId
		--									WHERE SCSetup.intScaleSetupId = SC.intScaleSetupId 
		--										AND ItemUOM.intItemId = SC.intItemId
		--							 )
		,intCostUOMId				= CASE
										WHEN ISNULL(CNT.intPriceItemUOMId,0) = 0 THEN LI.intItemUOMId 
										WHEN ISNULL(CNT.intPriceItemUOMId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(CNT.intItemId, CNT.intPriceItemUOMId)
									END
		,intContractHeaderId		= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN CNT.intContractHeaderId
									  END
		,intContractDetailId		= LI.intTransactionDetailId
		,dtmDate					= SC.dtmTicketDateTime
		,dblQty						= LI.dblQty
		,dblCost					= LI.dblCost
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= NULL --No LOTS from scale
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		,ysnIsStorage				= CASE 
										WHEN CNT.intPricingTypeId = 2 THEN 1
										ELSE LI.ysnIsStorage
									  END
		,dblFreightRate				= SC.dblFreightRate
		,intSourceId				= SC.intTicketId
		,intSourceType		 		= 1 -- Source type for scale is 1 
		,strSourceScreenName		= 'Scale Ticket'
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId INNER JOIN dbo.tblICItemUOM ItemUOM	ON ItemUOM.intItemId = SC.intItemId 
		AND ItemUOM.intItemUOMId = @intTicketItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		LEFT JOIN dbo.vyuCTContractDetailView CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
WHERE	SC.intTicketId = @intTicketId 
		AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0)

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

IF @InventoryReceiptId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	EXEC uspICRaiseError 80004; 
	RETURN;
END

SELECT @intFreightItemId = SCSetup.intFreightItemId, @intHaulerId = SCTicket.intHaulerId
	, @ysnDeductFreightFarmer = SCTicket.ysnFarmerPaysFreight 
	, @ysnDeductFeesCusVen = SCTicket.ysnCusVenPaysFees
FROM tblSCScaleSetup SCSetup LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
WHERE SCTicket.intTicketId = @intTicketId

		INSERT INTO @OtherCharges
		(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]
				,[intCostCurrencyId]  	
				,[intChargeId]
				,[intForexRateTypeId]
				,[dblForexRate] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[strAllocateCostBy] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
		)
		SELECT	
		DISTINCT
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intCostCurrencyId]  				= RE.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= 0
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 
												CASE 
													WHEN QM.dblDiscountAmount < 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId) * -1)
														ELSE (QM.dblDiscountAmount * -1)
													END 
													WHEN QM.dblDiscountAmount > 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId)
														ELSE QM.dblDiscountAmount
													END 
												END
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= CASE
												WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, @intTicketItemUOMId)
												WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
											END
		,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN QM.dblDiscountAmount < 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId) * -1)
														ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, GR.intUnitMeasureId) * -1)
													END 
													WHEN QM.dblDiscountAmount > 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, IC.strCostMethod, GR.intUnitMeasureId)
														ELSE dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, GR.intUnitMeasureId)
													END 
												END
											END
		,[strAllocateCostBy]				= NULL
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		FROM @ReceiptStagingTable RE
		LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = RE.intSourceId
		LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
		LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
		WHERE RE.intSourceId = @intTicketId AND QM.dblDiscountAmount != 0

		--Insert record for fee
		INSERT INTO @OtherCharges
		(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]
				,[intCostCurrencyId]  	
				,[intChargeId]
				,[intForexRateTypeId]
				,[dblForexRate]  
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[strAllocateCostBy] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
		)
		SELECT
        DISTINCT
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intCostCurrencyId]  				= RE.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= 0
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblTicketFees
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, @intTicketItemUOMId)
		,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN SC.dblTicketFees
											END
		,[strAllocateCostBy]				= NULL
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= CASE 
												WHEN @ysnDeductFeesCusVen = 1 THEN 1
												WHEN @ysnDeductFeesCusVen = 0 THEN 0
											END
		,[ysnPrice]							= CASE 
												WHEN @ysnDeductFeesCusVen = 1 THEN 0
												WHEN @ysnDeductFeesCusVen = 0 THEN 1
											END
		FROM @ReceiptStagingTable RE
		INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
		INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
		WHERE RE.intSourceId = @intTicketId AND SC.dblTicketFees > 0

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
				INNER JOIN tblLGLoadDetail LGLD ON LGL.intLoadId = LGLD.intLoadId
				INNER JOIN tblLGLoadCost LGCOST ON LGCOST.intLoadId = LGCOST.intLoadId  
				WHERE LGL.intLoadId = @intLoadId

				IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
						IF ISNULL(@intLoadCostId,0) != 0
							BEGIN
								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]                    = IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN RE.dblFreightRate
																		WHEN IC.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN 0
																		WHEN IC.strCostMethod = 'Amount' THEN ROUND (LoadCost.dblRate  * dbo.fnCalculateQtyBetweenUOM(LoadCost.intItemUOMId, dbo.fnGetMatchingItemUOMId(RE.intItemId, LoadCost.intItemUOMId), SC.dblGrossUnits), 2)
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0

								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]                    = LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= LoadCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
							END
						ELSE
							BEGIN
								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN IC.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN 0
																		WHEN IC.strCostMethod = 'Amount' THEN ROUND (ContractCost.dblRate * dbo.fnCalculateQtyBetweenUOM(ContractCost.intItemUOMId, dbo.fnGetMatchingItemUOMId(RE.intItemId, ContractCost.intItemUOMId), SC.dblGrossUnits), 2)
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0

								INSERT INTO @OtherCharges
								(
										[intEntityVendorId] 
										,[strBillOfLadding] 
										,[strReceiptType] 
										,[intLocationId] 
										,[intShipViaId] 
										,[intShipFromId] 
										,[intCurrencyId]
										,[intCostCurrencyId]  	
										,[intChargeId]
										,[intForexRateTypeId]
										,[dblForexRate] 
										,[ysnInventoryCost] 
										,[strCostMethod] 
										,[dblRate] 
										,[intCostUOMId] 
										,[intOtherChargeEntityVendorId] 
										,[dblAmount] 
										,[strAllocateCostBy] 
										,[intContractHeaderId]
										,[intContractDetailId] 
										,[ysnAccrue]
										,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= ContractCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0
							END
					END
				ELSE
					BEGIN
						IF ISNULL(@intLoadCostId,0) != 0
							BEGIN
								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= LoadCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0

								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN LoadCost.dblRate
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= LoadCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN LoadCost.strCostMethod = 'Amount' THEN LoadCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
							END
						ELSE
							BEGIN
								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= ContractCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0

								INSERT INTO @OtherCharges
								(
									[intEntityVendorId] 
									,[strBillOfLadding] 
									,[strReceiptType] 
									,[intLocationId] 
									,[intShipViaId] 
									,[intShipFromId] 
									,[intCurrencyId]
									,[intCostCurrencyId]  	
									,[intChargeId]
									,[intForexRateTypeId]
									,[dblForexRate] 
									,[ysnInventoryCost] 
									,[strCostMethod] 
									,[dblRate] 
									,[intCostUOMId] 
									,[intOtherChargeEntityVendorId] 
									,[dblAmount] 
									,[strAllocateCostBy] 
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= RE.intCurrencyId
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= ContractCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
																	END
								,[strAllocateCostBy]				=  NULL
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								FROM tblCTContractCost ContractCost 
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0
							END
					END
			END
		ELSE
			BEGIN
				IF ISNULL(@intContractDetailId,0) = 0 
					BEGIN
						INSERT INTO @OtherCharges
						(
								[intEntityVendorId] 
								,[strBillOfLadding] 
								,[strReceiptType] 
								,[intLocationId] 
								,[intShipViaId] 
								,[intShipFromId] 
								,[intCurrencyId]
								,[intCostCurrencyId]  	
								,[intChargeId]
								,[intForexRateTypeId]
								,[dblForexRate]	 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
								,[ysnPrice]
						) 
						SELECT	[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]				= RE.intCurrencyId
								,[intChargeId]						= @intFreightItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= 0
								,[strCostMethod]					= IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN RE.dblFreightRate
																		WHEN IC.strCostMethod = 'Amount' THEN 0
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, RE.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= CASE
																		WHEN @intHaulerId = 0 THEN NULL
																		WHEN @intHaulerId != 0 THEN @intHaulerId
																	END
								,[dblAmount]						=  CASE
																		WHEN IC.strCostMethod = 'Per Unit' THEN 0
																		WHEN IC.strCostMethod = 'Amount' THEN ROUND (RE.dblFreightRate * SC.dblGrossUnits, 2)
																	END
								,[strAllocateCostBy]				= NULL
								,[intContractHeaderId]				= NULL
								,[intContractDetailId]				= NULL
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								FROM @ReceiptStagingTable RE 
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE RE.dblFreightRate != 0
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
						INSERT INTO @OtherCharges
						(
								[intEntityVendorId] 
								,[strBillOfLadding] 
								,[strReceiptType] 
								,[intLocationId] 
								,[intShipViaId] 
								,[intShipFromId] 
								,[intCurrencyId]
								,[intCostCurrencyId]  	
								,[intChargeId]
								,[intForexRateTypeId]
								,[dblForexRate] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
								,[ysnPrice]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intCostCurrencyId]				= RE.intCurrencyId
						,[intChargeId]						= ContractCost.intItemId
						,[intForexRateTypeId]				= RE.intForexRateTypeId
						,[dblForexRate]						= RE.dblForexRate
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= IC.strCostMethod
						,[dblRate]							= CASE
																WHEN IC.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																WHEN IC.strCostMethod = 'Amount' THEN 0
															END
						,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						= CASE
																WHEN IC.strCostMethod = 'Per Unit' THEN 0
																WHEN IC.strCostMethod = 'Amount' THEN ROUND (ContractCost.dblRate  * dbo.fnCalculateQtyBetweenUOM(ContractCost.intItemUOMId, dbo.fnGetMatchingItemUOMId(RE.intItemId, ContractCost.intItemUOMId), SC.dblGrossUnits), 2)
															END
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
						,[intContractDetailId]				= ContractCost.intContractDetailId
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= @ysnPrice
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
					END
				ELSE
					BEGIN
						INSERT INTO @OtherCharges
						(
							[intEntityVendorId] 
							,[strBillOfLadding] 
							,[strReceiptType] 
							,[intLocationId] 
							,[intShipViaId] 
							,[intShipFromId] 
							,[intCurrencyId]
							,[intCostCurrencyId]  	
							,[intChargeId]
							,[intForexRateTypeId]
							,[dblForexRate] 
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
							,[ysnPrice]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intCostCurrencyId]				= RE.intCurrencyId
						,[intChargeId]						= ContractCost.intItemId
						,[intForexRateTypeId]				= RE.intForexRateTypeId
						,[dblForexRate]						= RE.dblForexRate
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
															END
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						= CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																WHEN ContractCost.strCostMethod = 'Amount' THEN ContractCost.dblRate
															END
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
						,[intContractDetailId]				= ContractCost.intContractDetailId
						,[ysnAccrue]						= ContractCost.ysnAccrue
						,[ysnPrice]							= ContractCost.ysnPrice
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
						WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
					END
				INSERT INTO @OtherCharges
					(
							[intEntityVendorId] 
							,[strBillOfLadding] 
							,[strReceiptType] 
							,[intLocationId] 
							,[intShipViaId] 
							,[intShipFromId] 
							,[intCurrencyId]
							,[intCostCurrencyId]  	
							,[intChargeId] 
							,[intForexRateTypeId]
							,[dblForexRate]
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
							,[ysnPrice]
					)
					SELECT	
					[intEntityVendorId]					= RE.intEntityVendorId
					,[strBillOfLadding]					= RE.strBillOfLadding
					,[strReceiptType]					= RE.strReceiptType
					,[intLocationId]					= RE.intLocationId
					,[intShipViaId]						= RE.intShipViaId
					,[intShipFromId]					= RE.intShipFromId
					,[intCurrencyId]  					= RE.intCurrencyId
					,[intCostCurrencyId]				= RE.intCurrencyId
					,[intChargeId]						= ContractCost.intItemId
					,[intForexRateTypeId]				= RE.intForexRateTypeId
					,[dblForexRate]						= RE.dblForexRate
					,[ysnInventoryCost]					= 0
					,[strCostMethod]					= ContractCost.strCostMethod
					,[dblRate]							= CASE
															WHEN ContractCost.strCostMethod = 'Per Unit' THEN ContractCost.dblRate
															WHEN ContractCost.strCostMethod = 'Amount' THEN 0
														END
					,[intCostUOMId]						= ContractCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
					,[dblAmount]						= CASE
															WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
															WHEN ContractCost.strCostMethod = 'Amount' THEN  ContractCost.dblRate
														END
					,[strAllocateCostBy]				=  NULL
					,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
					,[intContractDetailId]				= ContractCost.intContractDetailId
					,[ysnAccrue]						= ContractCost.ysnAccrue
					,[ysnPrice]							= ContractCost.ysnPrice
					FROM tblCTContractCost ContractCost
					LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
					LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
					WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
			END
	END

SELECT @checkContract = COUNT(intContractDetailId) FROM @ReceiptStagingTable WHERE intContractDetailId != 0;
IF(@checkContract > 0)
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'

SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
IF (@total = 0)
	RETURN;

EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		,@OtherCharges
		,@intUserId;

-- Update the Inventory Receipt Key to the Transaction Table
UPDATE	SC
SET		SC.intInventoryReceiptId = addResult.intInventoryReceiptId
FROM	dbo.tblSCTicket SC INNER JOIN #tmpAddItemReceiptResult addResult
			ON SC.intTicketId = addResult.intSourceId

_PostOrUnPost:
-- Post the Inventory Receipts                                            
DECLARE @ReceiptId INT
		--,@intEntityId INT
		,@strTransactionId NVARCHAR(50);

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult) 
BEGIN

	SELECT TOP 1 
			@ReceiptId = intInventoryReceiptId  
	FROM	#tmpAddItemReceiptResult 
  
	SET @InventoryReceiptId = @ReceiptId

	UPDATE tblGRStorageHistory 
	SET [intInventoryReceiptId] = @InventoryReceiptId
	WHERE [strType] = 'From Scale' AND intCustomerStorageId = (SELECT MAX(intCustomerStorageId) FROM tblGRCustomerStorage) 
	AND ISNULL(intInventoryReceiptId,0) = 0

	--DECLARE @intInventoryReceiptItemId	INT = NULL,
	--		@dblQty						NUMERIC(18,6) = 0

	--SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId) 
	--FROM	tblICInventoryReceiptItem
	--WHERE	intInventoryReceiptId = @InventoryReceiptId

	--WHILE ISNULL(@intInventoryReceiptItemId,0) > 0
	--BEGIN
	--	SELECT	@dblQty						=	dblOpenReceive,
	--			@intContractDetailId		=	intLineNo
	--	FROM	tblICInventoryReceiptItem 
	--	WHERE	intInventoryReceiptItemId	=	 @intInventoryReceiptItemId

	--	IF @intContractDetailId > 0
	--	BEGIN
	--		EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId, @dblQty, @intUserId, @intInventoryReceiptItemId, 'Scale', @intTicketItemUOMId
	--	END

	--	SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId) 
	--	FROM	tblICInventoryReceiptItem
	--	WHERE	intInventoryReceiptId = @InventoryReceiptId	AND
	--			intInventoryReceiptItemId > @intInventoryReceiptItemId
	--END

	-- Post the Inventory Receipt that was created
	--SELECT	@strTransactionId = strReceiptNumber 
	--FROM	tblICInventoryReceipt 
	--WHERE	intInventoryReceiptId = @ReceiptId

	--SELECT	TOP 1 @intEntityId = [intEntityUserSecurityId] 
	--FROM	dbo.tblSMUserSecurity 
	--WHERE	[intEntityUserSecurityId] = @intEntityId
	--BEGIN
	--EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;			
	--END
		
	DELETE	FROM #tmpAddItemReceiptResult 
	WHERE	intInventoryReceiptId = @ReceiptId
END

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
       ,[intTicketFileId]= ISH.intInventoryReceiptItemId
       ,[strSourceType]= 'Inventory Receipt'
	   ,[intSort]=SD.[intSort]
	   ,[strDiscountChargeType]=SD.[strDiscountChargeType]
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
IRI.intInventoryReceiptId = @InventoryReceiptId AND dbo.fnGetItemLotType(IRI.intItemId) <> 0;

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
           ,[strGarden]
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
           ,[strLotNumber]  = @strTicketNumber 
           ,[strLotAlias] = RCT.intSourceId 
           ,[intSubLocationId] = RCT.intSubLocationId
           ,[intStorageLocationId] = RCT.intStorageLocationId
           ,[intItemUnitMeasureId] = RCT.intUnitMeasureId
           ,[dblQuantity] = RCT.dblReceived
           ,[dblGrossWeight] = RCT.dblGross
           ,[dblTareWeight] = RCT.dblGross - RCT.dblNet
           ,[dblCost] = RCT.dblUnitCost
           ,[intUnitPallet] = NULL
           ,[dblStatedGrossPerUnit] = NULL
           ,[dblStatedTarePerUnit] = NULL
           ,[strContainerNo] = NULL
           ,[intEntityVendorId] = NULL
           ,[strGarden] = NULL
           ,[strMarkings] = NULL 
           ,[intOriginId] = NULL
           ,[intSeasonCropYear] = NULL
           ,[strVendorLotId] = NULL
           ,[dtmManufacturedDate] = NULL
           ,[strRemarks] = NULL
           ,[strCondition] = NULL
           ,[dtmCertified] = NULL
           ,[dtmExpiryDate] = DATEADD(YEAR, 2, ICIR.dtmReceiptDate)
           ,[intSort] = NULL
           ,[intConcurrencyId] = 1
		   FROM	dbo.tblICInventoryReceiptItem RCT
				INNER JOIN dbo.tblICInventoryReceipt ICIR ON RCT.intInventoryReceiptId = ICIR.intInventoryReceiptId
		   WHERE RCT.intInventoryReceiptItemId = @intLoopReceiptItemId
   END

   -- Attempt to fetch next row from cursor
   FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;