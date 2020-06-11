CREATE PROCEDURE [dbo].[uspARImportTransactionsCSV]
	 @ImportLogId			INT
	,@ImportFormat			NVARCHAR(50)
	,@ImportItemId			INT = NULL
	,@ImportLocationId		INT = NULL
	,@ConversionAccountId	INT = NULL
	,@IsTank				BIT = 0
	,@IsFromOldVersion		BIT = 0	
	,@UserEntityId			INT	= NULL
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
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

DECLARE @IMPORTFORMAT_STANDARD NVARCHAR(50) = 'Standard'
      , @IMPORTFORMAT_CARQUEST NVARCHAR(50) = 'CarQuest'

SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultAccountId = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference)

INSERT INTO @InvoicesForImport
SELECT intImportLogDetailId FROM tblARImportLogDetail
WHERE intImportLogId = @ImportLogId
	AND ISNULL(ysnSuccess,0) = 1
	AND ISNULL(ysnImported,0) = 0
ORDER BY intImportLogDetailId
	
WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicesForImport)
	BEGIN
		DECLARE @ImportLogDetailId INT
		SELECT TOP 1 @ImportLogDetailId = intImportLogDetailId FROM @InvoicesForImport ORDER BY intImportLogDetailId
		
		DELETE FROM @EntriesForInvoice

		DECLARE	@EntityCustomerId			INT
			,@Date							DATETIME
			,@CompanyLocationId				INT
			,@EntityId						INT
			,@NewTransactionId				INT				= NULL		
			,@ErrorMessage					NVARCHAR(250)	= NULL
			,@TermId						INT				= NULL
			,@EntitySalespersonId			INT				= NULL
			,@EntityContactId				INT				= NULL
			,@DueDate						DATETIME		= NULL		
			,@ShipDate						DATETIME		= NULL
			,@CalculatedDate				DATETIME		= NULL
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
			,@TaxClassId					INT				= NULL
			,@AmountDue						NUMERIC(18,6)	= @ZeroDecimal
			,@TaxAmount						NUMERIC(18,6)	= @ZeroDecimal
			,@Total							NUMERIC(18,6)	= @ZeroDecimal
			,@SiteId						INT				= NULL
			,@PerformerId					INT				= NULL
			,@PercentFull					NUMERIC(18,6)   = @ZeroDecimal
			,@NewMeterReading				NUMERIC(18,6)   = @ZeroDecimal
			,@PreviousMeterReading			NUMERIC(18,6)   = @ZeroDecimal
			,@ConversionFactor				NUMERIC(18,6)   = @ZeroDecimal	
			,@BillingBy						NVARCHAR(50)	= NULL
			,@COGSAmount					NUMERIC(18,6)   = @ZeroDecimal
			,@CustomerNumber				NVARCHAR(100)	= NULL
			,@ItemCategory					NVARCHAR(100)	= NULL
			,@intItemLocationId				INT				= NULL
			,@ysnAllowNegativeStock			BIT				= 0
			,@intStockUnit					INT				= NULL
			,@intCostingMethod				INT				= NULL
			,@ysnOrigin						BIT				= 0
			,@ysnRecap						BIT			 	= 0

		IF @IsTank = 1
			BEGIN
				SELECT 
					 @EntityCustomerId				= (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = D.strCustomerNumber)
					,@Date							= D.dtmDate
					,@ShipDate						= D.dtmDate		
					,@CompanyLocationId				= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = D.strLocationName)
					,@EntityId						= ISNULL(@UserEntityId, H.[intEntityId])				
					,@EntitySalespersonId			= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' AND @IsFromOldVersion = 1 THEN (SELECT TOP 1 [intEntityId] FROM tblARSalesperson WHERE intEntityId = CONVERT(INT, D.strSalespersonNumber)) END
					,@TransactionType				= 'Invoice'
					,@Type							= 'Tank Delivery'
					,@Comment						= D.strTransactionNumber
					,@OriginId						= D.strTransactionNumber
					,@BOLNumber						= D.strBOLNumber
					,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
					,@DiscountPercentage			= (CASE WHEN ISNULL(D.dblDiscount, @ZeroDecimal) > 0 
															THEN (1 - ((ABS(D.dblTotal) - ISNULL(D.dblDiscount, @ZeroDecimal)) / ABS(D.dblTotal))) * 100
															ELSE @ZeroDecimal
													   END)
					,@ItemQtyShipped				= ISNULL(D.dblQuantity, @ZeroDecimal)
					,@ItemPrice						= ISNULL(D.dblSubtotal, @ZeroDecimal)				
					,@ItemId						= CASE WHEN @IsFromOldVersion = 1 THEN
															(SELECT TOP 1 intItemId FROM tblICItem WHERE intItemId = CONVERT(INT,D.strItemNumber))															
														ELSE
															(SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = D.strItemNumber)
													  END
					,@TaxGroupId					= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.strTaxGroup) ELSE 0 END
					,@AmountDue						= CASE WHEN D.strTransactionType <> 'Sales Order' THEN ISNULL(D.dblAmountDue, @ZeroDecimal) ELSE @ZeroDecimal END
					,@Total							= ISNULL(D.dblQuantity, @ZeroDecimal) * ISNULL(D.dblSubtotal, @ZeroDecimal)
					,@SiteId						= (SELECT TOP 1 intSiteID FROM tblTMSite WHERE intSiteNumber = CONVERT(INT, D.strSiteNumber))
					,@PerformerId					= NULL
					,@PercentFull					= ISNULL(D.dblPercentFull, @ZeroDecimal)
					,@NewMeterReading				= ISNULL(D.dblNewMeterReading, @ZeroDecimal)
					,@ysnRecap						= H.ysnRecap	
				FROM
					[tblARImportLogDetail] D
				INNER JOIN
					[tblARImportLog] H
						ON D.[intImportLogId] = H.[intImportLogId] 
				WHERE
					[intImportLogDetailId] = @ImportLogDetailId

				IF @SiteId IS NULL
					SET @ErrorMessage = 'The Site Number provided does not exists. '
				ELSE
					BEGIN
						SELECT TOP 1 @TermId = intDeliveryTermID FROM tblTMSite WHERE intSiteID = @SiteId
						SELECT @DueDate = CAST(dbo.fnGetDueDateBasedOnTerm(@Date, @TermId) AS DATE)
						SELECT TOP 1 @TaxGroupId = ISNULL(intTaxGroupId, 0) FROM [tblEMEntityLocation] WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1					
						SELECT TOP 1 @BillingBy				= TMS.strBillingBy
									,@ItemId				= TMS.intProduct 
									,@ItemDescription		= I.strDescription
									,@PreviousMeterReading	= CCS.dblLastMeterReading
									,@ConversionFactor		= CCS.dblConversionFactor
						FROM tblTMSite TMS 
							INNER JOIN vyuARCustomerConsumptionSite CCS ON TMS.intSiteID = CCS.intSiteID
							LEFT JOIN tblICItem I ON TMS.intProduct = I.intItemId
						WHERE TMS.intSiteID = @SiteId

						IF @IsFromOldVersion = 0
							BEGIN
								SELECT TOP 1 @EntitySalespersonId = intDriverID FROM tblTMDispatch WHERE intSiteID = @SiteId
								SELECT @EntitySalespersonId = (SELECT ISNULL(@EntitySalespersonId, 0))
							END

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

				UPDATE tblARImportLogDetail SET dblTotal = @Total, strTransactionType = 'Invoice' WHERE intImportLogDetailId = @ImportLogDetailId
			END
		ELSE IF @ImportFormat = @IMPORTFORMAT_CARQUEST
			BEGIN
				SELECT 
					  @EntityCustomerId				= C.[intEntityId]
					, @CustomerNumber				= C.strCustomerNumber
					, @Date							= ILD.dtmDate
					, @PostDate						= NULL
					, @ShipDate						= ILD.dtmShipDate
					, @CompanyLocationId			= CL.intCompanyLocationId
					, @EntityId						= ISNULL(@UserEntityId, IL.intEntityId)
					, @EntitySalespersonId			= SP.[intEntityId]
					, @TermId						= C.intTermsId
					, @DueDate						= dbo.fnGetDueDateBasedOnTerm(ILD.dtmDate, C.intTermsId)
					, @TransactionType				= ILD.strTransactionType
					, @Type							= ISNULL(ILD.strSourceType,@Type)
					, @Comment						= @IMPORTFORMAT_CARQUEST + ' ' + ILD.strTransactionType + ' ' + ILD.strTransactionNumber
					, @OriginId						= ILD.strTransactionNumber
					, @DiscountAmount				= ISNULL(ABS(ILD.dblDiscount), @ZeroDecimal)
					, @DiscountPercentage			= (CASE WHEN ISNULL(ILD.dblDiscount, @ZeroDecimal) > 0 
															THEN (1 - ((ABS(ILD.dblTotal) - ISNULL(ILD.dblDiscount, @ZeroDecimal)) / ABS(ILD.dblTotal))) * 100
															ELSE @ZeroDecimal
													   END)
					, @ItemQtyShipped				= 1
					, @ItemId						= ICI.intItemId
					, @ItemPrice					= ABS(ISNULL(ILD.dblSubtotal, @ZeroDecimal))
					, @ItemDescription				= ICI.strDescription
					, @TaxGroupId					= TGC.intTaxGroupId
					, @TaxClassId					= CATEGORYTAX.intTaxClassId
					, @ItemCategory                 = ISNULL(ICC.strCategoryCode, '') + ' - ' + ISNULL(ICC.strDescription, '')
					, @Total						= ABS(ILD.dblTotal)
					, @COGSAmount					= ABS(ILD.dblCOGSAmount)
					, @FreightTermId				= ISNULL(EL.intFreightTermId, 0)
					, @ShipViaId					= ISNULL(EL.intShipViaId, 0)
					, @TaxAmount					= ABS(ILD.dblTax)
					, @intItemLocationId			= ICIL.intItemLocationId
					, @ysnAllowNegativeStock		= (CASE WHEN ICIL.intAllowNegativeInventory = 1 THEN 1 ELSE 0 END)
					, @intStockUnit					= ICUOM.intItemUOMId
					, @intCostingMethod				= ICIL.intCostingMethod
					,@ysnRecap						= H.ysnRecap	
				FROM
					tblARImportLogDetail ILD
				INNER JOIN
					[tblARImportLog] H
						ON ILD.[intImportLogId] = H.[intImportLogId] 
				INNER JOIN
					tblARImportLog IL
						ON ILD.intImportLogId = IL.intImportLogId
				LEFT JOIN
					(tblARCustomer C
						INNER JOIN tblEMEntity EC
							ON C.[intEntityId] = EC.intEntityId
						INNER JOIN tblEMEntityLocation EL
							ON C.[intEntityId] = EL.intEntityId
							AND EL.ysnDefaultLocation = 1)
						ON ILD.strCustomerNumber = EC.strEntityNo
				LEFT JOIN
					tblSMCompanyLocation CL
						ON CL.intCompanyLocationId = @ImportLocationId
				LEFT JOIN
					(tblARSalesperson SP 
						INNER JOIN tblEMEntity ESP
							ON SP.[intEntityId] = ESP.intEntityId)
						ON ILD.strSalespersonNumber = ESP.strEntityNo
				LEFT JOIN
					tblICItem ICI
						ON ICI.intItemId = @ImportItemId
						AND ICI.strType = 'Inventory'
				LEFT JOIN
					tblICCategory ICC
						ON ICI.intCategoryId = ICC.intCategoryId
				CROSS APPLY
					(SELECT TOP 1 intCategoryId, intTaxClassId
					FROM tblICCategoryTax 
					WHERE intCategoryId = ICI.intCategoryId
					) CATEGORYTAX
				CROSS APPLY
					(SELECT TOP 1 intTaxCodeId, intTaxClassId
					FROM tblSMTaxCode
					WHERE intTaxClassId = CATEGORYTAX.intTaxClassId
					) TC
				LEFT JOIN
					tblSMTaxGroupCode TGC ON TC.intTaxCodeId = TGC.intTaxCodeId
				LEFT JOIN
					tblICItemLocation ICIL 
						ON ICIL.intItemId = ICI.intItemId 
						AND ICIL.intLocationId = @ImportLocationId
				LEFT JOIN
					tblICItemUOM ICUOM
						ON ICUOM.intItemId = ICI.intItemId						
						AND ICUOM.ysnStockUnit = 1
				WHERE 
					ILD.intImportLogDetailId = @ImportLogDetailId
			END
		ELSE
			BEGIN
				SELECT 
					 @EntityCustomerId				= (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = D.strCustomerNumber)
					,@Date							= D.dtmDate
					,@CompanyLocationId				= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = D.strLocationName)
					,@EntityId						= ISNULL(@UserEntityId, H.intEntityId)
					,@TermId						= CASE WHEN ISNULL(D.strTerms, '') <> '' THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = D.strTerms) ELSE 0 END
					,@EntitySalespersonId			= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' THEN (SELECT TOP 1 SP.[intEntityId] FROM tblARSalesperson SP INNER JOIN tblEMEntity E ON SP.[intEntityId] = E.intEntityId WHERE E.strEntityNo = D.strSalespersonNumber) ELSE 0 END
					,@DueDate						= D.dtmDueDate		
					,@ShipDate						= D.dtmShipDate
					,@CalculatedDate				= D.dtmCalculated
					,@PostDate						= D.dtmPostDate 
					,@TransactionType				= D.strTransactionType
					,@Type							= ISNULL(D.strSourceType,@Type)
					,@Comment						= D.strTransactionNumber
					,@OriginId						= D.strTransactionNumber
					,@PONumber						= D.strPONumber
					,@BOLNumber						= D.strBOLNumber
					,@FreightTermId					= CASE WHEN ISNULL(D.strFreightTerm, '') <> '' THEN (SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = D.strFreightTerm) ELSE 0 END
					,@ShipViaId						= CASE WHEN ISNULL(D.strShipVia, '') <> '' THEN (SELECT TOP 1 [intEntityId] FROM tblSMShipVia WHERE strShipVia = D.strShipVia)	ELSE 0 END
					,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
					,@DiscountPercentage			= (CASE WHEN ISNULL(D.dblDiscount, @ZeroDecimal) > 0 
															THEN (1 - ((ABS(D.dblTotal) - ISNULL(D.dblDiscount, @ZeroDecimal)) / ABS(D.dblTotal))) * 100
															ELSE @ZeroDecimal
													   END)
					,@ItemQtyShipped				= 1.000000
					,@ItemPrice						= ISNULL(D.[dblSubtotal], @ZeroDecimal)
					,@ItemDescription				= D.strComment
					,@TaxGroupId					= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.strTaxGroup) ELSE 0 END
					,@AmountDue						= CASE WHEN D.strTransactionType <> 'Sales Order' THEN ISNULL(D.dblAmountDue, @ZeroDecimal) ELSE @ZeroDecimal END
					,@TaxAmount						= ISNULL(D.dblTax, @ZeroDecimal)
					,@Total							= ISNULL(D.dblTotal, @ZeroDecimal)
					,@ysnOrigin						= D.ysnOrigin
					,@ysnRecap						= H.ysnRecap			
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
				SELECT @ErrorMessage = 'Invoice:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strInvoiceNumber + '). ' FROM tblARInvoice WHERE RTRIM(LTRIM(ISNULL(strInvoiceOriginId,''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) 
				AND @EntityCustomerId = intEntityCustomerId  AND @CompanyLocationId	= intCompanyLocationId 
				AND @Date = dtmDate AND @TransactionType = strTransactionType AND LEN(RTRIM(LTRIM(ISNULL(strInvoiceOriginId,'')))) > 0
			END
		ELSE
			BEGIN
				SELECT @ErrorMessage = 'Sales Order:' + RTRIM(LTRIM(ISNULL(@OriginId,''))) + ' was already imported! (' + strSalesOrderNumber + '). ' FROM tblSOSalesOrder WHERE RTRIM(LTRIM(ISNULL(strSalesOrderOriginId,''))) = RTRIM(LTRIM(ISNULL(@OriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL(strSalesOrderOriginId,'')))) > 0
			END
					
		IF ISNULL(@TransactionType, '') = '' OR @TransactionType NOT IN('Invoice', 'Sales Order', 'Credit Memo', 'Tank Delivery', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment')
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Transaction Type provided does not exists. '

		IF ISNULL(@EntityCustomerId, 0) = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Customer Number provided does not exists. '

		IF ISNULL(@CompanyLocationId, 0) = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Location Name provided does not exists. '
	
		IF @TermId IS NULL
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Term Code provided does not exists. '
		ELSE IF @TermId = 0 AND @IsTank = 0
			BEGIN
				SELECT TOP 1 @TermId = intTermsId FROM [tblARCustomer] WHERE [intEntityId] = @EntityCustomerId  
				IF ISNULL(@TermId, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The customer provided doesn''t have default terms. '				
			END
	
		IF @FreightTermId IS NULL AND @IsTank = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Freight Term provided does not exists. '
		ELSE IF @FreightTermId = 0
			SELECT TOP 1 @FreightTermId = intFreightTermId FROM [tblEMEntityLocation] WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1

		IF @ShipViaId IS NULL AND @IsTank = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Ship Via provided does not exists. '
		ELSE IF @ShipViaId = 0
			SELECT TOP 1 @ShipViaId = intShipViaId FROM [tblEMEntityLocation] WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1

		IF @EntitySalespersonId IS NULL
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'The Salesperson provided does not exists. '
		ELSE IF @EntitySalespersonId = 0
			SELECT TOP 1 @EntitySalespersonId = intSalespersonId FROM tblARCustomer WHERE [intEntityId] = @EntityCustomerId

		IF @TaxGroupId IS NULL
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 
								CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST
									THEN 'Category ' + @ItemCategory + ' doesn''t have default tax class set up.'
									ELSE 'The Tax Group provided does not exists. '
								END									
		ELSE IF @TaxGroupId = 0
			SET @TaxGroupId = NULL
			
		IF @ImportFormat = @IMPORTFORMAT_CARQUEST
			BEGIN
				IF ISNULL(@ItemId, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item is required.'

				IF ISNULL(@TaxGroupId, 0) > 0 AND NOT EXISTS (SELECT NULL FROM tblSMTaxGroupCode WHERE intTaxGroupId = @TaxGroupId)
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Tax Group must have atleast (1) one Tax Code setup.'
				
				IF ISNULL(@TaxClassId, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item Category doesn''t have default tax class set up.'

				IF ISNULL(@intItemLocationId, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item Location for the selected item is required.'

				IF ISNULL(@ysnAllowNegativeStock, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item should allow negative stock.'

				IF ISNULL(@intStockUnit, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item''s stock unit should not be null.'

				IF ISNULL(@intCostingMethod, 0) = 0
					SET @ErrorMessage = ISNULL(@ErrorMessage, '') + 'Item''s location costing method should be either FIFO or LIFO.'
			END

		SELECT TOP 1 @EntityContactId = intEntityContactId FROM vyuARCustomerSearch WHERE [intEntityId] = @EntityCustomerId

		IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1 and @ysnRecap = 0
			BEGIN TRY
				IF @TransactionType <> 'Sales Order'
					BEGIN
						INSERT INTO @EntriesForInvoice(
							 [strSourceTransaction]
							,[strTransactionType]
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
							,[dtmCalculated]
							,[dtmPostDate]
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
							,[intLoadId]
							,[strActualCostId]
							,[intShipmentId]
							,[intTransactionId]
							,[intEntityId]
							,[ysnResetDetails]
							,[ysnPost]
							,[ysnImportedFromOrigin]
							,[ysnImportedAsPosted]
							,[intInvoiceDetailId]
							,[intItemId]
							,[ysnInventory]
							,[strItemDescription]
							,[intOrderUOMId]
							,[dblQtyOrdered]
							,[intItemUOMId]
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
							,[strImportFormat]
							,[dblCOGSAmount]
							,[intTempDetailIdForTaxes]
							,[intConversionAccountId]
							,[intCurrencyExchangeRateTypeId]
							,[intCurrencyExchangeRateId]
							,[dblCurrencyExchangeRate]
							,[intSubCurrencyId]
							,[dblSubCurrencyRate]
							,[ysnUseOriginIdAsInvoiceNumber]
						)
						SELECT 
							 [strSourceTransaction]		= 'Import'
							,[strTransactionType]		= @TransactionType
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
							,[dtmCalculated]			= @CalculatedDate
							,[dtmPostDate]				= @PostDate
							,[intEntitySalespersonId]	= @EntitySalespersonId
							,[intFreightTermId]			= @FreightTermId
							,[intShipViaId]				= @ShipViaId
							,[intPaymentMethodId]		= NULL
							,[strInvoiceOriginId]		= @OriginId
							,[strPONumber]				= @PONumber
							,[strBOLNumber]				= @BOLNumber
							,[strComments]				= @Comment
							,[intShipToLocationId]		= NULL
							,[intBillToLocationId]		= NULL
							,[ysnTemplate]				= 0
							,[ysnForgiven]				= 0
							,[ysnCalculated]			= CASE WHEN @CalculatedDate IS NULL THEN 0 ELSE 1 END
							,[ysnSplitted]				= 0
							,[intPaymentId]				= NULL
							,[intSplitId]				= NULL
							,[intLoadDistributionHeaderId]	= NULL
							,[intLoadId]				= NULL
							,[strActualCostId]			= NULL
							,[intShipmentId]			= NULL
							,[intTransactionId]			= NULL
							,[intEntityId]				= @EntityId
							,[ysnResetDetails]			= 1
							,[ysnPost]					= CASE WHEN isnull(@ysnOrigin, 0) = 1 
															THEN NULL
															ELSE  
																CASE WHEN @TransactionType IN ('Customer Prepayment', 'Overpayment') THEN 0
																ELSE CASE WHEN @PostDate IS NULL THEN 0 
																	 ELSE 1 
															    END
															END
														  END 
							,[ysnImportedFromOrigin]	= CASE WHEN @ysnOrigin = 1 THEN 1 ELSE 0 END
							,[ysnImportedAsPosted]		= CASE WHEN @ysnOrigin = 1 THEN 1 ELSE 0 END
							,[intInvoiceDetailId]		= NULL
							,[intItemId]				= CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @ItemId ELSE NULL END
							,[ysnInventory]				= CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST AND ISNULL(@ItemId, 0) > 0 THEN 
															CASE WHEN (SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @ItemId) = 'Inventory' THEN 1 ELSE 0 END
														  ELSE 0 END
							,[strItemDescription]		= @ItemDescription
							,[intOrderUOMId]			= NULL
							,[dblQtyOrdered]			= @ItemQtyShipped
							,[intItemUOMId]				= NULL
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
							,[ysnRecomputeTax]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST 
															   THEN 0 
															   ELSE CASE WHEN ISNULL(@TaxGroupId, 0) > 0 THEN 1 ELSE 0 END
														  END
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
							,[strImportFormat]			= @ImportFormat
							,[dblCOGSAmount]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END
							,[intTempDetailIdForTaxes]  = @ImportLogDetailId
							,[intConversionAccountId]	= @ConversionAccountId
							,[intCurrencyExchangeRateTypeId]	= NULL
							,[intCurrencyExchangeRateId]		= NULL
							,[dblCurrencyExchangeRate]	= 1.000000
							,[intSubCurrencyId]			= NULL
							,[dblSubCurrencyRate]		= 1.000000
							,[ysnUseOriginIdAsInvoiceNumber] = CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST AND (@OriginId IS NOT NULL  AND  @CustomerNumber <> '9998') THEN 1 ELSE 0 END
				
						IF @ImportFormat = @IMPORTFORMAT_CARQUEST
							BEGIN
								INSERT INTO @TaxDetails(
									[intDetailId] 
								  , [intTaxGroupId]
								  , [intTaxCodeId]
								  , [intTaxClassId]
								  , [strTaxableByOtherTaxes]
								  , [strCalculationMethod]
								  , [dblRate]
								  , [intTaxAccountId]
								  , [dblTax]
								  , [dblAdjustedTax]
								  , [ysnTaxAdjusted]
								  , [ysnSeparateOnInvoice]
								  , [ysnCheckoffTax]
								  , [ysnTaxExempt]
								  , [ysnTaxOnly]
								  , [strNotes]
								  , [intTempDetailIdForTaxes])
								SELECT  TOP 1
								    [intDetailId]				= NULL
								  , [intTaxGroupId]				= TGC.intTaxGroupId
								  , [intTaxCodeId]				= TGC.intTaxCodeId
								  , [intTaxClassId]				= TC.intTaxClassId
								  , [strTaxableByOtherTaxes]	= TC.strTaxableByOtherTaxes
								  , [strCalculationMethod]		= TCR.strCalculationMethod
								  , [dblRate]					= TCR.dblRate
								  , [intTaxAccountId]			= TC.intSalesTaxAccountId
								  , [dblTax]					= 0
								  , [dblAdjustedTax]			= @TaxAmount
								  , [ysnTaxAdjusted]			= 1
								  , [ysnSeparateOnInvoice]		= 0 
								  , [ysnCheckoffTax]			= TC.ysnCheckoffTax
								  , [ysnTaxExempt]				= CASE WHEN ISNULL(@TaxAmount, 0) > 0 THEN 0 ELSE 1 END
								  , [ysnTaxOnly]				= TC.ysnTaxOnly
								  , [strNotes]					= NULL
								  , [intTempDetailIdForTaxes]	= @ImportLogDetailId
								FROM tblSMTaxGroupCode TGC
									INNER JOIN tblSMTaxCode TC
										ON TGC.intTaxCodeId = TC.intTaxCodeId
									INNER JOIN tblSMTaxCodeRate TCR
										ON TC.intTaxCodeId = TCR.intTaxCodeId
								WHERE TGC.intTaxGroupId = @TaxGroupId 
								  AND TC.intTaxClassId = @TaxClassId
							END
						
						EXEC [dbo].[uspARProcessInvoices]
							 @InvoiceEntries	 = @EntriesForInvoice
							,@LineItemTaxEntries = @TaxDetails
							,@UserId			 = @EntityId
		 					,@GroupingOption	 = 11
							,@FromImportTransactionCSV = 1
							,@RaiseError		 = 1
							,@ErrorMessage		 = @ErrorMessage OUTPUT
							,@CreatedIvoices	 = @CreatedIvoices OUTPUT
			
						SET @NewTransactionId = (SELECT TOP 1 intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))

						IF ISNULL(@NewTransactionId, 0) > 0
							BEGIN
								UPDATE tblARInvoice 
								SET intEntitySalespersonId = @EntitySalespersonId
								  , strType = CASE WHEN @IsTank = 1 THEN 'Tank Delivery' ELSE @Type END
								WHERE intInvoiceId = @NewTransactionId

								IF @ImportFormat = @IMPORTFORMAT_CARQUEST
									BEGIN
										DECLARE @invoiceToPost	NVARCHAR(MAX)
										SET @invoiceToPost = CONVERT(NVARCHAR(MAX), @NewTransactionId)

										UPDATE tblICItemPricing SET dblLastCost = @COGSAmount WHERE intItemId = @ImportItemId AND intItemLocationId = @intItemLocationId

										EXEC dbo.uspARPostInvoice @post = 1, @recap = 0, @param = @invoiceToPost, @userId = @UserEntityId
									END
							END
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
						FROM [tblEMEntityLocation] WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1
						SET @DueDate = ISNULL(@DueDate, @computedDueDate)

						INSERT INTO tblSOSalesOrder 
							([strSalesOrderOriginId]
							,[intEntityCustomerId]
							,[dtmDate]
							,[dtmDueDate]
							,[intCurrencyId]
							,[intCompanyLocationId]
							,[intEntitySalespersonId]
							,[intEntityContactId]
							,[intOrderedById]
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
						SELECT NULL
							, @EntityCustomerId
							, @Date
							, @DueDate
							, @DefaultCurrencyId
							, @CompanyLocationId
							, @EntitySalespersonId
							, @EntityContactId
							, @UserEntityId
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
							, NULL
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
	
		SELECT @isValidFiscalYear = CASE WHEN @TransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN dbo.isOpenAccountingDateByModule(@Date, 'Accounts Receivable') ELSE 1 END

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
						   ,[strEventResult]	= CASE WHEN @TransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment') AND @ErrorMessage = 'Unable to find an open fiscal year period to match the transaction date.'
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

		UPDATE tblARImportLogDetail SET [intConversionAccountId] = @ConversionAccountId  WHERE intImportLogDetailId = @ImportLogDetailId
		
		DELETE FROM @InvoicesForImport WHERE [intImportLogDetailId] = @ImportLogDetailId

	END

END