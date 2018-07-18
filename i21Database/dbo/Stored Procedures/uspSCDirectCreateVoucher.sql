CREATE PROCEDURE [dbo].[uspSCDirectCreateVoucher]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@dtmScaleDate DATETIME,
	@intUserId INT
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
		,@intBillId INT
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

BEGIN TRY

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpScaleToVoucherStagingTable')) 
			DROP TABLE #tmpScaleToVoucherStagingTable
		CREATE TABLE #tmpScaleToVoucherStagingTable (
			[intAccountId]					INT             NULL
			,[intItemId]					INT             NULL
			,[strMiscDescription]			NVARCHAR(500)	NULL
			,[intUnitOfMeasureId]           INT             NULL
			,[dblQtyReceived]				DECIMAL(18, 6)	NULL 
			,[dblUnitQty]					DECIMAL(38, 20)	NULL 
			,[dblDiscount]					DECIMAL(18, 6)	NOT NULL DEFAULT 0
			,[intCostUOMId]                 INT             NULL
			,[dblCost]						DECIMAL(38, 20)	NULL 
			,[dblCostUnitQty]               DECIMAL(38, 20)	NULL 
			,[intTaxGroupId]				INT             NULL
			,[intInvoiceId]					INT             NULL
			,[intScaleTicketId]				INT				NULL
			,[intContractDetailId]          INT             NULL
			,[intLoadDetailId]              INT             NULL
			,[intFreightItemId]             INT             NULL
			,[dblFreightRate]               DECIMAL(38, 20)	NULL
			,[intTicketFeesItemId]          INT             NULL
			,[dblTicketFees]				DECIMAL(38, 20)	NULL
			,[intEntityId]					INT             NULL
			,[intScaleSetupId]				INT             NULL
			,[ysnFarmerPaysFreight]			BIT				NULL
			,[ysnCusVenPaysFees]			BIT				NULL
			,[dblGrossUnits]				DECIMAL(38, 20)	NULL
			,[dblNetUnits]					DECIMAL(38, 20)	NULL
			,[strVendorOrderNumber]			NVARCHAR(50)	NULL
			,[intStorageScheduleTypeId]		INT				NULL
		)
		
		--FOR LINE ITEM
		INSERT INTO #tmpScaleToVoucherStagingTable(
			[intAccountId]
			,[intItemId]
			,[strMiscDescription]
			,[dblQtyReceived]
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
		)
		SELECT 
			intAccountId				= NULL
			,intItemId					= SC.intItemId
			,strMiscDescription			= ICI.strDescription
			,dblQtyReceived				= SC.dblNetUnits
			,dblUnitQty					= SC.dblConvertedUOMQty
			,dblDiscount				= 0
			,dblCost					= CASE
											WHEN CNT.intPricingTypeId = 2 THEN 
											(
												SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CNT.intBasisUOMId,(SC.dblUnitPrice + SC.dblUnitBasis)),0)),0) 
												FROM dbo.fnRKGetFutureAndBasisPrice (1,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId, SC.intCurrencyId)
												LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = SC.intItemId
											)
											ELSE
												CASE 
													WHEN CNT.ysnUseFXPrice = 1 
															AND CNT.intCurrencyExchangeRateId IS NOT NULL 
															AND CNT.dblRate IS NOT NULL 
															AND CNT.intFXPriceUOMId IS NOT NULL 
													THEN CNT.dblSeqPrice
													ELSE (SC.dblUnitPrice + SC.dblUnitBasis)
												END 
												* -- AD.dblQtyToPriceUOMConvFactor
												CASE 
													WHEN CNT.ysnUseFXPrice = 1 
															AND CNT.intCurrencyExchangeRateId IS NOT NULL 
															AND CNT.dblRate IS NOT NULL 
															AND CNT.intFXPriceUOMId IS NOT NULL 
													THEN ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,CNT.intFXPriceUOMId,1),1)),1)
													WHEN CNT.intPricingTypeId = 5 THEN 1
													ELSE ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,CNT.intItemUOMId,ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CNT.intItemUOMId,ISNULL(CNT.intPriceItemUOMId,CNT.intAdjItemUOMId),1),1)),1)
												END 
										END
			,intTaxGroupId				= dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
			,intInvoiceId				= null
			,intScaleTicketId			= SC.intTicketId
			,intUnitOfMeasureId			= SC.intItemUOMIdTo
			,intCostUOMId				= SC.intItemUOMIdTo
			,dblCostUnitQty				= SC.dblConvertedUOMQty
			,intContractDetailId		= CNT.intContractDetailId
			,intLoadDetailId			= LGD.intLoadDetailId
			,intFreightItemId			= SCSetup.intFreightItemId
			,dblFreightRate				= SC.dblFreightRate
			,intTicketFeesItemId		= SCSetup.intDefaultFeeItemId
			,dblTicketFees				= SC.dblTicketFees
			,intEntityId				= SC.intEntityId
			,intScaleSetupId			= SC.intScaleSetupId
			,ysnFarmerPaysFreight		= SC.ysnFarmerPaysFreight
			,ysnCusVenPaysFees			= SC.ysnCusVenPaysFees
			,dblGrossUnits				= SC.dblGrossUnits
			,dblNetUnits				= SC.dblNetUnits
			,strVendorOrderNumber		= 'TKT-' + SC.strTicketNumber
			,intStorageScheduleTypeId	= SC.intStorageScheduleTypeId 
		FROM tblSCTicket SC 
		INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
		INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
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
			FROM tblCTContractDetail CTD 
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
			CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
		) CNT ON CNT.intContractDetailId = SC.intContractId
		LEFT JOIN tblLGLoadDetail LGD ON LGD.intLoadId = SC.intLoadId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = SC.intEntityId AND ysnDefaultLocation = 1
		WHERE SC.intTicketId = @intTicketId
		

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
			[intLoadDetailId]
		)  
		SELECT 
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
		 FROM #tmpScaleToVoucherStagingTable

		--FOR FREIGHT CHARGES
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
		)
		SELECT 
			intAccountId			= NULL
			,intItemId				= IC.intItemId
			,strMiscDescription		= IC.strDescription
			,dblQtyReceived			= CASE 
										WHEN IC.strCostMethod = 'Amount' THEN 1
										WHEN IC.strCostMethod = 'Per Unit' THEN CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblNetUnits ELSE SC.dblNetUnits * -1 END
										ELSE CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblGrossUnits ELSE SC.dblGrossUnits * -1 END
									END
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
		FROM #tmpScaleToVoucherStagingTable SC
		LEFT JOIN tblICItem IC ON IC.intItemId = SC.intFreightItemId
		WHERE SC.intScaleTicketId = @intTicketId AND SC.dblFreightRate != 0
				
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
		)
		SELECT 
			intAccountId			= NULL
			,intItemId				= IC.intItemId
			,strMiscDescription		= IC.strDescription
			,dblQtyReceived			= CASE WHEN IC.strCostMethod = 'Per Unit' THEN
										CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 
											THEN SC.dblNetUnits 
											ELSE (SC.dblNetUnits) * -1 
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
		FROM #tmpScaleToVoucherStagingTable SC
		LEFT JOIN tblICItem IC ON IC.intItemId = SC.intTicketFeesItemId
		WHERE SC.intScaleTicketId = @intTicketId AND SC.dblTicketFees > 0

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
		)
		SELECT 
			intAccountId			= NULL
			,intItemId				= IC.intItemId
			,strMiscDescription		= IC.strDescription
			,dblQtyReceived			= CASE WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblNetUnits ELSE CASE
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
														WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intScaleTicketId,QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblCost))) * -1)
														WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intScaleTicketId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId, ISNULL(CNT.dblSeqPrice, (SC.dblCost)))
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
		FROM #tmpScaleToVoucherStagingTable SC
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

		SELECT @vendorOrderNumber = strVendorOrderNumber FROM #tmpScaleToVoucherStagingTable
		SELECT @recCount = COUNT(*) FROM @voucherDetailDirectInventory;
		IF ISNULL(@recCount,0) > 0
		BEGIN
			EXEC [dbo].[uspAPCreateBillData] 
				@userId = @intUserId
				,@vendorId = @intEntityId
				,@type = 1
				,@voucherDetailDirect = @voucherDetailDirectInventory
				,@shipTo = @intLocationId
				,@vendorOrderNumber = @vendorOrderNumber
				,@voucherDate = @dtmScaleDate
				,@billId = @intBillId OUTPUT

			IF ISNULL(@intBillId,0) > 0
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