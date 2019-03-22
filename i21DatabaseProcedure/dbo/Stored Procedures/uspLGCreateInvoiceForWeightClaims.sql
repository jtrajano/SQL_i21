CREATE PROCEDURE uspLGCreateInvoiceForWeightClaims 
	 @intWeightClaimId INT
	,@intUserId INT
	,@NewInvoiceId INT = NULL OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @strWeightClaimNo NVARCHAR(100)
	DECLARE @strErrorMessage NVARCHAR(4000);
	DECLARE @intErrorSeverity INT;
	DECLARE @intErrorState INT;
	DECLARE @intCompanyLocationId INT;

		SELECT @strWeightClaimNo = strReferenceNumber
		FROM tblLGWeightClaim
		WHERE intWeightClaimId = @intWeightClaimId

		IF EXISTS (
				SELECT TOP 1 1
				FROM tblLGWeightClaimDetail WCD
				JOIN tblARInvoice INV ON INV.intInvoiceId = WCD.intInvoiceId
				WHERE WCD.intWeightClaimId = @intWeightClaimId
				)
		BEGIN
				DECLARE @ErrorMessage NVARCHAR(250)

				SET @ErrorMessage = 'Invoice was already created for ' + @strWeightClaimNo;

				RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
		END

	DECLARE @ZeroDecimal DECIMAL(18, 6)
		,@DateOnly DATETIME
		,@ShipmentNumber NVARCHAR(100)
		,@InvoiceId INT
		,@InvoiceNumber NVARCHAR(25)
		,@TransactionType NVARCHAR(25)
		,@Type NVARCHAR(100)
		,@EntityCustomerId INT
		,@CompanyLocationId INT
		,@AccountId INT
		,@CurrencyId INT
		,@TermId INT
		,@SourceId INT
		,@PeriodsToAccrue INT
		,@Date DATETIME
		,@DueDate DATETIME
		,@ShipDate DATETIME
		,@PostDate DATETIME
		,@CalculatedDate DATETIME
		,@InvoiceSubtotal NUMERIC(18, 6)
		,@Shipping NUMERIC(18, 6)
		,@Tax NUMERIC(18, 6)
		,@InvoiceTotal NUMERIC(18, 6)
		,@Discount NUMERIC(18, 6)
		,@DiscountAvailable NUMERIC(18, 6)
		,@Interest NUMERIC(18, 6)
		,@AmountDue NUMERIC(18, 6)
		,@Payment NUMERIC(18, 6)
		,@EntitySalespersonId INT
		,@FreightTermId INT
		,@ShipViaId INT
		,@PaymentMethodId INT
		,@InvoiceOriginId NVARCHAR(8)
		,@PONumber NVARCHAR(25)
		,@BOLNumber NVARCHAR(50)
		,@Comments NVARCHAR(max)
		,@FooterComments NVARCHAR(max)
		,@ShipToLocationId INT
		,@ShipToLocationName NVARCHAR(50)
		,@ShipToAddress NVARCHAR(100)
		,@ShipToCity NVARCHAR(30)
		,@ShipToState NVARCHAR(50)
		,@ShipToZipCode NVARCHAR(12)
		,@ShipToCountry NVARCHAR(25)
		,@BillToLocationId INT
		,@BillToLocationName NVARCHAR(50)
		,@BillToAddress NVARCHAR(100)
		,@BillToCity NVARCHAR(30)
		,@BillToState NVARCHAR(50)
		,@BillToZipCode NVARCHAR(12)
		,@BillToCountry NVARCHAR(25)
		,@Posted BIT
		,@Paid BIT
		,@Processed BIT
		,@Template BIT
		,@Forgiven BIT
		,@Calculated BIT
		,@Splitted BIT
		,@PaymentId INT
		,@SplitId INT
		,@DistributionHeaderId INT
		,@LoadDistributionHeaderId INT
		,@ActualCostId NVARCHAR(50)
		,@InboundShipmentId INT
		,@TransactionId INT
		,@OriginalInvoiceId INT
		,@intARAccountId INT
		,@strErrMsg NVARCHAR(MAX)
		,@EntriesForInvoice AS InvoiceIntegrationStagingTable

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	INSERT INTO @EntriesForInvoice (
		[strSourceTransaction]
		,[strTransactionType]
		,[strType]
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
		,[dblSubCurrencyRate]
		)
	SELECT [strSourceTransaction] = 'Weight Claim'
		,[strTransactionType] = 'Credit Memo'
		,[strType] = 'Standard'
		,[intSourceId] = WC.intWeightClaimId
		,[strSourceId] = WC.strReferenceNumber
		,[intInvoiceId] = NULL
		,[intEntityCustomerId] = WCD.intPartyEntityId
		,[intCompanyLocationId] = CD.intCompanyLocationId
		,[intCurrencyId] = @CurrencyId
		,[intTermId] = @TermId
		,[intPeriodsToAccrue] = @PeriodsToAccrue
		,[dtmDate] = GETDATE()
		,[dtmDueDate] = @DueDate
		,[dtmShipDate] = @ShipDate
		,[intEntitySalespersonId] = @EntitySalespersonId
		,[intFreightTermId] = @FreightTermId
		,[intShipViaId] = @ShipViaId
		,[intPaymentMethodId] = @PaymentMethodId
		,[strInvoiceOriginId] = @InvoiceOriginId
		,[strPONumber] = @PONumber
		,[strBOLNumber] = @BOLNumber
		,[strComments] = @Comments
		,[intShipToLocationId] = @ShipToLocationId
		,[intBillToLocationId] = @BillToLocationId
		,[ysnTemplate] = @Template
		,[ysnForgiven] = @Forgiven
		,[ysnCalculated] = @Calculated
		,[ysnSplitted] = @Splitted
		,[intPaymentId] = @PaymentId
		,[intSplitId] = @SplitId
		,[intDistributionHeaderId] = @DistributionHeaderId
		,[strActualCostId] = @ActualCostId
		,[intShipmentId] = NULL
		,[intTransactionId] = @TransactionId
		,[intOriginalInvoiceId] = @OriginalInvoiceId
		,[intEntityId] = 1
		,[ysnResetDetails] = 0
		,[ysnRecap] = 0
		,[ysnPost] = 0
		,[intInvoiceDetailId] = NULL
		,[intItemId] = CD.[intItemId]
		,[ysnInventory] = 1
		,[strDocumentNumber] = @ShipmentNumber
		,[strItemDescription] = CASE 
			WHEN ISNULL(I.[strDescription], '') = ''
				THEN I.strItemNo
			ELSE I.strDescription
			END
		,[intOrderUOMId] = LD.intWeightItemUOMId
		,[dblQtyOrdered] = WCD.dblFromNet
		,[intItemUOMId] = WCD.intPriceItemUOMId
		,[dblQtyShipped] = CASE WHEN LD.intWeightItemUOMId <> WCD.intPriceItemUOMId THEN  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId,WCD.intPriceItemUOMId,ABS(WCD.dblClaimableWt)),2) ELSE ROUND(WCD.dblClaimableWt,2) END
		,[dblDiscount] = 0 
		,[dblItemWeight] = CASE WHEN LD.intWeightItemUOMId <> WCD.intPriceItemUOMId THEN  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId,WCD.intPriceItemUOMId,ABS(WCD.dblClaimableWt)),2) ELSE ROUND(WCD.dblClaimableWt,2) END
		,[intItemWeightUOMId] = LD.intWeightItemUOMId
		,[dblPrice] = WCD.dblUnitPrice
		,[dblUnitPrice] = WCD.dblUnitPrice
		,[strPricing] = 'Inventory Shipment Item Price'
		,[ysnRefreshPrice] = 0
		,[strMaintenanceType] = NULL
		,[strFrequency] = NULL
		,[dtmMaintenanceDate] = NULL
		,[dblMaintenanceAmount] = @ZeroDecimal
		,[dblLicenseAmount] = @ZeroDecimal
		,[intTaxGroupId] = NULL
		,[intStorageLocationId] = NULL
		,[ysnRecomputeTax] = 1
		,[intSCInvoiceId] = NULL
		,[strSCInvoiceNumber] = NULL
		,[intSCBudgetId] = NULL
		,[strSCBudgetDescription] = NULL
		,[intInventoryShipmentItemId] = NULL
		,[intLoadDetailId] = NULL
		,[intLoadId] = LD.intLoadId
		,[intLotId] = NULL
		,[strShipmentNumber] = NULL
		,[intRecipeItemId] = NULL
		,[intSalesOrderDetailId] = NULL
		,[strSalesOrderNumber] = NULL
		,[intContractHeaderId] = CD.intContractHeaderId
		,[intContractDetailId] = CD.[intContractDetailId]
		,[intShipmentPurchaseSalesContractId] = NULL
		,[dblShipmentGrossWt] = 1
		,[dblShipmentTareWt] = 1
		,[dblShipmentNetWt] = 1
		,[intTicketId] = NULL
		,[intTicketHoursWorkedId] = NULL
		,[intOriginalInvoiceDetailId] = NULL
		,[intSiteId] = NULL
		,[strBillingBy] = NULL
		,[dblPercentFull] = NULL
		,[dblNewMeterReading] = @ZeroDecimal
		,[dblPreviousMeterReading] = @ZeroDecimal
		,[dblConversionFactor] = @ZeroDecimal
		,[intPerformerId] = NULL
		,[ysnLeaseBilling] = 0
		,[ysnVirtualMeterReading] = 0
		,[ysnClearDetailTaxes] = 0
		,[intTempDetailIdForTaxes] = NULL
		,[intCurrencyExchangeRateTypeId] = ARID.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId] = ARID.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate] = ARID.[dblCurrencyExchangeRate]
		,[intSubCurrencyId] = WCD.intCurrencyId
		,[dblSubCurrencyRate] = CASE WHEN CUR.ysnSubCurrency = 1 THEN 100 ELSE 1 END
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	JOIN tblLGLoadDetail LD ON LD.intSContractDetailId = CD.intContractDetailId
	JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intShipmentType = 1
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	LEFT OUTER JOIN (
		SELECT intLoadDetailId
			,intDestinationGradeId
			,intDestinationWeightId
			,intCurrencyExchangeRateTypeId
			,intCurrencyExchangeRateId
			,dblCurrencyExchangeRate
		FROM tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intLoadDetailId, 0) = 0
		) ARID ON ARID.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = WCD.intCurrencyId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	UNION

	SELECT [strSourceTransaction] = 'Weight Claim'
		,[strTransactionType] = 'Credit Memo'
		,[strType] = 'Standard'
		,[intSourceId] = WC.intWeightClaimId
		,[strSourceId] = WC.strReferenceNumber
		,[intInvoiceId] = NULL
		,[intEntityCustomerId] = WCD.intVendorId
		,[intCompanyLocationId] = @intCompanyLocationId
		,[intCurrencyId] = @CurrencyId
		,[intTermId] = @TermId
		,[intPeriodsToAccrue] = @PeriodsToAccrue
		,[dtmDate] = GETDATE()
		,[dtmDueDate] = @DueDate
		,[dtmShipDate] = @ShipDate
		,[intEntitySalespersonId] = @EntitySalespersonId
		,[intFreightTermId] = @FreightTermId
		,[intShipViaId] = @ShipViaId
		,[intPaymentMethodId] = @PaymentMethodId
		,[strInvoiceOriginId] = @InvoiceOriginId
		,[strPONumber] = @PONumber
		,[strBOLNumber] = @BOLNumber
		,[strComments] = @Comments
		,[intShipToLocationId] = @ShipToLocationId
		,[intBillToLocationId] = @BillToLocationId
		,[ysnTemplate] = @Template
		,[ysnForgiven] = @Forgiven
		,[ysnCalculated] = @Calculated
		,[ysnSplitted] = @Splitted
		,[intPaymentId] = @PaymentId
		,[intSplitId] = @SplitId
		,[intDistributionHeaderId] = @DistributionHeaderId
		,[strActualCostId] = @ActualCostId
		,[intShipmentId] = NULL
		,[intTransactionId] = @TransactionId
		,[intOriginalInvoiceId] = @OriginalInvoiceId
		,[intEntityId] = 1
		,[ysnResetDetails] = 0
		,[ysnRecap] = 0
		,[ysnPost] = 0
		,[intInvoiceDetailId] = NULL
		,[intItemId] = WCD.[intItemId]
		,[ysnInventory] = 1
		,[strDocumentNumber] = @ShipmentNumber
		,[strItemDescription] = CASE 
			WHEN ISNULL(I.[strDescription], '') = ''
				THEN I.strItemNo
			ELSE I.strDescription
			END
		,[intOrderUOMId] = WCD.intItemUOMId
		,[dblQtyOrdered] = WCD.dblQuantity
		,[intItemUOMId] = WCD.intItemUOMId
		,[dblQtyShipped] = WCD.dblQuantity
		,[dblDiscount] = 0 
		,[dblItemWeight] = WCD.dblQuantity
		,[intItemWeightUOMId] = WCD.intItemUOMId
		,[dblPrice] = CASE WHEN CUR.ysnSubCurrency = 1 THEN WCD.dblRate/100 ELSE WCD.dblRate END
		,[dblUnitPrice] = CASE WHEN CUR.ysnSubCurrency = 1 THEN WCD.dblRate/100 ELSE WCD.dblRate END
		,[strPricing] = 'Inventory Shipment Item Price'
		,[ysnRefreshPrice] = 0
		,[strMaintenanceType] = NULL
		,[strFrequency] = NULL
		,[dtmMaintenanceDate] = NULL
		,[dblMaintenanceAmount] = @ZeroDecimal
		,[dblLicenseAmount] = @ZeroDecimal
		,[intTaxGroupId] = NULL
		,[intStorageLocationId] = NULL
		,[ysnRecomputeTax] = 1
		,[intSCInvoiceId] = NULL
		,[strSCInvoiceNumber] = NULL
		,[intSCBudgetId] = NULL
		,[strSCBudgetDescription] = NULL
		,[intInventoryShipmentItemId] = NULL
		,[intLoadDetailId] = NULL
		,[intLoadId] = L.intLoadId
		,[intLotId] = NULL
		,[strShipmentNumber] = NULL
		,[intRecipeItemId] = NULL
		,[intSalesOrderDetailId] = NULL
		,[strSalesOrderNumber] = NULL
		,[intContractHeaderId] = NULL
		,[intContractDetailId] = NULL
		,[intShipmentPurchaseSalesContractId] = NULL
		,[dblShipmentGrossWt] = 1
		,[dblShipmentTareWt] = 1
		,[dblShipmentNetWt] = 1
		,[intTicketId] = NULL
		,[intTicketHoursWorkedId] = NULL
		,[intOriginalInvoiceDetailId] = NULL
		,[intSiteId] = NULL
		,[strBillingBy] = NULL
		,[dblPercentFull] = NULL
		,[dblNewMeterReading] = @ZeroDecimal
		,[dblPreviousMeterReading] = @ZeroDecimal
		,[dblConversionFactor] = @ZeroDecimal
		,[intPerformerId] = NULL
		,[ysnLeaseBilling] = 0
		,[ysnVirtualMeterReading] = 0
		,[ysnClearDetailTaxes] = 0
		,[intTempDetailIdForTaxes] = NULL
		,[intCurrencyExchangeRateTypeId] = NULL
		,[intCurrencyExchangeRateId] = NULL
		,[dblCurrencyExchangeRate] = NULL
		,[intSubCurrencyId] = WCD.intCurrencyId
		,[dblSubCurrencyRate] = CASE WHEN CUR.ysnSubCurrency = 1 THEN 100 ELSE 1 END
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimOtherCharges WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
	JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId AND L.intShipmentType = 1
	JOIN tblICItem I ON I.intItemId = WCD.intItemId
	LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = WCD.intRateCurrencyId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	DECLARE @LineItemTaxEntries LineItemTaxDetailStagingTable
		,@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)

	EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
		,@LineItemTaxEntries = @LineItemTaxEntries
		,@UserId = 1
		,@GroupingOption = 11
		,@RaiseError = 1
		,@ErrorMessage = @CurrentErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedIvoices OUTPUT
		,@UpdatedIvoices = @UpdatedIvoices OUTPUT

	SELECT TOP 1 @NewInvoiceId = intInvoiceId
	FROM tblARInvoice
	WHERE intInvoiceId IN (
			SELECT intID
			FROM fnGetRowsFromDelimitedValues(@CreatedIvoices)
			)

	UPDATE tblLGWeightClaimDetail
	SET intInvoiceId = @NewInvoiceId
	WHERE intWeightClaimId = @intWeightClaimId

	RETURN @NewInvoiceId

--	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	--IF @@TRANCOUNT >0
	--	ROLLBACK TRANSACTION

	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH