CREATE PROCEDURE [dbo].[uspSCProcessDirectShipment]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@dtmScaleDate DATETIME,
	@intUserId INT,
	@intWeight INT,
	@intGrade INT,
	@strInOutFlag NVARCHAR(5)
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
		,@voucherDetailNonInventory AS VoucherDetailNonInventory
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
		,@recapId INT;

BEGIN TRY
	IF @strInOutFlag = 'I'
		BEGIN
			IF ISNULL(@intWeight, 0) = 1 OR ISNULL(@intWeight, 0) = 0
			BEGIN
				INSERT INTO @voucherDetailNonInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId]
				)
				SELECT 
					intAccountId = NULL
					,intItemId = SC.intItemId
					,strMiscDescription = ICI.strDescription
					,dblQtyReceived = SC.dblNetUnits
					,dblDiscount = 0
					,dblCost = CASE
									WHEN CNT.intPricingTypeId = 2 THEN 
									(
										SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(SC.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CNT.intBasisUOMId,(SC.dblUnitPrice + SC.dblUnitBasis)),0)),0) 
										FROM dbo.fnRKGetFutureAndBasisPrice (1,SC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SC.intItemId)
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
					,intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,SC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,intInvoiceId = null
				FROM tblSCTicket SC 
				INNER JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
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
				LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = SC.intEntityId AND ysnDefaultLocation = 1
				WHERE SC.intTicketId = @intTicketId

				--FOR DISCOUNT CHARGES
				INSERT INTO @voucherDetailNonInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId]
				)
				SELECT 
					intAccountId = NULL
					,intItemId = IC.intItemId
					,strMiscDescription = IC.strDescription
					,dblQtyReceived = CASE WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblNetUnits ELSE CASE
											WHEN QM.dblDiscountAmount < 0 THEN 1
											WHEN QM.dblDiscountAmount > 0 THEN -1
										END
									 END
					,dblDiscount = 0
					,dblCost =  CASE
									WHEN IC.strCostMethod = 'Per Unit' THEN 
									CASE 
										WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
										WHEN QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
									END
									WHEN IC.strCostMethod = 'Amount' THEN 
									CASE 
										WHEN SC.intStorageScheduleTypeId > 0 AND ISNULL(SC.intContractId,0) = 0 THEN 0
										ELSE
											CASE
												WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId) * -1)
												WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId)
											END
									END
								END
					,intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,IC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,intInvoiceId = null
				FROM tblSCTicket SC 
				INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId
				LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = SC.intEntityId AND ysnDefaultLocation = 1
				LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
				INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
				WHERE SC.intTicketId = @intTicketId

				--FOR FEE CHARGES
				INSERT INTO @voucherDetailNonInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId]
				)
				SELECT 
					intAccountId = NULL
					,intItemId = IC.intItemId
					,strMiscDescription = IC.strDescription
					,dblQtyReceived = CASE WHEN IC.strCostMethod = 'Per Unit' THEN
										CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 
											THEN SC.dblNetUnits 
											ELSE (SC.dblNetUnits) * -1 
										END
									ELSE 1 END
					,dblDiscount = 0
					,dblCost =  CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblTicketFees ELSE SC.dblTicketFees * -1 END
					,intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,IC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,intInvoiceId = null
				FROM tblSCTicket SC
				INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
				LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = SC.intEntityId AND ysnDefaultLocation = 1
				LEFT JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
				WHERE SC.intTicketId = @intTicketId AND SC.dblTicketFees > 0
			
				--FOR FREIGHT CHARGES
				INSERT INTO @voucherDetailNonInventory(
					[intAccountId],
					[intItemId],
					[strMiscDescription],
					[dblQtyReceived], 
					[dblDiscount], 
					[dblCost], 
					[intTaxGroupId],
					[intInvoiceId]
				)
				SELECT 
					intAccountId = NULL
					,intItemId = IC.intItemId
					,strMiscDescription = IC.strDescription
					,dblQtyReceived = CASE 
										WHEN IC.strCostMethod = 'Amount' THEN 1
										WHEN IC.strCostMethod = 'Per Unit' THEN CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblNetUnits ELSE SC.dblNetUnits * -1 END
										ELSE CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblGrossUnits ELSE SC.dblGrossUnits * -1 END
									END
					,dblDiscount = 0
					,dblCost = CASE WHEN ISNULL(SC.ysnFarmerPaysFreight,0) = 0 THEN SC.dblFreightRate ELSE SC.dblFreightRate * -1 END
					,intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,IC.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,intInvoiceId = null
				FROM tblSCTicket SC
				INNER JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
				LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = SC.intEntityId AND ysnDefaultLocation = 1
				LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
				WHERE SC.intTicketId = @intTicketId AND SC.dblFreightRate != 0 AND SC.intContractId IS NULL
			
				EXEC [dbo].[uspAPCreateBillData] 
					@userId = @intUserId
					,@vendorId = @intEntityId
					,@type = 1
					,@voucherNonInvDetails = @voucherDetailNonInventory
					,@shipTo = @intLocationId
					,@vendorOrderNumber = NULL
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
				INSERT INTO @ItemsToIncreaseInTransitDirect(
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId]
					,[intLotId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[dblQty]
					,[intTransactionId]
					,[strTransactionId]
					,[intTransactionTypeId]
					,[intFOBPointId]
				)
				SELECT 
					intItemId = SC.intItemId
					,intItemLocationId = ICIL.intItemLocationId
					,intItemUOMId = SC.intItemUOMIdTo
					,intLotId = SC.intLotId
					,intSubLocationId = SC.intSubLocationId
					,intStorageLocationId = SC.intStorageLocationId
					,dblQty = SC.dblNetUnits
					,intTransactionId = 1
					,strTransactionId = SC.strTicketNumber
					,intTransactionTypeId = 1
					,intFOBPointId = NULL
				FROM tblSCTicket SC 
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				WHERE SC.intTicketId = @intTicketId
				EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;
			END
		END
	ELSE
		BEGIN
			IF ISNULL(@intWeight, 0) = 1 OR ISNULL(@intWeight, 0) = 0
			BEGIN
				INSERT INTO @invoiceIntegrationStagingTable (
					[strTransactionType]
					,[strType]
					,[strSourceTransaction]
					,[intSourceId]
					,[strSourceId]
					,[intInvoiceId]
					,[intEntityCustomerId]
					,[intCompanyLocationId]
					,[intCurrencyId]
					,[intTermId]
					,[dtmDate]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intEntityId]
					,[ysnResetDetails]
					,[intItemId]
					,[strItemDescription]
					,[intOrderUOMId]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblPrice]
					,[ysnRefreshPrice]
					,[intTaxGroupId]
					,[ysnRecomputeTax]
					,[intContractDetailId]
					,[intTicketId]
					,[intDestinationGradeId]
					,[intDestinationWeightId]		
				)
				SELECT 
					[strTransactionType] = 'Invoice'
					,[strType] = 'Standard'
					,[strSourceTransaction] = 'Ticket Management'
					,[intSourceId] = SC.intTicketId
					,[strSourceId] = ''
					,[intInvoiceId] = NULL --NULL Value will create new invoice
					,[intEntityCustomerId] = @intEntityId
					,[intCompanyLocationId] = SC.intProcessingLocationId
					,[intCurrencyId] = SC.intCurrencyId
					,[intTermId] = EM.intFreightTermId
					,[dtmDate] = SC.dtmTicketDateTime
					,[ysnTemplate] = 0
					,[ysnForgiven] = 0
					,[ysnCalculated] = 0
					,[ysnSplitted] = 0
					,[intEntityId] = @intUserId
					,[ysnResetDetails] = 0
					,[intItemId] = SC.intItemId
					,[strItemDescription] = ICI.strItemNo
					,[intOrderUOMId]= NULL
					,[intItemUOMId] = NULL
					,[dblQtyOrdered] = SC.dblNetUnits
					,[dblQtyShipped] = SC.dblNetUnits
					,[dblDiscount] = 0
					,[dblPrice] = SC.dblUnitPrice + dblUnitBasis
					,[ysnRefreshPrice] = 0
					,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
					,[ysnRecomputeTax] = 1
					,[intContractDetailId] = SC.intContractId
					,[intTicketId] = SC.intTicketId
					,[intDestinationGradeId] = SC.intGradeId
					,[intDestinationWeightId] = SC.intWeightId
					FROM tblSCTicket SC
					LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
					LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
					LEFT JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId		
					WHERE SC.intTicketId = @intTicketId

				EXEC [dbo].[uspARProcessInvoices] 
					@InvoiceEntries = @invoiceIntegrationStagingTable
					,@UserId = @intUserId
					,@GroupingOption = 11
					,@RaiseError = 1
					,@ErrorMessage = @ErrorMessage OUTPUT
					,@CreatedIvoices = @CreatedInvoices OUTPUT
					,@UpdatedIvoices = @UpdatedInvoices OUTPUT

					EXEC [dbo].[uspARPostInvoice]
					@batchId			= NULL,
					@post				= 1,
					@recap				= 0,
					@param				= @CreatedInvoices,
					@userId				= @intUserId,
					@beginDate			= NULL,
					@endDate			= NULL,
					@beginTransaction	= NULL,
					@endTransaction		= NULL,
					@exclude			= NULL,
					@successfulCount	= @successfulCount OUTPUT,
					@invalidCount		= @invalidCount OUTPUT,
					@success			= @success OUTPUT,
					@batchIdUsed		= @batchIdUsed OUTPUT,
					@recapId			= @recapId OUTPUT,
					@transType			= N'all',
					@accrueLicense		= 0,
					@raiseError			= 1
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