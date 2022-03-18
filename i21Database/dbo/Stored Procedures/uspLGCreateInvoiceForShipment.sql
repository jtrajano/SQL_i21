CREATE PROCEDURE uspLGCreateInvoiceForShipment
	@intLoadId    INT,
	@intUserId    INT,
	@intType	INT = 1, /* 1 - Direct, 2 - Provisional, 3 - Proforma */
	@NewInvoiceId INT = NULL OUTPUT	
AS 
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal		DECIMAL(18,6)
		,@DateOnly			DATETIME
		,@ShipmentNumber	NVARCHAR(100)
		,@InvoiceId			INT
		,@InvoiceNumber		NVARCHAR(25)

SELECT
	 @ZeroDecimal	= 0.000000	
	,@DateOnly		= CAST(GETDATE() AS DATE)


DECLARE
	 @TransactionType			NVARCHAR(25)
	,@Type						NVARCHAR(100)
	,@EntityCustomerId			INT
	,@CompanyLocationId			INT
	,@AccountId					INT
	,@CurrencyId				INT
	,@TermId					INT
	,@SourceId					INT
	,@PeriodsToAccrue			INT
	,@Date						DATETIME
	,@DueDate					DATETIME
	,@ShipDate					DATETIME
	,@PostDate					DATETIME
	,@CalculatedDate			DATETIME
	,@InvoiceSubtotal			NUMERIC(18, 6)
	,@Shipping					NUMERIC(18, 6)
	,@Tax						NUMERIC(18, 6)
	,@InvoiceTotal				NUMERIC(18, 6)
	,@Discount					NUMERIC(18, 6)
	,@DiscountAvailable			NUMERIC(18, 6)
	,@Interest					NUMERIC(18, 6)
	,@AmountDue					NUMERIC(18, 6)
	,@Payment					NUMERIC(18, 6)
	,@EntitySalespersonId		INT
	,@FreightTermId				INT
	,@ShipViaId					INT
	,@PaymentMethodId			INT
	,@InvoiceOriginId			NVARCHAR(8)
	,@PONumber					NVARCHAR(25)
	,@BOLNumber					NVARCHAR(50)
	,@Comments					NVARCHAR(max)
	,@FooterComments			NVARCHAR(max)
	,@ShipToLocationId			INT
	,@ShipToLocationName		NVARCHAR(50)
	,@ShipToAddress				NVARCHAR(100)
	,@ShipToCity				NVARCHAR(30)
	,@ShipToState				NVARCHAR(50)
	,@ShipToZipCode				NVARCHAR(12)
	,@ShipToCountry				NVARCHAR(25)
	,@BillToLocationId			INT
	,@BillToLocationName		NVARCHAR(50)
	,@BillToAddress				NVARCHAR(100)
	,@BillToCity				NVARCHAR(30)
	,@BillToState				NVARCHAR(50)
	,@BillToZipCode				NVARCHAR(12)
	,@BillToCountry				NVARCHAR(25)
	,@Posted					BIT
	,@Paid						BIT
	,@Processed					BIT
	,@Template					BIT
	,@Forgiven					BIT
	,@Calculated				BIT
	,@Splitted					BIT
	,@PaymentId					INT
	,@SplitId					INT
	,@DistributionHeaderId		INT
	,@LoadDistributionHeaderId	INT
	,@ActualCostId				NVARCHAR(50)
	,@InboundShipmentId			INT
	,@TransactionId				INT
	,@OriginalInvoiceId			INT
	,@intARAccountId			INT
	,@isPosted					BIT
	,@intContractHeaderId		INT
	,@intContractDetailId		INT
	,@intPricingTypeId			INT
	,@dblQty					NUMERIC(18, 6)

	SELECT TOP 1 @intARAccountId = ISNULL(intARAccountId,0) FROM tblARCompanyPreference
	IF @intARAccountId = 0
	BEGIN
		RAISERROR('Please configure ''AR Account'' in company preference.',16,1)
	END

	IF OBJECT_ID (N'tempdb.dbo.#tmpLGContractPrice') IS NOT NULL DROP TABLE #tmpLGContractPrice
	CREATE TABLE #tmpLGContractPrice (
		intIdentityId INT
		,intContractHeaderId int
		,intContractDetailId int
		,ysnLoad bit
		,intPriceContractId int
		,intPriceFixationId int
		,intPriceFixationDetailId int
		,dblQuantity numeric(18,6)
		,dblPrice numeric(18,6)
	)

	SELECT
		 @ShipmentNumber			= L.strLoadNumber
		,@TransactionType			= CASE WHEN (@intType = 3) THEN 'Proforma Invoice' ELSE 'Invoice' END
		,@Type						= CASE WHEN (@intType = 2) THEN 'Provisional' ELSE 'Standard' END 
		,@EntityCustomerId			= LD.intCustomerEntityId
		,@CompanyLocationId			= LD.intSCompanyLocationId 	
		,@AccountId					= NULL
		,@CurrencyId				= L.intCurrencyId
		,@TermId					= NULL
		,@SourceId					= @intLoadId
		,@PeriodsToAccrue			= 1
		,@Date						= @DateOnly
		,@DueDate					= NULL
		,@ShipDate					= L.dtmScheduledDate
		,@PostDate					= @DateOnly
		,@CalculatedDate			= @DateOnly
		,@InvoiceSubtotal			= @ZeroDecimal
		,@Shipping					= @ZeroDecimal
		,@Tax						= @ZeroDecimal
		,@InvoiceTotal				= @ZeroDecimal
		,@Discount					= @ZeroDecimal
		,@DiscountAvailable			= @ZeroDecimal
		,@Interest					= @ZeroDecimal
		,@AmountDue					= @ZeroDecimal
		,@Payment					= @ZeroDecimal
		,@EntitySalespersonId		= ISNULL(LD.intSalespersonId, ARC.[intSalespersonId])
		,@FreightTermId				= L.intFreightTermId
		,@ShipViaId					= CD.intShipViaId
		,@PaymentMethodId			= NULL
		,@InvoiceOriginId			= NULL
		,@PONumber					= NULL --SO.[strPONumber]
		,@BOLNumber					= L.strBLNumber
		,@Comments					= L.strLoadNumber + ' : ' + L.strCustomerReference
		,@FooterComments			= NULL
		,@ShipToLocationId			= LD.intCustomerEntityLocationId
		,@ShipToLocationName		= NULL
		,@ShipToAddress				= NULL
		,@ShipToCity				= NULL
		,@ShipToState				= NULL
		,@ShipToZipCode				= NULL
		,@ShipToCountry				= NULL
		,@BillToLocationId			= NULL
		,@BillToLocationName		= NULL
		,@BillToAddress				= NULL
		,@BillToCity				= NULL
		,@BillToState				= NULL
		,@BillToZipCode				= NULL
		,@BillToCountry				= NULL
		,@Posted					= 0
		,@Paid						= 0
		,@Processed					= 0
		,@Template					= 0
		,@Forgiven					= 0
		,@Calculated				= 0
		,@Splitted					= 0
		,@PaymentId					= NULL
		,@SplitId					= NULL
		,@DistributionHeaderId		= NULL
		,@LoadDistributionHeaderId	= NULL
		,@ActualCostId				= NULL
		,@InboundShipmentId			= NULL
		,@TransactionId				= NULL
		,@OriginalInvoiceId			= NULL
		,@isPosted					= ISNULL(L.ysnPosted, 0)
		,@intContractHeaderId		= CH.intContractHeaderId
		,@intContractDetailId		= CD.intContractDetailId
		,@intPricingTypeId			= CH.intPricingTypeId
		,@dblQty					= LD.dblQuantity
	FROM [tblLGLoad] L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN [tblARCustomer] ARC ON LD.intCustomerEntityId = ARC.[intEntityId]
	WHERE L.intLoadId = @intLoadId

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable		

	IF (@intType = 3 AND @isPosted = 0)
		
		/* Proforma Invoice for Unposted LS */
		INSERT INTO @EntriesForInvoice
			([strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[intPeriodsToAccrue]
			,[dtmDate]
			,[dtmDueDate]
			,[dtmShipDate]
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[strPONumber]
			,[strBOLNumber]
			,[strComments]
			,[intShipToLocationId]
			,[intBillToLocationId]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intPaymentId]
			,[intSplitId]
			,[intLoadDistributionHeaderId]
			,[strActualCostId]
			,[intShipmentId]
			,[intTransactionId]
			,[intOriginalInvoiceId]
			,[intEntityId]
			,[ysnResetDetails]
			,[ysnRecap]
			,[ysnPost]
			,[intInvoiceDetailId]
			,[intItemId]
			,[ysnInventory]
			,[strDocumentNumber]
			,[strItemDescription]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblItemWeight]
			,[intItemWeightUOMId]
			,[dblPrice]
			,[intPriceUOMId]
			,[dblUnitPrice]
			,[strPricing]
			,[ysnRefreshPrice]
			,[strMaintenanceType]
			,[strFrequency]
			,[dtmMaintenanceDate]
			,[dblMaintenanceAmount]
			,[dblLicenseAmount]
			,[intTaxGroupId]
			,[intStorageLocationId]
			,[ysnRecomputeTax]
			,[intSCInvoiceId]
			,[strSCInvoiceNumber]
			,[intSCBudgetId]
			,[strSCBudgetDescription]
			,[intInventoryShipmentItemId]
			,[intLoadDetailId]
			,[intLoadId]
			,[intLotId]
			,[strShipmentNumber]
			,[intRecipeItemId] 
			,[intSalesOrderDetailId]
			,[strSalesOrderNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]
			,[dblShipmentTareWt]
			,[dblShipmentNetWt]
			,[intTicketId]
			,[intTicketHoursWorkedId]
			,[intOriginalInvoiceDetailId]
			,[intSiteId]
			,[strBillingBy]
			,[dblPercentFull]
			,[dblNewMeterReading]
			,[dblPreviousMeterReading]
			,[dblConversionFactor]
			,[intPerformerId]
			,[ysnLeaseBilling]
			,[ysnVirtualMeterReading]
			,[ysnClearDetailTaxes]
			,[intTempDetailIdForTaxes]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate])
		SELECT
			[strTransactionType]					= @TransactionType
			,[strType]								= @Type
			,[strSourceTransaction]					= 'Load Schedule'
			,[intSourceId]							= @intLoadId
			,[strSourceId]							= L.strLoadNumber
			,[intInvoiceId]							= NULL
			,[intEntityCustomerId]					= LD.intCustomerEntityId 
			,[intCompanyLocationId]					= @CompanyLocationId 
			,[intCurrencyId]						= CASE WHEN L.intSourceType = 7 
															THEN LD.intPriceCurrencyId 
														 ELSE 
															CASE WHEN (CD.ysnUseFXPrice = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND 
																		CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL) 
																THEN CD.intInvoiceCurrencyId 
															ELSE 
																CASE WHEN AD.ysnSeqSubCurrency = 1 THEN 
																		(SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = intSeqCurrencyId)
																	ELSE 
																		AD.intSeqCurrencyId 
																	END
																END
														 END 
			,[intTermId]							= @TermId 
			,[intPeriodsToAccrue]					= @PeriodsToAccrue 
			,[dtmDate]								= @Date 
			,[dtmDueDate]							= @DueDate 
			,[dtmShipDate]							= @ShipDate 
			,[intEntitySalespersonId]				= @EntitySalespersonId 
			,[intFreightTermId]						= @FreightTermId 
			,[intShipViaId]							= @ShipViaId 
			,[intPaymentMethodId]					= @PaymentMethodId 
			,[strInvoiceOriginId]					= @InvoiceOriginId 
			,[strPONumber]							= @PONumber 
			,[strBOLNumber]							= @BOLNumber 
			,[strComments]							= @Comments 
			,[intShipToLocationId]					= @ShipToLocationId 
			,[intBillToLocationId]					= @BillToLocationId
			,[ysnTemplate]							= @Template
			,[ysnForgiven]							= @Forgiven
			,[ysnCalculated]						= @Calculated
			,[ysnSplitted]							= @Splitted
			,[intPaymentId]							= @PaymentId
			,[intSplitId]							= @SplitId
			,[intDistributionHeaderId]				= @DistributionHeaderId
			,[strActualCostId]						= @ActualCostId
			,[intShipmentId]						= NULL
			,[intTransactionId]						= @TransactionId
			,[intOriginalInvoiceId]					= @OriginalInvoiceId
			,[intEntityId]							= @intUserId
			,[ysnResetDetails]						= 0
			,[ysnRecap]								= 0
			,[ysnPost]								= 0
			,[intInvoiceDetailId]					= NULL
			,[intItemId]							= LD.[intItemId]
			,[ysnInventory]							= 1
			,[strDocumentNumber]					= @ShipmentNumber 
			,[strItemDescription]					= CASE WHEN ISNULL(I.[strDescription],'') = '' THEN I.strItemNo ELSE I.strDescription END
			,[intOrderUOMId]						= CD.intItemUOMId 
			,[dblQtyOrdered]						= ISNULL(LD.dblQuantity, 0)
			,[intItemUOMId]							= LD.intWeightItemUOMId
			,[dblQtyShipped]						= ISNULL(LD.dblQuantity, 0)
			,[dblDiscount]							= CAST(0.0000000 AS NUMERIC(18, 6))
			,[dblItemWeight]						= dbo.fnCalculateQtyBetweenUOM(ISNULL(CD.intItemUOMId, LD.intItemUOMId), LD.intWeightItemUOMId, 1.000000)
			,[intItemWeightUOMId]					= LD.intWeightItemUOMId
			,[dblPrice]								= CASE WHEN L.intSourceType = 7 THEN LD.dblUnitPrice ELSE dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) END
			,[intPriceUOMId]						= ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId)
			,[dblUnitPrice]							= CASE WHEN L.intSourceType = 7 
															THEN (LD.dblUnitPrice) * dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intPriceUOMId, LD.intItemUOMId), 1)
														 ELSE ((dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)) 
															* dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId), 1)) 
														END
			,[strPricing]							= 'Inventory Shipment Item Price'
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= NULL
			,[strFrequency]							= NULL
			,[dtmMaintenanceDate]					= NULL
			,[dblMaintenanceAmount]					= @ZeroDecimal 
			,[dblLicenseAmount]						= @ZeroDecimal
			,[intTaxGroupId]						= NULL
			,[intStorageLocationId]					= NULL 
			,[ysnRecomputeTax]						= 1
			,[intSCInvoiceId]						= NULL
			,[strSCInvoiceNumber]					= NULL
			,[intSCBudgetId]						= NULL
			,[strSCBudgetDescription]				= NULL
			,[intInventoryShipmentItemId]			= NULL
			,[intLoadDetailId]						= LD.[intLoadDetailId] 
			,[intLoadId]							= @intLoadId
			,[intLotId]								= NULL 
			,[strShipmentNumber]					= CAST('' AS NVARCHAR(50))
			,[intRecipeItemId]						= NULL 
			,[intSalesOrderDetailId]				= NULL
			,[strSalesOrderNumber]					= NULL
			,[intContractHeaderId]					= CD.[intContractHeaderId] 
			,[intContractDetailId]					= CD.[intContractDetailId] 
			,[intShipmentPurchaseSalesContractId]	= NULL
			,[dblShipmentGrossWt]					= LD.dblGross
			,[dblShipmentTareWt]					= LD.dblTare
			,[dblShipmentNetWt]						= LD.dblNet
			,[intTicketId]							= NULL
			,[intTicketHoursWorkedId]				= NULL
			,[intOriginalInvoiceDetailId]			= NULL
			,[intSiteId]							= NULL
			,[strBillingBy]							= NULL
			,[dblPercentFull]						= NULL
			,[dblNewMeterReading]					= @ZeroDecimal
			,[dblPreviousMeterReading]				= @ZeroDecimal
			,[dblConversionFactor]					= @ZeroDecimal
			,[intPerformerId]						= NULL
			,[ysnLeaseBilling]						= 0
			,[ysnVirtualMeterReading]				= 0
			,[ysnClearDetailTaxes]					= 0
			,[intTempDetailIdForTaxes]				= NULL
			,[intCurrencyExchangeRateTypeId]		= CD.intRateTypeId
			,[intCurrencyExchangeRateId]			= CD.intCurrencyExchangeRateId
			,[dblCurrencyExchangeRate]				= CD.dblRate
			,[intSubCurrencyId]						= AD.intSeqCurrencyId 
			,[dblSubCurrencyRate]					= CASE WHEN AD.ysnSeqSubCurrency = 1
															THEN CU.intCent
														ELSE 1.000000
														END
		FROM tblLGLoad L
			LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
			LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = AD.intSeqCurrencyId
		WHERE L.intLoadId = @intLoadId

	ELSE
		IF(@intPricingTypeId = 2)
		BEGIN
			INSERT INTO #tmpLGContractPrice
			EXEC uspCTGetContractPrice @intContractHeaderId,@intContractDetailId, @dblQty, 'Invoice'

			IF NOT EXISTS (SELECT 1 FROM #tmpLGContractPrice HAVING SUM(dblPrice) <> 0)
			BEGIN
				RAISERROR('One or more contracts is not yet priced. Please price the contracts to proceed.', 16, 1);
			END
		END

		IF ((SELECT TOP 1 ISNULL(ysnAllowInvoiceForPartialPriced, 0) FROM tblLGCompanyPreference) = 0)
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM 
						tblCTContractDetail CD
						JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intSContractDetailId
						JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
						WHERE L.intLoadId = @intLoadId AND CD.intPricingTypeId IN (2)) AND @intType = 1
			BEGIN
				SELECT TOP 1 
					@InvoiceNumber = CH.strContractNumber,
					@ShipmentNumber = CAST(CD.intContractSeq AS nvarchar(10))
				FROM tblCTContractDetail CD
					JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intSContractDetailId
					JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
					LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CD.intContractDetailId
				WHERE L.intLoadId = @intLoadId AND CD.intPricingTypeId IN (2) AND (PF.dblTotalLots IS NULL OR PF.dblLotsFixed < PF.dblTotalLots)

				DECLARE @ErrorMessageNotPriced NVARCHAR(250)

				SET @ErrorMessageNotPriced = 'Contract No. ' + @InvoiceNumber + '/' + @ShipmentNumber + ' is not fully priced. Unable to create Direct Invoice.';

				IF (@ErrorMessageNotPriced IS NOT NULL)
				BEGIN
					RAISERROR(@ErrorMessageNotPriced, 16, 1);
					RETURN 0;
				END
			END
		END

		INSERT INTO @EntriesForInvoice
			([strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intTermId]
			,[intPeriodsToAccrue]
			,[dtmDate]
			,[dtmDueDate]
			,[dtmShipDate]
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[strPONumber]
			,[strBOLNumber]
			,[strComments]
			,[intShipToLocationId]
			,[intBillToLocationId]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intPaymentId]
			,[intSplitId]
			,[intLoadDistributionHeaderId]
			,[strActualCostId]
			,[intShipmentId]
			,[intTransactionId]
			,[intOriginalInvoiceId]
			,[intEntityId]
			,[ysnResetDetails]
			,[ysnRecap]
			,[ysnPost]
			,[intInvoiceDetailId]
			,[intItemId]
			,[ysnInventory]
			,[strDocumentNumber]
			,[strItemDescription]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblItemWeight]
			,[intItemWeightUOMId]
			,[dblPrice]
			,[intPriceUOMId]
			,[dblUnitPrice]
			,[strPricing]
			,[ysnRefreshPrice]
			,[strMaintenanceType]
			,[strFrequency]
			,[dtmMaintenanceDate]
			,[dblMaintenanceAmount]
			,[dblLicenseAmount]
			,[intTaxGroupId]
			,[intStorageLocationId]
			,[ysnRecomputeTax]
			,[intSCInvoiceId]
			,[strSCInvoiceNumber]
			,[intSCBudgetId]
			,[strSCBudgetDescription]
			,[intInventoryShipmentItemId]
			,[intLoadDetailId]
			,[intLoadId]
			,[intLotId]
			,[strShipmentNumber]
			,[intRecipeItemId] 
			,[intSalesOrderDetailId]
			,[strSalesOrderNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]
			,[dblShipmentTareWt]
			,[dblShipmentNetWt]
			,[intTicketId]
			,[intTicketHoursWorkedId]
			,[intOriginalInvoiceDetailId]
			,[intSiteId]
			,[strBillingBy]
			,[dblPercentFull]
			,[dblNewMeterReading]
			,[dblPreviousMeterReading]
			,[dblConversionFactor]
			,[intPerformerId]
			,[ysnLeaseBilling]
			,[ysnVirtualMeterReading]
			,[ysnClearDetailTaxes]
			,[intTempDetailIdForTaxes]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate])
		SELECT
			[strTransactionType]					= @TransactionType
			,[strType]								= @Type
			,[strSourceTransaction]					= 'Load Schedule'
			,[intSourceId]							= @intLoadId
			,[strSourceId]							= ARSI.strLoadNumber
			,[intInvoiceId]							= NULL
			,[intEntityCustomerId]					= ARSI.intEntityCustomerId 
			,[intCompanyLocationId]					= @CompanyLocationId 
			,[intCurrencyId]						= ARSI.intCurrencyId 
			,[intTermId]							= @TermId 
			,[intPeriodsToAccrue]					= @PeriodsToAccrue 
			,[dtmDate]								= @Date 
			,[dtmDueDate]							= @DueDate 
			,[dtmShipDate]							= @ShipDate 
			,[intEntitySalespersonId]				= @EntitySalespersonId 
			,[intFreightTermId]						= @FreightTermId 
			,[intShipViaId]							= @ShipViaId 
			,[intPaymentMethodId]					= @PaymentMethodId 
			,[strInvoiceOriginId]					= @InvoiceOriginId 
			,[strPONumber]							= @PONumber 
			,[strBOLNumber]							= @BOLNumber 
			,[strComments]							= @Comments 
			,[intShipToLocationId]					= @ShipToLocationId 
			,[intBillToLocationId]					= @BillToLocationId
			,[ysnTemplate]							= @Template
			,[ysnForgiven]							= @Forgiven
			,[ysnCalculated]						= @Calculated
			,[ysnSplitted]							= @Splitted
			,[intPaymentId]							= @PaymentId
			,[intSplitId]							= @SplitId
			,[intDistributionHeaderId]				= @DistributionHeaderId
			,[strActualCostId]						= @ActualCostId
			,[intShipmentId]						= NULL
			,[intTransactionId]						= @TransactionId
			,[intOriginalInvoiceId]					= @OriginalInvoiceId
			,[intEntityId]							= @intUserId
			,[ysnResetDetails]						= 0
			,[ysnRecap]								= 0
			,[ysnPost]								= 0
			,[intInvoiceDetailId]					= NULL
			,[intItemId]							= ARSI.[intItemId]
			,[ysnInventory]							= 1
			,[strDocumentNumber]					= @ShipmentNumber 
			,[strItemDescription]					= CASE WHEN ISNULL(ARSI.[strItemDescription],'') = '' THEN ARSI.strItemNo ELSE ARSI.strItemDescription END
			,[intOrderUOMId]						= ARSI.[intOrderUOMId] 
			,[dblQtyOrdered]						= CASE WHEN @intPricingTypeId = 2 THEN ISNULL(CP.[dblQuantity], ARSI.[dblQtyOrdered]) ELSE ARSI.[dblQtyOrdered] END
			,[intItemUOMId]							= ARSI.[intItemUOMId] 
			,[dblQtyShipped]						= CASE WHEN @intPricingTypeId = 2 
														THEN 
															CASE WHEN (ARSI.[dblShipmentQuantity] < dbo.fnCalculateQtyBetweenUOM(ARSI.[intOrderUOMId], ARSI.[intWeightUOMId], CP.dblCurRunningQuantity))
																THEN ARSI.[dblShipmentQuantity] - dbo.fnCalculateQtyBetweenUOM(ARSI.[intOrderUOMId], ARSI.[intWeightUOMId], ISNULL(CP.dblPrevRunningQuantity, 0)) 
															ELSE 
																dbo.fnCalculateQtyBetweenUOM(ARSI.[intOrderUOMId], ARSI.[intWeightUOMId], CP.dblQuantity)
															END
														ELSE ARSI.[dblShipmentQuantity] END
			,[dblDiscount]							= ARSI.[dblDiscount] 
			,[dblItemWeight]						= ARSI.[dblWeight]  
			,[intItemWeightUOMId]					= ARSI.[intWeightUOMId] 
			,[dblPrice]								= CASE WHEN @intPricingTypeId = 2 THEN CP.[dblPrice] ELSE ARSI.[dblPrice] END
			,[intPriceUOMId]						= ARSI.[intPriceUOMId]
			,[dblUnitPrice]							= CASE WHEN @intPricingTypeId = 2 THEN dbo.fnCalculateQtyBetweenUOM(ARSI.[intItemUOMId], ARSI.[intPriceUOMId], CP.[dblPrice]) ELSE ARSI.[dblShipmentUnitPrice] END
			,[strPricing]							= 'Inventory Shipment Item Price'
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= NULL
			,[strFrequency]							= NULL
			,[dtmMaintenanceDate]					= NULL
			,[dblMaintenanceAmount]					= @ZeroDecimal 
			,[dblLicenseAmount]						= @ZeroDecimal
			,[intTaxGroupId]						= ARSI.[intTaxGroupId] 
			,[intStorageLocationId]					= ARSI.[intStorageLocationId] 
			,[ysnRecomputeTax]						= 1
			,[intSCInvoiceId]						= NULL
			,[strSCInvoiceNumber]					= NULL
			,[intSCBudgetId]						= NULL
			,[strSCBudgetDescription]				= NULL
			,[intInventoryShipmentItemId]			= NULL
			,[intLoadDetailId]						= ARSI.[intLoadDetailId] 
			,[intLoadId]							= @intLoadId
			,[intLotId]								= ARSI.[intLotId] 
			,[strShipmentNumber]					= ARSI.strInventoryShipmentNumber 
			,[intRecipeItemId]						= ARSI.[intRecipeItemId] 
			,[intSalesOrderDetailId]				= ARSI.[intSalesOrderDetailId] 
			,[strSalesOrderNumber]					= ARSI.[strSalesOrderNumber] 
			,[intContractHeaderId]					= ARSI.[intContractHeaderId] 
			,[intContractDetailId]					= ARSI.[intContractDetailId] 
			,[intShipmentPurchaseSalesContractId]	= NULL
			,[dblShipmentGrossWt]					= CASE WHEN @intPricingTypeId = 2 THEN dbo.fnCalculateQtyBetweenUOM(ARSI.[intOrderUOMId], ARSI.[intWeightUOMId], CP.[dblQuantity]) ELSE ARSI.[dblGrossWt] END
			,[dblShipmentTareWt]					= CASE WHEN @intPricingTypeId = 2 THEN 0 ELSE ARSI.[dblTareWt] END
			,[dblShipmentNetWt]						= CASE WHEN @intPricingTypeId = 2 THEN dbo.fnCalculateQtyBetweenUOM(ARSI.[intOrderUOMId], ARSI.[intWeightUOMId], CP.[dblQuantity]) ELSE ARSI.[dblNetWt] END
			,[intTicketId]							= ARSI.[intTicketId] 
			,[intTicketHoursWorkedId]				= NULL
			,[intOriginalInvoiceDetailId]			= NULL
			,[intSiteId]							= NULL
			,[strBillingBy]							= NULL
			,[dblPercentFull]						= NULL
			,[dblNewMeterReading]					= @ZeroDecimal
			,[dblPreviousMeterReading]				= @ZeroDecimal
			,[dblConversionFactor]					= @ZeroDecimal
			,[intPerformerId]						= NULL
			,[ysnLeaseBilling]						= 0
			,[ysnVirtualMeterReading]				= 0
			,[ysnClearDetailTaxes]					= 0
			,[intTempDetailIdForTaxes]				= NULL
			,[intCurrencyExchangeRateTypeId]		= ARSI.[intCurrencyExchangeRateTypeId] 
			,[intCurrencyExchangeRateId]			= ARSI.[intCurrencyExchangeRateId] 
			,[dblCurrencyExchangeRate]				= ARSI.[dblCurrencyExchangeRate] 
			,[intSubCurrencyId]						= ARSI.intSubCurrencyId 
			,[dblSubCurrencyRate]					= ARSI.dblSubCurrencyRate 
		FROM vyuARShippedItems ARSI
			OUTER APPLY (
				SELECT cp.* 
					,dblPrevRunningQuantity = (SELECT SUM(dblQuantity) FROM #tmpLGContractPrice prcp
											WHERE prcp.intIdentityId < cp.intIdentityId
												AND cp.intContractDetailId = ARSI.intContractDetailId)
					,dblCurRunningQuantity = (SELECT SUM(dblQuantity) FROM #tmpLGContractPrice crcp 
											WHERE crcp.intIdentityId <= cp.intIdentityId
												AND cp.intContractDetailId = ARSI.intContractDetailId)
				FROM #tmpLGContractPrice cp
				WHERE cp.intContractDetailId = ARSI.intContractDetailId) CP
		WHERE ARSI.[strTransactionType] = 'Load Schedule' 
		  AND ARSI.[intLoadId] = @intLoadId
	
	IF EXISTS(SELECT TOP 1 1 FROM tblARInvoice ARI
		JOIN tblARInvoiceDetail ARID ON ARID.intInvoiceId = ARI.intInvoiceId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ARID.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE LD.intLoadId = @intLoadId
		AND ARI.intInvoiceId NOT IN 
			(SELECT intInvoiceId FROM tblLGWeightClaimDetail WCD 
			INNER JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = WCD.intWeightClaimId
			WHERE WC.intLoadId = @intLoadId)
		AND ((@intType = 1 AND ARI.strTransactionType = 'Invoice' AND ARI.strType = 'Standard')
			OR (@intType = 2 AND ARI.strTransactionType = 'Invoice' AND ARI.strType = 'Provisional')
			OR (@intType = 3 AND ARI.strTransactionType = 'Proforma Invoice' AND ARI.strType = 'Standard'))
	)
	BEGIN
		SELECT TOP 1
			@InvoiceNumber		= ARI.[strInvoiceNumber]
		   ,@ShipmentNumber		= L.strLoadNumber 
		FROM tblARInvoice ARI
		JOIN tblARInvoiceDetail ARID ON ARID.intInvoiceId = ARI.intInvoiceId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ARID.intLoadDetailId
		JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE LD.intLoadId = @intLoadId 
		AND ARI.intInvoiceId NOT IN 
			(SELECT intInvoiceId FROM tblLGWeightClaimDetail WCD 
			INNER JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = WCD.intWeightClaimId
			WHERE WC.intLoadId = @intLoadId)
		AND ((@intType = 1 AND ARI.strTransactionType = 'Invoice' AND ARI.strType = 'Standard')
			OR (@intType = 2 AND ARI.strTransactionType = 'Invoice' AND ARI.strType = 'Provisional')
			OR (@intType = 3 AND ARI.strTransactionType = 'Proforma Invoice' AND ARI.strType = 'Standard'))

		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = CASE @intType 
								WHEN 2 THEN 'Provisional '
								WHEN 3 THEN 'Proforma ' 
								ELSE '' END +
							'Invoice (' + @InvoiceNumber + ') was already created for ' + @ShipmentNumber;

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
	DECLARE	 @LineItemTaxEntries	LineItemTaxDetailStagingTable
			,@CurrentErrorMessage NVARCHAR(250)
			,@CreatedIvoices NVARCHAR(MAX)
			,@UpdatedIvoices NVARCHAR(MAX)	
				

	EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries		= @EntriesForInvoice
		,@LineItemTaxEntries	= @LineItemTaxEntries
		,@UserId				= @intUserId
		,@GroupingOption		= 11
		,@RaiseError			= 1
		,@ErrorMessage			= @CurrentErrorMessage	OUTPUT
		,@CreatedIvoices		= @CreatedIvoices		OUTPUT
		,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT

		
	SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))		
	
	IF (@intType = 1 AND EXISTS(SELECT TOP 1 1 FROM #tmpLGContractPrice) AND EXISTS(SELECT TOP 1 1 FROM @EntriesForInvoice))
	BEGIN
		/* INSERT tblCTPriceFixationDetailAPAR */
		INSERT INTO tblCTPriceFixationDetailAPAR (
			intPriceFixationDetailId
			, intInvoiceId
			, intInvoiceDetailId
			, intConcurrencyId
		)
		SELECT intPriceFixationDetailId = PRICE.intPriceFixationDetailId
			, intInvoiceId				= ID.intInvoiceId
			, intInvoiceDetailId		= ID.intInvoiceDetailId
			, intConcurrencyId			= 1
		FROM tblARInvoiceDetail ID
		INNER JOIN #tmpLGContractPrice PRICE 
			ON ID.intContractDetailId = PRICE.intContractDetailId 
				AND ID.dblPrice = PRICE.dblPrice
		WHERE ID.intInvoiceId = @NewInvoiceId
		AND ID.intInventoryShipmentChargeId IS NULL
			
	END
         
	RETURN @NewInvoiceId
END