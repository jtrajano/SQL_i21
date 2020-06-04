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
		,@intContractCostId AS INT
		,@currencyDecimal AS INT
		,@ysnRequireProducerQty AS BIT
		,@intDeliverySheetId INT
		,@intFreightItemId INT;
DECLARE @_intStorageHistoryId INT
	
SELECT @intFreightItemId = SCSetup.intFreightItemId
	, @intHaulerId = SC.intHaulerId
	, @ysnDeductFreightFarmer = SC.ysnFarmerPaysFreight 
	, @ysnDeductFeesCusVen = SC.ysnCusVenPaysFees
	, @intTicketItemUOMId = SC.intItemUOMIdTo
	, @intLoadId = SC.intLoadId
	, @intContractDetailId = SC.intContractId
	, @splitDistribution = SC.strDistributionOption
	, @intItemId = SC.intItemId 
	, @ticketStatus = SC.strTicketStatus
	, @intContractCostId = SC.intContractCostId
	, @intDeliverySheetId = SC.intDeliverySheetId
FROM tblSCTicket SC 
INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId 
WHERE SC.intTicketId = @intTicketId

IF @ticketStatus = 'C'
BEGIN
	 --Raise the error:
	RAISERROR('Ticket already completed', 16, 1);
	RETURN;
END

SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@ReceiptItemLotStagingTable AS ReceiptItemLotStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int;

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemReceiptResult (
		intSourceId INT
		,intInventoryReceiptId INT
	)
END 


INSERT INTO @ReceiptStagingTable(
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
		,intFreightTermId
		,intLoadReceive
		,ysnAllowVoucher
		,intShipFromEntityId
		,[intLoadShipmentId] 
		,[intLoadShipmentDetailId] 
		,intTaxGroupId
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
		,intShipFromId				= COALESCE(SC.intFarmFieldId, VND.intShipFromId, VNDL.intEntityLocationId)
		,intShipViaId				= SC.intFreightCarrierId
		,intDiscountSchedule		= SC.intDiscountId
		,strVendorRefNo				= 'TKT-' + SC.strTicketNumber
		,intForexRateTypeId			= NULL
		,dblForexRate				= NULL
		--Detail
		,intItemId					= SC.intItemId
		,intItemLocationId			= SC.intProcessingLocationId
		,intItemUOMId				= LI.intItemUOMId
		,intGrossNetUOMId			= LI.intItemUOMId
									/*CASE
										WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN SC.intItemUOMIdFrom
										ELSE LI.intItemUOMId
									END*/
		,intCostUOMId				= LI.intItemUOMId
		,intContractHeaderId		= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN CNT.intContractHeaderId
									  END
		,intContractDetailId		= LI.intTransactionDetailId
		,dtmDate					= SC.dtmTicketDateTime
		,dblQty						= LI.dblQty
		,dblCost					= CASE
			                            WHEN CNT.intPricingTypeId = 2 THEN 
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													 AND CNT.dblRate IS NOT NULL 
													 AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN 
													(SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice),0) + LI.dblCost
													FROM dbo.fnRKGetFutureAndBasisPrice (1,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId,ISNULL(CNT.intInvoiceCurrencyId,CNT.intCurrencyId))
													LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId 
													WHERE futureUOM.intItemId = LI.intItemId)
												ELSE 
													(SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CNT.intBasisUOMId,LI.dblCost),0)),0) 
													FROM dbo.fnRKGetFutureAndBasisPrice (1,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId,ISNULL(CNT.intInvoiceCurrencyId,CNT.intCurrencyId))
													LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId 
													WHERE futureUOM.intItemId = LI.intItemId)
											END 
										ELSE
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													 AND CNT.dblRate IS NOT NULL 
													 AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN CNT.dblSeqPrice
												ELSE LI.dblCost
											END 
											* -- AD.dblQtyToPriceUOMConvFactor
											CASE 
												WHEN CNT.ysnUseFXPrice = 1 
													 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													 AND CNT.dblRate IS NOT NULL 
													 AND CNT.intFXPriceUOMId IS NOT NULL 
												THEN ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(LI.intItemUOMId,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,CNT.intFXPriceUOMId,1),1)),1)
												WHEN CNT.intPricingTypeId = 5 THEN 1
												ELSE ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(LI.intItemUOMId,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,ISNULL(CNT.intPriceItemUOMId,CNT.intAdjItemUOMId),1),1)),1)
											END 
									END
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= SC.intLotId
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		,ysnIsStorage				= LI.ysnIsStorage
		,dblFreightRate				= SC.dblFreightRate
		,intSourceId				= SC.intTicketId
		,intSourceType		 		= 1 -- Source type for scale is 1 
		,strSourceScreenName		= 'Scale Ticket'
		,strChargesLink				= 'CL-'+ CAST (LI.intId AS nvarchar(MAX)) 
		,dblGross					=  CASE
										WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN (LI.dblQty /  SC.dblNetUnits) * (SC.dblGrossWeight - SC.dblTareWeight)
										ELSE (LI.dblQty / SC.dblNetUnits) * SC.dblGrossUnits
									END
		,dblNet						= CASE
										WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN 
											CASE WHEN SC.dblShrink > 0 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, LI.dblQty) ELSE (LI.dblQty /  SC.dblNetUnits) * (SC.dblGrossWeight - SC.dblTareWeight) END
										ELSE LI.dblQty 
									END
		,intFreightTermId			= COALESCE(CNT.intFreightTermId,FRM.intFreightTermId,VNDSF.intFreightTermId,VNDL.intFreightTermId)
		,intLoadReceive				= CASE WHEN CNT.ysnLoad = 1 THEN 1 ELSE NULL END
		,ysnAllowVoucher			= CASE WHEN LI.ysnIsStorage = 1 THEN 0 ELSE
										CASE  
											WHEN CNT.intPricingTypeId = 2 OR CNT.intPricingTypeId = 5 THEN 0 
											ELSE LI.ysnAllowVoucher 
										END
									END
		,intShipFromEntityId		= SC.intEntityId
		,[intLoadShipmentId] 		= CASE WHEN LI.strSourceTransactionId = 'LOD' THEN SC.intLoadId ELSE NULL END
		,[intLoadShipmentDetailId] 	= CASE WHEN LI.strSourceTransactionId = 'LOD' THEN SC.intLoadDetailId ELSE NULL END
		,intTaxGroupId				= CASE WHEN LI.strSourceTransactionId = 'DP' THEN -1 ELSE NULL END
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId 
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
	,CTD.intFreightTermId
	,AD.dblSeqPrice
	,CU.intCent
	,CU.ysnSubCurrency
	,CTH.ysnLoad
	FROM tblCTContractDetail CTD 
	INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
) CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
INNER JOIN tblICItem IC 
	ON IC.intItemId = LI.intItemId
LEFT JOIN tblEMEntityLocation FRM
	ON SC.intFarmFieldId = FRM.intEntityLocationId
LEFT JOIN tblAPVendor VND
	ON SC.intEntityId = VND.intEntityId
LEFT JOIN tblEMEntityLocation VNDL
	ON VND.intEntityId = VNDL.intEntityId
		AND VNDL.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation VNDSF
	ON VND.intShipFromId = VNDSF.intEntityLocationId
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
		,[ysnAllowVoucher]
		,[intLoadShipmentId] 
		,[intLoadShipmentCostId] 
		,intTaxGroupId
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
												WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
												WHEN QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
											END
											WHEN IC.strCostMethod = 'Amount' THEN 0
											ELSE 0
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
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost, 0) * -1)
														ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost) * -1)
													END 
													WHEN QM.dblDiscountAmount > 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost, 0)
														ELSE dbo.fnSCCalculateDiscount(RE.intSourceId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost)
													END 
												END
											END
										END
	,[intContractHeaderId]				= RE.intContractHeaderId
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
	,[ysnAllowVoucher]				= RE.ysnAllowVoucher
	,[intLoadShipmentId] 			= RE.intLoadShipmentId
	,[intLoadShipmentCostId] 		= RE.intLoadShipmentDetailId
	,intTaxGroupId = RE.intTaxGroupId
	FROM @ReceiptStagingTable RE
	LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = RE.intSourceId
	LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
	LEFT JOIN (
		SELECT intContractHeaderId
		,intContractDetailId
		,intPricingTypeId
		FROM tblCTContractDetail 
	) CNT ON CNT.intContractDetailId = RE.intContractDetailId
	WHERE RE.intSourceId = @intTicketId AND (QM.dblDiscountAmount != 0 OR GR.ysnSpecialDiscountCode = 1) AND RE.ysnIsStorage = 0 AND ISNULL(intPricingTypeId,0) IN (0,1,2,5,6) 

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
		,ysnAllowVoucher
		,[intLoadShipmentId] 			
		,[intLoadShipmentCostId] 	
		,intTaxGroupId	
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
											WHEN IC.strCostMethod = 'Amount' THEN ROUND ((RE.dblQty / SC.dblNetUnits * SC.dblTicketFees), 2)
										END
	,[intContractHeaderId]				= RE.intContractHeaderId
	,[intContractDetailId]				= RE.intContractDetailId
	,[ysnAccrue]						= CASE 
											WHEN @ysnDeductFeesCusVen = 1 THEN 0
                                            WHEN @ysnDeductFeesCusVen = 0 THEN 1
										END
	,[ysnPrice]							= @ysnDeductFeesCusVen 
	,[strChargesLink]					= RE.strChargesLink
	,[ysnAllowVoucher]				= RE.ysnAllowVoucher
	,[intLoadShipmentId] 			= RE.intLoadShipmentId
	,[intLoadShipmentCostId] 		= RE.intLoadShipmentDetailId
	,intTaxGroupId = RE.intTaxGroupId
	FROM @ReceiptStagingTable RE
	INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
	INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
	INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
	WHERE RE.intSourceId = @intTicketId AND SC.dblTicketFees > 0 AND RE.ysnIsStorage = 0

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

	--LOAD SCHEDULE
	BEGIN
		IF	ISNULL(@intLoadId,0) != 0 
			BEGIN

				-------OLD CODE--------------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------------------------
				/*BEGIN
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
								,[strCostMethod]                    = LoadCost.strCostMethod
								,[dblRate]							= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																		ELSE RE.dblFreightRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
																		ELSE 0
																	END						
								,[intContractHeaderId]				= RE.intContractHeaderId
								,[intContractDetailId]				= RE.intContractDetailId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(LoadCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
								,[ysnAccrue]						= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN LoadCost.ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
								,[strCostMethod]					= IC.strCostMethod
								,[dblRate]							= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																		ELSE ContractCost.dblRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
								,[dblAmount]						= CASE
																		WHEN ContractCost.strCostMethod = 'Amount' THEN 
																		CASE
																			WHEN RE.ysnIsStorage = 1 THEN 0
																			WHEN RE.ysnIsStorage = 0 THEN ContractCost.dblRate
																		END
																		ELSE 0
																	END
								,[intContractHeaderId]				= RE.intContractHeaderId
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= @ysnAccrue
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(ContractCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
								,[intContractHeaderId]				= RE.intContractHeaderId
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN ContractCost.ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(LoadCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
								,[intContractHeaderId]				= RE.intContractHeaderId
								,[intContractDetailId]				= RE.intContractDetailId
								,[ysnAccrue]						= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN LoadCost.ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
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
									,[ysnAllowVoucher]
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(ContractCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
								,[intContractHeaderId]				= RE.intContractHeaderId
								,[intContractDetailId]				= ContractCost.intContractDetailId
								,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN ContractCost.ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
								WHERE RE.intContractDetailId = @intLoadContractId AND ContractCost.dblRate != 0
							END
					END
				END*/
				---------------------------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------------------------

				BEGIN
					SELECT @intLoadContractId = LGLD.intPContractDetailId, @intLoadCostId = LGCOST.intLoadCostId FROM tblLGLoad LGL
					INNER JOIN tblLGLoadDetail LGLD ON LGL.intLoadId = LGLD.intLoadId
					INNER JOIN tblLGLoadCost LGCOST ON LGL.intLoadId = LGCOST.intLoadId  
					WHERE LGL.intLoadId = @intLoadId
				
					IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
						-- freight other charge
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
									,[ysnAllowVoucher]
									,[intLoadShipmentId] 			
									,[intLoadShipmentCostId] 
									,intTaxGroupId		
								)
								SELECT	
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
									,[ysnAllowVoucher]	
									,[intLoadShipmentId] 			
									,[intLoadShipmentCostId] 	
									,intTaxGroupId
								FROM [dbo].[fnSCGetLoadFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId)
					END
					-- non freight
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
						,[ysnAllowVoucher]
						,[intLoadShipmentId]	
						,[intLoadShipmentCostId]
						,intTaxGroupId
					)
					SELECT	
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
						,[ysnAllowVoucher]
						,[intLoadShipmentId] 			
						,[intLoadShipmentCostId]	
						,intTaxGroupId			
					FROM dbo.[fnSCGetLoadNoneFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId)
				END	
			END
		ELSE
			BEGIN
				IF ISNULL(@intContractDetailId,0) = 0 and isnull(@intFreightItemId, 0) != 0
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
						,ysnAllowVoucher
						,[intLoadShipmentId]			 
						,[intLoadShipmentCostId]
						,intTaxGroupId		
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
						,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
						,[intContractHeaderId]				= CASE WHEN SC.strDistributionOption = 'SPL' AND ISNULL(RE.intContractHeaderId,0) > 0 THEN RE.intContractHeaderId ELSE NULL END
						,[intContractDetailId]				= CASE WHEN SC.strDistributionOption = 'SPL' AND ISNULL(RE.intContractDetailId,0) > 0 THEN RE.intContractDetailId ELSE NULL END
						,[ysnAccrue]						= @ysnAccrue
						,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
						,[strChargesLink]					= RE.strChargesLink
						,[ysnAllowVoucher]				= RE.ysnAllowVoucher
						,[intLoadShipmentId]			= RE.intLoadShipmentId 
						,[intLoadShipmentCostId]		= RE.intLoadShipmentDetailId
						,intTaxGroupId = RE.intTaxGroupId
						FROM @ReceiptStagingTable RE 						
						-- JOIN tblICItem ICI on RE.intItemId = @intFreightItemId
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
								,[ysnAllowVoucher]
								,[intLoadShipmentId]		
								,[intLoadShipmentCostId]	
								,intTaxGroupId
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
							,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
							,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
							,[strChargesLink]					= RE.strChargesLink
							,[ysnAllowVoucher]				= RE.ysnAllowVoucher
							,[intLoadShipmentId]			= RE.intLoadShipmentId 
							,[intLoadShipmentCostId]		= RE.intLoadShipmentDetailId
							,intTaxGroupId = RE.intTaxGroupId
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
								,[ysnAllowVoucher]
								,[intLoadShipmentId]			
								,[intLoadShipmentCostId]
								,intTaxGroupId		
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
							,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
							,[ysnAccrue]						= ContractCost.ysnAccrue
							,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN ContractCost.ysnPrice ELSE 0 END
							,[strChargesLink]					= RE.strChargesLink
							,[ysnAllowVoucher]				= RE.ysnAllowVoucher
							,[intLoadShipmentId]			= RE.intLoadShipmentId 
							,[intLoadShipmentCostId]		= RE.intLoadShipmentDetailId
							,intTaxGroupId = RE.intTaxGroupId
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
								,[ysnAllowVoucher]
								,[intLoadShipmentId]			 
								,[intLoadShipmentCostId]	
								,intTaxGroupId	
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
								,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
								,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
								,[strChargesLink]					= RE.strChargesLink
								,[ysnAllowVoucher]				= RE.ysnAllowVoucher
								,[intLoadShipmentId]			= RE.intLoadShipmentId 
								,[intLoadShipmentCostId]		= RE.intLoadShipmentDetailId
								,intTaxGroupId = RE.intTaxGroupId
								FROM @ReceiptStagingTable RE 
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE RE.dblFreightRate != 0 AND RE.intContractDetailId IS NULL
						END
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
					,[intContractHeaderId]
					,[intContractDetailId] 
					,[ysnAccrue]
					,[ysnPrice]
					,[strChargesLink]
					,[ysnAllowVoucher]
					,[intLoadShipmentId]	
					,[intLoadShipmentCostId]
					,intTaxGroupId
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
				,[ysnInventoryCost]					= CASE WHEN ISNULL(ContractCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
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
				,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
				,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN ContractCost.ysnPrice ELSE 0 END
				,[strChargesLink]					= RE.strChargesLink
				,[ysnAllowVoucher]				= RE.ysnAllowVoucher
				,[intLoadShipmentId]			= RE.intLoadShipmentId 
				,[intLoadShipmentCostId]		= RE.intLoadShipmentDetailId
				,intTaxGroupId = RE.intTaxGroupId
				FROM tblCTContractCost ContractCost
				LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
				LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
				LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
				WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
			END
	END

SELECT @checkContract = COUNT(intId) FROM @ReceiptStagingTable WHERE strReceiptType = 'Purchase Contract' AND ysnIsStorage = 0;
IF(@checkContract > 0)
BEGIN
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'
	UPDATE @OtherCharges SET strReceiptType = 'Purchase Contract'
END

-- IF @strReceiptType = 'Delayed Price' 
-- BEGIN
-- 	UPDATE @ReceiptStagingTable SET intTaxGroupId = -1
-- 	UPDATE @OtherCharges SET intTaxGroupId = -1
-- END

SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
IF (@total = 0)
	RETURN;

IF @intLotType != 0
BEGIN 
	SELECT TOP 1 @ysnRequireProducerQty = ysnRequireProducerQty FROM tblCTCompanyPreference 
	IF ISNULL(@ysnRequireProducerQty, 0) = 1
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
			,[dtmExpiryDate]
			,[strBillOfLadding]
			,[strCertificate]
			,[intProducerId]
			,[strCertificateId]
			,[strTrackingNumber]
			,[intSourceType]
			,[intContractHeaderId]
			,[intContractDetailId]
		)
		SELECT 
			[strReceiptType]		= RE.strReceiptType
			,[intItemId]			= RE.intItemId
			,[intLotId]				= RE.intLotId
			,[strLotNumber]			= CASE
										WHEN SC.strLotNumber = '' THEN NULL
										ELSE SC.strLotNumber
									END
			,[intLocationId]		= RE.intLocationId
			,[intShipFromId]		= RE.intShipFromId
			,[intShipViaId]			= RE.intShipViaId
			,[intSubLocationId]		= RE.intSubLocationId
			,[intStorageLocationId] = RE.intStorageLocationId
			,[intCurrencyId]		= RE.intCurrencyId
			,[intItemUnitMeasureId] = RE.intItemUOMId
			,[dblQuantity]			= CASE 
										WHEN ISNULL(CTC.dblQuantity, 0) > 0 THEN (CTC.dblQuantity / CTD.dblQuantity) * RE.dblQty
										ELSE RE.dblQty
									END
			,[dblGrossWeight]		= CASE 
										WHEN ISNULL(CTC.dblQuantity, 0) > 0 THEN (CTC.dblQuantity / CTD.dblQuantity) * RE.dblGross
										ELSE RE.dblGross
									END
			,[dblTareWeight]		= CASE 
										WHEN ISNULL(CTC.dblQuantity, 0) > 0 THEN (CTC.dblQuantity / CTD.dblQuantity) * (RE.dblGross - RE.dblNet)
										ELSE CASE WHEN SC.dblShrink > 0 THEN (RE.dblGross - RE.dblNet) ELSE 0 END
									END
			,[dblCost]				= RE.dblCost
			,[intEntityVendorId]	= RE.intEntityVendorId
			,[dtmManufacturedDate]	= RE.dtmDate
			,[dtmExpiryDate]		= dbo.fnICCalculateExpiryDate(RE.intItemId, NULL , RE.dtmDate)
			,[strBillOfLadding]		= ''
			,[strCertificate]		= ICC.strCertificationName
			,[intProducerId]		= CTC.intProducerId
			,[strCertificateId]		= CTC.strCertificationId
			,[strTrackingNumber]	= CTC.strTrackingNumber
			,[intSourceType]		= RE.intSourceType
			,[intContractHeaderId]	= RE.intContractHeaderId
			,[intContractDetailId]	= RE.intContractDetailId
		FROM @ReceiptStagingTable RE 
		INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
		INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = RE.intItemId
		LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = RE.intContractDetailId
		LEFT JOIN tblCTContractCertification CTC ON CTC.intContractDetailId = RE.intContractDetailId
		LEFT JOIN tblICCertification ICC ON ICC.intCertificationId = CTC.intCertificationId
	END
	ELSE
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
			,[dtmExpiryDate]
			,[strBillOfLadding]
			,[intSourceType]
			,[intContractHeaderId]
			,[intContractDetailId]
		)
		SELECT 
			[strReceiptType]		= RE.strReceiptType
			,[intItemId]			= RE.intItemId
			,[intLotId]				= RE.intLotId
			,[strLotNumber]			= CASE
										WHEN SC.strLotNumber = '' THEN NULL
										ELSE SC.strLotNumber
									END
			,[intLocationId]		= RE.intLocationId
			,[intShipFromId]		= RE.intShipFromId
			,[intShipViaId]			= RE.intShipViaId
			,[intSubLocationId]		= RE.intSubLocationId
			,[intStorageLocationId] = RE.intStorageLocationId
			,[intCurrencyId]		= RE.intCurrencyId
			,[intItemUnitMeasureId] = RE.intItemUOMId
			,[dblQuantity]			= RE.dblQty
			,[dblGrossWeight]		= RE.dblGross 
			,[dblTareWeight]		= CASE WHEN SC.dblShrink > 0 THEN (RE.dblGross - RE.dblNet) ELSE 0 END
			,[dblCost]				= RE.dblCost
			,[intEntityVendorId]	= RE.intEntityVendorId
			,[dtmManufacturedDate]	= RE.dtmDate
			,[dtmExpiryDate]		= dbo.fnICCalculateExpiryDate(RE.intItemId, NULL , RE.dtmDate)
			,[strBillOfLadding]		= ''
			,[intSourceType]		= RE.intSourceType
			,[intContractHeaderId]	= RE.intContractHeaderId
			,[intContractDetailId]	= RE.intContractDetailId
		FROM @ReceiptStagingTable RE 
		INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
		INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = RE.intItemId
	END
END


-- update @OtherCharges set dblRate = isnull(dblRate, 0) where dblRate is null

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
	SET @_intStorageHistoryId = 0

	SELECT TOP 1
		@_intStorageHistoryId = SH.intStorageHistoryId
	FROM tblGRStorageHistory SH
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblICInventoryReceipt IR ON IR.intEntityVendorId=CS.intEntityId 
	WHERE SH.[strType] IN ('From Scale', 'From Delivery Sheet')
	AND IR.intInventoryReceiptId=@InventoryReceiptId 
	AND ISNULL(SH.intInventoryReceiptId,0) = 0

	IF(ISNULL(@_intStorageHistoryId,0) > 0)
	BEGIN
		UPDATE SH  
		SET SH.[intInventoryReceiptId] = @InventoryReceiptId
		FROM tblGRStorageHistory SH
		WHERE SH.intStorageHistoryId = @_intStorageHistoryId


		EXEC uspGRRiskSummaryLog @_intStorageHistoryId
	END

	DELETE	FROM #tmpAddItemReceiptResult 
	WHERE	intInventoryReceiptId = @ReceiptId
END

/*
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
*/
GO


