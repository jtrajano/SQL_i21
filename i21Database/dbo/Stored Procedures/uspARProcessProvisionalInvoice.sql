﻿CREATE PROCEDURE [dbo].[uspARProcessProvisionalInvoice]
	 @InvoiceId		INT
	,@UserId		INT	
	,@RaiseError	BIT				= 0
	,@NewInvoiceId	INT				= NULL	OUTPUT
	,@ErrorMessage	NVARCHAR(250)	= NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON


DECLARE @UserEntityId	INT
		,@InitTranCount	INT
		,@Savepoint		NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInventoryItemToInvoices' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

SET @UserEntityId = ISNULL((SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WITH (NOLOCK) WHERE intEntityId = @UserId), @UserId)

DECLARE  @InvoiceNumber			NVARCHAR(25)
		,@EntityCustomerId		INT
		,@CompanyLocationId		INT
		,@AccountId				INT
		,@CurrencyId			INT
		,@TermId				INT
		,@Date					DATETIME
		,@ShipDate				DATETIME
		,@EntitySalespersonId	INT
		,@FreightTermId			INT
		,@ShipViaId				INT
		,@PaymentMethodId		INT
		,@InvoiceOriginId		NVARCHAR(8)
		,@PONumber				NVARCHAR(25)
		,@BOLNumber				NVARCHAR(50)
		,@DeliverPickup			NVARCHAR(100)
		,@Comments				NVARCHAR(500)
		,@ShipToLocationId		INT
		,@BillToLocationId		INT
		,@ShipmentId			INT
		,@OriginalInvoiceId		INT
		
SELECT
	 @InvoiceNumber			= [strInvoiceNumber]
	,@EntityCustomerId		= [intEntityCustomerId]
	,@CompanyLocationId		= [intCompanyLocationId]
	,@AccountId				= ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference),[intAccountId])
	,@CurrencyId			= [intCurrencyId]
	,@TermId				= [intTermId]
	,@Date					= CAST(GETDATE() AS DATE)
	,@ShipDate				= [dtmShipDate]
	,@EntitySalespersonId	= [intEntitySalespersonId]
	,@FreightTermId			= [intFreightTermId]
	,@ShipViaId				= [intShipViaId]
	,@PaymentMethodId		= [intPaymentMethodId]
	,@InvoiceOriginId		= [strInvoiceNumber]
	,@PONumber				= [strPONumber]
	,@BOLNumber				= [strBOLNumber]
	--,@DeliverPickup			= [strDeliverPickup]
	,@Comments				= [strComments]
	,@ShipToLocationId		= [intShipToLocationId]
	,@BillToLocationId		= [intBillToLocationId]
	,@ShipmentId			= [intShipmentId]
	,@OriginalInvoiceId		= [intInvoiceId]
FROM
	tblARInvoice
WHERE 
	[intInvoiceId] = @InvoiceId 

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

BEGIN TRY
	INSERT INTO @EntriesForInvoice(
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
		,[ysnPost]
		,[ysnFromProvisional]
		,[intInvoiceDetailId]
		,[intItemId]
		,[ysnInventory]
		,[strDocumentNumber]
		,[strItemDescription]
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[intPriceUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[dblUnitPrice]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]
		,[intItemWeightUOMId]
		,[dblItemWeight]
		,[dblShipmentGrossWt]
		,[dblShipmentTareWt]
		,[dblShipmentNetWt]
		,[intLoadDetailId]
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
		,[intDestinationGradeId]
		,[intDestinationWeightId]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId] 
		,[dblSubCurrencyRate]
		,[intStorageLocationId]
		,[intCompanyLocationSubLocationId]
		,[dblComputedGrossPrice]
		,[intBankId]
		,[intBankAccountId]
		,[intBorrowingFacilityId]
		,[intBorrowingFacilityLimitId]
		,[strTradeFinanceNo]
		,[strBankReferenceNo]
		,[strBankTradeReference]
		,[dblLoanAmount]
		,[intBankValuationRuleId]
		,[strTradeFinanceComments]
		,[strGoodsStatus]
		,[intDefaultPayToBankAccountId]
		,[intPayToCashBankAccountId]
		,[strPaymentInstructions]
		,[strSourcedFrom]
	)
	SELECT
		 [strTransactionType]				= 'Invoice'
		,[strType]							= 'Standard'
		,[strSourceTransaction]				= 'Provisional'
		,[intSourceId]						= @InvoiceId   
		,[strSourceId]						= @InvoiceNumber
		,[intInvoiceId]						= NULL
		,[intEntityCustomerId]				= @EntityCustomerId
		,[intCompanyLocationId]				= @CompanyLocationId
		,[intCurrencyId]					= @CurrencyId
		,[intTermId]						= @TermId
		,[dtmDate]							= @Date 
		,[dtmDueDate]						= NULL
		,[dtmShipDate]						= CAST(ISNULL(@ShipDate, GETDATE()) AS DATE)
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intFreightTermId]					= @FreightTermId
		,[intShipViaId]						= @ShipViaId
		,[intPaymentMethodId]				= @PaymentMethodId
		,[strInvoiceOriginId]				= @InvoiceNumber
		,[strPONumber]						= @PONumber
		,[strBOLNumber]						= @BOLNumber
		,[strComments]						= @Comments
		,[intShipToLocationId]				= @ShipToLocationId
		,[intBillToLocationId]				= @BillToLocationId
		,[ysnTemplate]						= 0
		,[ysnForgiven]						= 0
		,[ysnCalculated]					= 0
		,[ysnSplitted]						= 0
		,[intPaymentId]						= NULL
		,[intSplitId]						= NULL
		,[intLoadDistributionHeaderId]		= NULL
		,[strActualCostId]					= NULL
		,[intShipmentId]					= NULL
		,[intTransactionId]					= NULL
		,[intOriginalInvoiceId]				= @OriginalInvoiceId
		,[intEntityId]						= @UserEntityId
		,[ysnResetDetails]					= 1
		,[ysnPost]							= NULL
		,[ysnFromProvisional]               = 1
	
		,[intInvoiceDetailId]				= NULL 
		,[intItemId]						= ARID.[intItemId] 
		,[ysnInventory]						= 1
		,[strDocumentNumber]				= @InvoiceNumber
		,[strItemDescription]				= ARID.[strItemDescription] 
		,[intOrderUOMId]					= ARID.[intOrderUOMId]
		,[dblQtyOrdered]					= ARID.[dblQtyOrdered] 
		,[intItemUOMId]						= ARID.[intItemUOMId]
		,[intPriceUOMId]					= ARID.[intPriceUOMId]
		,[dblQtyShipped]					= ARID.[dblQtyShipped]
		,[dblDiscount]						= ARID.[dblDiscount]
		,[dblPrice]							= ISNULL(ARID.[dblPrice], 0) 
		,[dblUnitPrice]						= ISNULL(ARID.[dblUnitPrice], 0) 
		,[ysnRefreshPrice]					= 0
		,[strMaintenanceType]				= ARID.[strMaintenanceType]
		,[strFrequency]						= ARID.[strFrequency]
		,[dtmMaintenanceDate]				= ARID.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]				= ARID.[dblMaintenanceAmount]
		,[dblLicenseAmount]					= ARID.[dblLicenseAmount]
		,[intTaxGroupId]					= ARID.[intTaxGroupId]
		,[ysnRecomputeTax]					= 1
		,[intSCInvoiceId]					= ARID.[intSCInvoiceId]
		,[strSCInvoiceNumber]				= ARID.[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]		= ARID.[intInventoryShipmentItemId]
		,[strShipmentNumber]				= ARID.[strShipmentNumber]
		,[intSalesOrderDetailId]			= ARID.[intSalesOrderDetailId]
		,[strSalesOrderNumber]				= ARID.[strSalesOrderNumber] 
		,[intContractHeaderId]				= ARID.[intContractHeaderId] 
		,[intContractDetailId]				= ARID.[intContractDetailId] 
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intItemWeightUOMId]				= ARID.[intItemWeightUOMId]
		,[dblItemWeight]					= ARID.[dblItemWeight] 
		,[dblShipmentGrossWt]				= ARID.[dblShipmentGrossWt]
		,[dblShipmentTareWt]				= ARID.[dblShipmentTareWt]
		,[dblShipmentNetWt]					= ARID.[dblShipmentNetWt]
		,[intLoadDetailId]					= ARID.[intLoadDetailId]
		,[intTicketId]						= ARID.[intTicketId]
		,[intTicketHoursWorkedId]			= ARID.[intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]		= ARID.[intInvoiceDetailId] 
		,[intSiteId]						= ARID.[intSiteId]
		,[strBillingBy]						= ARID.[strBillingBy]
		,[dblPercentFull]					= ARID.[dblPercentFull]
		,[dblNewMeterReading]				= ARID.[dblNewMeterReading]
		,[dblPreviousMeterReading]			= ARID.[dblPreviousMeterReading]
		,[dblConversionFactor]				= ARID.[dblConversionFactor]
		,[intPerformerId]					= ARID.[intPerformerId]
		,[ysnLeaseBilling]					= ARID.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]			= ARID.[ysnVirtualMeterReading]
		,[intDestinationGradeId]			= ARID.[intDestinationGradeId]
		,[intDestinationWeightId]			= ARID.[intDestinationWeightId]
		,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]		= ARID.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= ARID.[dblCurrencyExchangeRate]
		,[intSubCurrencyId]					= ARID.[intSubCurrencyId]
		,[dblSubCurrencyRate]				= ARID.[dblSubCurrencyRate]
		,[intStorageLocationId]				= ARID.[intStorageLocationId]
		,[intCompanyLocationSubLocationId]	= ARID.[intCompanyLocationSubLocationId]
		,[dblComputedGrossPrice]			= ARID.[dblComputedGrossPrice]
		,[intBankId]						= ARI.[intBankId]
		,[intBankAccountId]					= ARI.[intBankAccountId]
		,[intBorrowingFacilityId]			= ARI.[intBorrowingFacilityId]
		,[intBorrowingFacilityLimitId]		= ARI.[intBorrowingFacilityLimitId]
		,[strTransactionNo]					= ARI.[strTransactionNo]
		,[strBankReferenceNo]				= ARI.[strBankReferenceNo]
		,[strBankTradeReference]			= ARI.[strBankTradeReference]
		,[dblLoanAmount]					= ARI.[dblLoanAmount]
		,[intBankValuationRuleId]			= ARI.[intBankValuationRuleId]
		,[strTradeFinanceComments]			= ARI.[strTradeFinanceComments]
		,[strGoodsStatus]					= ARI.[strGoodsStatus]
		,[intDefaultPayToBankAccountId]		= ARI.[intDefaultPayToBankAccountId]
		,[intPayToCashBankAccountId]		= ARI.[intPayToCashBankAccountId]
		,[strPaymentInstructions]			= ARI.[strPaymentInstructions]
		,[strSourcedFrom]					= ARI.[strSourcedFrom]
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	WHERE
		ARID.[intInvoiceId] = @InvoiceId
								
UNION ALL

SELECT 
		[strTransactionType]				= 'Invoice'
		,[strType]							= 'Standard'
		,[strSourceTransaction]				= 'Provisional'
		,[intSourceId]						= @InvoiceId   
		,[strSourceId]						= @InvoiceNumber
		,[intInvoiceId]						= NULL
		,[intEntityCustomerId]				= @EntityCustomerId
		,[intCompanyLocationId]				= @CompanyLocationId
		,[intCurrencyId]					= @CurrencyId
		,[intTermId]						= @TermId
		,[dtmDate]							= @Date 
		,[dtmDueDate]						= NULL
		,[dtmShipDate]						= CAST(ISNULL(@ShipDate, GETDATE()) AS DATE)
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intFreightTermId]					= @FreightTermId
		,[intShipViaId]						= @ShipViaId
		,[intPaymentMethodId]				= @PaymentMethodId
		,[strInvoiceOriginId]				= @InvoiceNumber
		,[strPONumber]						= @PONumber
		,[strBOLNumber]						= @BOLNumber
		,[strComments]						= @Comments
		,[intShipToLocationId]				= @ShipToLocationId
		,[intBillToLocationId]				= @BillToLocationId
		,[ysnTemplate]						= 0
		,[ysnForgiven]						= 0
		,[ysnCalculated]					= 0
		,[ysnSplitted]						= 0
		,[intPaymentId]						= NULL
		,[intSplitId]						= NULL
		,[intDistributionHeaderId]			= NULL
		,[strActualCostId]					= NULL
		,[intShipmentId]					= NULL
		,[intTransactionId]					= NULL
		,[intOriginalInvoiceId]				= @OriginalInvoiceId
		,[intEntityId]						= @UserEntityId
		,[ysnResetDetails]					= 1
		,[ysnPost]							= NULL	
		,[ysnFromProvisional]               = 1

		,[intInvoiceDetailId]				= NULL 
		,[intItemId]						= ARID.[intItemId] 
		,[ysnInventory]						= 1
		,[strDocumentNumber]				= @InvoiceNumber
		,[strItemDescription]				= I.[strDescription] 
		,[intOrderUOMId]					= ARID.[intItemUOMId]		
		,[dblQtyOrdered]					= ARID.[dblQtyOrdered] 
		,[intItemUOMId]						= ARID.[intItemUOMId] 
		,[intPriceUOMId]					= ARID.[intPriceUOMId]
		,[dblQtyShipped]					= ARID.[dblQtyShipped]  
		,[dblDiscount]						= 0.00
		,[dblPrice]							= ISNULL(ARID.[dblPrice], 0)
		,[dblUnitPrice]						= ISNULL(ARID.[dblUnitPrice], 0)
		,[ysnRefreshPrice]					= 0
		,[strMaintenanceType]				= ARID.[strMaintenanceType]
		,[strFrequency]						= ARID.[strFrequency]
		,[dtmMaintenanceDate]				= ARID.[dtmMaintenanceDate]
		,[dblMaintenanceAmount]				= ARID.[dblMaintenanceAmount]
		,[dblLicenseAmount]					= ARID.[dblLicenseAmount]
		,[intTaxGroupId]					= ARID.[intTaxGroupId]
		,[ysnRecomputeTax]					= 1
		,[intSCInvoiceId]					= ARID.[intSCInvoiceId]
		,[strSCInvoiceNumber]				= ARID.[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]		= NULL
		,[strShipmentNumber]				= NULL
		,[intSalesOrderDetailId]			= NULL
		,[strSalesOrderNumber]				= NULL
		,[intContractHeaderId]				= ARID.[intContractHeaderId] 
		,[intContractDetailId]				= ARID.[intContractDetailId] 
		,[intShipmentPurchaseSalesContractId]= NULL
		,[intItemWeightUOMId]				= NULL
		,[dblItemWeight]					= 0.00
		,[dblShipmentGrossWt]				= 0.00
		,[dblShipmentTareWt]				= 0.00
		,[dblShipmentNetWt]					= 0.00
		,[intLoadDetailId]					= ARID.[intLoadDetailId]
		,[intTicketId]						= ARID.[intTicketId]
		,[intTicketHoursWorkedId]			= ARID.[intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]		= ARID.[intInvoiceDetailId] 
		,[intSiteId]						= ARID.[intSiteId]
		,[strBillingBy]						= ARID.[strBillingBy]
		,[dblPercentFull]					= ARID.[dblPercentFull]
		,[dblNewMeterReading]				= ARID.[dblNewMeterReading]
		,[dblPreviousMeterReading]			= ARID.[dblPreviousMeterReading]
		,[dblConversionFactor]				= ARID.[dblConversionFactor]
		,[intPerformerId]					= ARID.[intPerformerId]
		,[ysnLeaseBilling]					= ARID.[ysnLeaseBilling]
		,[ysnVirtualMeterReading]			= ARID.[ysnVirtualMeterReading]
		,[intDestinationGradeId]			= NULL
		,[intDestinationWeightId]			= NULL
		,[intCurrencyExchangeRateTypeId]	= ARID.intCurrencyExchangeRateId
		,[intCurrencyExchangeRateId]		= NULL
		,[dblCurrencyExchangeRate]			= ISNULL(ARID.dblCurrencyExchangeRate,1)
		,[intSubCurrencyId]					= ARID.[intSubCurrencyId]
		,[dblSubCurrencyRate]				= ARID.[dblSubCurrencyRate]
		,[intStorageLocationId]				= ARID.[intStorageLocationId]
		,[intCompanyLocationSubLocationId]	= ARID.[intCompanyLocationSubLocationId]
		,[dblComputedGrossPrice]			= ARID.[dblComputedGrossPrice]
		,[intBankId]						= NULL
		,[intBankAccountId]					= NULL
		,[intBorrowingFacilityId]			= NULL
		,[intBorrowingFacilityLimitId]		= NULL
		,[strTransactionNo]					= NULL
		,[strBankReferenceNo]				= NULL
		,[strBankTradeReference]			= NULL
		,[dblLoanAmount]					= NULL
		,[intBankValuationRuleId]			= NULL
		,[strTradeFinanceComments]			= NULL
		,[strGoodsStatus]					= NULL
		,[intDefaultPayToBankAccountId]		= NULL
		,[intPayToCashBankAccountId]		= NULL
		,[strPaymentInstructions]			= NULL
		,[strSourcedFrom]					= NULL
	FROM 
		tblARInvoiceDetail ARID
	LEFT JOIN tblICItem I
		ON ARID.intItemId = I.intItemId
	WHERE intInvoiceId = @InvoiceId AND ISNULL(ARID.intInventoryShipmentItemId,0) = 0 AND ISNULL(ARID.intLoadDetailId,0) = 0

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE	@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	

DECLARE @LineItemTaxes AS LineItemTaxDetailStagingTable

BEGIN TRY
EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries		= @EntriesForInvoice
	,@LineItemTaxEntries	= @LineItemTaxes
	,@UserId				= @UserId
	,@GroupingOption		= 11
	,@RaiseError			= @RaiseError
	,@ErrorMessage			= @CurrentErrorMessage	OUTPUT
	,@CreatedIvoices		= @CreatedIvoices		OUTPUT
	,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT


	IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
		BEGIN
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = @CurrentErrorMessage;
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
		
SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))

EXEC dbo.uspCTUpdateFinancialStatus @NewInvoiceId, 'Invoice'

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

GO