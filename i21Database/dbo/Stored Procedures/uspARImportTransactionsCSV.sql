CREATE PROCEDURE [dbo].[uspARImportTransactionsCSV]
	 @ImportLogId	INT		
	,@UserEntityId	INT	= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal		NUMERIC(18, 6)
	  , @DateNow			DATETIME
	  , @DefaultCurrencyId	INT
	  , @CreatedIvoices		NVARCHAR(MAX)
	  , @BOLNumber			NVARCHAR(50)

DECLARE @InvoicesForImport AS TABLE(intImportLogDetailId INT UNIQUE)
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)

INSERT INTO 
	@InvoicesForImport
SELECT
	[intImportLogDetailId] 
FROM
	[tblARImportLogDetail]
WHERE
	[intImportLogId] = @ImportLogId
	AND ISNULL([ysnSuccess],0) = 1
	AND ISNULL(ysnImported,0) = 0
ORDER BY
	[intImportLogDetailId]
	
WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicesForImport)
BEGIN
	DECLARE @ImportLogDetailId INT
	SELECT TOP 1
		@ImportLogDetailId = [intImportLogDetailId]
	FROM
		@InvoicesForImport
	ORDER BY
		[intImportLogDetailId]
		
	DECLARE	@EntityCustomerId			INT
		,@InvoiceDate					DATETIME
		,@CompanyLocationId				INT
		,@EntityId						INT
		,@NewTransactionId				INT				= NULL		
		,@ErrorMessage					NVARCHAR(250)	= NULL
		,@TermId						INT				= NULL
		,@EntitySalespersonId			INT				= NULL
		,@DueDate						DATETIME		= NULL		
		,@ShipDate						DATETIME		= NULL
		,@PostDate						DATETIME		= NULL
		,@TransactionType				NVARCHAR(50)	= 'Invoice'
		,@Type							NVARCHAR(200)	= 'Standard'
		,@Comment						NVARCHAR(500)	= ''
		,@OriginId						NVARCHAR(16)	= ''
		,@PONumber						NVARCHAR(50)	= ''		
		,@FreightTermId					INT				= NULL
		,@ShipViaId						INT				= NULL		
		,@DiscountAmount				NUMERIC(18,6)   = @ZeroDecimal
		,@DiscountPercentage			NUMERIC(18,6)	= @ZeroDecimal
		,@ItemQtyShipped				NUMERIC(18,6)	= @ZeroDecimal
		,@ItemPrice						NUMERIC(18,6)	= @ZeroDecimal
		,@ItemDescription				NVARCHAR(500)	= NULL
		,@TaxGroupId					INT				= NULL
		,@AmountDue						NUMERIC(18,6)	= @ZeroDecimal
		,@TaxAmount						NUMERIC(18,6)	= @ZeroDecimal
			
	SELECT 
		 @EntityCustomerId				= (SELECT TOP 1 [intEntityId] FROM tblEntity WHERE [strEntityNo] = D.[strCustomerNumber])
		,@InvoiceDate					= D.[dtmDate] 					
		,@CompanyLocationId				= (SELECT TOP 1 [intCompanyLocationId] FROM tblSMCompanyLocation WHERE strLocationName = D.[strLocationName])
		,@EntityId						= ISNULL(@UserEntityId, H.[intEntityId])
		,@TermId						= (SELECT TOP 1 [intTermID] FROM tblSMTerm WHERE [strTerm] = D.[strTerms])
		,@EntitySalespersonId			= (SELECT TOP 1 [intEntitySalespersonId] FROM tblARSalesperson WHERE [strSalespersonId] = D.[strSalespersonNumber])
		,@DueDate						= D.dtmDueDate		
		,@ShipDate						= D.dtmShipDate
		,@PostDate						= D.[dtmPostDate] 
		,@TransactionType				= D.[strTransactionType]
		,@Type							= (CASE WHEN D.[strTransactionType] = 'Credit Memo' THEN 'Credit Memo' ELSE 'Standard' END)
		,@Comment						= D.[strTransactionNumber]
		,@OriginId						= D.[strTransactionNumber]
		,@PONumber						= D.[strPONumber] 
		,@BOLNumber						= D.[strBOLNumber]		
		,@FreightTermId					= (SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = D.strFreightTerm)
		,@ShipViaId						= (SELECT TOP 1 intEntityShipViaId FROM tblSMShipVia WHERE strShipVia = D.strShipVia)		
		,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
		,@DiscountPercentage			= (CASE WHEN ISNULL(D.[dblDiscount], @ZeroDecimal) > 0 
												THEN (1 - ((ABS(D.[dblTotal]) - ISNULL(D.[dblDiscount], @ZeroDecimal)) / ABS(D.[dblTotal]))) * 100
												ELSE @ZeroDecimal
										   END)
		,@ItemQtyShipped				= 1.000000
		,@ItemPrice						= ISNULL(D.[dblSubtotal], @ZeroDecimal)
		,@ItemDescription				= D.[strComment] 
		,@TaxGroupId					= (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.[strTaxGroup])
		,@AmountDue						= CASE WHEN D.[strTransactionType] <> 'Sales Order' THEN ISNULL(D.[dblAmountDue], @ZeroDecimal) ELSE @ZeroDecimal END
		,@TaxAmount						= ISNULL(D.[dblTax], @ZeroDecimal)
	FROM
		[tblARImportLogDetail] D
	INNER JOIN
		[tblARImportLog] H
			ON D.[intImportLogId] = H.[intImportLogId] 
	WHERE
		[intImportLogDetailId] = @ImportLogDetailId
	
	IF @TransactionType <> 'Sales Order'
		BEGIN
			SELECT @ErrorMessage = 'Invoice:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strInvoiceNumber + ')' FROM [tblARInvoice] WHERE RTRIM(LTRIM(ISNULL([strInvoiceOriginId],''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL([strInvoiceOriginId],'')))) > 0
		END
	ELSE
		BEGIN
			SELECT @ErrorMessage = 'Sales Order:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strSalesOrderNumber + ')' FROM [tblSOSalesOrder] WHERE RTRIM(LTRIM(ISNULL([strSalesOrderOriginId],''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL([strSalesOrderOriginId],'')))) > 0
		END

	IF ISNULL(@EntityCustomerId, 0) = 0
		SET @ErrorMessage = 'The Customer Number provided does not exists.'

	IF ISNULL(@CompanyLocationId, 0) = 0
		SET @ErrorMessage = 'The Location Name provided does not exists.'
	
	IF ISNULL(@TermId, 0) = 0
		SET @ErrorMessage = 'The Term Code provided does not exists.'

	IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1
		BEGIN TRY
			IF @TransactionType <> 'Sales Order'
				BEGIN
					INSERT INTO @EntriesForInvoice(
						 [strSourceTransaction]
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
						,[strDeliverPickup]
						,[strComments]
						,[intShipToLocationId]
						,[intBillToLocationId]
						,[ysnTemplate]
						,[ysnForgiven]
						,[ysnCalculated]
						,[ysnSplitted]
						,[intPaymentId]
						,[intSplitId]
						,[intDistributionHeaderId]
						,[strActualCostId]
						,[intShipmentId]
						,[intTransactionId]
						,[intEntityId]
						,[ysnResetDetails]
						,[ysnPost]
						,[intInvoiceDetailId]
						,[intItemId]
						,[ysnInventory]
						,[strItemDescription]
						,[intItemUOMId]
						,[dblQtyOrdered]
						,[dblQtyShipped]
						,[dblDiscount]
						,[dblPrice]
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
						,[intTicketId]
						,[intTicketHoursWorkedId]
						,[intSiteId]
						,[strBillingBy]
						,[dblPercentFull]
						,[dblNewMeterReading]
						,[dblPreviousMeterReading]
						,[dblConversionFactor]
						,[intPerformerId]
						,[ysnLeaseBilling]
						,[ysnVirtualMeterReading]
					)
					SELECT 
						 [strSourceTransaction]		= 'Import'
						,[intSourceId]				= @ImportLogDetailId
						,[strSourceId]				= CAST(@ImportLogDetailId AS NVARCHAR(250))
						,[intInvoiceId]				= NULL
						,[intEntityCustomerId]		= @EntityCustomerId
						,[intCompanyLocationId]		= @CompanyLocationId
						,[intCurrencyId]			= @DefaultCurrencyId
						,[intTermId]				= @TermId
						,[dtmDate]					= @InvoiceDate
						,[dtmDueDate]				= @DueDate
						,[dtmShipDate]				= @ShipDate
						,[intEntitySalespersonId]	= @EntitySalespersonId
						,[intFreightTermId]			= @FreightTermId
						,[intShipViaId]				= @ShipViaId
						,[intPaymentMethodId]		= NULL
						,[strInvoiceOriginId]		= @OriginId
						,[strPONumber]				= @PONumber
						,[strBOLNumber]				= @BOLNumber
						,[strDeliverPickup]			= NULL
						,[strComments]				= @Comment
						,[intShipToLocationId]		= NULL
						,[intBillToLocationId]		= NULL
						,[ysnTemplate]				= 0
						,[ysnForgiven]				= 0
						,[ysnCalculated]			= 0
						,[ysnSplitted]				= 0
						,[intPaymentId]				= NULL
						,[intSplitId]				= NULL
						,[intDistributionHeaderId]	= NULL
						,[strActualCostId]			= NULL
						,[intShipmentId]			= NULL
						,[intTransactionId]			= NULL
						,[intEntityId]				= @EntityId
						,[ysnResetDetails]			= 1
						,[ysnPost]					= CASE WHEN @PostDate IS NULL THEN 0 ELSE 1 END
						,[intInvoiceDetailId]		= NULL
						,[intItemId]				= NULL
						,[ysnInventory]				= 0
						,[strItemDescription]		= @ItemDescription
						,[intItemUOMId]				= NULL
						,[dblQtyOrdered]			= @ItemQtyShipped
						,[dblQtyShipped]			= @ItemQtyShipped
						,[dblDiscount]				= @DiscountPercentage
						,[dblPrice]					= @ItemPrice
						,[ysnRefreshPrice]			= 0
						,[strMaintenanceType]		= NULL
						,[strFrequency]				= NULL
						,[dtmMaintenanceDate]		= NULL
						,[dblMaintenanceAmount]		= NULL
						,[dblLicenseAmount]			= NULL
						,[intTaxGroupId]			= @TaxGroupId
						,[ysnRecomputeTax]			= CASE WHEN ISNULL(@TaxGroupId, 0) > 0 THEN 1 ELSE 0 END
						,[intSCInvoiceId]			= NULL
						,[strSCInvoiceNumber]		= NULL
						,[intInventoryShipmentItemId] = NULL
						,[strShipmentNumber]		= NULL
						,[intSalesOrderDetailId]	= NULL
						,[strSalesOrderNumber]		= NULL
						,[intContractHeaderId]		= NULL
						,[intContractDetailId]		= NULL
						,[intShipmentPurchaseSalesContractId]	= NULL
						,[intTicketId]				= NULL
						,[intTicketHoursWorkedId]	= NULL
						,[intSiteId]				= NULL
						,[strBillingBy]				= NULL
						,[dblPercentFull]			= NULL
						,[dblNewMeterReading]		= NULL
						,[dblPreviousMeterReading]	= NULL
						,[dblConversionFactor]		= NULL
						,[intPerformerId]			= NULL
						,[ysnLeaseBilling]			= NULL
						,[ysnVirtualMeterReading]	= NULL
				
					EXEC [dbo].[uspARProcessInvoices]
						 @InvoiceEntries	= @EntriesForInvoice
						,@UserId			= @EntityId
						,@GroupingOption	= 11
						,@RaiseError		= 1
						,@ErrorMessage		= @ErrorMessage OUTPUT
						,@CreatedIvoices	= @CreatedIvoices OUTPUT
			
					SET @NewTransactionId = (SELECT TOP 1 intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))
				END
			ELSE
				BEGIN
					SET @NewTransactionId = 1
				END
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
		END CATCH
	
	IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) > 0
		BEGIN
			UPDATE tblARImportLogDetail
			SET [ysnImported]		= 0
			   ,[ysnSuccess]       = 0
			   ,[strEventResult]	= @ErrorMessage
			WHERE [intImportLogDetailId] = @ImportLogDetailId

			UPDATE tblARImportLog 
			SET intSuccessCount = intSuccessCount - 1
			  , intFailedCount = intFailedCount + 1
			WHERE intImportLogId = @ImportLogId
		END
	ELSE IF(ISNULL(@NewTransactionId,0) <> 0)
		BEGIN
			IF @TransactionType <> 'Sales Order'
				BEGIN
					UPDATE tblARImportLogDetail
					SET [ysnImported]		= 1
					   ,[strEventResult]	= (SELECT strTransactionType + ':' + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewTransactionId) + ' Imported.'
					WHERE [intImportLogDetailId] = @ImportLogDetailId
				END
			ELSE
				BEGIN
					UPDATE tblARImportLogDetail
					SET [ysnImported]		= 1
					   ,[strEventResult]	= (SELECT strTransactionType + ':' + strSalesOrderNumber FROM tblSOSalesOrder WHERE intSalesOrderId = @NewTransactionId) + ' Imported.'
					WHERE [intImportLogDetailId] = @ImportLogDetailId
				END			
		END
		
	DELETE FROM @InvoicesForImport WHERE [intImportLogDetailId] = @ImportLogDetailId

END
	
	
END