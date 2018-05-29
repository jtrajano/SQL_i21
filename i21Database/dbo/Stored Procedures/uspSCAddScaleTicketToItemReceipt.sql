﻿CREATE PROCEDURE [dbo].[uspSCAddScaleTicketToItemReceipt]
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

DECLARE @intTicketItemUOMId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @dblTicketGross AS DECIMAL (38, 20)
DECLARE @dblTicketTare AS DECIMAL (38, 20)
DECLARE @intScaleStationId AS INT
		,@intFreightVendorId AS INT
		,@intItemId AS INT
		,@intLotType AS INT
		,@ysnDeductFreightFarmer AS BIT
		,@ysnDeductFeesCusVen AS BIT
		,@strTicketNumber AS NVARCHAR(40)
		,@dblTicketFees AS DECIMAL(7, 2)
		,@checkContract AS INT
		,@intContractDetailId AS INT
		,@intLoadContractId AS INT
		,@intLoadId AS INT
		,@intLoadCostId AS INT
		,@intHaulerId AS INT
		,@ysnAccrue AS BIT
		,@ysnPrice AS BIT
		,@batchId AS NVARCHAR(40)
		,@ticketBatchId AS NVARCHAR(40)
		,@splitDistribution AS NVARCHAR(40)
		,@ticketStatus AS NVARCHAR(10)
		,@intContractCostId AS INT;
		
BEGIN 
	SELECT @intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId
	, @intContractDetailId = SC.intContractId, @splitDistribution = SC.strDistributionOption
	, @intItemId = SC.intItemId , @ticketStatus = SC.strTicketStatus, @intContractCostId = SC.intContractCostId
	FROM	dbo.tblICItemUOM UM	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
END

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@ReceiptItemLotStagingTable AS ReceiptItemLotStagingTable,
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
		,strChargesLink
		,dblGross
		,dblNet
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
										WHEN ISNULL(CNT.intContractDetailId,0) > 0 THEN
										CASE
											WHEN ISNULL(CNT.intInvoiceCurrencyId,0) > 0 THEN CNT.intInvoiceCurrencyId
											ELSE CNT.intCurrencyId
										END
									END
		,intLocationId				= SC.intProcessingLocationId
		,intShipFromId				= CASE 
										WHEN ISNULL((SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = @intEntityId), 0) > 0
										THEN (SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = @intEntityId)
										ELSE (SELECT TOP 1 intEntityLocationId from tblEMEntityLocation where intEntityId = @intEntityId AND ysnDefaultLocation = 1)
									END
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
		,intGrossNetUOMId			= LI.intItemUOMId
		,intCostUOMId				= CASE
										WHEN ISNULL(CNT.intPriceItemUOMId,0) = 0 THEN LI.intItemUOMId 
										WHEN ISNULL(CNT.intPriceItemUOMId,0) > 0 THEN 
										CASE WHEN CNT.intPricingTypeId = 2 THEN LI.intItemUOMId
										ELSE
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													AND CNT.dblRate IS NOT NULL 
													AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN dbo.fnGetMatchingItemUOMId(CNT.intItemId, LI.intItemUOMId)
												ELSE dbo.fnGetMatchingItemUOMId(CNT.intItemId, CNT.intPriceItemUOMId)
											END
										END
									END
		,intContractHeaderId		= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN CNT.intContractHeaderId
									  END
		,intContractDetailId		= LI.intTransactionDetailId
		,dtmDate					= SC.dtmTicketDateTime
		,dblQty						= LI.dblQty
		,dblCost					= CASE
			                            WHEN CNT.intPricingTypeId = 2 THEN 
										(
											SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,intSettlementUOMId,dblSettlementPrice),0) + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(intSettlementUOMId,CNT.intBasisUOMId,LI.dblCost),0)
											FROM dbo.fnRKGetFutureAndBasisPrice (1,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId)
										)
										ELSE
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													 AND CNT.dblRate IS NOT NULL 
													 AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN 
													dbo.fnCTConvertQtyToTargetItemUOM(
														CNT.intFXPriceUOMId
														,ISNULL(CNT.intPriceItemUOMId,CNT.intAdjItemUOMId)
														,(
															LI.dblCost / CASE WHEN CNT.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CNT.intCent,0) = 0 THEN 1 ELSE CNT.intCent END ELSE 1 END			
														)
													) * CNT.dblRate

												ELSE
													LI.dblCost
											END 
											* -- AD.dblQtyToPriceUOMConvFactor
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													 AND CNT.dblRate IS NOT NULL 
													 AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN 
													dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,CNT.intFXPriceUOMId,1)
												ELSE ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,ISNULL(CNT.intPriceItemUOMId,CNT.intAdjItemUOMId),1),1)
											END 
									END
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= NULL -- SC.intLotId
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		,ysnIsStorage				= LI.ysnIsStorage
		,dblFreightRate				= SC.dblFreightRate
		,intSourceId				= SC.intTicketId
		,intSourceType		 		= 1 -- Source type for scale is 1 
		,strSourceScreenName		= 'Scale Ticket'
		,strChargesLink				= 'CL-'+ CAST (LI.intId AS nvarchar(MAX)) 
		,dblGross					= (LI.dblQty / SC.dblNetUnits) * SC.dblGrossUnits
		,dblNet						= LI.dblQty
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId INNER JOIN dbo.tblICItemUOM ItemUOM	ON ItemUOM.intItemId = SC.intItemId 
		AND ItemUOM.intItemUOMId = @intTicketItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		LEFT JOIN (
			SELECT CTD.intContractHeaderId
			,CTD.intContractDetailId
			,CTD.intItemId
			,CTD.intItemUOMId
			,CTD.intFutureMarketId
			,CTD.intFutureMonthId
			,CTD.intRateTypeId 
			,CTD.intPriceItemUOMId
			,CTD.ysnUseFXPrice
			,CTD.intCurrencyExchangeRateId 
			,CTD.dblRate 
			,CTD.intFXPriceUOMId 
			,CTD.intInvoiceCurrencyId 
			,CTD.intCurrencyId
			,CTD.intAdjItemUOMId
			,CTD.intPricingTypeId
			,CTD.intBasisUOMId
			,CTD.dtmEndDate
			,CU.intCent
			,CU.ysnSubCurrency
			FROM tblCTContractDetail CTD 
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
		) CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
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

	--FOR DISCOUNT CHARGES
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
		,[intContractHeaderId]
		,[intContractDetailId] 
		,[ysnAccrue]
		,[ysnPrice]
		,[strChargesLink]
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
	,[intChargeId]						= IC.intItemId
	,[intForexRateTypeId]				= RE.intForexRateTypeId
	,[dblForexRate]						= RE.dblForexRate
	,[ysnInventoryCost]					= IC.ysnInventoryCost
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE 
												WHEN QM.dblDiscountAmount < 0 THEN 
												CASE
													WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId) * -1)
													ELSE (QM.dblDiscountAmount * -1)
												END 
												WHEN QM.dblDiscountAmount > 0 THEN 
												CASE
													WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId)
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
												WHEN RE.ysnIsStorage = 1 THEN 0
												WHEN RE.ysnIsStorage = 0 THEN
												CASE
													WHEN QM.dblDiscountAmount < 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId) * -1)
														ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId) * -1)
													END 
													WHEN QM.dblDiscountAmount > 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId)
														ELSE dbo.fnSCCalculateDiscount(RE.intSourceId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId)
													END 
												END
											END
										END
	,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = RE.intContractDetailId)
	,[intContractDetailId]				= RE.intContractDetailId
	,[ysnAccrue]						= CASE
											WHEN QM.dblDiscountAmount < 0 THEN 1
											WHEN QM.dblDiscountAmount > 0 THEN 0
										END
	,[ysnPrice]							= CASE
											WHEN QM.dblDiscountAmount < 0 THEN 0
											WHEN QM.dblDiscountAmount > 0 THEN 1
										END
	,[strChargesLink]					= RE.strChargesLink
	FROM @ReceiptStagingTable RE
	LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = RE.intSourceId
	LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
	WHERE RE.intSourceId = @intTicketId AND QM.dblDiscountAmount != 0 AND RE.ysnIsStorage = 0

	--FOR FEE CHARGES
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
		,[intContractHeaderId]
		,[intContractDetailId] 
		,[ysnAccrue]
		,[ysnPrice]
		,[strChargesLink]
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
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= IC.ysnInventoryCost
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblTicketFees
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, @intTicketItemUOMId)
		,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN RE.ysnIsStorage = 1 THEN 0
													WHEN RE.ysnIsStorage = 0 THEN SC.dblTicketFees
												END
											END
		,[intContractHeaderId]				= RE.intContractHeaderId
		,[intContractDetailId]				= RE.intContractDetailId
		,[ysnAccrue]						= CASE 
												WHEN @ysnDeductFeesCusVen = 1 THEN 0
                                                WHEN @ysnDeductFeesCusVen = 0 THEN 1
											END
		,[ysnPrice]							= @ysnDeductFeesCusVen
		,[strChargesLink]					= RE.strChargesLink
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
				INNER JOIN tblLGLoadCost LGCOST ON LGL.intLoadId = LGCOST.intLoadId  
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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= ISNULL(LoadCost.intCurrencyId,RE.intCurrencyId)
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]                    = IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN IC.strCostMethod = 'Amount' THEN 0
																		ELSE RE.dblFreightRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN IC.strCostMethod = 'Amount' THEN ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
																		ELSE 0
																	END						
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId
								AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0

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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= ISNULL(LoadCost.intCurrencyId,RE.intCurrencyId)
								,[intChargeId]						= LoadCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]                    = LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																		ELSE LoadCost.dblRate
																	END
								,[intCostUOMId]						= LoadCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN  ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
																		ELSE 0
																	END								
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblICItem IC ON IC.intItemId = LoadCost.intItemId
								WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intPContractDetailId = @intLoadContractId 
								AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0
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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= ISNULL(ContractCost.intCurrencyId,RE.intCurrencyId)
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]					= IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN IC.strCostMethod = 'Amount' THEN 0
																		ELSE ContractCost.dblRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN IC.strCostMethod = 'Amount' THEN 
																		CASE
																			WHEN RE.ysnIsStorage = 1 THEN 0
																			WHEN RE.ysnIsStorage = 0 THEN ContractCost.dblRate
																		END
																		ELSE 0
																	END
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								,[strChargesLink]					= RE.strChargesLink
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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intEntityVendorId]					= RE.intEntityVendorId
								,[strBillOfLadding]					= RE.strBillOfLadding
								,[strReceiptType]					= RE.strReceiptType
								,[intLocationId]					= RE.intLocationId
								,[intShipViaId]						= RE.intShipViaId
								,[intShipFromId]					= RE.intShipFromId
								,[intCurrencyId]  					= RE.intCurrencyId
								,[intCostCurrencyId]  				= ISNULL(ContractCost.intCurrencyId,RE.intCurrencyId)
								,[intChargeId]						= ContractCost.intItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																		ELSE ContractCost.dblRate
																	END
								,[intCostUOMId]						= ContractCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 
																		CASE
																			WHEN RE.ysnIsStorage = 1 THEN 0
																			WHEN RE.ysnIsStorage = 0 THEN ContractCost.dblRate
																		END
																		ELSE 0
																	END
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM tblCTContractCost ContractCost 
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
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
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]					= LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																		ELSE LoadCost.dblRate
																	END
								,[intCostUOMId]						= LoadCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
																		ELSE 0
																	END
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
								,[intContractDetailId]				= @intLoadContractId
								,[ysnAccrue]						= LoadCost.ysnAccrue
								,[ysnPrice]							= LoadCost.ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM tblLGLoadDetail LoadDetail
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = LoadDetail.intPContractDetailId
								LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblICItem IC ON IC.intItemId = LoadCost.intItemId
								WHERE LoadCost.intLoadId = @intLoadId AND LoadDetail.intPContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
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
									,[intContractHeaderId]
									,[intContractDetailId] 
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
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
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]					= ContractCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																		ELSE ContractCost.dblRate
																	END
								,[intCostUOMId]						= ContractCost.intItemUOMId
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND ((RE.dblQty / SC.dblNetUnits * ContractCost.dblRate), 2)
																		ELSE 0
																	END
								,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= ContractCost.ysnAccrue
								,[ysnPrice]							= ContractCost.ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
								WHERE RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0
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
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
							,[ysnPrice]
							,[strChargesLink]
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
							,[intChargeId]						= @intFreightItemId
							,[intForexRateTypeId]				= RE.intForexRateTypeId
							,[dblForexRate]						= RE.dblForexRate
							,[ysnInventoryCost]					= IC.ysnInventoryCost
							,[strCostMethod]					= IC.strCostMethod
							,[dblRate]							= CASE
																	WHEN IC.strCostMethod = 'Amount' THEN 0
																	ELSE RE.dblFreightRate
																END
							,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, RE.intItemUOMId)
							,[intOtherChargeEntityVendorId]		= CASE
																	WHEN @intHaulerId = 0 THEN NULL
																	WHEN @intHaulerId != 0 THEN @intHaulerId
																END
							,[dblAmount]						=  CASE
																	WHEN IC.strCostMethod = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * SC.dblFreightRate), 2)
																	ELSE 0
																END
							,[intContractHeaderId]				= NULL
							,[intContractDetailId]				= NULL
							,[ysnAccrue]						= @ysnAccrue
							,[ysnPrice]							= @ysnPrice
							,[strChargesLink]					= RE.strChargesLink
							FROM @ReceiptStagingTable RE 
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE RE.dblFreightRate != 0
					END
				ELSE IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
					IF ISNULL(@intContractCostId,0) = 0
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
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
								,[ysnPrice]
								,[strChargesLink]
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
							,[intChargeId]						= SCS.intFreightItemId
							,[intForexRateTypeId]				= RE.intForexRateTypeId
							,[dblForexRate]						= RE.dblForexRate
							,[ysnInventoryCost]					= 0
							,[strCostMethod]					= IC.strCostMethod
							,[dblRate]							= CASE
																	WHEN IC.strCostMethod = 'Amount' THEN 0
																	ELSE SC.dblFreightRate
																	
																END
							,[intCostUOMId]						= SC.intItemUOMIdTo
							,[intOtherChargeEntityVendorId]		= CASE
																		WHEN @intHaulerId = 0 THEN NULL
																		WHEN @intHaulerId != 0 THEN @intHaulerId
																	END
							,[dblAmount]						= CASE
																	WHEN IC.strCostMethod = 'Amount' THEN 
																	CASE
																		WHEN RE.ysnIsStorage = 1 THEN 0
																		WHEN RE.ysnIsStorage = 0 THEN 
																		CASE 
																			WHEN ISNULL(CT.intContractCostId,0) = 0 THEN 
																				(RE.dblQty / SC.dblNetUnits * SC.dblFreightRate)
																			ELSE 
																				ROUND ((RE.dblQty / SC.dblNetUnits * CT.dblRate), 2)
																		END
																	END
																	ELSE 0
																END
							,[intContractHeaderId]				= RE.intContractHeaderId
							,[intContractDetailId]				= RE.intContractDetailId
							,[ysnAccrue]						= @ysnAccrue
							,[ysnPrice]							= @ysnPrice
							,[strChargesLink]					= RE.strChargesLink
							FROM @ReceiptStagingTable RE
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							OUTER APPLY(
								SELECT * FROM tblCTContractCost WHERE intContractDetailId = RE.intContractDetailId 
								AND dblRate != 0 
								AND intItemId = @intFreightItemId
							) CT
							WHERE SC.dblFreightRate != 0
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
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
								,[ysnPrice]
								,[strChargesLink]
							)
							SELECT	
							[intEntityVendorId]					= RE.intEntityVendorId
							,[strBillOfLadding]					= RE.strBillOfLadding
							,[strReceiptType]					= RE.strReceiptType
							,[intLocationId]					= RE.intLocationId
							,[intShipViaId]						= RE.intShipViaId
							,[intShipFromId]					= RE.intShipFromId
							,[intCurrencyId]  					= RE.intCurrencyId
							,[intCostCurrencyId]				= ISNULL(ContractCost.intCurrencyId,RE.intCurrencyId)
							,[intChargeId]						= ContractCost.intItemId
							,[intForexRateTypeId]				= RE.intForexRateTypeId
							,[dblForexRate]						= RE.dblForexRate
							,[ysnInventoryCost]					= IC.ysnInventoryCost
							,[strCostMethod]					= ISNULL(ContractCost.strCostMethod,IC.strCostMethod)
							,[dblRate]							= CASE
																	WHEN ISNULL(ContractCost.strCostMethod,IC.strCostMethod) = 'Amount' THEN 0
																	ELSE ISNULL(ContractCost.dblRate,RE.dblFreightRate)
																END
							,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
							,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
							,[dblAmount]						= CASE
																	WHEN ISNULL(ContractCost.strCostMethod,IC.strCostMethod) = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * ISNULL(ContractCost.dblRate,RE.dblFreightRate)), 2) 
																	ELSE 0
																END
							,[intContractHeaderId]				= RE.intContractHeaderId
							,[intContractDetailId]				= RE.intContractDetailId
							,[ysnAccrue]						= @ysnAccrue
							,[ysnPrice]							= @ysnPrice
							,[strChargesLink]					= RE.strChargesLink
							FROM tblCTContractCost ContractCost
							LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0

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
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
								,[ysnPrice]
								,[strChargesLink]
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
								,[intChargeId]						= @intFreightItemId
								,[intForexRateTypeId]				= RE.intForexRateTypeId
								,[dblForexRate]						= RE.dblForexRate
								,[ysnInventoryCost]					= IC.ysnInventoryCost
								,[strCostMethod]					= SC.strCostMethod
								,[dblRate]							= CASE
																		WHEN SC.strCostMethod = 'Amount' THEN 0
																		ELSE RE.dblFreightRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, RE.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= CASE
																		WHEN @intHaulerId = 0 THEN NULL
																		WHEN @intHaulerId != 0 THEN @intHaulerId
																	END
								,[dblAmount]						=  CASE
																		WHEN SC.strCostMethod = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * SC.dblFreightRate), 2)
																		ELSE 0
																	END
								,[intContractHeaderId]				= NULL
								,[intContractDetailId]				= NULL
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= @ysnPrice
								,[strChargesLink]					= RE.strChargesLink
								FROM @ReceiptStagingTable RE 
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE RE.dblFreightRate != 0 AND RE.intContractDetailId IS NULL
						END
					END
				ELSE
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
					,[intContractHeaderId]
					,[intContractDetailId] 
					,[ysnAccrue]
					,[ysnPrice]
					,[strChargesLink]
				)
				SELECT	
				[intEntityVendorId]					= RE.intEntityVendorId
				,[strBillOfLadding]					= RE.strBillOfLadding
				,[strReceiptType]					= RE.strReceiptType
				,[intLocationId]					= RE.intLocationId
				,[intShipViaId]						= RE.intShipViaId
				,[intShipFromId]					= RE.intShipFromId
				,[intCurrencyId]  					= RE.intCurrencyId
				,[intCostCurrencyId]				= ISNULL(ContractCost.intCurrencyId,RE.intCurrencyId)
				,[intChargeId]						= ContractCost.intItemId
				,[intForexRateTypeId]				= RE.intForexRateTypeId
				,[dblForexRate]						= RE.dblForexRate
				,[ysnInventoryCost]					= IC.ysnInventoryCost
				,[strCostMethod]					= ContractCost.strCostMethod
				,[dblRate]							= CASE
														WHEN ContractCost.strCostMethod = 'Amount' THEN 0
														ELSE ISNULL(ContractCost.dblRate,RE.dblFreightRate)
													END
				,[intCostUOMId]						= ContractCost.intItemUOMId
				,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
				,[dblAmount]						= CASE
														WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * ISNULL(ContractCost.dblRate,RE.dblFreightRate)), 2)
														ELSE 0
													END
				,[intContractHeaderId]				= RE.intContractHeaderId
				,[intContractDetailId]				= RE.intContractDetailId
				,[ysnAccrue]						= ContractCost.ysnAccrue
				,[ysnPrice]							= ContractCost.ysnPrice
				,[strChargesLink]					= RE.strChargesLink
				FROM tblCTContractCost ContractCost
				LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
				LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
				LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
				WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
			END
	END

SELECT @checkContract = COUNT(intId) FROM @ReceiptStagingTable WHERE strReceiptType = 'Purchase Contract' AND ysnIsStorage = 0;
IF(@checkContract > 0)
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'

SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
IF (@total = 0)
	RETURN;

SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
IF @intLotType != 0
BEGIN 
	INSERT INTO @ReceiptItemLotStagingTable(
		[strReceiptType]
		,[intItemId]
		,[intLotId]
		,[strLotNumber]
		,[intLocationId]
		,[intShipFromId]
		,[intShipViaId]	
		,[intSubLocationId]
		,[intStorageLocationId] 
		,[intCurrencyId]
		,[intItemUnitMeasureId]
		,[dblQuantity]
		,[dblGrossWeight]
		,[dblTareWeight]
		,[dblCost]
		,[intEntityVendorId]
		,[dtmManufacturedDate]
		,[strBillOfLadding]
		,[intSourceType]
		,[intContractHeaderId]
		,[intContractDetailId]
	)
	SELECT 
		[strReceiptType]		= RE.strReceiptType
		,[intItemId]			= RE.intItemId
		,[intLotId]				= NULL --RE.intLotId
		,[strLotNumber]			= NULL --SC.strLotNumber
		,[intLocationId]		= RE.intLocationId
		,[intShipFromId]		= RE.intShipFromId
		,[intShipViaId]			= RE.intShipViaId
		,[intSubLocationId]		= RE.intSubLocationId
		,[intStorageLocationId] = RE.intStorageLocationId
		,[intCurrencyId]		= RE.intCurrencyId
		,[intItemUnitMeasureId] = CASE
									WHEN IC.ysnLotWeightsRequired = 1 THEN SC.intItemUOMIdFrom
									ELSE RE.intItemUOMId
								END
		,[dblQuantity]			= RE.dblQty
		,[dblGrossWeight]		= RE.dblQty
		,[dblTareWeight]		= 0
		,[dblCost]				= RE.dblCost
		,[intEntityVendorId]	= RE.intEntityVendorId
		,[dtmManufacturedDate]	= RE.dtmDate
		,[strBillOfLadding]		= ''
		,[intSourceType]		= RE.intSourceType
		,[intContractHeaderId]	= RE.intContractHeaderId
		,[intContractDetailId]	= RE.intContractDetailId

		FROM @ReceiptStagingTable RE 
		INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
		INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = RE.intItemId
END

EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		,@OtherCharges
		,@intUserId
		,@ReceiptItemLotStagingTable;

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

	UPDATE SH  
	SET SH.[intInventoryReceiptId] = @InventoryReceiptId
	FROM tblGRStorageHistory SH
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblICInventoryReceipt IR ON IR.intEntityVendorId=CS.intEntityId 
	WHERE SH.[strType] = 'From Scale' AND IR.intInventoryReceiptId=@InventoryReceiptId 
	AND ISNULL(SH.intInventoryReceiptId,0) = 0

	DELETE	FROM #tmpAddItemReceiptResult 
	WHERE	intInventoryReceiptId = @ReceiptId
END

IF @ticketStatus = 'O'
	SET @ticketStatus = 'Open'
ELSE IF @ticketStatus = 'R'
	SET @ticketStatus = 'Reopen'

EXEC dbo.uspSMAuditLog 
	@keyValue			= @intTicketId						-- Primary Key Value of the Ticket. 
	,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
	,@entityId			= @intUserId						-- Entity Id.
	,@actionType		= 'Updated'							-- Action Type
	,@changeDescription	= 'Ticket Status'					-- Description
	,@fromValue			= @ticketStatus						-- Old Value
	,@toValue			= 'Completed'						-- New Value
	,@details			= '';

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
