CREATE PROCEDURE [dbo].[uspSCDirectCreateVoucher]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@dtmScaleDate DATETIME,
	@intUserId INT,
	@intBillId INT = NULL OUTPUT
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
DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@voucherDetailDirectInventory AS VoucherDetailDirectInventory
		,@invoiceIntegrationStagingTable AS InvoiceIntegrationStagingTable
		,@InTransitTableType AS InTransitTableType
		,@success INT
		,@intInvoiceId INT
		,@intFreightTermId INT
		,@intShipToId INT
		,@CreatedInvoices NVARCHAR(MAX)
		,@UpdatedInvoices NVARCHAR(MAX)
		,@successfulCount INT
		,@invalidCount INT
		,@batchIdUsed NVARCHAR(100)
		,@recapId INT
		,@recCount INT
		,@vendorOrderNumber NVARCHAR(50)
		,@voucherPayable as VoucherPayable
		,@voucherTaxDetail as VoucherDetailTax
		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge
DECLARE @ScaleToVoucherStagingTable AS ScaleDirectToVoucherItem
DECLARE @intTicketCommodityId INT
DECLARE @intFutureMarketId INT
DECLARE @intFutureMonthId INT
DECLARE @intTicketStorageScheduleTypeId INT

BEGIN TRY

	SELECT TOP 1
		 @intTicketStorageScheduleTypeId =  intStorageScheduleTypeId
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId

	--FOR LINE ITEM
	BEGIN
		---LOAD
		BEGIN
			INSERT INTO @ScaleToVoucherStagingTable(
				[intAccountId]
				,[intItemId]
				,[strMiscDescription]
				,[dblQuantity]
				,[dblUnitQty]
				,[dblDiscount]
				,[dblCost]
				,[intTaxGroupId]
				,[intInvoiceId]
				,[intScaleTicketId]
				,[intUnitOfMeasureId]
				,[intCostUOMId]
				,[dblCostUnitQty]
				,[intContractDetailId]
				,[intLoadDetailId]
				,[intFreightItemId]
				,[dblFreightRate]
				,[intTicketFeesItemId]
				,[dblTicketFees]
				,[intEntityId]
				,[intScaleSetupId]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[dblGrossUnits]
				,[dblNetUnits]
				,[strVendorOrderNumber]
				,[intStorageScheduleTypeId]
				,[intUnitItemUOMId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				intAccountId				= NULL
				,intItemId					= SC.intItemId
				,strMiscDescription			= ICI.strDescription
				,dblQuantity				= SCL.dblQty
				,dblUnitQty					= ICUOM.dblUnitQty
				,dblDiscount				= 0
				,dblCost					= ISNULL(CNT.dblCashPrice,LGD.dblUnitPrice)
				,intTaxGroupId				= dbo.fnGetTaxGroupIdForVendor(SCL.intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,intInvoiceId				= null
				,intScaleTicketId			= SC.intTicketId
				,intUnitOfMeasureId			= SC.intItemUOMIdTo
				,intCostUOMId				= SC.intItemUOMIdTo
				,dblCostUnitQty				= ICUOM.dblUnitQty
				,intContractDetailId		= CNT.intContractDetailId
				,intLoadDetailId			= LGD.intLoadDetailId
				,intFreightItemId			= ISNULL(SCSetup.intFreightItemId,0)
				,dblFreightRate				= SC.dblFreightRate
				,intTicketFeesItemId		= ISNULL(SCSetup.intDefaultFeeItemId,0)
				,dblTicketFees				= SC.dblTicketFees
				,intEntityId				= SCL.intEntityId
				,intScaleSetupId			= SC.intScaleSetupId
				,ysnFarmerPaysFreight		= SC.ysnFarmerPaysFreight
				,ysnCusVenPaysFees			= SC.ysnCusVenPaysFees
				,dblGrossUnits				= SC.dblGrossUnits
				,dblNetUnits				= SC.dblNetUnits
				,strVendorOrderNumber		= 'TKT-' + SC.strTicketNumber
				,intStorageScheduleTypeId	= SC.intStorageScheduleTypeId 
				,[intUnitItemUOMId]			= SC.intItemUOMIdTo
				,intTicketDistributionAllocationId = SCTA.intTicketDistributionAllocationId
			FROM tblSCTicket SC 
			INNER JOIN tblSCTicketLoadUsed SCL
				ON SC.intTicketId = SCL.intTicketId
			INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
			INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblICItemUOM ICUOM
				ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
			INNER JOIN tblLGLoadDetail LGD 
				ON SCL.intLoadDetailId = LGD.intLoadDetailId
			LEFT JOIN tblCTContractDetail CNT
				ON CNT.intContractDetailId = LGD.intPContractDetailId
			INNER JOIN tblSCTicketDistributionAllocation SCTA
				ON SCL.intTicketLoadUsedId = SCTA.intSourceId
					AND intSourceType = 2
			
			-- INNER JOIN (
			-- 	SELECT CTD.intContractHeaderId
			-- 	,CTD.intContractDetailId
			-- 	,CTD.intItemId
			-- 	,CTD.intItemUOMId
			-- 	,CTD.intFutureMarketId
			-- 	,CTD.intFutureMonthId
			-- 	,CTD.intRateTypeId 
			-- 	,CTD.intPriceItemUOMId
			-- 	,CTD.ysnUseFXPrice
			-- 	,CTD.intCurrencyExchangeRateId 
			-- 	,CTD.dblRate 
			-- 	,CTD.intFXPriceUOMId 
			-- 	,CTD.intInvoiceCurrencyId 
			-- 	,CTD.intCurrencyId
			-- 	,CTD.intAdjItemUOMId
			-- 	,CTD.intPricingTypeId
			-- 	,CTD.intBasisUOMId
			-- 	,CTD.dtmEndDate
			-- 	,AD.dblSeqPrice
			-- 	,CU.intCent
			-- 	,CU.ysnSubCurrency
			-- 	FROM tblCTContractDetail CTD 
			-- 	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
			-- 	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
			-- ) CNT ON CNT.intContractDetailId = LGD.intPContractDetailId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = SCL.intEntityId AND ysnDefaultLocation = 1
			WHERE SC.intTicketId = @intTicketId
		END

		---CONTRACT
		BEGIN
			INSERT INTO @ScaleToVoucherStagingTable(
				[intAccountId]
				,[intItemId]
				,[strMiscDescription]
				,[dblQuantity]
				,[dblUnitQty]
				,[dblDiscount]
				,[dblCost]
				,[intTaxGroupId]
				,[intInvoiceId]
				,[intScaleTicketId]
				,[intUnitOfMeasureId]
				,[intCostUOMId]
				,[dblCostUnitQty]
				,[intContractDetailId]
				,[intLoadDetailId]
				,[intFreightItemId]
				,[dblFreightRate]
				,[intTicketFeesItemId]
				,[dblTicketFees]
				,[intEntityId]
				,[intScaleSetupId]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[dblGrossUnits]
				,[dblNetUnits]
				,[strVendorOrderNumber]
				,[intStorageScheduleTypeId]
				,[intUnitItemUOMId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				intAccountId				= NULL
				,intItemId					= SC.intItemId
				,strMiscDescription			= ICI.strDescription
				,dblQuantity				= SCC.dblScheduleQty
				,dblUnitQty					= ICUOM.dblUnitQty
				,dblDiscount				= 0
				,dblCost					= CTD.dblCashPrice
				,intTaxGroupId				= dbo.fnGetTaxGroupIdForVendor(SCC.intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,intInvoiceId				= null
				,intScaleTicketId			= SC.intTicketId
				,intUnitOfMeasureId			= SC.intItemUOMIdTo
				,intCostUOMId				= SC.intItemUOMIdTo
				,dblCostUnitQty				= ICUOM.dblUnitQty
				,intContractDetailId		= CTD.intContractDetailId
				,intLoadDetailId			= NULL
				,intFreightItemId			= ISNULL(SCSetup.intFreightItemId,0)
				,dblFreightRate				= SC.dblFreightRate
				,intTicketFeesItemId		= ISNULL(SCSetup.intDefaultFeeItemId,0)
				,dblTicketFees				= SC.dblTicketFees
				,intEntityId				= SCC.intEntityId
				,intScaleSetupId			= SC.intScaleSetupId
				,ysnFarmerPaysFreight		= SC.ysnFarmerPaysFreight
				,ysnCusVenPaysFees			= SC.ysnCusVenPaysFees
				,dblGrossUnits				= SC.dblGrossUnits
				,dblNetUnits				= SC.dblNetUnits
				,strVendorOrderNumber		= 'TKT-' + SC.strTicketNumber
				,intStorageScheduleTypeId	= SC.intStorageScheduleTypeId 
				,[intUnitItemUOMId]			= SC.intItemUOMIdTo
				,intTicketDistributionAllocationId = SCTA.intTicketDistributionAllocationId
			FROM tblSCTicket SC 
			INNER JOIN tblSCTicketContractUsed SCC
				ON SC.intTicketId = SCC.intTicketId
			INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
			INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblICItemUOM ICUOM
				ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
			INNER JOIN tblCTContractDetail CTD
				ON SCC.intContractDetailId = CTD.intContractDetailId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = SCC.intEntityId AND ysnDefaultLocation = 1
			INNER JOIN tblSCTicketDistributionAllocation SCTA
				ON SCC.intTicketContractUsed = SCTA.intSourceId
					AND intSourceType = 1
			WHERE SC.intTicketId = @intTicketId
		END

		---STORAGE (DP ONLY)
		BEGIN

			---FOR CHECKing RISK PRICE
			BEGIN
				SELECT TOP 1
					@intTicketCommodityId = intCommodityId
				FROM tblSCTicket
				WHERE intTicketId = @intTicketId

				-- Get default futures market and month for the commodity
				EXEC uspSCGetDefaultFuturesMarketAndMonth @intTicketCommodityId, @intFutureMarketId OUTPUT, @intFutureMonthId OUTPUT;
			END

			INSERT INTO @ScaleToVoucherStagingTable(
				[intAccountId]
				,[intItemId]
				,[strMiscDescription]
				,[dblQuantity]
				,[dblUnitQty]
				,[dblDiscount]
				,[dblCost]
				,[intTaxGroupId]
				,[intInvoiceId]
				,[intScaleTicketId]
				,[intUnitOfMeasureId]
				,[intCostUOMId]
				,[dblCostUnitQty]
				,[intContractDetailId]
				,[intLoadDetailId]
				,[intFreightItemId]
				,[dblFreightRate]
				,[intTicketFeesItemId]
				,[dblTicketFees]
				,[intEntityId]
				,[intScaleSetupId]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[dblGrossUnits]
				,[dblNetUnits]
				,[strVendorOrderNumber]
				,[intStorageScheduleTypeId]
				,[intUnitItemUOMId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				intAccountId				= NULL
				,intItemId					= SC.intItemId
				,strMiscDescription			= ICI.strDescription
				,dblQuantity				= SCS.dblQty
				,dblUnitQty					= ICUOM.dblUnitQty
				,dblDiscount				= 0
				,dblCost					= (SELECT TOP 1 
													ISNULL(dblSettlementPrice,0) + ISNULL(dblBasis,0)
											   FROM dbo.fnRKGetFutureAndBasisPrice(1,@intTicketCommodityId,SeqMonth.strSeqMonth,3,@intFutureMarketId,@intFutureMonthId,SC.intProcessingLocationId,null,0,SC.intItemId,null))
				,intTaxGroupId				= dbo.fnGetTaxGroupIdForVendor(SCS.intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,intInvoiceId				= null
				,intScaleTicketId			= SC.intTicketId
				,intUnitOfMeasureId			= SC.intItemUOMIdTo
				,intCostUOMId				= SC.intItemUOMIdTo
				,dblCostUnitQty				= ICUOM.dblUnitQty
				,intContractDetailId		= SCS.intContractDetailId
				,intLoadDetailId			= NULL
				,intFreightItemId			= ISNULL(SCSetup.intFreightItemId,0)
				,dblFreightRate				= SC.dblFreightRate
				,intTicketFeesItemId		= ISNULL(SCSetup.intDefaultFeeItemId,0)
				,dblTicketFees				= SC.dblTicketFees
				,intEntityId				= SCS.intEntityId
				,intScaleSetupId			= SC.intScaleSetupId
				,ysnFarmerPaysFreight		= SC.ysnFarmerPaysFreight
				,ysnCusVenPaysFees			= SC.ysnCusVenPaysFees
				,dblGrossUnits				= SC.dblGrossUnits
				,dblNetUnits				= SC.dblNetUnits
				,strVendorOrderNumber		= 'TKT-' + SC.strTicketNumber
				,intStorageScheduleTypeId	= SC.intStorageScheduleTypeId 
				,[intUnitItemUOMId]			= SC.intItemUOMIdTo
				,intTicketDistributionAllocationId = SCTA.intTicketDistributionAllocationId
			FROM tblSCTicket SC 
			INNER JOIN tblSCTicketStorageUsed SCS
				ON SC.intTicketId = SCS.intTicketId
			INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
			INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblICItemUOM ICUOM
				ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = SCS.intEntityId AND ysnDefaultLocation = 1
			INNER JOIN tblGRStorageType GRT
				ON GRT.intStorageScheduleTypeId = SCS.intStorageTypeId
			INNER JOIN tblSCTicketDistributionAllocation SCTA
				ON SCS.intTicketStorageUsedId = SCTA.intSourceId
					AND intSourceType = 3
			OUTER APPLY(
				SELECT	
					strSeqMonth = RIGHT(CONVERT(varchar, dtmEndDate, 106),8)
				FROM	tblCTContractDetail 
				WHERE	intContractDetailId = SCS.intContractDetailId 
			) SeqMonth

			WHERE SC.intTicketId = @intTicketId
		END


		---SPOT
		BEGIN 
			INSERT INTO @ScaleToVoucherStagingTable(
				[intAccountId]
				,[intItemId]
				,[strMiscDescription]
				,[dblQuantity]
				,[dblUnitQty]
				,[dblDiscount]
				,[dblCost]
				,[intTaxGroupId]
				,[intInvoiceId]
				,[intScaleTicketId]
				,[intUnitOfMeasureId]
				,[intCostUOMId]
				,[dblCostUnitQty]
				,[intContractDetailId]
				,[intLoadDetailId]
				,[intFreightItemId]
				,[dblFreightRate]
				,[intTicketFeesItemId]
				,[dblTicketFees]
				,[intEntityId]
				,[intScaleSetupId]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[dblGrossUnits]
				,[dblNetUnits]
				,[strVendorOrderNumber]
				,[intStorageScheduleTypeId]
				,[intUnitItemUOMId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				intAccountId				= NULL
				,intItemId					= SC.intItemId
				,strMiscDescription			= ICI.strDescription
				,dblQuantity				= SCS.dblQty
				,dblUnitQty					= ICUOM.dblUnitQty
				,dblDiscount				= 0
				,dblCost					= ISNULL(SCS.dblUnitFuture,0) + ISNULL(SCS.dblUnitBasis,0)
				,intTaxGroupId				= dbo.fnGetTaxGroupIdForVendor(SCS.intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
				,intInvoiceId				= null
				,intScaleTicketId			= SC.intTicketId
				,intUnitOfMeasureId			= SC.intItemUOMIdTo
				,intCostUOMId				= SC.intItemUOMIdTo
				,dblCostUnitQty				= ICUOM.dblUnitQty
				,intContractDetailId		= NULL
				,intLoadDetailId			= NULL
				,intFreightItemId			= ISNULL(SCSetup.intFreightItemId,0)
				,dblFreightRate				= SC.dblFreightRate
				,intTicketFeesItemId		= ISNULL(SCSetup.intDefaultFeeItemId,0)
				,dblTicketFees				= SC.dblTicketFees
				,intEntityId				= SCS.intEntityId
				,intScaleSetupId			= SC.intScaleSetupId
				,ysnFarmerPaysFreight		= SC.ysnFarmerPaysFreight
				,ysnCusVenPaysFees			= SC.ysnCusVenPaysFees
				,dblGrossUnits				= SC.dblGrossUnits
				,dblNetUnits				= SC.dblNetUnits
				,strVendorOrderNumber		= 'TKT-' + SC.strTicketNumber
				,intStorageScheduleTypeId	= SC.intStorageScheduleTypeId 
				,[intUnitItemUOMId]			= SC.intItemUOMIdTo
				,intTicketDistributionAllocationId = SCTA.intTicketDistributionAllocationId
			FROM tblSCTicket SC 
			INNER JOIN tblSCTicketSpotUsed SCS
				ON SC.intTicketId = SCS.intTicketId
			INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
			INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblICItemUOM ICUOM
				ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
			INNER JOIN tblSCTicketDistributionAllocation SCTA
				ON SCS.intTicketSpotUsedId = SCTA.intSourceId
					AND intSourceType = 4
			LEFT JOIN tblEMEntityLocation EM 
				ON EM.intEntityId = SCS.intEntityId AND ysnDefaultLocation = 1
			WHERE SC.intTicketId = @intTicketId
		END
	END

	--Inventory Item
	INSERT INTO @voucherDetailDirectInventory (
		[intAccountId],
		[intItemId],
		[strMiscDescription],
		[dblQtyReceived],
		[dblUnitQty],
		[dblDiscount], 
		[dblCost], 
		[intTaxGroupId],
		[intInvoiceId],
		[intScaleTicketId],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[dblCostUnitQty],
		[intContractDetailId],
		[intLoadDetailId],
		intTicketDistributionAllocationId
	)  
	SELECT 
		[intAccountId],
		[intItemId],
		[strMiscDescription],
		[dblQuantity], 
		[dblUnitQty],
		[dblDiscount], 
		[dblCost], 
		[intTaxGroupId],
		[intInvoiceId],
		[intScaleTicketId],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[dblCostUnitQty],
		[intContractDetailId],
		[intLoadDetailId]
		,intTicketDistributionAllocationId
	FROM @ScaleToVoucherStagingTable

	---TICKET OTHER CHARGES AND DISCOUNTS
	BEGIN
		--FOR FREIGHT CHARGES
		BEGIN  
			IF(@intTicketStorageScheduleTypeId = -6) ---LOAD
			BEGIN
				INSERT INTO @voucherDetailDirectInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblUnitQty],
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId],
					[intScaleTicketId],
					[intUnitOfMeasureId],
					[intCostUOMId],
					[dblCostUnitQty],
					[intContractDetailId],
					[intLoadDetailId]
					,intTicketDistributionAllocationId
				)
				SELECT 
					intAccountId			= NULL
					,intItemId				= IC.intItemId
					,strMiscDescription		= IC.strDescription
					,dblQtyReceived			= (CASE 
												WHEN IC.strCostMethod = 'Amount' THEN 1
												WHEN IC.strCostMethod = 'Per Unit' THEN CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblQuantity ELSE SC.dblQuantity END
												ELSE CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblQuantity ELSE SC.dblQuantity * -1 END
											END) * -1
					,dblUnitQty				= SC.dblUnitQty
					,dblDiscount			= 0
					,dblCost				= LDCTC.dblRate
					,intTaxGroupId			= SC.intTaxGroupId
					,intInvoiceId			= null
					,intScaleTicketId		= SC.intScaleTicketId
					,intUnitOfMeasureId		= LDCTC.intItemUOMId
					,intCostUOMId			= LDCTC.intItemUOMId
					,dblCostUnitQty			= LDCTCITM.dblUnitQty
					,intContractDetailId	= SC.intContractDetailId
					,intLoadDetailId		= SC.intLoadDetailId
					,SC.intTicketDistributionAllocationId
				FROM @ScaleToVoucherStagingTable SC
				------******* START Load Contract Cost *****----------------
				INNER JOIN tblLGLoadDetail LD
					ON SC.intLoadDetailId = LD.intLoadDetailId
				INNER JOIN tblCTContractDetail LDCT
					ON LD.intPContractDetailId = LDCT.intContractDetailId
				INNER JOIN tblCTContractCost LDCTC
					ON LDCT.intContractDetailId = LDCTC.intContractDetailId
						AND LDCTC.intItemId = SC.intFreightItemId
						AND LDCTC.ysnPrice = 1
				INNER JOIN tblICItemUOM LDCTCITM		
					ON LDCTCITM.intItemUOMId = LDCTC.intItemUOMId
				------******* END Load Contract Cost *****----------------
				LEFT JOIN tblICItem IC 
					ON IC.intItemId = SC.intFreightItemId
				WHERE SC.intScaleTicketId = @intTicketId 
				
			END
			ELSE
			BEGIN
				INSERT INTO @voucherDetailDirectInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblUnitQty],
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId],
					[intScaleTicketId],
					[intUnitOfMeasureId],
					[intCostUOMId],
					[dblCostUnitQty],
					[intContractDetailId],
					[intLoadDetailId]
					,intTicketDistributionAllocationId
				)
				SELECT 
					intAccountId			= NULL
					,intItemId				= IC.intItemId
					,strMiscDescription		= IC.strDescription
					,dblQtyReceived			= (CASE 
												WHEN IC.strCostMethod = 'Amount' THEN 1
												WHEN IC.strCostMethod = 'Per Unit' THEN CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblQuantity ELSE SC.dblQuantity END
												ELSE CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblQuantity ELSE SC.dblQuantity END
											END) * -1
					,dblUnitQty				= SC.dblUnitQty
					,dblDiscount			= 0
					,dblCost				= SC.dblFreightRate
					,intTaxGroupId			= SC.intTaxGroupId
					,intInvoiceId			= null
					,intScaleTicketId		= SC.intScaleTicketId
					,intUnitOfMeasureId		= SC.intUnitOfMeasureId
					,intCostUOMId			= SC.intCostUOMId
					,dblCostUnitQty			= SC.dblCostUnitQty
					,intContractDetailId	= SC.intContractDetailId
					,intLoadDetailId		= SC.intLoadDetailId
					,SC.intTicketDistributionAllocationId
				FROM @ScaleToVoucherStagingTable SC
				LEFT JOIN tblICItem IC 
					ON IC.intItemId = SC.intFreightItemId
				WHERE SC.intScaleTicketId = @intTicketId 
					AND SC.dblFreightRate != 0
					AND ysnFarmerPaysFreight = 1
			END
		END

		--FOR FEE CHARGES
		INSERT INTO @voucherDetailDirectInventory(
			[intAccountId],
			[intItemId],
			[strMiscDescription],
			[dblQtyReceived], 
			[dblUnitQty],
			[dblDiscount], 
			[dblCost], 
			[intTaxGroupId],
			[intInvoiceId],
			[intScaleTicketId],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[dblCostUnitQty],
			[intContractDetailId],
			[intLoadDetailId]
			,intTicketDistributionAllocationId
		)
		SELECT 
			intAccountId			= NULL
			,intItemId				= IC.intItemId
			,strMiscDescription		= IC.strDescription
			,dblQtyReceived			= CASE WHEN IC.strCostMethod = 'Per Unit' THEN
										CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 
											THEN SC.dblQuantity 
											ELSE (SC.dblQuantity) * -1 
										END
									ELSE 1 END
			,dblUnitQty				= SC.dblUnitQty 
			,dblDiscount			= 0
			,dblCost				= SC.dblTicketFees
			,intTaxGroupId			= SC.intTaxGroupId
			,intInvoiceId			= null
			,intScaleTicketId		= SC.intScaleTicketId
			,intUnitOfMeasureId		= SC.intUnitOfMeasureId
			,intCostUOMId			= SC.intCostUOMId
			,dblCostUnitQty			= SC.dblCostUnitQty
			,intContractDetailId	= SC.intContractDetailId
			,intLoadDetailId		= SC.intLoadDetailId
			,SC.intTicketDistributionAllocationId
		FROM @ScaleToVoucherStagingTable SC
		LEFT JOIN tblICItem IC ON IC.intItemId = SC.intTicketFeesItemId
		WHERE SC.intScaleTicketId = @intTicketId 
			AND SC.dblTicketFees > 0
			AND SC.ysnCusVenPaysFees = 1

		--FOR DISCOUNT
		INSERT INTO @voucherDetailDirectInventory(
			[intAccountId],
			[intItemId],
			[strMiscDescription],
			[dblQtyReceived], 
			[dblUnitQty],
			[dblDiscount], 
			[dblCost], 
			[intTaxGroupId],
			[intInvoiceId],
			[intScaleTicketId],
			[intUnitOfMeasureId],
			[intCostUOMId],
			[dblCostUnitQty],
			[intContractDetailId],
			[intLoadDetailId]
			,intTicketDistributionAllocationId
		)
		SELECT 
			intAccountId			= NULL
			,intItemId				= IC.intItemId
			,strMiscDescription		= IC.strDescription
			,dblQtyReceived			= CASE WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblQuantity ELSE CASE
											WHEN QM.dblDiscountAmount < 0 THEN 1
											WHEN QM.dblDiscountAmount > 0 THEN -1
										END
									END
			,dblUnitQty				= SC.dblUnitQty
			,dblDiscount			= 0
			,dblCost				=  CASE
											WHEN IC.strCostMethod = 'Per Unit' THEN 
											CASE 
												WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
												WHEN QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
											END
											WHEN IC.strCostMethod = 'Amount' THEN 
											CASE 
												WHEN SC.intStorageScheduleTypeId > 0 AND ISNULL(SC.intContractDetailId,0) = 0 THEN 0
												ELSE
													CASE
														WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intScaleTicketId,QM.intTicketDiscountId, SC.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblCost))) * -1)
														WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intScaleTicketId, QM.intTicketDiscountId, SC.dblQuantity, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblCost)))
													END
											END
										END
			,intTaxGroupId			= SC.intTaxGroupId
			,intInvoiceId			= null
			,intScaleTicketId		= SC.intScaleTicketId
			,intUnitOfMeasureId		= SC.intUnitOfMeasureId
			,intCostUOMId			= SC.intCostUOMId
			,dblCostUnitQty			= SC.dblCostUnitQty
			,intContractDetailId	= SC.intContractDetailId
			,intLoadDetailId		= SC.intLoadDetailId
			,SC.intTicketDistributionAllocationId
		FROM @ScaleToVoucherStagingTable SC
		INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intScaleTicketId
		LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
		LEFT JOIN (
			SELECT 
			CTD.intContractHeaderId
			,CTD.intContractDetailId
			,CTD.intPricingTypeId
			,AD.dblSeqPrice
			FROM tblCTContractDetail CTD
			CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
		) CNT ON CNT.intContractDetailId = SC.intContractDetailId
		WHERE SC.intScaleTicketId = @intTicketId AND QM.dblDiscountAmount != 0 AND ISNULL(intPricingTypeId,0) IN (0,1,2,5,6)
	END

	--OTHER CHARGES OUTSIDE TICKET NON-FEE AND NON FREIGHT CONTRACT, LOAD COST TAB
	BEGIN
		--LOAD SCHEDULE
		BEGIN

			IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpLoadOtherCharges')) 
				DROP TABLE #tmpLoadOtherCharges
			
			SELECT 
				intAccountId			= NULL
				,intItemId				= IC.intItemId
				,strMiscDescription		= IC.strDescription
				,dblQtyReceived			= 	(CASE 
												WHEN LGC.strCostMethod = 'Amount' THEN 1
												WHEN LGC.strCostMethod = 'Per Unit' THEN TSC.dblQuantity 
											END) 
										
				,dblUnitQty				= TSC.dblUnitQty
				,dblDiscount			= 0
				,dblCost				= LGC.dblRate
				,intTaxGroupId			= NULL
				,intInvoiceId			= NULL
				,intScaleTicketId		= TSC.intScaleTicketId
				,intUnitOfMeasureId		= TSC.intUnitOfMeasureId
				,intCostUOMId			= LGC.intItemUOMId
				,dblCostUnitQty			= ICUOM.dblUnitQty
				,intContractDetailId	= LGD.intPContractDetailId
				,intLoadDetailId		= LGD.intLoadDetailId
				,TSC.intTicketDistributionAllocationId
			INTO #tmpLoadOtherCharges
			FROM @ScaleToVoucherStagingTable TSC
			INNER JOIN tblSCTicket SC
				ON TSC.intScaleTicketId = SC.intTicketId
			INNER JOIN tblSCScaleSetup SCSetup 
				ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblLGLoadDetail LGD
				ON TSC.intLoadDetailId = LGD.intLoadDetailId
			INNER JOIN tblLGLoad LGH
				ON LGD.intLoadId = LGH.intLoadId
			INNER JOIN tblLGLoadCost LGC
				ON LGH.intLoadId = LGC.intLoadId
			INNER JOIN tblICItem IC 
				ON IC.intItemId = LGC.intItemId
			INNER JOIN tblICItemUOM ICUOM
				ON LGC.intItemUOMId = ICUOM.intItemUOMId
			WHERE LGC.intItemId IS NOT NULL
				AND LGC.intItemId <> TSC.intFreightItemId
				AND LGC.intItemId <> TSC.intTicketFeesItemId
				AND LGC.dblRate <> 0
				AND LGC.ysnAccrue = 1

			INSERT INTO @voucherDetailDirectInventory(
				[intAccountId],
				[intItemId],
				[strMiscDescription],
				[dblQtyReceived], 
				[dblUnitQty],
				[dblDiscount], 
				[dblCost], 
				[intTaxGroupId],
				[intInvoiceId],
				[intScaleTicketId],
				[intUnitOfMeasureId],
				[intCostUOMId],
				[dblCostUnitQty],
				[intContractDetailId],
				[intLoadDetailId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				[intAccountId],
				[intItemId],
				[strMiscDescription],
				[dblQtyReceived] = dblQtyReceived * -1, 
				[dblUnitQty],
				[dblDiscount], 
				[dblCost], 
				[intTaxGroupId],
				[intInvoiceId],
				[intScaleTicketId],
				[intUnitOfMeasureId],
				[intCostUOMId],
				[dblCostUnitQty],
				[intContractDetailId],
				[intLoadDetailId]
				,intTicketDistributionAllocationId
			FROM #tmpLoadOtherCharges
			
		END

		--CONTRACT
		BEGIN
			
			IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpContractOtherCharges')) 
				DROP TABLE #tmpContractOtherCharges
			SELECT 
				intAccountId			= NULL
				,intItemId				= IC.intItemId
				,strMiscDescription		= IC.strDescription
				,dblQuantity			= 	(CASE 
												WHEN CTC.strCostMethod = 'Amount' THEN 1
												WHEN CTC.strCostMethod = 'Per Unit' THEN TSC.dblQuantity 
											END) * -1
				,dblUnitQty				= TSC.dblUnitQty
				,dblDiscount			= 0
				,dblCost				= CTC.dblRate
				,intTaxGroupId			= NULL
				,intInvoiceId			= NULL
				,intScaleTicketId		= TSC.intScaleTicketId
				,intUnitOfMeasureId		= TSC.intUnitOfMeasureId
				,intCostUOMId			= CTC.intItemUOMId
				,dblCostUnitQty			= ICUOM.dblUnitQty
				,intContractDetailId	= CTD.intContractDetailId
				,intLoadDetailId		= NULL
				,strCostMethod			= CTC.strCostMethod
				,TSC.intTicketDistributionAllocationId
			INTO #tmpContractOtherCharges
			FROM @ScaleToVoucherStagingTable TSC
			INNER JOIN tblSCTicket SC
				ON TSC.intScaleTicketId = SC.intTicketId
			INNER JOIN tblSCScaleSetup SCSetup 
				ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblCTContractDetail CTD
				ON SC.intContractId = CTD.intContractDetailId
			INNER JOIN tblCTContractHeader CTH
				ON CTD.intContractHeaderId = CTH.intContractHeaderId
			INNER JOIN tblCTContractCost CTC
				ON CTD.intContractDetailId = CTC.intContractDetailId
			INNER JOIN tblICItem IC 
				ON IC.intItemId = CTC.intItemId
			INNER JOIN tblICItemUOM ICUOM
				ON CTC.intItemUOMId = ICUOM.intItemUOMId
			WHERE CTD.intItemId IS NOT NULL
				AND CTC.intItemUOMId IS NOT NULL
				AND CTC.intItemId <> TSC.intFreightItemId
				AND CTC.intItemId <> TSC.intTicketFeesItemId
				AND CTC.dblRate <> 0
				AND CTC.ysnBasis <> 1
				AND CTC.ysnPrice = 1
				AND CTC.intItemId NOT IN (SELECT DISTINCT intItemId FROM #tmpLoadOtherCharges)
			
			
			INSERT INTO @voucherDetailDirectInventory(
				[intAccountId],
				[intItemId],
				[strMiscDescription],
				[dblQtyReceived], 
				[dblUnitQty],
				[dblDiscount], 
				[dblCost], 
				[intTaxGroupId],
				[intInvoiceId],
				[intScaleTicketId],
				[intUnitOfMeasureId],
				[intCostUOMId],
				[dblCostUnitQty],
				[intContractDetailId],
				[intLoadDetailId]
				,intTicketDistributionAllocationId
			)
			SELECT 
				[intAccountId],
				[intItemId],
				[strMiscDescription],
				[dblQuantity], 
				[dblUnitQty],
				[dblDiscount], 
				[dblCost], 
				[intTaxGroupId],
				[intInvoiceId],
				[intScaleTicketId],
				[intUnitOfMeasureId],
				[intCostUOMId],
				[dblCostUnitQty],
				[intContractDetailId],
				[intLoadDetailId]
				,intTicketDistributionAllocationId
			FROM #tmpContractOtherCharges
		END
	END

	SELECT @vendorOrderNumber = strVendorOrderNumber FROM @ScaleToVoucherStagingTable
	SELECT @recCount = COUNT(1) FROM @voucherDetailDirectInventory;
	IF ISNULL(@recCount,0) > 0
	
	/* CREATE VOUCHER */

	BEGIN 
		INSERT INTO @voucherPayable(
		[intTransactionType],
		[intItemId],
		[strMiscDescription],
		[intInventoryReceiptItemId],
		[dblQuantityToBill],
		[dblOrderQty],
		[dblExchangeRate],
		[intCurrencyExchangeRateTypeId],
		[ysnSubCurrency],
		[intAccountId],
		[dblCost],
		[dblOldCost],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intQtyToBillUOMId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblQtyToBillUnitQty],
		[intCurrencyId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category],
		[intLoadShipmentDetailId],
		[strBillOfLading],
		[intScaleTicketId],
		[intLocationId],			
		[intShipFromId],
		[intShipToId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[intPurchaseTaxGroupId],
		[dblTax],
		[intEntityVendorId],
		[strVendorOrderNumber],
		[intLoadShipmentId],
		[strReference],
		[strSourceNumber],
		[intSubLocationId],
		[intItemLocationId]
		,ysnStage
		,intTicketDistributionAllocationId
		)
		EXEC [dbo].[uspSCGenerateVoucherDetails] @voucherItems,@voucherOtherCharges,@voucherDetailDirectInventory
		IF EXISTS(SELECT TOP 1 NULL FROM @voucherPayable)
		BEGIN
			INSERT INTO @voucherTaxDetail(
			[intVoucherPayableId]
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]		
			,[ysnTaxExempt]	
			,[ysnTaxOnly]
			)
			SELECT	[intVoucherPayableId]
					,[intTaxGroupId]				
					,[intTaxCodeId]				
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[intAccountId]				
					,[dblTax]					
					,[dblAdjustedTax]			
					,[ysnTaxAdjusted]			
					,[ysnSeparateOnBill]			
					,[ysnCheckOffTax]		
					,[ysnTaxExempt]	
					,[ysnTaxOnly]
			FROM dbo.fnICGeneratePayablesTaxes(
					@voucherPayable
					,1
					,DEFAULT 
				)
			BEGIN /* Create Voucher */
				DECLARE @createVoucher BIT = 0
				DECLARE @postVoucher   BIT = 0
				--SELECT * FROM @voucherPayable
				SELECT @createVoucher = ysnCreateVoucher, @postVoucher = ysnPostVoucher FROM tblAPVendor WHERE intEntityId = @intEntityId
				IF ISNULL(@createVoucher, 0) = 1 OR ISNULL(@postVoucher, 0) = 1
					EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayable,@voucherPayableTax = @voucherTaxDetail, @userId = @intUserId,@throwError = 1, @error = @ErrorMessage OUT, @createdVouchersId = @intBillId OUT
				ELSE
					EXEC [dbo].[uspAPUpdateVoucherPayableQty] @voucherPayable = @voucherPayable, @voucherPayableTax = @voucherTaxDetail, @post = 1, @throwError = 1,@error = @ErrorMessage OUT

				IF ISNULL(@ErrorMessage,'') <> ''
				BEGIN
					RAISERROR(@ErrorMessage,16,1);
				END
			END
		END
	END

	IF ISNULL(@intBillId,0) > 0 AND @postVoucher = 1
	BEGIN
		UPDATE tblAPBillDetail SET intScaleTicketId = @intTicketId WHERE intBillId = @intBillId
		EXEC [dbo].[uspAPPostBill]
		@post = 1
		,@recap = 0
		,@isBatch = 0
		,@param = @intBillId 
		,@userId = @intUserId
		,@success = @success OUTPUT
	END

	--GENERATE 3RD PARTY PAYABLES
	BEGIN
		EXEC uspSCGenerate3PartyDirectInPayables @ScaleToVoucherStagingTable, @intUserId
	END

		
		
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