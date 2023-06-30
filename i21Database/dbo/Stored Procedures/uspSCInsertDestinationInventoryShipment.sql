CREATE PROCEDURE [dbo].[uspSCInsertDestinationInventoryShipment]
	@ScaleDWGAllocation ScaleDWGAllocation READONLY
	,@intTicketId INT
	,@intUserId INT
	,@ysnPost BIT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);


DECLARE @DestinationItems AS DestinationShipmentItem 
		,@ShipmentCharges AS DestinationShipmentCharge 
		,@scaleStaging AS ScaleDestinationStagingTable
		,@strBatchId NVARCHAR(40)
		,@InventoryShipmentId INT
		,@intHaulerId INT
		,@intFreightItemId INT
		,@intLoadId INT
		,@intLoadContractId INT
		,@intLoadCostId INT
		,@intContractDetailId INT
		,@intContractCost INT
		,@ysnDeductFreightFarmer BIT
		,@ysnDeductFeesCusVen BIT
		,@ysnAccrue BIT
		,@ysnPrice BIT
		,@splitDistribution AS NVARCHAR(40)
		,@intContractCostId INT
		,@dtmScaleDate DATETIME
		,@dblQuantity NUMERIC(38,20)
		,@currencyDecimal INT;
DECLARE @ysnHasISContract BIT = 0;

BEGIN TRY

	IF EXISTS(SELECT TOP 1 1 FROM @ScaleDWGAllocation)
	BEGIN
		SET @ysnHasISContract = 1
	END

	SELECT @dblQuantity = SUM(dblQuantity) FROM tblICInventoryShipmentItem ICSI 
	LEFT JOIN tblICInventoryShipment ICS ON ICS.intInventoryShipmentId = ICSI.intInventoryShipmentId
	WHERE ICSI.intSourceId = @intTicketId AND intSourceType = 1
	-- SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
	SET @currencyDecimal = 20

-- Insert the Inventory Shipment detail items 
	SELECT @intFreightItemId = SCSetup.intFreightItemId
	, @intHaulerId = SCTicket.intHaulerId
	, @splitDistribution = SCTicket.strDistributionOption
	, @ysnDeductFreightFarmer = SCTicket.ysnFarmerPaysFreight 
	, @ysnDeductFeesCusVen = SCTicket.ysnCusVenPaysFees
	, @intLoadId = SCTicket.intLoadId
	, @intContractDetailId = SCTicket.intContractId
	, @intContractCostId = SCTicket.intContractCostId
	, @dtmScaleDate = SCTicket.dtmTicketDateTime
	FROM tblSCScaleSetup SCSetup
	LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId
	WHERE intTicketId = @intTicketId

	INSERT INTO @scaleStaging
	(
		[intTicketId]
		,[intEntityId]
		,[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[intCurrencyId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intTransactionHeaderId]
		,[intTransactionDetailId]
		,[strCostMethod]
		,[intScaleSetupId]
		,[dblFreightRate]
		,[dblTicketFees]
		,[dblGross]
		,[dblTare]
		,[strChargesLink]
		,[ysnIsStorage]
	)
	SELECT 
		[intTicketId]					= SC.intTicketId
		,[intEntityId]					= ICS.intEntityCustomerId
		,[intItemId]					= SC.intItemId
		,[intItemLocationId]			= SC.intProcessingLocationId
		,[intItemUOMId]					= SC.intItemUOMIdTo
		,[dtmDate]						= SC.dtmTicketDateTime
		,[dblQty]						= 	CASE WHEN @ysnHasISContract = 1
										  	THEN 
											  	ICSI.dblQuantity + ISNULL(DWGAlloc.dblUnitAdjustment,0)
										  	ELSE
										  		(CASE WHEN @dblQuantity != SC.dblNetUnits THEN ROUND((ICSI.dblQuantity / @dblQuantity),@currencyDecimal) * SC.dblNetUnits ELSE ICSI.dblQuantity END)
										  	END
		,[dblUOMQty]					= SC.dblConvertedUOMQty
		,[dblCost]						= ICSI.dblUnitPrice
		,[intCurrencyId]				= SC.intCurrencyId
		,[intContractHeaderId]			= ICSI.intOrderId
		,[intContractDetailId]			= ICSI.intLineNo
		,[intTransactionHeaderId]		= ICSI.intInventoryShipmentId
		,[intTransactionDetailId]		= ICSI.intInventoryShipmentItemId
		,[strCostMethod]				= SC.strCostMethod
		,[intScaleSetupId]				= SC.intScaleSetupId
		,[dblFreightRate]				= ISNULL(SC.dblFreightRate, 0)
		,[dblTicketFees]				= SC.dblTicketFees
		,[dblGross]						= 	CASE WHEN @ysnHasISContract = 1
										  	THEN
												CASE WHEN SC.dblNetUnits <> SC.dblDWGOriginalNetUnits
												THEN
													ROUND((ICSI.dblQuantity + ISNULL(DWGAlloc.dblUnitAdjustment,0))/SC.dblNetUnits,@currencyDecimal) * SC.dblGrossUnits
												ELSE
													ICSI.dblGross
												END
										  	ELSE
												(CASE WHEN @dblQuantity != SC.dblNetUnits THEN ROUND((ICSI.dblQuantity / @dblQuantity),@currencyDecimal) * SC.dblGrossUnits ELSE ICSI.dblGross END)
											END
		,[dblTare]						= 	CASE WHEN @ysnHasISContract = 1
										  	THEN
											  	CASE WHEN SC.dblNetUnits <> SC.dblDWGOriginalNetUnits
													THEN (ROUND((ICSI.dblQuantity + ISNULL(DWGAlloc.dblUnitAdjustment,0.0))/SC.dblNetUnits,@currencyDecimal) * SC.dblGrossUnits) - (ROUND(((ICSI.dblQuantity + ISNULL(DWGAlloc.dblUnitAdjustment,0.0)) / SC.dblNetUnits),@currencyDecimal) * SC.dblNetUnits)
												ELSE ICSI.dblGross - ICSI.dblQuantity 
												END
											ELSE
												(CASE WHEN @dblQuantity != SC.dblNetUnits 
													THEN (ROUND((ICSI.dblQuantity / @dblQuantity),@currencyDecimal) * SC.dblGrossUnits) - (ROUND((ICSI.dblQuantity / @dblQuantity),@currencyDecimal) * SC.dblNetUnits)
												ELSE ICSI.dblGross - ICSI.dblQuantity 
												END)
											END
		,[strChargesLink]				= ICSI.strChargesLink
		,[ysnIsStorage]					= CASE WHEN ICSI.intOwnershipType = 1 THEN 1 ELSE 0 END
	FROM tblSCTicket SC 
	LEFT JOIN tblICInventoryShipmentItem ICSI ON ICSI.intSourceId = SC.intTicketId
	LEFT JOIN tblICInventoryShipment ICS ON ICS.intInventoryShipmentId = ICSI.intInventoryShipmentId
	LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = ICSI.intLineNo
	LEFT JOIN @ScaleDWGAllocation DWGAlloc ON  ICSI.intInventoryShipmentItemId = DWGAlloc.intInventoryShipmentItemId
	WHERE SC.intTicketId = @intTicketId AND ICS.intSourceType = 1 AND CASE WHEN CTD.intPricingTypeId = 2 THEN 1 ELSE CASE WHEN ISNULL(ICSI.ysnAllowInvoice,1) = 1 THEN 1 ELSE 0 END END = 1 

	INSERT INTO @DestinationItems (
		[intItemId] 
		,[intItemLocationId] 
		,[dblDestinationQty] 
		,[intSourceId] 
		,[intInventoryShipmentId] 
		,[intInventoryShipmentItemId] 
		,[dblDestinationGross]
		,[dblDestinationNet]
	)
	SELECT	
		[intItemId]						= SC.intItemId 
		,[intItemLocationId]			= ICIL.intItemLocationId
		,[dblDestinationQty]			= SC.dblQty --CASE WHEN SCT.dblNetUnits > @dblQuantity THEN CASE WHEN SCT.dblNetUnits > (CD.dblScheduleQty + CD.dblAvailableQty) THEN CD.dblOriginalQty ELSE SC.dblQty END ELSE SC.dblQty END
		,[intSourceId]					= 1
		,[intInventoryShipmentId]		= SC.intTransactionHeaderId
		,[intInventoryShipmentItemId]	= SC.intTransactionDetailId
		,[dblDestinationGross]			= SC.dblGross
		,[dblDestinationNet]			= SC.dblGross - SC.dblTare
	FROM @scaleStaging SC 
	INNER JOIN tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intItemLocationId 
	WHERE SC.intTicketId = @intTicketId

	INSERT INTO @ShipmentCharges
	(
		intInventoryShipmentId
		,intContractId 
		,intContractDetailId 
		,intChargeId 
		,strCostMethod 
		,dblRate 
		,intCostUOMId 
		,intCurrency 
		,dblAmount 
		,intEntityVendorId 
		,ysnAccrue 
		,ysnPrice 
		,intForexRateTypeId 
		,dblForexRate 
		,strChargesLink 
	)
	SELECT
	--Charges
	[intInventoryShipmentId]			= SC.intTransactionHeaderId
	,[intContractId]					= SC.intContractHeaderId
	,[intContractDetailId]				= SC.intContractDetailId
	,[intChargeId]						= GR.intItemId
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE
												WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SC.intTicketId, SC.intEntityId, QM.intTicketDiscountId, SC.dblQty, GR.intUnitMeasureId,SC.dblCost, 0) * -1)
												ELSE (QM.dblDiscountAmount * -1)
											END 
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= CASE
											WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, SC.intItemUOMId)
											WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
										END
	,[intCurrencyId]  					= SC.intCurrencyId
	,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN SC.ysnIsStorage = 0 THEN 0
													ELSE
													ROUND(CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SC.intTicketId, SC.intEntityId, QM.intTicketDiscountId, SC.dblQty, GR.intUnitMeasureId,SC.dblCost, 0) * -1)
														ELSE (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, SC.dblQty, GR.intUnitMeasureId,SC.dblCost) * -1)
													END,2)
												END 
											END
	,[intOtherChargeEntityVendorId]		= NULL
	,[ysnAccrue]						= 0
	,[ysnPrice]							= 1
	,[intForexRateTypeId]				= NULL
	,[dblForexRate]						= NULL
	,[strChargesLink]					= SC.strChargesLink
	FROM @scaleStaging SC
	LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId
	LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
	WHERE SC.intTicketId = @intTicketId AND QM.dblDiscountAmount != 0

	--Insert record for fee
	INSERT INTO @ShipmentCharges
	(
		intInventoryShipmentId
		,intContractId
		,intContractDetailId 
		,intChargeId 
		,strCostMethod 
		,dblRate 
		,intCostUOMId 
		,intCurrency 
		,dblAmount 
		,intEntityVendorId 
		,ysnAccrue 
		,ysnPrice 
		,intForexRateTypeId 
		,dblForexRate
		,strChargesLink 
	)
	SELECT	
		intInventoryShipmentId		= SC.intTransactionHeaderId 
		,intContractId				= NULL
		,intContractDetailId		= NULL
		,intChargeId				= SCSetup.intDefaultFeeItemId
		,strCostMethod				= IC.strCostMethod 
		,dblRate					= CASE
										WHEN IC.strCostMethod = 'Per Unit' THEN 
										CASE
											WHEN @ysnDeductFeesCusVen = 1 THEN (SC.dblTicketFees * -1)
											WHEN @ysnDeductFeesCusVen = 0 THEN SC.dblTicketFees
										END
										WHEN IC.strCostMethod = 'Amount' THEN 0
									END
		,intCostUOMId				= dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, SC.intItemUOMId) 
		,intCurrency				= SC.intCurrencyId
		,dblAmount					= CASE
										WHEN IC.strCostMethod = 'Per Unit' THEN 0
										WHEN IC.strCostMethod = 'Amount' THEN 
										CASE
											WHEN @ysnDeductFeesCusVen = 0 THEN ROUND(SC.dblTicketFees, 2)
											WHEN @ysnDeductFeesCusVen = 1 THEN ROUND(SC.dblTicketFees, 2) * -1
										END
									END
		,intEntityVendorId			= null
		,ysnAccrue					= 0
		,ysnPrice					= 1
		,intForexRateTypeId			= null 
		,dblForexRate				= null
		,strChargesLink				= SC.strChargesLink
	FROM @scaleStaging SC
	INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
	INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
	WHERE SC.intTicketId = @intTicketId AND SC.dblTicketFees > 0

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
							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId 
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= SC.strCostMethod
							,[dblRate]						= CASE
																WHEN SC.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END
							,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = LoadDetail.intSContractDetailId
							LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intSContractDetailId = @intLoadContractId
							AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0 AND SC.intTicketId = @intTicketId

							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId 
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= LoadCost.strCostMethod
							,[dblRate]						= CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END	
							,[intCostUOMId]					= LoadCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = LoadDetail.intSContractDetailId
							LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
							WHERE LoadCost.intItemId != @intFreightItemId AND LoadDetail.intSContractDetailId = @intLoadContractId 
							AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0 AND SC.intTicketId = @intTicketId
						END
					ELSE
						BEGIN
							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId 
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= SC.intContractDetailId
							,[intChargeId]					= ContractCost.intItemId
							,[strCostMethod]				= SC.strCostMethod
							,[dblRate]						= CASE
																WHEN SC.strCostMethod = 'Amount' THEN 0
																ELSE ContractCost.dblRate
															END
							,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * ContractCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblCTContractCost ContractCost
							LEFT JOIN @scaleStaging SC ON SC.intContractHeaderId = ContractCost.intContractDetailId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE ContractCost.intItemId = @intFreightItemId AND SC.intContractDetailId = @intLoadContractId 
							AND ContractCost.dblRate != 0 AND SC.intTicketId = @intTicketId

							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId 
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= SC.intContractDetailId
							,[intChargeId]					= ContractCost.intItemId
							,[strCostMethod]				= ContractCost.strCostMethod
							,[dblRate]						= CASE
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																ELSE ContractCost.dblRate
															END	
							,[intCostUOMId]					= ContractCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * ContractCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= ContractCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblCTContractCost ContractCost
							LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = ContractCost.intContractDetailId
							WHERE ContractCost.intItemId != @intFreightItemId AND SC.intContractHeaderId = @intLoadContractId 
							AND ContractCost.dblRate != 0 AND SC.intTicketId = @intTicketId
						END
				END
			ELSE
				BEGIN
					IF ISNULL(@intLoadCostId,0) != 0
						BEGIN
							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId 
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= LoadCost.strCostMethod
							,[dblRate]						= CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END	
							,[intCostUOMId]					= LoadCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= LoadCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN @scaleStaging SC ON SC.intContractHeaderId = LoadDetail.intSContractDetailId
							LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
							WHERE LoadCost.intLoadId = @intLoadId AND LoadDetail.intSContractDetailId = @intLoadContractId 
							AND LoadCost.dblRate != 0 AND SC.intTicketId = @intTicketId
						END
					ELSE
						BEGIN
							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId
								,intContractDetailId  
								,intChargeId 
								,strCostMethod 
								,dblRate 
								,intCostUOMId 
								,intCurrency 
								,dblAmount 
								,intEntityVendorId 
								,ysnAccrue 
								,ysnPrice 
								,intForexRateTypeId 
								,dblForexRate
								,strChargesLink 
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intTransactionHeaderId
							,[intContractId]				= SC.intContractHeaderId
							,[intContractDetailId]			= ContractCost.intContractDetailId
							,[intChargeId]					= ContractCost.intItemId
							,[strCostMethod]				= ContractCost.strCostMethod
							,[dblRate]						= CASE
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																ELSE ContractCost.dblRate
															END	
							,[intCostUOMId]					= ContractCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN ContractCost.strCostMethod = 'Per Unit' THEN 0
																WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * ContractCost.dblRate, 2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= ContractCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							,[strChargesLink]				= SC.strChargesLink
							FROM tblCTContractCost ContractCost
							LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = ContractCost.intContractDetailId
							WHERE SC.intContractHeaderId = @intLoadContractId AND ContractCost.dblRate != 0 AND SC.intTicketId = @intTicketId
						END
				END
		END
	ELSE
		BEGIN
			IF ISNULL(@intContractDetailId,0) = 0 
				BEGIN
					INSERT INTO @ShipmentCharges
					(
						intInventoryShipmentId
						,intContractId
						,intContractDetailId 
						,intChargeId 
						,strCostMethod 
						,dblRate 
						,intCostUOMId 
						,intCurrency 
						,dblAmount 
						,intEntityVendorId 
						,ysnAccrue 
						,ysnPrice 
						,intForexRateTypeId 
						,dblForexRate
						,strChargesLink 
					)
					SELECT	
					[intInventoryShipmentId]		= SC.intTransactionHeaderId
					,[intContractId]				= NULL
					,[intContractDetailId]			= NULL
					,[intChargeId]					= @intFreightItemId
					,[strCostMethod]				= SC.strCostMethod
					,[dblRate]						= CASE
														WHEN SC.strCostMethod = 'Amount' THEN 0
														ELSE SC.dblFreightRate
													END
					,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMId)
					,[intCurrencyId]  				= SC.intCurrencyId
					,[dblAmount]					=  CASE
														WHEN SC.strCostMethod = 'Amount' THEN ROUND (SC.dblQty * SC.dblFreightRate, 2)
														ELSE 0
													END 
					,[intEntityVendorId]			= CASE
														WHEN @intHaulerId = 0 THEN NULL
														WHEN @intHaulerId != 0 THEN @intHaulerId
													END
					,[ysnAccrue]					= @ysnAccrue
					,[ysnPrice]						= @ysnPrice
					,[intForexRateTypeId]			= NULL
					,[dblForexRate]					= NULL
					,[strChargesLink]				= SC.strChargesLink
					FROM @scaleStaging SC
					LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
					LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
					WHERE SC.dblFreightRate > 0 AND SC.intTicketId = @intTicketId
				END
			ELSE IF ISNULL(@intFreightItemId,0) != 0
			BEGIN
				IF ISNULL(@intContractCostId,0) = 0
					BEGIN
						INSERT INTO @ShipmentCharges
						(
							intInventoryShipmentId
							,intContractId
							,intContractDetailId 
							,intChargeId 
							,strCostMethod 
							,dblRate 
							,intCostUOMId 
							,intCurrency 
							,dblAmount 
							,intEntityVendorId 
							,ysnAccrue 
							,ysnPrice 
							,intForexRateTypeId 
							,dblForexRate
							,strChargesLink 
						)
						SELECT	
						[intInventoryShipmentId]	= SC.intTransactionHeaderId
						,[intContractId]			= SC.intContractHeaderId
						,[intContractDetailId]		= SC.intContractDetailId
						,[intChargeId]				= SCS.intFreightItemId
						,[strCostMethod]			= SC.strCostMethod
						,[dblRate]					= CASE
														WHEN SC.strCostMethod = 'Amount' THEN 0
														ELSE SC.dblFreightRate
													END
						,[intCostUOMId]				= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMId)
						,[intCurrencyId]  			= SC.intCurrencyId
						,[dblAmount]				=  CASE
														WHEN SC.strCostMethod = 'Amount' THEN 
														CASE
															WHEN ISNULL(CT.intContractCostId,0) = 0 THEN ROUND(SC.dblQty * SC.dblFreightRate, 2)
															ELSE ROUND(SC.dblQty * CT.dblRate, 2)
														END
														ELSE 0
													END
						,[intEntityVendorId]		= CASE
														WHEN @intHaulerId = 0 THEN NULL
														WHEN @intHaulerId != 0 THEN @intHaulerId
													END
						,[ysnAccrue]				= @ysnAccrue
						,[ysnPrice]					= @ysnPrice
						,[intForexRateTypeId]		= NULL
						,[dblForexRate]				= NULL
						,[strChargesLink]			= SC.strChargesLink
						FROM @scaleStaging SC
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						OUTER APPLY(
							SELECT * FROM tblCTContractCost WHERE intContractDetailId = SC.intContractDetailId 
							AND dblRate != 0 
							AND intItemId = @intFreightItemId
						) CT
						WHERE SC.dblFreightRate != 0 AND SC.intTicketId = @intTicketId
					END
				ELSE
					BEGIN
						INSERT INTO @ShipmentCharges
						(
							intInventoryShipmentId
							,intContractId
							,intContractDetailId 
							,intChargeId 
							,strCostMethod 
							,dblRate 
							,intCostUOMId 
							,intCurrency 
							,dblAmount 
							,intEntityVendorId 
							,ysnAccrue 
							,ysnPrice 
							,intForexRateTypeId 
							,dblForexRate
							,strChargesLink 
						)
						SELECT	
						[intInventoryShipmentId]		= SC.intTransactionHeaderId
						,[intContractId]				= SC.intContractHeaderId
						,[intContractDetailId]			= SC.intContractDetailId
						,[intChargeId]					= ContractCost.intItemId
						,[strCostMethod]				= SC.strCostMethod
						,[dblRate]						= CASE
															WHEN SC.strCostMethod = 'Amount' THEN 0
															ELSE ContractCost.dblRate
														END
						,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
						,[intCurrencyId]  				= SC.intCurrencyId
						,[dblAmount]					=  CASE
															WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblQty * ContractCost.dblRate, 2)
															ELSE 0
														END
						,[intEntityVendorId]			= ContractCost.intVendorId
						,[ysnAccrue]					= @ysnAccrue
						,[ysnPrice]						= @ysnPrice
						,[intForexRateTypeId]			= NULL
						,[dblForexRate]					= NULL
						,[strChargesLink]				= SC.strChargesLink
						FROM tblCTContractCost ContractCost
						LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = ContractCost.intContractDetailId
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE ContractCost.intItemId = @intFreightItemId 
						AND ContractCost.dblRate != 0 
						AND SC.intTicketId = @intTicketId

						INSERT INTO @ShipmentCharges
						(
							intInventoryShipmentId
							,intContractId
							,intContractDetailId 
							,intChargeId 
							,strCostMethod 
							,dblRate 
							,intCostUOMId 
							,intCurrency 
							,dblAmount 
							,intEntityVendorId 
							,ysnAccrue 
							,ysnPrice 
							,intForexRateTypeId 
							,dblForexRate
							,strChargesLink 
						)
						SELECT	
						[intInventoryShipmentId]		= SC.intTransactionHeaderId
						,[intContractId]				= NULL
						,[intContractDetailId]			= NULL
						,[intChargeId]					= @intFreightItemId
						,[strCostMethod]				= SC.strCostMethod
						,[dblRate]						= CASE
															WHEN SC.strCostMethod = 'Amount' THEN 0
															ELSE SC.dblFreightRate
														END
						,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMId)
						,[intCurrencyId]  				= SC.intCurrencyId
						,[dblAmount]					=  CASE
															WHEN SC.strCostMethod = 'Amount' THEN ROUND (SC.dblQty * SC.dblFreightRate, 2)
															ELSE 0
														END
						,[intEntityVendorId]			= CASE
															WHEN @intHaulerId = 0 THEN NULL
															WHEN @intHaulerId != 0 THEN @intHaulerId
														END
						,[ysnAccrue]					= @ysnAccrue
						,[ysnPrice]						= @ysnPrice
						,[intForexRateTypeId]			= NULL
						,[dblForexRate]					= NULL
						,[strChargesLink]				= SC.strChargesLink
						FROM @scaleStaging SC
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE SC.dblFreightRate > 0 AND SC.intContractDetailId IS NULL AND SC.intTicketId = @intTicketId
					END
			END

			INSERT INTO @ShipmentCharges
			(
				intInventoryShipmentId
				,intContractId
				,intContractDetailId 
				,intChargeId 
				,strCostMethod 
				,dblRate 
				,intCostUOMId 
				,intCurrency 
				,dblAmount 
				,intEntityVendorId 
				,ysnAccrue 
				,ysnPrice 
				,intForexRateTypeId 
				,dblForexRate
				,strChargesLink 
			)
			SELECT	
			[intInventoryShipmentId]			= SC.intTransactionHeaderId
			,[intContractId]					= SC.intContractHeaderId
			,[intContractDetailId]				= SC.intContractDetailId
			,[intChargeId]						= ContractCost.intItemId
			,[strCostMethod]					= ContractCost.strCostMethod
			,[dblRate]							= CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN 0
													ELSE ContractCost.dblRate
												END
			,[intCostUOMId]						= ContractCost.intItemUOMId
			,[intCurrencyId]  					= SC.intCurrencyId
			,[dblAmount]						=  CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND (SC.dblQty * ISNULL(ContractCost.dblRate, SC.dblFreightRate), 2)
													ELSE 0
												END	
			,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
			,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
			,[ysnPrice]							= ContractCost.ysnPrice
			,[intForexRateTypeId]				= NULL
			,[dblForexRate]						= NULL
			,[strChargesLink]					= SC.strChargesLink
			FROM tblCTContractCost ContractCost
			LEFT JOIN @scaleStaging SC ON SC.intContractDetailId = ContractCost.intContractDetailId
			WHERE ContractCost.intItemId != @intFreightItemId AND ContractCost.dblRate != 0 
			AND SC.intTicketId = @intTicketId
		END
		
	---Update ysnAddPayable. Do not add charges to payable if DWG is unposted
	UPDATE @ShipmentCharges
	SET ysnAddPayable = @ysnPost


	-- Call the uspICPostDestinationInventoryShipment sp to post the following:
	-- 1. Destination qty 
	-- 2. Other charges. 
	-- 3. Inventory Adjustment. 
	DECLARE @CURERENT_DATE DATETIME = GETDATE()
	EXEC [uspICPostDestinationInventoryShipment] @ysnPost ,0 ,@CURERENT_DATE ,@DestinationItems ,@ShipmentCharges ,@intUserId ,@strBatchId 
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH