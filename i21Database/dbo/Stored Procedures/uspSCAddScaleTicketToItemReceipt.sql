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
SET ANSI_WARNINGS ON

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

DECLARE @REFERENCE_ONLY BIT
DECLARE @BATCH_ID NVARCHAR(50) 
DECLARE @STORY_MODE SMALLINT = 1
SELECT @BATCH_ID = NEWID()


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
	, @REFERENCE_ONLY = CASE WHEN SC.intStorageScheduleTypeId = -9 THEN 1 ELSE 0 END
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
		--Load other charges and contract other charges variable are used to have a temporary holder of other charges
		--later on the data on will be consolidated to the other charges variable
		--it should only hold the unique other charge item and the duplicated item will be deleted on the load charges variable.
		--this process is only applicable 
		@LOAD_OTHER_CHARGES AS ReceiptOtherChargesTableType, 
		@CONTRACT_OTHER_CHARGES AS ReceiptOtherChargesTableType, 
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
		,ysnAddPayable
		,dblBasis
		,dblFutures
		,strFuturesMonth
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
		,intGrossNetUOMId			= CASE
										WHEN (IC.ysnLotWeightsRequired = 1 AND @intLotType != 0) THEN SC.intItemUOMIdFrom
										ELSE LI.intItemUOMId
									  END
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
										WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN dbo.fnMultiply( dbo.fnDivide(LI.dblQty,SC.dblNetUnits), (SC.dblGrossWeight - SC.dblTareWeight))
										ELSE dbo.fnMultiply(dbo.fnDivide(LI.dblQty, SC.dblNetUnits), SC.dblGrossUnits)
									END
		,dblNet						= CASE
										WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN 
											CASE WHEN SC.dblShrink > 0 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, LI.dblQty) ELSE dbo.fnMultiply( dbo.fnDivide(LI.dblQty,SC.dblNetUnits), (SC.dblGrossWeight - SC.dblTareWeight)) END
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
		,[intLoadShipmentId] 		= NULL
		,[intLoadShipmentDetailId] 	= CASE WHEN LI.strSourceTransactionId = 'LOD' THEN LI.intSourceTransactionId ELSE NULL END
		,intTaxGroupId				= CASE WHEN StorageType.ysnDPOwnedType = 1 THEN -1 
										ELSE 
											CASE WHEN ISNULL(CNT.intPricingTypeId,0) = 2 OR ISNULL(CNT.intPricingTypeId,0) = 3 
											THEN -1
											ELSE NULL
											END 
										END
		,ysnAddPayable				= CASE WHEN ISNULL(CNT.intPricingTypeId,0) = 2 OR ISNULL(CNT.intPricingTypeId,0) = 3 OR ISNULL(CNT.intPricingTypeId,0) = 5 
										THEN 0
										ELSE NULL
										END
		,dblBasis					= CNT.dblBasis
		,dblFutures					= CNT.dblFutures
		,strFuturesMonth			= CNT.strFuturesMonth
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
	,CTD.dblBasis
	,CTD.dblFutures
	,FUTURES_MONTH.strFutureMonth as strFuturesMonth
	FROM tblCTContractDetail CTD 
	INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth FUTURES_MONTH
		ON CTD.intFutureMonthId = FUTURES_MONTH.intFutureMonthId
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
LEFT JOIN tblGRStorageType StorageType
	ON LI.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId 
LEFT JOIN tblCTContractDetail ConDetail
	ON LI.intTransactionDetailId = ConDetail.intContractDetailId
LEFT JOIN tblCTContractHeader ConHeader
	ON ConDetail.intContractHeaderId = ConHeader.intContractHeaderId
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
	,[strCostMethod]					= CASE WHEN CNT.intPricingTypeId = 5 THEN 'Per Unit' ELSE IC.strCostMethod END --case when QM.strCalcMethod = '3' then 'Gross Unit' else IC.strCostMethod end
	,[dblRate]							= 	ROUND(ISNULL((CASE
												WHEN IC.strCostMethod = 'Per Unit'  OR  ISNULL(CNT.intPricingTypeId, 0) = 5 THEN 
													-- CASE WHEN ISNULL(CNT.intPricingTypeId, 0) = 5 THEN	
															(
																(
																		CASE WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost, 0))    
																			ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost))  
																		END
																	) / (dbo.fnCalculateQtyBetweenUOM(RE.intItemUOMId, ISNULL(IUOM.intItemUOMId,RE.intItemUOMId), RE.dblQty))
															) * CASE WHEN QM.dblDiscountAmount < 0 THEN  -1 ELSE 1 END
													
												WHEN IC.strCostMethod = 'Amount' THEN --0
													CASE
														WHEN RE.ysnIsStorage = 1 THEN 0
														WHEN RE.ysnIsStorage = 0 THEN
															CASE 
																WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost, 0))    
																ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, RE.dblCost))  
															END 
															* CASE WHEN QM.dblDiscountAmount < 0 THEN  -1 ELSE 1 END 														

															
													END
												ELSE 0
											END),0.0),6)


	,[intCostUOMId]						= CASE
											WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, @intTicketItemUOMId)
											WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
										END
	,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
	,[dblAmount]						= CASE
											WHEN IC.strCostMethod = 'Per Unit' AND CNT.intPricingTypeId <> 5 THEN 0
											WHEN IC.strCostMethod = 'Amount' OR CNT.intPricingTypeId = 5 THEN 
												ROUND(
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
												END,2)
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
	,[intLoadShipmentCostId] 		= NULL--RE.intLoadShipmentDetailId
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
	LEFT JOIN tblICItemUOM IUOM ON RE.intItemId = IUOM.intItemId AND GR.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE RE.intSourceId = @intTicketId AND (QM.dblDiscountAmount != 0 OR GR.ysnSpecialDiscountCode = 1) AND RE.ysnIsStorage = 0 AND ISNULL(intPricingTypeId,0) IN (0,1,2,5,6) 

		and isnull(@intDeliverySheetId,0 ) = 0
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
	,[intLoadShipmentCostId] 		= NULL--RE.intLoadShipmentDetailId
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

	PRINT 'CHECKING IF HAS LOAD : ' + LTRIM(@intLoadId)
	--LOAD SCHEDULE
	BEGIN
		IF	ISNULL(@intLoadId,0) != 0 
			BEGIN
				BEGIN
					SELECT TOP 1
						@intLoadContractId = LGLD.intPContractDetailId
						, @intLoadCostId = LGCOST.intLoadCostId 
					FROM tblLGLoad LGL
					INNER JOIN tblLGLoadDetail LGLD ON LGL.intLoadId = LGLD.intLoadId
					INNER JOIN tblLGLoadCost LGCOST ON LGL.intLoadId = LGCOST.intLoadId  
					WHERE LGL.intLoadId = @intLoadId
				
					-- PLEASE UPDATE ANY CHANGES IN IMPLEMENTATION ON BOTH CONDITION
					-- THE ONLY DIFFERENCE ON THE PROCESS THE REFERENCE DIRECTLY INSERT DATA TO OTHER CHARGES
					-- THE OTHER PROCESS USE A DIFFERENT TABLE THEN LATER ON MERGE TOGETHER
					IF @REFERENCE_ONLY = 0
					BEGIN
						IF ISNULL(@intFreightItemId,0) != 0
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
									FROM [dbo].[fnSCGetLoadFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId, @REFERENCE_ONLY)
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
						FROM dbo.[fnSCGetLoadNoneFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId, @REFERENCE_ONLY)

					END
					ELSE
					BEGIN					
						
						DELETE FROM @CONTRACT_OTHER_CHARGES
						DELETE FROM @LOAD_OTHER_CHARGES

						/* -- LOAD RELATED CHARGES */
						IF ISNULL(@intFreightItemId,0) != 0
						BEGIN						
							INSERT INTO @LOAD_OTHER_CHARGES
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
							FROM [dbo].[fnSCGetLoadFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId, @REFERENCE_ONLY)
						END
					
						INSERT INTO @LOAD_OTHER_CHARGES
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
						FROM dbo.[fnSCGetLoadNoneFreightItemCharges](@ReceiptStagingTable,@ysnPrice,@ysnAccrue,@intFreightItemId,@intLoadCostId, @REFERENCE_ONLY)

						/* -- LOAD RELATED CHARGES -- */
					
						DECLARE @voucherPayable AS VoucherPayable
						DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
						DECLARE @error NVARCHAR(1000)
						INSERT INTO @voucherPayable(
								[intEntityVendorId]
								,[intTransactionType]
								,[intLocationId]
								,[intCurrencyId]
								,[dtmDate]
								,[strVendorOrderNumber]
								,[strReference]
								,[strSourceNumber]
								,[intContractHeaderId]
								,[intContractDetailId]
								,[intContractSeqId]
								,[intContractCostId]
								,[intInventoryReceiptItemId]
								,[intLoadShipmentId]
								,[strLoadShipmentNumber]
								,[intLoadShipmentDetailId]
								,[intLoadShipmentCostId]
								,[intItemId]
								,[strMiscDescription]
								,[dblOrderQty]
								,[dblOrderUnitQty]
								,[intOrderUOMId]
								,[dblQuantityToBill]
								,[dblQtyToBillUnitQty]
								,[intQtyToBillUOMId]
								,[dblCost]
								,[dblCostUnitQty]
								,[intCostUOMId]
								,[dblNetWeight]
								,[dblWeightUnitQty]
								,[intWeightUOMId]
								,[intCostCurrencyId]
								,[intFreightTermId]
								,[dblTax]
								,[dblDiscount]
								,[dblExchangeRate]
								,[ysnSubCurrency]
								,[intSubCurrencyCents]
								,[intAccountId]
								,[strBillOfLading]
								,[ysnReturn]
								,[ysnStage]
								,[intStorageLocationId]
								,[intSubLocationId]
								,[intScaleTicketId]
								)


						SELECT
								[intEntityVendorId] = RE.intEntityVendorId
								,[intTransactionType] = 2
								,[intLocationId] = RE.intLocationId
								,[intCurrencyId] = RE.intCurrencyId
								,[dtmDate] = RE.dtmDate
								,[strVendorOrderNumber] = RE.strVendorRefNo
								,[strReference] = RE.strVendorRefNo
								,[strSourceNumber] = LTRIM(SC.strTicketNumber)
								,[intContractHeaderId] = NULL
								,[intContractDetailId] = NULL
								,[intContractSeqId] = NULL
								,[intContractCostId] = NULL
								,[intInventoryReceiptItemId] = NULL
								,[intLoadShipmentId] = SC.intLoadId
								,[strLoadShipmentNumber] = LTRIM(LG_LOAD.strLoadNumber)
								,[intLoadShipmentDetailId] = RE.intLoadShipmentDetailId
								,[intLoadShipmentCostId] = LoadCost.intLoadCostId
								,[intItemId] = IC.intItemId
								,[strMiscDescription] = IC.strDescription
								,[dblOrderQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE RE.dblNet END
								,[dblOrderUnitQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
								,[intOrderUOMId] = LoadCost.intItemUOMId
								,[dblQuantityToBill] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE RE.dblNet END
								,[dblQtyToBillUnitQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
								,[intQtyToBillUOMId] = LoadCost.intItemUOMId
								,[dblCost] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') 
									THEN ABS(
												ROUND(
														dbo.fnMultiply(
															dbo.fnDivide(RE.dblQty , SC.dblNetUnits)
																, ISNULL(LoadCost.dblAmount, LoadCost.dblRate)
															), 2
												)
											) 
									ELSE ABS(
												ROUND(
														dbo.fnMultiply(
															dbo.fnDivide(RE.dblQty , SC.dblNetUnits)
																, ISNULL(LoadCost.dblRate, LoadCost.dblAmount)
															), 2
												)
											) END 
								,[dblCostUnitQty] = 1 -- need to clarify how to handle this
														--CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
								,[intCostUOMId] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE LoadCost.intItemUOMId END
								,[dblNetWeight] = 0
								,[dblWeightUnitQty] = 1
								,[intWeightUOMId] = NULL
								,[intCostCurrencyId] = LoadCost.intCurrencyId
								,[intFreightTermId] = NULL
								,[dblTax] = 0
								,[dblDiscount] = 0
								,[dblExchangeRate] = CASE WHEN (LoadCost.intCurrencyId <> @DefaultCurrencyId) THEN 0 ELSE 1 END
								,[ysnSubCurrency] =	CC.ysnSubCurrency
								,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
								,[intAccountId] = apClearing.intAccountId
								,[strBillOfLading] = LG_LOAD.strBLNumber
								,[ysnReturn] = CAST(0 AS BIT)
								,[ysnStage] = CAST(0 AS BIT)
								,[intStorageLocationId] = NULL
								,[intSubLocationId] = NULL
								,SC.intTicketId
							FROM @ReceiptStagingTable RE 			
								INNER JOIN tblSCTicket SC 
									ON SC.intTicketId = RE.intSourceId
								INNER JOIN tblLGLoad LG_LOAD
									ON SC.intLoadId = LG_LOAD.intLoadId				
								LEFT JOIN tblLGLoadCost LoadCost 
									ON LoadCost.intLoadId = SC.intLoadId
								LEFT JOIN tblICItem IC 
									ON IC.intItemId = LoadCost.intItemId
								OUTER APPLY tblLGCompanyPreference LG_COMPANY_PREFERENCE
									LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = RE.intCurrencyId
									LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = RE.intItemId and ItemLoc.intLocationId = RE.intLocationId
									LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = RE.intItemUOMId
									LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId									
									LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = LoadCost.intItemUOMId
									LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
									INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON RE.[intEntityVendorId] = D1.[intEntityId]
									LEFT JOIN tblSMCompanyLocation COMPANY_LOCATION 
										ON SC.intProcessingLocationId = COMPANY_LOCATION.intCompanyLocationId
									LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = COMPANY_LOCATION.intAPAccount
											

								WHERE LoadCost.dblRate > 0 									
									AND ISNULL(@intFreightItemId, 0) != CASE WHEN  ISNULL(@intFreightItemId, 0) = 0 THEN 1 ELSE LoadCost.intItemId END 
									AND (LoadCost.strEntityType <> 'Customer' OR LoadCost.strEntityType IS NULL)
									AND ISNULL(LoadCost.ysnVendorPrepayment, 0) = 1
									And ISNULL(LoadCost.ysnPrice, 0) = 0 
									AND ISNULL(LoadCost.ysnAccrue, 0) = 0
									AND RE.ysnIsStorage = 0
							
							UNION ALL
							-- FOR STORAGE DEBIT MEMO
							SELECT
								[intEntityVendorId] = RE.intEntityVendorId
								,[intTransactionType] = 3
								,[intLocationId] = RE.intLocationId
								,[intCurrencyId] = RE.intCurrencyId
								,[dtmDate] = RE.dtmDate
								,[strVendorOrderNumber] = RE.strVendorRefNo
								,[strReference] = RE.strVendorRefNo
								,[strSourceNumber] = LTRIM(SC.strTicketNumber)
								,[intContractHeaderId] = NULL
								,[intContractDetailId] = NULL
								,[intContractSeqId] = NULL
								,[intContractCostId] = NULL
								,[intInventoryReceiptItemId] = NULL
								,[intLoadShipmentId] = SC.intLoadId
								,[strLoadShipmentNumber] = LTRIM(LG_LOAD.strLoadNumber)
								,[intLoadShipmentDetailId] = RE.intLoadShipmentDetailId
								,[intLoadShipmentCostId] = LoadCost.intLoadCostId
								,[intItemId] = IC.intItemId
								,[strMiscDescription] = IC.strDescription
								,[dblOrderQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE RE.dblNet END
								,[dblOrderUnitQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
								,[intOrderUOMId] = LoadCost.intItemUOMId
								,[dblQuantityToBill] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE RE.dblNet END
								,[dblQtyToBillUnitQty] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
								,[intQtyToBillUOMId] = LoadCost.intItemUOMId
								,[dblCost] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') 
									THEN ABS(
												ROUND(
														dbo.fnMultiply(
															dbo.fnDivide(RE.dblQty , SC.dblNetUnits)
																, ISNULL(LoadCost.dblAmount, LoadCost.dblRate)
															), 2
												)
											) 
									ELSE ABS(
												ROUND(
														dbo.fnMultiply(
															dbo.fnDivide(RE.dblQty , SC.dblNetUnits)
																, ISNULL(LoadCost.dblRate, LoadCost.dblAmount)
															), 2
												)
											) END 
								,[dblCostUnitQty] = 1 -- need to clarify how to handle this
														--CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
								,[intCostUOMId] = CASE WHEN LoadCost.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE LoadCost.intItemUOMId END
								,[dblNetWeight] = 0
								,[dblWeightUnitQty] = 1
								,[intWeightUOMId] = NULL
								,[intCostCurrencyId] = LoadCost.intCurrencyId
								,[intFreightTermId] = NULL
								,[dblTax] = 0
								,[dblDiscount] = 0
								,[dblExchangeRate] = CASE WHEN (LoadCost.intCurrencyId <> @DefaultCurrencyId) THEN 0 ELSE 1 END
								,[ysnSubCurrency] =	CC.ysnSubCurrency
								,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
								,[intAccountId] = apClearing.intAccountId
								,[strBillOfLading] = LG_LOAD.strBLNumber
								,[ysnReturn] = CAST(0 AS BIT)
								,[ysnStage] = CAST(0 AS BIT)
								,[intStorageLocationId] = NULL
								,[intSubLocationId] = NULL
								,SC.intTicketId
							FROM @ReceiptStagingTable RE 			
								INNER JOIN tblSCTicket SC 
									ON SC.intTicketId = RE.intSourceId
								INNER JOIN tblLGLoad LG_LOAD
									ON SC.intLoadId = LG_LOAD.intLoadId				
								LEFT JOIN tblLGLoadCost LoadCost 
									ON LoadCost.intLoadId = SC.intLoadId
								LEFT JOIN tblICItem IC 
									ON IC.intItemId = LoadCost.intItemId
								OUTER APPLY tblLGCompanyPreference LG_COMPANY_PREFERENCE
									LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = RE.intCurrencyId
									LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = RE.intItemId and ItemLoc.intLocationId = RE.intLocationId
									LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = RE.intItemUOMId
									LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId									
									LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = LoadCost.intItemUOMId
									LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
									INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON RE.[intEntityVendorId] = D1.[intEntityId]
									OUTER APPLY dbo.fnGetItemGLAccountAsTable(IC.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense') itemAccnt
									LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
												

								WHERE LoadCost.dblRate > 0 									
									AND ISNULL(@intFreightItemId, 0) != CASE WHEN  ISNULL(@intFreightItemId, 0) = 0 THEN 1 ELSE LoadCost.intItemId END 
									AND (LoadCost.strEntityType <> 'Customer' OR LoadCost.strEntityType IS NULL)
									AND ISNULL(LoadCost.ysnVendorPrepayment,0) = 0
									And ISNULL(LoadCost.ysnPrice, 0) = 1 
									AND ISNULL(LoadCost.ysnAccrue, 0) = 0
									AND RE.ysnIsStorage = 1
						
						DECLARE @ACCOUNT_CHECKING NVARCHAR(MAX) = ''
						SELECT 

							@ACCOUNT_CHECKING = @ACCOUNT_CHECKING + CASE WHEN [intTransactionType] = 2 THEN 'AP account for ' + strMiscDescription + ' is missing.' --VENDOR PREPAYMENT
																		WHEN [intTransactionType] = 3  THEN 'Other charge expense account for ' + strMiscDescription + ' is missing.'-- DEBIT MEMO
											END 	 
						FROM @voucherPayable
						WHERE ISNULL(intAccountId, 0) = 0
						IF @ACCOUNT_CHECKING != ''
						BEGIN
							RAISERROR(@ACCOUNT_CHECKING, 16, 1);
							RETURN;

						END
						--SELECT '---'
						--SELECT 'uspSCAddScaleTicketToItemReceipt'
						--SELECT * FROM @voucherPayable
						--SELECT ysnIsStorage,LoadCost.dblRate,@intFreightItemId, LoadCost.intItemId, LoadCost.ysnVendorPrepayment,LoadCost.ysnAccrue,LoadCost.ysnPrice, * FROM @ReceiptStagingTable RE 			
						--		INNER JOIN tblSCTicket SC 
						--			ON SC.intTicketId = RE.intSourceId
						--		INNER JOIN tblLGLoad LG_LOAD
						--			ON SC.intLoadId = LG_LOAD.intLoadId				
						--		LEFT JOIN tblLGLoadCost LoadCost 
						--			ON LoadCost.intLoadId = SC.intLoadId
						--		LEFT JOIN tblICItem IC 
						--			ON IC.intItemId = LoadCost.intItemId
						--		OUTER APPLY tblLGCompanyPreference LG_COMPANY_PREFERENCE
						--			LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = RE.intCurrencyId
						--			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = RE.intItemId and ItemLoc.intLocationId = RE.intLocationId
						--			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = RE.intItemUOMId
						--			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId									
						--			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = LoadCost.intItemUOMId
						--			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
						--			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON RE.[intEntityVendorId] = D1.[intEntityId]
						--			OUTER APPLY dbo.fnGetItemGLAccountAsTable(RE.intItemId, ItemLoc.intItemLocationId, 'AP Account') itemAccnt
						--			LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
												

						exec uspAPCreateVoucher    
							@voucherPayables = @voucherPayable    
							,@voucherPayableTax = DEFAULT    
							,@userId = @intUserId    
							,@throwError = 1
							,@error = @error OUT
						
							--,@createdVouchersId  = @createdVouchersId out  			
						--- THIS IS FOR THE NEGATIVE CHECKING
						
						-- This is looking for cost that matches the freight item
						INSERT INTO @CONTRACT_OTHER_CHARGES
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
						,[ysnAllowVoucher]				= CASE WHEN ContractCost.ysnAccrue = 1 AND ContractCost.intVendorId <> RE.intEntityVendorId THEN 1 ELSE RE.ysnAllowVoucher END
						,[intLoadShipmentId]			= RE.intLoadShipmentId 
						,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
						,intTaxGroupId = RE.intTaxGroupId
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
						LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0

						-- other charges listed
						INSERT INTO @CONTRACT_OTHER_CHARGES
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
							,[ysnAllowVoucher]				= CASE WHEN ISNULL(@intHaulerId,0) > 0 AND @intHaulerId <> RE.intEntityVendorId THEN 1 ELSE RE.ysnAllowVoucher END
							,[intLoadShipmentId]			= RE.intLoadShipmentId 
							,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
							,intTaxGroupId = RE.intTaxGroupId
							FROM @ReceiptStagingTable RE 
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE RE.dblFreightRate != 0 AND RE.intContractDetailId IS NULL
						
								
						/* DELETE DUPLICATE ITEM OF LOAD AND CONTRACT CHARGES*/
						DELETE FROM @LOAD_OTHER_CHARGES 
							WHERE intId IN( 
								SELECT LOAD_CHARGES.intId
								FROM @LOAD_OTHER_CHARGES LOAD_CHARGES
									JOIN @CONTRACT_OTHER_CHARGES CONTRACT_CHARGES
										ON LOAD_CHARGES.intChargeId = CONTRACT_CHARGES.intChargeId 
											AND LOAD_CHARGES.intContractDetailId = CONTRACT_CHARGES.intContractDetailId
						)

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
						SELECT [intEntityVendorId] 
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
						FROM @CONTRACT_OTHER_CHARGES 
						UNION ALL
						SELECT [intEntityVendorId] 
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
						FROM @LOAD_OTHER_CHARGES

						--						
						--

						DELETE FROM @CONTRACT_OTHER_CHARGES
						DELETE FROM @LOAD_OTHER_CHARGES
					END

				END 

				UPDATE L
				SET
					intShipmentStatus = 4,
					dtmDeliveredDate = T.dtmTicketDateTime
				FROM tblLGLoad L
				INNER JOIN tblSCTicket T ON T.intLoadId = L.intLoadId
				WHERE L.intLoadId = @intLoadId
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
						,[ysnInventoryCost]					= CASE WHEN ISNULL(RE.ysnIsStorage,0) = 0 THEN
																	CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
															  ELSE
																	0 -- should not affect inventory cost for customer storage	
															  END
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
						,[ysnAllowVoucher]				= CASE WHEN ISNULL(RE.ysnIsStorage,0) = 0 
														  THEN
																CASE WHEN ISNULL(@ysnAccrue,0) = 1 AND ISNULL(@intHaulerId,0) > 0 AND @intHaulerId <> RE.intEntityVendorId 
																THEN 1 
																ELSE RE.ysnAllowVoucher 
																END
														  ELSE
																1 -- allow to be added in add payable for customer storage
														  END
						,[intLoadShipmentId]			= RE.intLoadShipmentId 
						,[intLoadShipmentCostId]		= NULL --RE.intLoadShipmentDetailId
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
																		ROUND (CASE 
																					WHEN ISNULL(CT.intContractCostId,0) = 0 THEN 
																						(RE.dblQty / SC.dblNetUnits * SC.dblFreightRate)
																					ELSE 
																						(RE.dblQty / SC.dblNetUnits * CT.dblRate)
																				END, 2)
																	END
																	ELSE 0
																END
							,[intContractHeaderId]				= RE.intContractHeaderId
							,[intContractDetailId]				= RE.intContractDetailId
							,[ysnAccrue]						= @ysnAccrue
							,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
							,[strChargesLink]					= RE.strChargesLink
							,[ysnAllowVoucher]				= CASE WHEN ISNULL(@intHaulerId,0) > 0 AND @intHaulerId <> RE.intEntityVendorId THEN 1 ELSE RE.ysnAllowVoucher END
							,[intLoadShipmentId]			= RE.intLoadShipmentId 
							,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
							,intTaxGroupId = RE.intTaxGroupId
							FROM @ReceiptStagingTable RE
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							OUTER APPLY(
								SELECT * FROM tblCTContractCost WHERE intContractDetailId = RE.intContractDetailId 
								AND dblRate != 0 
								AND intItemId = @intFreightItemId
								AND ISNULL(ysnBasis,0) = 0
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
							,[ysnAllowVoucher]				= CASE WHEN ContractCost.ysnAccrue = 1 AND ContractCost.intVendorId <> RE.intEntityVendorId THEN 1 ELSE RE.ysnAllowVoucher END
							,[intLoadShipmentId]			= RE.intLoadShipmentId 
							,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
							,intTaxGroupId = RE.intTaxGroupId
							FROM tblCTContractCost ContractCost
							LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE ContractCost.intItemId = @intFreightItemId 
								AND RE.intContractDetailId IS NOT NULL 
								AND ContractCost.dblRate != 0
								AND ISNULL(ContractCost.ysnBasis,0) = 0

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
								,[ysnAllowVoucher]				= CASE WHEN ISNULL(@intHaulerId,0) > 0 AND @intHaulerId <> RE.intEntityVendorId THEN 1 ELSE RE.ysnAllowVoucher END
								,[intLoadShipmentId]			= RE.intLoadShipmentId 
								,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
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
				,[ysnAllowVoucher]				= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0  AND ISNULL(ContractCost.intVendorId,0) <> RE.intEntityVendorId  THEN 1 ELSE RE.ysnAllowVoucher END 
				,[intLoadShipmentId]			= RE.intLoadShipmentId 
				,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
				,intTaxGroupId = RE.intTaxGroupId
				FROM tblCTContractCost ContractCost
				LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
				LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
				LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
				WHERE ContractCost.intItemId != @intFreightItemId 
					AND RE.intContractDetailId IS NOT NULL 
					AND ContractCost.dblRate != 0
					AND ISNULL(ContractCost.ysnBasis,0) = 0
				
			END
	END

SELECT @checkContract = COUNT(intId) FROM @ReceiptStagingTable WHERE strReceiptType = 'Purchase Contract' AND ysnIsStorage = 0;
IF(@checkContract > 0)
BEGIN
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'
	UPDATE @OtherCharges SET strReceiptType = 'Purchase Contract'
END

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

exec uspSCUpdateDeliverySheetDate @intTicketId = @intTicketId




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

	IF (ISNULL(@intDeliverySheetId, 0) = 0 )
	BEGIN

		SELECT TOP 1
			@_intStorageHistoryId = SH.intStorageHistoryId
		FROM tblGRStorageHistory SH
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
		JOIN tblSCTicket Ticket 
			ON CS.intTicketId = Ticket.intTicketId
		--JOIN tblICInventoryReceipt IR ON IR.intEntityVendorId=CS.intEntityId 
		WHERE SH.[strType] IN ('From Scale')
		AND Ticket.intInventoryReceiptId = @InventoryReceiptId 
		AND ISNULL(SH.intInventoryReceiptId,0) = 0
	
	END
	ELSE
	BEGIN

		SELECT TOP 1
			@_intStorageHistoryId = SH.intStorageHistoryId
		FROM tblGRStorageHistory SH
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
		JOIN tblSCTicket Ticket 
			ON CS.intDeliverySheetId = Ticket.intDeliverySheetId	
				AND SH.intTicketId = Ticket.intTicketId
		WHERE SH.[strType] IN ('From Delivery Sheet')	 
			AND Ticket.intTicketId = @intTicketId

		
				
	END

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