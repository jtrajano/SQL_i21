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
		@splitDistribution AS NVARCHAR(40),
		@ticketStatus AS NVARCHAR(10),
		@intContractCostId AS INT,
		@intShipToId INT,
		@intFreightTermId INT,
		@strWhereFinalizedWeight NVARCHAR(20),
		@strWhereFinalizedGrade NVARCHAR(20);

DECLARE @SALES_CONTRACT AS INT = 1
		,@SALES_ORDER AS INT = 2
		,@TRANSFER_ORDER AS INT = 3

DECLARE @intTicketItemUOMId INT,
		@intItemId INT,
		@intLotType INT;

SELECT	@intTicketItemUOMId = SC.intItemUOMIdTo
, @intLoadId = SC.intLoadId
, @intContractDetailId = SC.intContractId 
, @intItemId = SC.intItemId
, @splitDistribution = SC.strDistributionOption
, @ticketStatus = SC.strTicketStatus
, @intContractCostId = SC.intContractCostId
, @strWhereFinalizedWeight = SC.strWeightFinalized
, @strWhereFinalizedGrade = SC.strGradeFinalized
FROM vyuSCTicketScreenView SC
WHERE SC.intTicketId = @intTicketId

IF @ticketStatus = 'C'
BEGIN
     --Raise the error:
    RAISERROR('Ticket already completed', 16, 1);
    RETURN;
END

SELECT @intFreightTermId = intFreightTermId, @intShipToId = intShipToId 
FROM tblARCustomer AR
LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
WHERE AR.intEntityId = @intEntityId

SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)


IF ISNULL(@intShipToId, 0) = 0
BEGIN
	RAISERROR('Customer is missing The "Ship To" information, To correct, click on customer link and fill up "Ship To" on the Customer tab', 11, 1);
	RETURN;
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
		,intPriceUOMId
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
		,strChargesLink
		,dblGross
		,dblTare
		,ysnDestinationWeightsAndGrades
		,intLoadShipped
		,ysnAllowInvoice
	)
		SELECT
		intOrderType				= @intOrderType
		,intEntityCustomerId		= @intEntityId
		,intCurrencyId				= CASE
										WHEN ISNULL(CNT.intContractDetailId,0) = 0 THEN SC.intCurrencyId 
										WHEN ISNULL(CNT.intContractDetailId,0) > 0 THEN
											CASE
												WHEN ISNULL(CNT.intInvoiceCurrencyId,0) > 0 THEN CNT.intInvoiceCurrencyId
												ELSE CNT.intCurrencyId
											END
									END
		,intShipFromLocationId		= SC.intProcessingLocationId
		,intShipToLocationId		= @intShipToId
		,intShipViaId				= SC.intFreightCarrierId
		,intFreightTermId			= @intFreightTermId
		,strBOLNumber				= SC.strTicketNumber
		,intDiscountSchedule		= SC.intDiscountId
		,intForexRateTypeId			= NULL
		,dblForexRate				= NULL
		,intItemId					= LI.intItemId
		,intLineNo					= CNT.intContractDetailId
		,intOwnershipType			= CASE
									  WHEN LI.ysnIsStorage = 0 THEN 1
									  WHEN LI.ysnIsStorage = 1 THEN 2
									  END
		,dblQuantity				= CASE WHEN SC.intLotId > 0 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, ICL.intItemUOMId, LI.dblQty) ELSE LI.dblQty END
		,intPriceUOMId				= CASE WHEN SC.intLotId > 0 THEN ICL.intItemUOMId ELSE LI.intItemUOMId END
		,dblUnitPrice				= CASE
			                            WHEN CNT.intPricingTypeId = 2 THEN 
										CASE 
											WHEN CNT.ysnUseFXPrice = 1 
													AND CNT.intCurrencyExchangeRateId IS NOT NULL 
													AND CNT.dblRate IS NOT NULL 
													AND CNT.intFXPriceUOMId IS NOT NULL 
											THEN 
												(SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice),0) + LI.dblCost
												FROM dbo.fnRKGetFutureAndBasisPrice (2,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId,ISNULL(CNT.intInvoiceCurrencyId,CNT.intCurrencyId))
												LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId 
												WHERE futureUOM.intItemId = LI.intItemId)
											ELSE 
												(SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CNT.intBasisUOMId,LI.dblCost),0)),0) 
												FROM dbo.fnRKGetFutureAndBasisPrice (2,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId,ISNULL(CNT.intInvoiceCurrencyId,CNT.intCurrencyId))
												LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId 
												WHERE futureUOM.intItemId = LI.intItemId)
										END 
										ELSE
											CASE WHEN ISNULL(SC.intLotId,0) > 0 THEN  
												CASE 
													WHEN CNT.ysnUseFXPrice = 1 
														AND CNT.intCurrencyExchangeRateId IS NOT NULL 
														AND CNT.dblRate IS NOT NULL 
														AND CNT.intFXPriceUOMId IS NOT NULL 
													THEN CNT.dblSeqPrice
													ELSE LI.dblCost
												END 
												*
												CASE 
													WHEN CNT.ysnUseFXPrice = 1 
														 AND CNT.intCurrencyExchangeRateId IS NOT NULL 
														 AND CNT.dblRate IS NOT NULL 
														 AND CNT.intFXPriceUOMId IS NOT NULL 
													THEN ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ICL.intItemUOMId,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,CNT.intFXPriceUOMId,1),1)),1) 
													WHEN CNT.intPricingTypeId = 5 THEN 1
													ELSE ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ICL.intItemUOMId,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,ISNULL(CNT.intPriceItemUOMId,CNT.intAdjItemUOMId),1),1)),1)
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
										END
		,intWeightUOMId				= CASE WHEN SC.intLotId > 0 THEN ICL.intItemUOMId ELSE LI.intItemUOMId END
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		,intStorageScheduleTypeId	= CASE
									  WHEN LI.ysnIsStorage = 0 THEN  
										CASE 
											WHEN ISNULL(LI.intTransactionDetailId, 0) > 0 THEN LI.intStorageScheduleTypeId
											WHEN ISNULL(LI.intStorageScheduleTypeId, 0) > 0 THEN LI.intStorageScheduleTypeId
											ELSE NULL
										END
									  WHEN LI.ysnIsStorage = 1 THEN 
										CASE 
											WHEN ISNULL(SC.intStorageScheduleTypeId,0) > 0 THEN SC.intStorageScheduleTypeId
											WHEN ISNULL(SC.intStorageScheduleTypeId,0) <= 0 THEN 
											CASE
												WHEN ISNULL(LI.intStorageScheduleTypeId,0) = 0 THEN (SELECT intDefaultStorageTypeId FROM tblSCScaleSetup WHERE intScaleSetupId = SC.intScaleSetupId)
												WHEN ISNULL(LI.intStorageScheduleTypeId,0) > 0 THEN LI.intStorageScheduleTypeId
											END
										END
									  END
		,intItemUOMId				= CASE WHEN SC.intLotId > 0 THEN ICL.intItemUOMId ELSE LI.intItemUOMId END
		,intItemLotGroup			= LI.intId
		,intDestinationGradeId		= SC.intGradeId
		,intDestinationWeightId		= SC.intWeightId
		,intOrderId					= CNT.intContractHeaderId
		,dtmShipDate				= SC.dtmTicketDateTime
		,intSourceId				= SC.intTicketId
		,intSourceType				= 1
		,strSourceScreenName		= 'Scale Ticket'
		,strChargesLink				= 'CL-'+ CAST (LI.intId AS nvarchar(MAX)) 
		,dblGross					=  CASE 
										WHEN SC.intLotId > 0 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, ICL.intItemUOMId, (LI.dblQty /  SC.dblNetUnits) * (SC.dblGrossUnits))
										ELSE CASE WHEN SC.dblShrink > 0 THEN (LI.dblQty / SC.dblNetUnits) * SC.dblGrossUnits ELSE LI.dblQty END
									END
		,dblTare					= CASE
										WHEN SC.intLotId > 0 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, ICL.intItemUOMId, SC.dblShrink)
										ELSE CASE WHEN SC.dblShrink > 0 THEN ((LI.dblQty / SC.dblNetUnits) * SC.dblGrossUnits) - LI.dblQty ELSE 0 END
									END
		,ysnDestinationWeightsAndGrades = CASE
											WHEN ISNULL(@strWhereFinalizedWeight,'Origin') = 'Destination' OR ISNULL(@strWhereFinalizedGrade,'Origin') = 'Destination' THEN 1
											ELSE 0 
										END
		,intLoadShipped				= CASE WHEN CNT.ysnLoad = 1 THEN 1 ELSE NULL END
		,ysnAllowInvoice			= CASE WHEN LI.ysnIsStorage = 1 THEN 0 ELSE
										CASE  
											WHEN CNT.intPricingTypeId = 5 
												THEN 0 
											WHEN CNT.intPricingTypeId = 2
												THEN 
													CASE WHEN CNT.dblAvailablePriceContractQty > 0
														THEN 1
													ELSE 0 END
											ELSE LI.ysnAllowVoucher 
										END
									END
		FROM @Items LI INNER JOIN  dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId
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
			,AD.dblSeqPrice
			,CU.intCent
			,CU.ysnSubCurrency
			,CTH.ysnLoad
			,ISNULL(PCD.dblQuantity,0) - ISNULL(PCDInvoice.dblQtyShipped,0) dblAvailablePriceContractQty
			FROM tblCTContractDetail CTD 
			INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
			CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
			CROSS APPLY (
				SELECT  SUM(PFD.dblQuantity) dblQuantity FROM tblCTPriceFixation PF
				INNER JOIN tblCTPriceFixationDetail PFD
					ON PFD.intPriceFixationId = PF.intPriceFixationId
				WHERE PF.intContractDetailId = CTD.intContractDetailId and PF.intContractHeaderId = CTD.intContractHeaderId
			) PCD
			CROSS APPLY (
				SELECT SUM(dblQtyShipped) dblQtyShipped FROM tblCTPriceFixation PF
				INNER JOIN tblCTPriceFixationDetail PFD
					ON PFD.intPriceFixationId = PF.intPriceFixationId
				LEFT JOIN tblCTPriceFixationDetailAPAR APAR
					ON APAR.intPriceFixationDetailId = PFD.intPriceFixationDetailId
				LEFT JOIN tblARInvoiceDetail ARID
					ON ARID.intInvoiceDetailId = APAR.intInvoiceDetailId
				WHERE PF.intContractDetailId = CTD.intContractDetailId and PF.intContractHeaderId = CTD.intContractHeaderId
			) PCDInvoice
		) CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
		INNER JOIN tblICItem IC ON IC.intItemId = LI.intItemId
		LEFT JOIN tblICLot ICL ON ICL.intLotId = SC.intLotId
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

	-- INSERT OTHER CHARGES 
	BEGIN 
		SELECT @intFreightItemId = SCSetup.intFreightItemId
		, @intHaulerId = SCTicket.intHaulerId
		, @ysnDeductFreightFarmer = SCTicket.ysnFarmerPaysFreight 
		, @ysnDeductFeesCusVen = SCTicket.ysnCusVenPaysFees
		FROM tblSCScaleSetup SCSetup
		LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId
		WHERE intTicketId = @intTicketId

		--INSERT RECORD FOR DISCOUNT
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
			,[intContractDetailId]
			,[intCurrency]
			,[intChargeId]
			,[strCostMethod]
			,[dblRate]
			,[intCostUOMId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnPrice]
			,[strChargesLink]
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
		,[intContractDetailId]				= SE.intLineNo 
		,[intCurrencyId]  					= SE.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN  (QM.dblDiscountAmount * -1)
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
														WHEN SE.intOwnershipType = 2 THEN 0
														WHEN SE.intOwnershipType = 1 THEN 
														CASE
															WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SE.intSourceId, SE.intEntityCustomerId, QM.intTicketDiscountId, SE.dblQuantity, GR.intUnitMeasureId, SE.dblUnitPrice, 0) * -1)
															ELSE (dbo.fnSCCalculateDiscount(SE.intSourceId,QM.intTicketDiscountId, SE.dblQuantity, GR.intUnitMeasureId, SE.dblUnitPrice) * -1)
														END
													END 
												END
		,[ysnAccrue]						= 0
		,[ysnPrice]							= 1
		,[strChargesLink]					= SE.strChargesLink
		FROM @ShipmentStagingTable SE
		LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = SE.intSourceId
		LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
		LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
		WHERE SE.intSourceId = @intTicketId AND QM.dblDiscountAmount != 0

		--INSERT RECORD FOR FEES
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
			,[intContractDetailId]
			,[intCurrency]
			,[intChargeId]
			,[strCostMethod]
			,[dblRate]
			,[intCostUOMId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnPrice]
			,[strChargesLink]
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
		,[intContractDetailId]				= NULL 
		,[intCurrencyId]  					= SC.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 
												CASE
													WHEN @ysnDeductFeesCusVen = 1 THEN (SC.dblTicketFees * -1)
													WHEN @ysnDeductFeesCusVen = 0 THEN SC.dblTicketFees
												END
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, @intTicketItemUOMId)
		,[intOtherChargeEntityVendorId]		= NULL
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN @ysnDeductFeesCusVen = 0 THEN (SE.dblQuantity / SC.dblNetUnits * SC.dblTicketFees)
													WHEN @ysnDeductFeesCusVen = 1 THEN ROUND ((SE.dblQuantity / SC.dblNetUnits * SC.dblTicketFees), 2) * -1
												END
											END
		,[ysnAccrue]						= 0
		,[ysnPrice]							= 1
		,[strChargesLink]					= SE.strChargesLink
		FROM @ShipmentStagingTable SE
		INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
		INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
		WHERE SE.intSourceId = @intTicketId AND SC.dblTicketFees > 0

	IF @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) != 0
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
					SELECT @intLoadContractId = LGLD.intSContractDetailId, @intLoadCostId = LGCOST.intLoadCostId FROM tblLGLoad LGL
					INNER JOIN tblLGLoadDetail LGLD ON LGL.intLoadId = LGLD.intLoadId
					INNER JOIN tblLGLoadCost LGCOST ON LGL.intLoadId = LGCOST.intLoadId  
					WHERE LGL.intLoadId = @intLoadId

					IF ISNULL(@intFreightItemId,0) != 0
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
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
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= SE.intCurrencyId
									,[intChargeId]						= LoadCost.intItemId
									,[strCostMethod]					= SC.strCostMethod
									,[dblRate]							= CASE
																			WHEN SC.strCostMethod = 'Amount' THEN 0
																			ELSE LoadCost.dblRate
																		END
									,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
									,[intEntityVendorId]				= LoadCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN SC.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * LoadCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= @ysnAccrue
									,[ysnPrice]							= @ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblLGLoadDetail LoadDetail
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intSContractDetailId
									LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
									LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
									WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intSContractDetailId = @intLoadContractId
									AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0

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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
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
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= SE.intCurrencyId
									,[intChargeId]						= LoadCost.intItemId
									,[strCostMethod]					= LoadCost.strCostMethod
									,[dblRate]							= CASE
																			WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																			ELSE LoadCost.dblRate
																		END	
									,[intCostUOMId]						= LoadCost.intItemUOMId
									,[intEntityVendorId]				= LoadCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * LoadCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= LoadCost.ysnAccrue
									,[ysnPrice]							= LoadCost.ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblLGLoadDetail LoadDetail
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intSContractDetailId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
									WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intSContractDetailId = @intLoadContractId 
									AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0
								END
							ELSE IF ISNULL(@intContractCostId, 0) != 0
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
									)
									SELECT	
									[intOrderType]						= SE.intOrderType
									,[intSourceType]					= SE.intSourceType
									,[intEntityCustomerId]				= SE.intEntityCustomerId
									,[dtmShipDate]						= SE.dtmShipDate
									,[intShipFromLocationId]			= SE.intShipFromLocationId
									,[intShipToLocationId]				= SE.intShipToLocationId
									,[intFreightTermId]					= SE.intFreightTermId
									,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
																			then SE.intForexRateTypeId 
																			else 
																				ContractCost.intRateTypeId
																			end
									,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
																			then SE.dblForexRate 
																			else 
																				ContractCost.dblFX
																			end

									--Charges
									,[intContractId]					= SE.intOrderId
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
									,[intChargeId]						= ContractCost.intItemId
									,[strCostMethod]					= SC.strCostMethod
									,[dblRate]							= CASE
																			WHEN SC.strCostMethod = 'Amount' THEN 0
																			ELSE ContractCost.dblRate
																		END
									,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
									,[intEntityVendorId]				= ContractCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN SC.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * ContractCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= @ysnAccrue
									,[ysnPrice]							= @ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblCTContractCost ContractCost
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
									LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
									)
									SELECT	
									[intOrderType]						= SE.intOrderType
									,[intSourceType]					= SE.intSourceType
									,[intEntityCustomerId]				= SE.intEntityCustomerId
									,[dtmShipDate]						= SE.dtmShipDate
									,[intShipFromLocationId]			= SE.intShipFromLocationId
									,[intShipToLocationId]				= SE.intShipToLocationId
									,[intFreightTermId]					= SE.intFreightTermId
									,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
																			then SE.intForexRateTypeId 
																			else 
																				ContractCost.intRateTypeId
																			end
									,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
																			then SE.dblForexRate 
																			else 
																				ContractCost.dblFX
																			end

									--Charges
									,[intContractId]					= SE.intOrderId
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
									,[intChargeId]						= ContractCost.intItemId
									,[strCostMethod]					= ContractCost.strCostMethod
									,[dblRate]							= CASE
																			WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																			ELSE ContractCost.dblRate
																		END	
									,[intCostUOMId]						= ContractCost.intItemUOMId
									,[intEntityVendorId]				= ContractCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * ContractCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= ContractCost.ysnAccrue
									,[ysnPrice]							= ContractCost.ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblCTContractCost ContractCost
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
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
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= SE.intCurrencyId
									,[intChargeId]						= SCS.intFreightItemId
									,[strCostMethod]					= SC.strCostMethod
									,[dblRate]							= CASE
																			WHEN SC.strCostMethod = 'Amount' THEN 0
																			ELSE SC.dblFreightRate
																		END
									,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCS.intFreightItemId, SE.intItemUOMId)
									,[intEntityVendorId]				= CASE
																			WHEN @intHaulerId = 0 THEN NULL
																			WHEN @intHaulerId != 0 THEN @intHaulerId
																			END
									,[dblAmount]						=  CASE
																			WHEN SC.strCostMethod = 'Amount' THEN ROUND ((SE.dblQuantity / SC.dblNetUnits * SC.dblFreightRate), 2)
																			ELSE 0
																		END 
									,[ysnAccrue]						= CASE WHEN @intHaulerId = SE.intEntityCustomerId THEN 0 ELSE @ysnAccrue END
									,[ysnPrice]							= @ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM @ShipmentStagingTable SE 
									INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
									LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
									WHERE SC.dblFreightRate > 0

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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
									)
									SELECT	
									[intOrderType]						= SE.intOrderType
									,[intSourceType]					= SE.intSourceType
									,[intEntityCustomerId]				= SE.intEntityCustomerId
									,[dtmShipDate]						= SE.dtmShipDate
									,[intShipFromLocationId]			= SE.intShipFromLocationId
									,[intShipToLocationId]				= SE.intShipToLocationId
									,[intFreightTermId]					= SE.intFreightTermId
									,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
																			then SE.intForexRateTypeId 
																			else 
																				ContractCost.intRateTypeId
																			end
									,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
																			then SE.dblForexRate 
																			else 
																				ContractCost.dblFX
																			end

									--Charges
									,[intContractId]					= SE.intOrderId
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
									,[intChargeId]						= ContractCost.intItemId
									,[strCostMethod]					= ContractCost.strCostMethod
									,[dblRate]							= CASE
																			WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																			ELSE ContractCost.dblRate
																		END	
									,[intCostUOMId]						= ContractCost.intItemUOMId
									,[intEntityVendorId]				= ContractCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * ContractCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= ContractCost.ysnAccrue
									,[ysnPrice]							= ContractCost.ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblCTContractCost ContractCost
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
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
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= SE.intCurrencyId
									,[intChargeId]						= LoadCost.intItemId
									,[strCostMethod]					= LoadCost.strCostMethod
									,[dblRate]							= CASE
																			WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																			ELSE LoadCost.dblRate
																		END	
									,[intCostUOMId]						= LoadCost.intItemUOMId
									,[intEntityVendorId]				= LoadCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * LoadCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= LoadCost.ysnAccrue
									,[ysnPrice]							= LoadCost.ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblLGLoadDetail LoadDetail
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = LoadDetail.intSContractDetailId
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
									WHERE LoadCost.intLoadId = @intLoadId AND LoadDetail.intSContractDetailId = @intLoadContractId AND LoadCost.dblRate != 0
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
										,[intContractDetailId]
										,[intCurrency]
										,[intChargeId]
										,[strCostMethod]
										,[dblRate]
										,[intCostUOMId]
										,[intEntityVendorId]
										,[dblAmount]
										,[ysnAccrue]
										,[ysnPrice]
										,[strChargesLink]
									)
									SELECT	
									[intOrderType]						= SE.intOrderType
									,[intSourceType]					= SE.intSourceType
									,[intEntityCustomerId]				= SE.intEntityCustomerId
									,[dtmShipDate]						= SE.dtmShipDate
									,[intShipFromLocationId]			= SE.intShipFromLocationId
									,[intShipToLocationId]				= SE.intShipToLocationId
									,[intFreightTermId]					= SE.intFreightTermId
									,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
																			then SE.intForexRateTypeId 
																			else 
																				ContractCost.intRateTypeId
																			end
									,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
																			then SE.dblForexRate 
																			else 
																				ContractCost.dblFX
																			end

									--Charges
									,[intContractId]					= SE.intOrderId
									,[intContractDetailId]				= SE.intLineNo
									,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
									,[intChargeId]						= ContractCost.intItemId
									,[strCostMethod]					= ContractCost.strCostMethod
									,[dblRate]							= CASE
																			WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																			ELSE ContractCost.dblRate
																		END	
									,[intCostUOMId]						= ContractCost.intItemUOMId
									,[intEntityVendorId]				= ContractCost.intVendorId
									,[dblAmount]						=  CASE
																			WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																			WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * ContractCost.dblRate),2)
																			ELSE 0
																		END	
									,[ysnAccrue]						= ContractCost.ysnAccrue
									,[ysnPrice]							= ContractCost.ysnPrice
									,[strChargesLink]					= SE.strChargesLink
									FROM tblCTContractCost ContractCost
									LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId 
									LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
									WHERE SE.intOrderId = @intLoadContractId AND ContractCost.dblRate != 0
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
								,[intContractDetailId]
								,[intCurrency]
								,[intChargeId]
								,[strCostMethod]
								,[dblRate]
								,[intCostUOMId]
								,[intEntityVendorId]
								,[dblAmount]
								,[ysnAccrue]
								,[ysnPrice]
								,[strChargesLink]
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
							,[intContractId]					= CASE WHEN SC.strDistributionOption = 'SPL' AND ISNULL(SE.intOrderId,0) > 0 THEN SE.intOrderId ELSE NULL END
							,[intContractDetailId]				= CASE WHEN SC.strDistributionOption = 'SPL' AND ISNULL(SE.intLineNo,0) > 0 THEN SE.intLineNo ELSE NULL END 
							,[intCurrencyId]  					= SE.intCurrencyId
							,[intChargeId]						= @intFreightItemId
							,[strCostMethod]					= SC.strCostMethod
							,[dblRate]							= CASE
																	WHEN SC.strCostMethod = 'Amount' THEN 0
																	ELSE SC.dblFreightRate
																END
							,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SE.intItemUOMId)
							,[intEntityVendorId]				= CASE
																	WHEN @intHaulerId = 0 THEN NULL
																	WHEN @intHaulerId != 0 THEN @intHaulerId
																	END
							,[dblAmount]						=  CASE
																	WHEN SC.strCostMethod = 'Amount' THEN ROUND ((SE.dblQuantity / SC.dblNetUnits * SC.dblFreightRate), 2)
																	ELSE 0
																END 
							,[ysnAccrue]						= @ysnAccrue
							,[ysnPrice]							= @ysnPrice
							,[strChargesLink]					= SE.strChargesLink
							FROM @ShipmentStagingTable SE 
							LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE SC.dblFreightRate > 0
						END
					ELSE IF ISNULL(@intFreightItemId,0) != 0
					BEGIN
						IF ISNULL(@intContractCostId,0) = 0
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
									,[intContractDetailId]
									,[intCurrency]
									,[intChargeId]
									,[strCostMethod]
									,[dblRate]
									,[intCostUOMId]
									,[intEntityVendorId]
									,[dblAmount]
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intOrderType]				= SE.intOrderType
								,[intSourceType]			= SE.intSourceType
								,[intEntityCustomerId]		= SE.intEntityCustomerId
								,[dtmShipDate]				= SE.dtmShipDate
								,[intShipFromLocationId]	= SE.intShipFromLocationId
								,[intShipToLocationId]		= SE.intShipToLocationId
								,[intFreightTermId]			= SE.intFreightTermId
								,[intForexRateTypeId]		= case when CT.intCurrencyId is null 
																then SE.intForexRateTypeId 
																else 
																	CT.intRateTypeId
																end
								,[dblForexRate]				= case when CT.intCurrencyId is null 
																then SE.dblForexRate 
																else 
																	CT.dblFX
																end
				
								--Charges
								,[intContractId]			= SE.intOrderId
								,[intContractDetailId]		= SE.intLineNo
								,[intCurrencyId]  			= isnull(CT.intCurrencyId, SE.intCurrencyId)
								,[intChargeId]				= SCS.intFreightItemId
								,[strCostMethod]			= SC.strCostMethod
								,[dblRate]					= CASE
																WHEN SC.strCostMethod = 'Amount' THEN 0
																ELSE SC.dblFreightRate
															END
								,[intCostUOMId]				= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SE.intItemUOMId)
								,[intEntityVendorId]		= CASE
																WHEN @intHaulerId = 0 THEN NULL
																WHEN @intHaulerId != 0 THEN @intHaulerId
															END
								,[dblAmount]				=  CASE
																WHEN SC.strCostMethod = 'Amount' THEN 
																CASE
																	WHEN ISNULL(CT.intContractCostId,0) = 0 THEN ROUND((SE.dblQuantity / SC.dblNetUnits * SC.dblFreightRate),2)
																	ELSE ROUND((SE.dblQuantity / SC.dblNetUnits * CT.dblRate),2)
																END
																ELSE 0
															END	
								,[ysnAccrue]				= @ysnAccrue
								,[ysnPrice]					= @ysnPrice
								,[strChargesLink]			= SE.strChargesLink
								FROM @ShipmentStagingTable SE
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								OUTER APPLY(
									SELECT * FROM tblCTContractCost WHERE intContractDetailId = SE.intLineNo 
									AND dblRate != 0 
									AND intItemId = @intFreightItemId
								) CT
								WHERE SC.dblFreightRate != 0
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
									,[intContractDetailId]
									,[intCurrency]
									,[intChargeId]
									,[strCostMethod]
									,[dblRate]
									,[intCostUOMId]
									,[intEntityVendorId]
									,[dblAmount]
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
								)
								SELECT	
								[intOrderType]						= SE.intOrderType
								,[intSourceType]					= SE.intSourceType
								,[intEntityCustomerId]				= SE.intEntityCustomerId
								,[dtmShipDate]						= SE.dtmShipDate
								,[intShipFromLocationId]			= SE.intShipFromLocationId
								,[intShipToLocationId]				= SE.intShipToLocationId
								,[intFreightTermId]					= SE.intFreightTermId
								,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
																		then SE.intForexRateTypeId 
																		else 
																			ContractCost.intRateTypeId
																		end
								,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
																		then SE.dblForexRate 
																		else 
																			ContractCost.dblFX
																		end
				
								--Charges
								,[intContractId]					= SE.intOrderId
								,[intContractDetailId]				= SE.intLineNo
								,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
								,[intChargeId]						= ContractCost.intItemId
								,[strCostMethod]					= SC.strCostMethod
								,[dblRate]							= CASE
																		WHEN SC.strCostMethod = 'Amount' THEN 0
																		ELSE ContractCost.dblRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
								,[intEntityVendorId]				= ContractCost.intVendorId
								,[dblAmount]						=  CASE
																		WHEN SC.strCostMethod = 'Amount' THEN ROUND((SE.dblQuantity / SC.dblNetUnits * ContractCost.dblRate),2)
																		ELSE 0
																	END	
								,[ysnAccrue]						= CASE WHEN  ContractCost.intVendorId = SE.intEntityCustomerId THEN 0 ELSE ContractCost.ysnAccrue END
								,[ysnPrice]							= ContractCost.ysnPrice
								,[strChargesLink]					= SE.strChargesLink
								FROM tblCTContractCost ContractCost
								LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE ContractCost.intItemId = @intFreightItemId AND SE.intOrderId IS NOT NULL AND ContractCost.dblRate != 0

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
									,[intContractDetailId]
									,[intCurrency]
									,[intChargeId]
									,[strCostMethod]
									,[dblRate]
									,[intCostUOMId]
									,[intEntityVendorId]
									,[dblAmount]
									,[ysnAccrue]
									,[ysnPrice]
									,[strChargesLink]
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
								,[intContractDetailId]				= NULL 
								,[intCurrencyId]  					= SE.intCurrencyId
								,[intChargeId]						= @intFreightItemId
								,[strCostMethod]					= SC.strCostMethod
								,[dblRate]							= CASE
																		WHEN SC.strCostMethod = 'Amount' THEN 0
																		ELSE SC.dblFreightRate
																	END
								,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SE.intItemUOMId)
								,[intEntityVendorId]				= CASE
																		WHEN @intHaulerId = 0 THEN NULL
																		WHEN @intHaulerId != 0 THEN @intHaulerId
																		END
								,[dblAmount]						=  CASE
																		WHEN SC.strCostMethod = 'Amount' THEN ROUND ((SE.dblQuantity / SC.dblNetUnits * SC.dblFreightRate), 2)
																		ELSE 0
																	END 
								,[ysnAccrue]						= CASE WHEN @intHaulerId = SE.intEntityCustomerId THEN 0 ELSE @ysnAccrue END
								,[ysnPrice]							= @ysnPrice
								,[strChargesLink]					= SE.strChargesLink
								FROM @ShipmentStagingTable SE 
								LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
								LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
								LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
								WHERE SC.dblFreightRate > 0 AND SE.intLineNo IS NULL
							END
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
						,[intContractDetailId]
						,[intCurrency]
						,[intChargeId]
						,[strCostMethod]
						,[dblRate]
						,[intCostUOMId]
						,[intEntityVendorId]
						,[dblAmount]
						,[ysnAccrue]
						,[ysnPrice]
						,[strChargesLink]
					)
					SELECT
					[intOrderType]						= SE.intOrderType
					,[intSourceType]					= SE.intSourceType
					,[intEntityCustomerId]				= SE.intEntityCustomerId
					,[dtmShipDate]						= SE.dtmShipDate
					,[intShipFromLocationId]			= SE.intShipFromLocationId
					,[intShipToLocationId]				= SE.intShipToLocationId
					,[intFreightTermId]					= SE.intFreightTermId
					,[intForexRateTypeId]				= case when ContractCost.intCurrencyId is null 
															then SE.intForexRateTypeId 
															else 
																ContractCost.intRateTypeId
															end
					,[dblForexRate]						= case when ContractCost.intCurrencyId is null 
															then SE.dblForexRate 
															else 
																ContractCost.dblFX
															end
				
					--Charges
					,[intContractId]					= SE.intOrderId
					,[intContractDetailId]				= SE.intLineNo
					,[intCurrencyId]  					= isnull(ContractCost.intCurrencyId, SE.intCurrencyId)
					,[intChargeId]						= ContractCost.intItemId
					,[strCostMethod]					= ContractCost.strCostMethod
					,[dblRate]							= CASE
															WHEN ContractCost.strCostMethod = 'Amount' THEN 0
															ELSE ContractCost.dblRate
														END
					,[intCostUOMId]						= ContractCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
					,[dblAmount]						=  CASE
															WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND (((SE.dblQuantity / SC.dblNetUnits) * ISNULL(ContractCost.dblRate,SC.dblFreightRate)), 2)
															ELSE 0
														END	
					,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
					,[ysnPrice]							= ContractCost.ysnPrice
					,[strChargesLink]					= SE.strChargesLink
					FROM tblCTContractCost ContractCost
					LEFT JOIN @ShipmentStagingTable SE ON SE.intLineNo = ContractCost.intContractDetailId
					LEFT JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
					WHERE ContractCost.intItemId != @intFreightItemId AND SE.intOrderId IS NOT NULL AND ContractCost.dblRate != 0
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
END

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
			, strWarehouseCargoNumber
		)
		SELECT 
			intOrderType				= SE.intOrderType
			, intSourceType 			= SE.intSourceType
			, intEntityCustomerId		= SE.intEntityCustomerId
			, dtmShipDate				= SE.dtmShipDate
			, intShipFromLocationId		= SE.intShipFromLocationId
			, intShipToLocationId		= SE.intShipToLocationId
			, intFreightTermId			= SE.intFreightTermId
			, intItemLotGroup			= SE.intItemLotGroup
			, intLotId					= SC.intLotId
			, dblQuantity				= SE.dblQuantity
			, dblGrossWeight			= SE.dblGross 
			, dblTareWeight				= SE.dblTare
			, dblWeightPerQty			= 0
			, strWarehouseCargoNumber	= SC.strTicketNumber
			FROM @ShipmentStagingTable SE 
			INNER JOIN tblSCTicket SC ON SC.intTicketId = SE.intSourceId
			INNER JOIN tblICItem IC ON IC.intItemId = SE.intItemId
	END

EXEC dbo.uspICAddItemShipment
		@Items = @ShipmentStagingTable
		,@Charges = @ShipmentChargeStagingTable
		,@Lots = @ShipmentItemLotStagingTable
		,@intUserId = @intUserId;

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

exec uspSCUpdateDeliverySheetDate @intTicketId = @intTicketId

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
