﻿CREATE PROCEDURE [dbo].[uspARImportTransactionsCSV]
	 @ImportLogId	INT
	,@IsTank		BIT = 0	
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
	  , @DefaultAccountId	INT
	  , @CreatedIvoices		NVARCHAR(MAX)
	  , @BOLNumber			NVARCHAR(50)

DECLARE @InvoicesForImport AS TABLE(intImportLogDetailId INT UNIQUE)
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultAccountId = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference)

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
		,@Date							DATETIME
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
		,@ItemId						INT				= NULL
		,@ItemDescription				NVARCHAR(500)	= NULL
		,@TaxGroupId					INT				= NULL
		,@AmountDue						NUMERIC(18,6)	= @ZeroDecimal
		,@TaxAmount						NUMERIC(18,6)	= @ZeroDecimal
		,@Total							NUMERIC(18,6)	= @ZeroDecimal
		,@SiteId						INT				= NULL
		,@PerformerId					INT				= NULL
		,@ItemId						INT				= NULL
		,@PercentFull					NUMERIC(18,6)   = @ZeroDecimal
		,@NewMeterReading				NUMERIC(18,6)   = @ZeroDecimal
		,@PreviousMeterReading			NUMERIC(18,6)   = @ZeroDecimal
		,@ConversionFactor				NUMERIC(18,6)   = @ZeroDecimal	
		,@BillingBy						NVARCHAR(50)	= NULL

	IF @IsTank = 1
		BEGIN
			SELECT 
				 @EntityCustomerId				= (SELECT TOP 1 intEntityId FROM tblEntity WHERE strEntityNo = D.strCustomerNumber)
				,@Date							= D.[dtmDate] 					
				,@CompanyLocationId				= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE intCompanyLocationId = CONVERT(INT, D.strLocationName))
				,@EntityId						= ISNULL(@UserEntityId, H.[intEntityId])				
				,@EntitySalespersonId			= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' THEN (SELECT TOP 1 intEntitySalespersonId FROM vyuEMSalesperson WHERE strSalespersonName = D.strSalespersonNumber) ELSE 0 END
				,@TransactionType				= 'Invoice'
				,@Type							= 'Tank Delivery'
				,@Comment						= D.strTransactionNumber
				,@OriginId						= D.strTransactionNumber
				,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
				,@DiscountPercentage			= (CASE WHEN ISNULL(D.dblDiscount, @ZeroDecimal) > 0 
														THEN (1 - ((ABS(D.dblTotal) - ISNULL(D.dblDiscount, @ZeroDecimal)) / ABS(D.dblTotal))) * 100
														ELSE @ZeroDecimal
												   END)
				,@ItemQtyShipped				= ISNULL(D.dblQuantity, @ZeroDecimal)
				,@ItemPrice						= ISNULL(D.dblSubtotal, @ZeroDecimal)				
				,@ItemId						= (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = D.strItemNumber)
				,@TaxGroupId					= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.[strTaxGroup]) ELSE 0 END
				,@AmountDue						= CASE WHEN D.strTransactionType <> 'Sales Order' THEN ISNULL(D.dblAmountDue, @ZeroDecimal) ELSE @ZeroDecimal END
				,@Total							= ISNULL(D.dblQuantity, @ZeroDecimal) * ISNULL(D.dblSubtotal, @ZeroDecimal)
				,@SiteId						= (SELECT TOP 1 intSiteID FROM tblTMSite WHERE intSiteNumber = CONVERT(INT, D.strSiteNumber))
				,@PerformerId					= (CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' THEN (SELECT TOP 1 intEntitySalespersonId FROM tblARSalesperson WHERE strSalespersonId = D.strPerformer) ELSE 0 END)												  
				,@PercentFull					= ISNULL(D.dblPercentFull, @ZeroDecimal)
				,@NewMeterReading				= ISNULL(D.dblNewMeterReading, @ZeroDecimal)
			FROM
				[tblARImportLogDetail] D
			INNER JOIN
				[tblARImportLog] H
					ON D.[intImportLogId] = H.[intImportLogId] 
			WHERE
				[intImportLogDetailId] = @ImportLogDetailId

			UPDATE tblARImportLogDetail SET dblTotal = @Total WHERE intImportLogDetailId = @ImportLogDetailId
		END
	ELSE
		SELECT 
			 @EntityCustomerId				= (SELECT TOP 1 [intEntityId] FROM tblEntity WHERE [strEntityNo] = D.[strCustomerNumber])
			,@Date							= D.[dtmDate] 					
			,@CompanyLocationId				= (SELECT TOP 1 [intCompanyLocationId] FROM tblSMCompanyLocation WHERE strLocationName = D.[strLocationName])
			,@EntityId						= ISNULL(@UserEntityId, H.[intEntityId])
			,@TermId						= CASE WHEN ISNULL(D.strTerms, '') <> '' THEN (SELECT TOP 1 [intTermID] FROM tblSMTerm WHERE [strTerm] = D.[strTerms]) ELSE 0 END
			,@EntitySalespersonId			= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' THEN (SELECT TOP 1 [intEntitySalespersonId] FROM tblARSalesperson WHERE [strSalespersonId] = D.[strSalespersonNumber]) ELSE 0 END
			,@DueDate						= D.dtmDueDate		
			,@ShipDate						= D.dtmShipDate
			,@PostDate						= D.[dtmPostDate] 
			,@TransactionType				= D.[strTransactionType]
			,@Type							= CASE WHEN D.strTransactionType = 'Credit Memo' THEN D.strTransactionType ELSE 'Standard' END
			,@Comment						= D.[strTransactionNumber]
			,@OriginId						= D.[strTransactionNumber]
			,@PONumber						= D.[strPONumber] 
			,@BOLNumber						= D.[strBOLNumber]		
			,@FreightTermId					= CASE WHEN ISNULL(D.strFreightTerm, '') <> '' THEN (SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = D.strFreightTerm) ELSE 0 END
			,@ShipViaId						= CASE WHEN ISNULL(D.strShipVia, '') <> '' THEN (SELECT TOP 1 intEntityShipViaId FROM tblSMShipVia WHERE strShipVia = D.strShipVia)	ELSE 0 END
			,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
			,@DiscountPercentage			= (CASE WHEN ISNULL(D.[dblDiscount], @ZeroDecimal) > 0 
													THEN (1 - ((ABS(D.[dblTotal]) - ISNULL(D.[dblDiscount], @ZeroDecimal)) / ABS(D.[dblTotal]))) * 100
													ELSE @ZeroDecimal
											   END)
			,@ItemQtyShipped				= 1.000000
			,@ItemPrice						= ISNULL(D.[dblSubtotal], @ZeroDecimal)
			,@ItemDescription				= D.[strComment] 
			,@TaxGroupId					= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.[strTaxGroup]) ELSE 0 END
			,@AmountDue						= CASE WHEN D.[strTransactionType] <> 'Sales Order' THEN ISNULL(D.[dblAmountDue], @ZeroDecimal) ELSE @ZeroDecimal END
			,@TaxAmount						= ISNULL(D.[dblTax], @ZeroDecimal)
			,@Total							= ISNULL(D.[dblTotal], @ZeroDecimal)			
		FROM
			[tblARImportLogDetail] D
		INNER JOIN
			[tblARImportLog] H
				ON D.[intImportLogId] = H.[intImportLogId] 
		WHERE
			[intImportLogDetailId] = @ImportLogDetailId
	END

	IF @TransactionType <> 'Sales Order'
		BEGIN
			SELECT @ErrorMessage = 'Invoice:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strInvoiceNumber + '). ' FROM [tblARInvoice] WHERE RTRIM(LTRIM(ISNULL([strInvoiceOriginId],''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL([strInvoiceOriginId],'')))) > 0
		END
	ELSE
		BEGIN
			SELECT @ErrorMessage = 'Sales Order:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strSalesOrderNumber + '). ' FROM [tblSOSalesOrder] WHERE RTRIM(LTRIM(ISNULL([strSalesOrderOriginId],''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL([strSalesOrderOriginId],'')))) > 0
		END

	IF @IsTank = 1
		BEGIN
			IF @SiteId IS NULL
				SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Site Number provided does not exists. '
			ELSE
				BEGIN
					SELECT TOP 1 @TermId = intDeliveryTermID FROM tblTMSite WHERE intSiteID = @SiteId
					SELECT @DueDate = CAST(dbo.fnGetDueDateBasedOnTerm(@Date, @TermId) AS DATE)
					SELECT TOP 1 @TaxGroupId = ISNULL(intTaxGroupId, 0) FROM tblEntityLocation WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1					
					SELECT TOP 1 @BillingBy				= TMS.strBillingBy
								,@ItemId				= TMS.intProduct 
								,@ItemDescription		= I.strDescription
								,@PreviousMeterReading	= CCS.dblLastMeterReading
								,@ConversionFactor		= CCS.dblConversionFactor
					FROM tblTMSite TMS 
						INNER JOIN vyuARCustomerConsumptionSite CCS ON TMS.intSiteID = CCS.intSiteID
						LEFT JOIN tblICItem I ON TMS.intProduct = I.intItemId
					WHERE TMS.intSiteID = @SiteId

					IF @BillingBy = 'Tank'
						BEGIN
							SET @NewMeterReading	= NULL						
							SET @PerformerId		= NULL
						END
					ELSE IF @BillingBy IN ('Flow Meter', 'Virtual Meter')
						BEGIN
							SET @PercentFull		= NULL						
							SET @PerformerId		= NULL
						END
					ELSE IF @BillingBy = 'Service'
						BEGIN
							SET @NewMeterReading	= NULL
							SET @PercentFull		= NULL
						END
												
				END
		END
	ELSE
		BEGIN
			SET @SiteId					= NULL				
			SET @PerformerId			= NULL
			SET @PercentFull			= NULL
			SET @NewMeterReading		= NULL
			SET @PreviousMeterReading	= NULL
			SET @ConversionFactor		= NULL
			SET @BillingBy				= NULL
			SET @ItemId					= NULL
		END

	IF ISNULL(@TransactionType, '') = '' OR @TransactionType NOT IN('Invoice', 'Sales Order', 'Credit Memo', 'Tank Delivery')
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Transaction Type provided does not exists. '

	IF ISNULL(@EntityCustomerId, 0) = 0
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Customer Number provided does not exists. '

	IF ISNULL(@CompanyLocationId, 0) = 0
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Location Name provided does not exists. '
	
	IF @TermId IS NULL
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Term Code provided does not exists. '
	ELSE IF @TermId = 0 AND @IsTank = 0
		BEGIN
			SELECT TOP 1 @TermId = intTermsId FROM tblEntityLocation WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1
			IF ISNULL(@TermId, 0) = 0
				SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The customer provided doesn''t have default terms. '				
		END
	
	IF @FreightTermId IS NULL AND @IsTank = 0
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Freight Term provided does not exists. '
	ELSE IF @FreightTermId = 0
		SELECT TOP 1 @FreightTermId = intFreightTermId FROM tblEntityLocation WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1

	IF @ShipViaId IS NULL AND @IsTank = 0
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Ship Via provided does not exists. '
	ELSE IF @ShipViaId = 0
		SELECT TOP 1 @ShipViaId = intShipViaId FROM tblEntityLocation WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1

	IF @EntitySalespersonId IS NULL
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Salesperson provided does not exists. '
	ELSE IF @EntitySalespersonId = 0
		SELECT TOP 1 @EntitySalespersonId = intSalespersonId FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId

	IF @TaxGroupId IS NULL
		SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Tax Group provided does not exists. '
	ELSE IF @TaxGroupId = 0
		SET @TaxGroupId = NULL

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
						,[dtmDate]					= @Date
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
						,[intItemId]				= CASE WHEN @IsTank = 1 THEN @ItemId ELSE NULL END
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
						,[intSiteId]				= @SiteId
						,[strBillingBy]				= @BillingBy
						,[dblPercentFull]			= @PercentFull
						,[dblNewMeterReading]		= @NewMeterReading
						,[dblPreviousMeterReading]	= @PreviousMeterReading
						,[dblConversionFactor]		= @ConversionFactor
						,[intPerformerId]			= @PerformerId
						,[ysnLeaseBilling]			= NULL
						,[ysnVirtualMeterReading]	= CASE WHEN @BillingBy = 'Virtual Meter' THEN 1 ELSE 0 END
				
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
					DECLARE @computedDueDate DATETIME
					      , @shipToId		 INT
						  , @shipToName		 NVARCHAR(50)
						  , @shipToAddress	 NVARCHAR(300)
						  , @shipToCity		 NVARCHAR(100)
						  , @shipToState	 NVARCHAR(100)
						  , @shipToZipCode	 NVARCHAR(100)
						  , @shipToCountry	 NVARCHAR(100)

					SELECT @computedDueDate = dbo.fnGetDueDateBasedOnTerm(@Date, @TermId)
					SELECT TOP 1 
					       @shipToId		= intEntityLocationId
					     , @shipToName		= strLocationName
						 , @shipToAddress	= strAddress
						 , @shipToCity		= strCity
						 , @shipToState		= strState
						 , @shipToZipCode	= strZipCode
						 , @shipToCountry	= strCountry
					FROM tblEntityLocation WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1
					SET @DueDate = ISNULL(@DueDate, @computedDueDate)

					INSERT INTO tblSOSalesOrder 
						([strSalesOrderOriginId]
						,[intEntityCustomerId]
						,[dtmDate]
						,[dtmDueDate]
						,[intCurrencyId]
						,[intCompanyLocationId]
						,[intEntitySalespersonId]
						,[intShipViaId]
						,[strPONumber]
						,[intTermId]
						,[dblSalesOrderSubtotal]
						,[dblTax]
						,[dblSalesOrderTotal]
						,[dblDiscount]
						,[dblAmountDue]
						,[dblPayment]
						,[strTransactionType]
						,[strType]
						,[strOrderStatus]
						,[intAccountId]
						,[strBOLNumber]
						,[strComments]
						,[intFreightTermId]
						,[intEntityId]
						,[intShipToLocationId]
						,[intBillToLocationId]
						,[strShipToLocationName]
						,[strBillToLocationName]
						,[strShipToAddress]
						,[strBillToAddress]
						,[strShipToCity]
						,[strBillToCity]
						,[strShipToState]
						,[strBillToState]
						,[strShipToZipCode]
						,[strBillToZipCode]
						,[strShipToCountry]
						,[strBillToCountry])
					SELECT @OriginId
						, @EntityCustomerId
						, @Date
						, @DueDate
						, @DefaultCurrencyId
						, @CompanyLocationId
						, @EntitySalespersonId
						, @ShipViaId
						, @PONumber
						, @TermId
						, @ItemPrice
						, @TaxAmount
						, @Total
						, @DiscountAmount
					    , @ZeroDecimal
						, @ZeroDecimal
						, 'Order'
						, 'Standard'
						, 'Open'
						, @DefaultAccountId
						, @BOLNumber
						, @OriginId
						, @FreightTermId
						, @UserEntityId
						, @shipToId
						, @shipToId
						, @shipToName
						, @shipToName
						, @shipToAddress
						, @shipToAddress
						, @shipToCity
						, @shipToCity
						, @shipToState
						, @shipToState
						, @shipToZipCode
						, @shipToZipCode
						, @shipToCountry
						, @shipToCountry
					
					SET @NewTransactionId = SCOPE_IDENTITY()

					INSERT INTO tblSOSalesOrderDetail
						([intSalesOrderId]
					    ,[intItemId]
					    ,[strItemDescription]
					    ,[intItemUOMId]
					    ,[dblQtyOrdered]
					    ,[dblQtyAllocated]
					    ,[dblQtyShipped]
					    ,[dblDiscount]
					    ,[dblPrice]
					    ,[dblTotalTax]
					    ,[dblTotal])
					SELECT @NewTransactionId
					     , NULL
						 , @ItemDescription
						 , NULL
						 , @ItemQtyShipped
						 , @ZeroDecimal
						 , @ZeroDecimal
						 , @DiscountPercentage
						 , @ItemPrice
						 , @TaxAmount
						 , @Total
				END
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
		END CATCH
	
	DECLARE @isValidFiscalYear BIT = 1
	
	SELECT @isValidFiscalYear = CASE WHEN @TransactionType IN ('Invoice', 'Credit Memo') THEN dbo.isOpenAccountingDateByModule(@Date, 'Accounts Receivable') ELSE 1 END

	IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) > 0 AND @ErrorMessage <> 'Unable to find an open fiscal year period to match the transaction date.'
		BEGIN
			UPDATE tblARImportLogDetail
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= @ErrorMessage
			WHERE [intImportLogDetailId] = @ImportLogDetailId

			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - 1
			  , [intFailedCount]	= intFailedCount + 1
			WHERE [intImportLogId]  = @ImportLogId
		END
	ELSE IF(ISNULL(@NewTransactionId,0) <> 0) OR @ErrorMessage = 'Unable to find an open fiscal year period to match the transaction date.'
		BEGIN
			IF @TransactionType <> 'Sales Order'
				BEGIN
					UPDATE tblARImportLogDetail
					SET [ysnImported]		= 1
					   ,[strEventResult]	= CASE WHEN @TransactionType IN ('Invoice', 'Credit Memo') AND @ErrorMessage = 'Unable to find an open fiscal year period to match the transaction date.'
													THEN
														(SELECT TOP 1 strTransactionType + ':' + strInvoiceNumber FROM tblARInvoice ORDER BY intInvoiceId DESC) + ' Imported. But unable to post due to: ' + @ErrorMessage
													ELSE
														(SELECT strTransactionType + ':' + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewTransactionId) + ' Imported.'
												END
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