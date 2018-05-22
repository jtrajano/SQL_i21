CREATE PROCEDURE [dbo].[uspSCInsertDestinationInventoryShipment]
	@intTicketId INT,
	@intUserId INT,
	@ysnPost BIT
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
		,@dtmScaleDate DATETIME;

BEGIN TRY

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

	INSERT INTO @DestinationItems (
		[intItemId] 
		,[intItemLocationId] 
		,[dblDestinationQty] 
		,[intSourceId] 
		,[intInventoryShipmentId] 
		,[intInventoryShipmentItemId] 
	)
	SELECT	
		[intItemId] = si.intItemId 
		,[intItemLocationId] = il.intItemLocationId
		,[dblDestinationQty] = sc.dblNetUnits
		,[intSourceId] = 1
		,[intInventoryShipmentId] = s.intInventoryShipmentId
		,[intInventoryShipmentItemId] = si.intInventoryShipmentItemId 
	FROM tblSCTicket sc 
		INNER JOIN tblICInventoryShipmentItem si ON si.intSourceId = sc.intTicketId 
		INNER JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN tblICItemLocation il ON il.intItemId = si.intItemId AND il.intLocationId = s.intShipFromLocationId 
	WHERE sc.intTicketId = @intTicketId AND s.intSourceType = 1

	INSERT INTO @ShipmentCharges
	(
		intInventoryShipmentId
		,intContractId 
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
	)
	SELECT
	--Charges
	[intInventoryShipmentId]			= SC.intInventoryShipmentId
	,[intContractId]					= SC.intContractId
	,[intChargeId]						= IC.intItemId
	,[strCostMethod]					= IC.strCostMethod
	,[dblRate]							= CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE
												WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SC.intTicketId, SC.intEntityId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, 0) * -1)
												ELSE (QM.dblDiscountAmount * -1)
											END 
											WHEN IC.strCostMethod = 'Amount' THEN 0
										END
	,[intCostUOMId]						= CASE
											WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, SC.intItemUOMIdTo)
											WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
										END
	,[intCurrencyId]  					= SC.intCurrencyId
	,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN SC.intTicketTypeId > 0 AND ISNULL(SC.intContractId, 0 ) = 0 THEN 0
													ELSE
													CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(SC.intTicketId, SC.intEntityId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, 0) * -1)
														ELSE (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId) * -1)
													END
												END 
											END
	,[intOtherChargeEntityVendorId]		= NULL
	,[ysnAccrue]						= 0
	,[ysnPrice]							= 1
	,[intForexRateTypeId]				= NULL
	,[dblForexRate]						= NULL
	FROM tblSCTicket SC
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
	)
	SELECT	
		intInventoryShipmentId = SC.intInventoryShipmentId 
		,intContractId = NULL 
		,intChargeId = SCSetup.intDefaultFeeItemId
		,strCostMethod = IC.strCostMethod 
		,dblRate = CASE
						WHEN IC.strCostMethod = 'Per Unit' THEN 
						CASE
							WHEN @ysnDeductFeesCusVen = 1 THEN (SC.dblTicketFees * -1)
							WHEN @ysnDeductFeesCusVen = 0 THEN SC.dblTicketFees
						END
						WHEN IC.strCostMethod = 'Amount' THEN 0
					END
		,intCostUOMId = dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, SC.intItemUOMIdTo) 
		,intCurrency = SC.intCurrencyId
		,dblAmount = CASE
						WHEN IC.strCostMethod = 'Per Unit' THEN 0
						WHEN IC.strCostMethod = 'Amount' THEN 
						CASE
							WHEN @ysnDeductFeesCusVen = 0 THEN SC.dblTicketFees
							WHEN @ysnDeductFeesCusVen = 1 THEN (SC.dblTicketFees * -1)
						END
					END
		,intEntityVendorId = null
		,ysnAccrue = 0
		,ysnPrice = 1
		,intForexRateTypeId = null 
		,dblForexRate = null
	FROM tblSCTicket SC
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= SC.strCostMethod
							,[dblRate]						= CASE
																WHEN SC.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END
							,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN tblSCTicket SC ON SC.intContractId = LoadDetail.intSContractDetailId
							LEFT JOIN tblLGLoadCost LoadCost ON LoadCost.intLoadId = LoadDetail.intLoadId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE LoadCost.intItemId = @intFreightItemId AND LoadDetail.intSContractDetailId = @intLoadContractId
							AND LoadCost.intLoadId = @intLoadId AND LoadCost.dblRate != 0 AND SC.intTicketId = @intTicketId

							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId 
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= LoadCost.strCostMethod
							,[dblRate]						= CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END	
							,[intCostUOMId]					= LoadCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN tblSCTicket SC ON SC.intContractId = LoadDetail.intSContractDetailId
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= SC.intContractId
							,[intChargeId]					= ContractCost.intItemId
							,[strCostMethod]				= SC.strCostMethod
							,[dblRate]						= CASE
																WHEN SC.strCostMethod = 'Amount' THEN 0
																ELSE ContractCost.dblRate
															END
							,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * ContractCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= @ysnAccrue
							,[ysnPrice]						= @ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblCTContractCost ContractCost
							LEFT JOIN tblSCTicket SC ON SC.intContractId = ContractCost.intContractDetailId
							LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
							LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
							WHERE ContractCost.intItemId = @intFreightItemId AND SC.intContractId = @intLoadContractId 
							AND ContractCost.dblRate != 0 AND SC.intTicketId = @intTicketId

							INSERT INTO @ShipmentCharges
							(
								intInventoryShipmentId
								,intContractId 
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= SC.intContractId
							,[intChargeId]					= ContractCost.intItemId
							,[strCostMethod]				= ContractCost.strCostMethod
							,[dblRate]						= CASE
																WHEN ContractCost.strCostMethod = 'Amount' THEN 0
																ELSE ContractCost.dblRate
															END	
							,[intCostUOMId]					= ContractCost.intItemUOMId
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * ContractCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= ContractCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblCTContractCost ContractCost
							LEFT JOIN tblSCTicket SC ON SC.intContractId = ContractCost.intContractDetailId
							WHERE ContractCost.intItemId != @intFreightItemId AND SC.intContractId = @intLoadContractId 
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= LoadDetail.intSContractDetailId
							,[intChargeId]					= LoadCost.intItemId
							,[strCostMethod]				= LoadCost.strCostMethod
							,[dblRate]						= CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN 0
																ELSE LoadCost.dblRate
															END	
							,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, LoadCost.intItemUOMId)
							,[intCurrencyId]  				= SC.intCurrencyId
							,[dblAmount]					=  CASE
																WHEN LoadCost.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * LoadCost.dblRate,2)
																ELSE 0
															END	
							,[intEntityVendorId]			= LoadCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= LoadCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblLGLoadDetail LoadDetail
							LEFT JOIN tblSCTicket SC ON SC.intContractId = LoadDetail.intSContractDetailId
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
							)
							SELECT	
							[intInventoryShipmentId]		= SC.intInventoryShipmentId
							,[intContractId]				= ContractCost.intContractDetailId
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
																WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * ContractCost.dblRate, 2)
																ELSE 0
															END	
							,[intEntityVendorId]			= ContractCost.intVendorId
							,[ysnAccrue]					= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
							,[ysnPrice]						= ContractCost.ysnPrice
							,[intForexRateTypeId]			= NULL
							,[dblForexRate]					= NULL
							FROM tblCTContractCost ContractCost
							LEFT JOIN tblSCTicket SC ON SC.intContractId = ContractCost.intContractDetailId
							WHERE SC.intContractId = @intLoadContractId AND ContractCost.dblRate != 0 AND SC.intTicketId = @intTicketId
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
					)
					SELECT	
					[intInventoryShipmentId]		= SC.intInventoryShipmentId
					,[intContractId]				= NULL
					,[intChargeId]					= @intFreightItemId
					,[strCostMethod]				= SC.strCostMethod
					,[dblRate]						= CASE
														WHEN SC.strCostMethod = 'Amount' THEN 0
														ELSE SC.dblFreightRate
													END
					,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMIdTo)
					,[intCurrencyId]  				= SC.intCurrencyId
					,[dblAmount]					=  CASE
														WHEN SC.strCostMethod = 'Amount' THEN ROUND (SC.dblNetUnits * SC.dblFreightRate, 2)
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
					FROM blSCTicket SC
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
						)
						SELECT	
						[intInventoryShipmentId]	= SC.intInventoryShipmentId
						,[intContractId]			= SC.intContractId
						,[intChargeId]				= SCS.intFreightItemId
						,[strCostMethod]			= SC.strCostMethod
						,[dblRate]					= CASE
														WHEN SC.strCostMethod = 'Amount' THEN 0
														ELSE SC.dblFreightRate
													END
						,[intCostUOMId]				= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMIdTo)
						,[intCurrencyId]  			= SC.intCurrencyId
						,[dblAmount]				=  CASE
														WHEN SC.strCostMethod = 'Amount' THEN 
														CASE
															WHEN ISNULL(CT.intContractCostId,0) = 0 THEN ROUND(SC.dblNetUnits * SC.dblFreightRate, 2)
															ELSE ROUND(SC.dblNetUnits * CT.dblRate, 2)
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
						FROM tblSCTicket SC
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						OUTER APPLY(
							SELECT * FROM tblCTContractCost WHERE intContractDetailId = SC.intContractId 
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
						)
						SELECT	
						[intInventoryShipmentId]		= SC.intInventoryShipmentId
						,[intContractId]				= SC.intContractId
						,[intChargeId]					= ContractCost.intItemId
						,[strCostMethod]				= SC.strCostMethod
						,[dblRate]						= CASE
															WHEN SC.strCostMethod = 'Amount' THEN 0
															ELSE ContractCost.dblRate
														END
						,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
						,[intCurrencyId]  				= SC.intCurrencyId
						,[dblAmount]					=  CASE
															WHEN SC.strCostMethod = 'Amount' THEN ROUND(SC.dblNetUnits * ContractCost.dblRate, 2)
															ELSE 0
														END
						,[intEntityVendorId]			= ContractCost.intVendorId
						,[ysnAccrue]					= @ysnAccrue
						,[ysnPrice]						= @ysnPrice
						,[intForexRateTypeId]			= NULL
						,[dblForexRate]					= NULL
						FROM tblCTContractCost ContractCost
						LEFT JOIN tblSCTicket SC ON SC.intContractId = ContractCost.intContractDetailId
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE ContractCost.intItemId = @intFreightItemId 
						AND ContractCost.dblRate != 0 
						AND SC.intTicketId = @intTicketId

						INSERT INTO @ShipmentCharges
						(
							intInventoryShipmentId
							,intContractId 
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
						)
						SELECT	
						[intInventoryShipmentId]		= SC.intInventoryShipmentId
						,[intContractId]				= NULL
						,[intChargeId]					= @intFreightItemId
						,[strCostMethod]				= SC.strCostMethod
						,[dblRate]						= CASE
															WHEN SC.strCostMethod = 'Amount' THEN 0
															ELSE SC.dblFreightRate
														END
						,[intCostUOMId]					= dbo.fnGetMatchingItemUOMId(@intFreightItemId, SC.intItemUOMIdTo)
						,[intCurrencyId]  				= SC.intCurrencyId
						,[dblAmount]					=  CASE
															WHEN SC.strCostMethod = 'Amount' THEN ROUND (SC.dblNetUnits * SC.dblFreightRate, 2)
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
						FROM tblSCTicket SC
						LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
						LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
						WHERE SC.dblFreightRate > 0 AND SC.intTicketId = @intTicketId
					END
			END

			INSERT INTO @ShipmentCharges
			(
				intInventoryShipmentId
				,intContractId 
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
			)
			SELECT	
			[intInventoryShipmentId]			= SC.intInventoryShipmentId
			,[intContractId]					= SC.intContractId
			,[intChargeId]						= ContractCost.intItemId
			,[strCostMethod]					= ContractCost.strCostMethod
			,[dblRate]							= CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN 0
													ELSE ContractCost.dblRate
												END
			,[intCostUOMId]						= ContractCost.intItemUOMId
			,[intCurrencyId]  					= SC.intCurrencyId
			,[dblAmount]						=  CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN ROUND (SC.dblNetUnits * ISNULL(ContractCost.dblRate,SC.dblFreightRate), 2)
													ELSE 0
												END	
			,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
			,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
			,[ysnPrice]							= ContractCost.ysnPrice
			,[intForexRateTypeId]				= NULL
			,[dblForexRate]						= NULL
			FROM tblCTContractCost ContractCost
			LEFT JOIN tblSCTicket SC ON SC.intContractId = ContractCost.intContractDetailId
			WHERE ContractCost.intItemId != @intFreightItemId AND ContractCost.dblRate != 0 
			AND SC.intTicketId = @intTicketId
		END

	-- Call the uspICPostDestinationInventoryShipment sp to post the following:
	-- 1. Destination qty 
	-- 2. Other charges. 
	-- 3. Inventory Adjustment. 
	EXEC [uspICPostDestinationInventoryShipment] @ysnPost ,0 ,@dtmScaleDate ,@DestinationItems ,@ShipmentCharges ,@intUserId ,@strBatchId 
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