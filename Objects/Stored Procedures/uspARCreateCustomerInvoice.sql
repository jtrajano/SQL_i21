CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId				INT
	,@CompanyLocationId				INT
	,@CurrencyId					INT				= NULL
	,@TermId						INT				= NULL
	,@AccountId						INT				= NULL
	,@EntityId						INT
	,@InvoiceDate					DATETIME	
	,@DueDate						DATETIME		= NULL
	,@ShipDate						DATETIME		= NULL	
	,@CalculatedDate				DATETIME		= NULL
	,@PostDate						DATETIME		= NULL
	,@TransactionType				NVARCHAR(50)	= 'Invoice'
	,@Type							NVARCHAR(200)	= 'Standard'
	,@NewInvoiceId					INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0			
	,@EntitySalespersonId			INT				= NULL
	,@EntityContactId				INT				= NULL				
	,@FreightTermId					INT				= NULL
	,@ShipViaId						INT				= NULL
	,@PaymentMethodId				INT				= NULL
	,@InvoiceOriginId				NVARCHAR(25)	= NULL
	,@MobileBillingShiftNo			NVARCHAR(50)	= NULL
	,@PONumber						NVARCHAR(50)	= ''
	,@BOLNumber						NVARCHAR(50)	= ''
	,@Comment						NVARCHAR(MAX)	= ''
	,@FooterComment					NVARCHAR(MAX)	= ''
	,@ShipToLocationId				INT				= NULL
	,@BillToLocationId				INT				= NULL
	,@Posted						BIT				= 0	
	,@ImportedFromOrigin 			BIT				= 0
	,@ImportedAsPosted				BIT				= 0
	,@FromProvisional				BIT				= 0
	,@ServiceChargeCredit			BIT				= 0
	,@Template						BIT				= 0			
	,@Forgiven						BIT				= 0			
	,@Calculated					BIT				= 0			
	,@Splitted						BIT				= 0			
	,@ImpactInventory				BIT				= 1			
	,@PaymentId						INT				= NULL
	,@SplitId						INT				= NULL
	,@LoadDistributionHeaderId		INT				= NULL
	,@ActualCostId					NVARCHAR(50)	= NULL			
	,@ShipmentId					INT				= NULL
	,@TransactionId					INT				= NULL
	,@MeterReadingId				INT				= NULL
	,@OriginalInvoiceId				INT				= NULL
	,@LoadId                        INT             = NULL
	,@PeriodsToAccrue				INT				= 1
	,@SourceId						INT				= 0
	,@ImportFormat                  NVARCHAR(50)    = NULL		
	,@TruckDriverId					INT				= NULL
	,@TruckDriverReferenceId		INT				= NULL
	,@ItemId						INT				= NULL
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@ItemIsInventory				BIT				= 0
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemOrderUOMId				INT				= NULL
	,@ItemQtyOrdered				NUMERIC(38,20)	= 0.000000
	,@ItemUOMId						INT				= NULL
	,@ItemPriceUOMId				INT				= NULL
	,@ItemQtyShipped				NUMERIC(38,20)	= 0.000000
	,@ItemUnitQuantity				NUMERIC(38,20)	= 1.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
	,@ItemPrice						NUMERIC(18,6)	= 0.000000	
	,@ItemUnitPrice					NUMERIC(18,6)	= 0.000000	
	,@RefreshPrice					BIT				= 0
	,@AllowRePrice					BIT				= 0
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000
	,@ItemTaxGroupId				INT				= NULL
	,@ItemStorageLocationId			INT				= NULL
	,@ItemCompanyLocationSubLocationId	INT				= NULL
	,@RecomputeTax					BIT				= 1
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemInventoryShipmentChargeId	INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemSubFormula				NVARCHAR(50)	= NULL
	,@ItemRecipeItemId				INT				= NULL
	,@ItemRecipeId					INT				= NULL
	,@ItemSublocationId				INT				= NULL
	,@ItemCostTypeId				INT				= NULL
	,@ItemMarginById				INT				= NULL
	,@ItemCommentTypeId				INT				= NULL
	,@ItemMargin					NUMERIC(18,6)	= NULL
	,@ItemRecipeQty					NUMERIC(18,6)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
	,@ItemWeightUOMId				INT				= NULL	
	,@ItemWeight					NUMERIC(38,20)	= 0.000000		
	,@ItemShipmentGrossWt			NUMERIC(38,20)	= 0.000000		
	,@ItemShipmentTareWt			NUMERIC(38,20)	= 0.000000		
	,@ItemShipmentNetWt				NUMERIC(38,20)	= 0.000000			
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL		
	,@ItemCustomerStorageId			INT				= NULL		
	,@ItemSiteDetailId				INT				= NULL		
	,@ItemLoadDetailId				INT				= NULL		
	,@ItemLotId						INT				= NULL		
	,@ItemOriginalInvoiceDetailId	INT				= NULL		
	,@ItemSiteId					INT				= NULL												
	,@ItemBillingBy					NVARCHAR(200)	= NULL
	,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId				INT				= NULL
	,@ItemLeaseBilling				BIT				= 0
	,@ItemVirtualMeterReading		BIT				= 0
	,@ItemConversionAccountId		INT				= NULL
	,@ItemSalesAccountId			INT				= NULL
	,@ItemCurrencyExchangeRateTypeId	INT				= NULL
	,@ItemCurrencyExchangeRateId	INT				= NULL
	,@ItemCurrencyExchangeRate		NUMERIC(18,8)	= 1.000000
	,@ItemSubCurrencyId				INT				= NULL
	,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
	,@DocumentMaintenanceId			INT				= NULL
	,@ItemStorageScheduleTypeId		INT				= NULL
	,@ItemDestinationGradeId		INT				= NULL
	,@ItemDestinationWeightId		INT				= NULL
	,@UseOriginIdAsInvoiceNumber    BIT				= 0
	,@intLineOfBusinessId			INT				= NULL
	,@intICTId						INT				= NULL
	,@intSalesOrderId				INT				= NULL
	,@ItemAddonDetailKey			NVARCHAR(100)	= NULL
	,@ItemAddonParent				BIT				= NULL
	,@ItemAddOnQuantity				NUMERIC(38,20)	= NULL
	,@PaidCPP						BIT				= 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@DefaultCurrency INT
		,@ARAccountId INT
		,@InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARCreateCustomerInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
		

SET @ZeroDecimal = 0.000000
SELECT @DateOnly = CAST(GETDATE() AS DATE)

IF ISNULL(@Comment, '') = ''
	BEGIN
		EXEC	[dbo].[uspARGetDefaultComment]
					@intCompanyLocationId = @CompanyLocationId,
					@intEntityCustomerId = @EntityCustomerId,
					@strTransactionType = @TransactionType,
					@strType = @Type,
					@strHeaderComment = @Comment OUTPUT,
					@DocumentMaintenanceId = @DocumentMaintenanceId,
					@intDocumentUsedId = @DocumentMaintenanceId OUTPUT
	END
IF ISNULL(@FooterComment, '') = ''
	BEGIN
		EXEC	[dbo].[uspARGetDefaultComment]
					@intCompanyLocationId = @CompanyLocationId,
					@intEntityCustomerId = @EntityCustomerId,
					@strTransactionType = @TransactionType,
					@strType = @Type,
					@strFooterComment = @FooterComment OUTPUT,
					@DocumentMaintenanceId = @DocumentMaintenanceId
	END

IF(ISNULL(@DocumentMaintenanceId, 0) > 0)
BEGIN
	EXEC	[dbo].[uspARGetDefaultComment]
		@intCompanyLocationId = @CompanyLocationId,
		@intEntityCustomerId = @EntityCustomerId,
		@strTransactionType = @TransactionType,
		@strType = @Type,
		@strHeaderComment = @Comment OUTPUT,
		@strFooterComment = @FooterComment OUTPUT,
		@DocumentMaintenanceId = @DocumentMaintenanceId
END

IF ISNULL(@EntityContactId, 0) = 0
	BEGIN
		SELECT TOP 1 @EntityContactId = intEntityContactId FROM vyuEMEntityContact WHERE intEntityId = @EntityCustomerId AND ysnDefaultContact = 1 AND Customer = 1
	END

IF ISNULL(@TransactionType, '') = ''
	SET @TransactionType = 'Invoice'

IF ISNULL(@Type, '') = ''
	SET @Type = 'Standard'


IF @AccountId IS NOT NULL
	SET @ARAccountId = @AccountId
ELSE
	SET @ARAccountId = [dbo].[fnARGetInvoiceTypeAccount](@TransactionType, @CompanyLocationId)


IF @ARAccountId IS NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash')
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There is no setup for AR Account in the Company Configuration.', 16, 1);
		SET @ErrorMessage = 'There is no setup for AR Account in the Company Configuration.'
		RETURN 0;
	END

IF @ARAccountId IS NOT NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund') AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'AR Account' AND [intAccountId] =  @ARAccountId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The account id provided is not a valid account of category "AR Account".', 16, 1);
		SET @ErrorMessage = 'The account id provided is not a valid account of category "AR Account".'
		RETURN 0;
	END

DECLARE @CompanyLocation NVARCHAR(250)
IF @ARAccountId IS NULL AND @TransactionType = 'Cash'
	BEGIN
		SELECT TOP 1 @CompanyLocation = [strLocationName] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There is no Undeposited Funds account setup under Company Location - %s.', 16, 1, @CompanyLocation);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('There is no Undeposited Funds account setup under Company Location - %s.', @CompanyLocation, DEFAULT)
		RETURN 0;
	END

IF @ARAccountId IS NULL AND @TransactionType = 'Cash Refund'
	BEGIN
		SELECT TOP 1 @CompanyLocation = [strLocationName] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There is no AP account setup under Company Location - %s.', 16, 1, @CompanyLocation);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('There is no AP account setup under Company Location - %s.', @CompanyLocation, DEFAULT)
		RETURN 0;
	END

IF @ARAccountId IS NOT NULL AND @TransactionType = 'Cash' AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'Undeposited Funds' AND [intAccountId] =  @ARAccountId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There account id provided is not a valid account of category "Undeposited Funds".', 16, 1);
		SET @ErrorMessage = 'There account id provided is not a valid account of category "Undeposited Funds".'
		RETURN 0;
	END

IF @ARAccountId IS NOT NULL AND @TransactionType = 'Cash Refund' AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'AP Account' AND [intAccountId] =  @ARAccountId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There account id provided is not a valid account of category "AP Account".', 16, 1);
		SET @ErrorMessage = 'There account id provided is not a valid account of category "AP Account".'
		RETURN 0;
	END

IF @ARAccountId IS NULL AND @TransactionType = 'Customer Prepayment'
	BEGIN		
		SELECT TOP 1 @CompanyLocation = [strLocationName] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There is no Customer Prepaid account setup under Company Location - %s.', 16, 1, @CompanyLocation);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('There is no Customer Prepaid account setup under Company Location - %s.', @CompanyLocation, DEFAULT) 
		RETURN 0;
	END

IF  @TransactionType = 'Customer Prepayment' AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'Customer Prepayments' AND [intAccountId] =  @ARAccountId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There account id provided is not a valid account of category "Customer Prepayments".', 16, 1);
		SET @ErrorMessage = 'There account id provided is not a valid account of category "Customer Prepayments".'
		RETURN 0;
	END

	
IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @EntityCustomerId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The customer Id provided does not exists!', 16, 1);
		SET @ErrorMessage = 'The customer Id provided does not exists!'
		RETURN 0;
	END

IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @EntityCustomerId AND ysnActive = 1)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The customer provided is not active!', 16, 1);
		SET @ErrorMessage = 'The customer provided is not active!'
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The company location Id provided does not exists!', 16, 1);		
		SET @ErrorMessage = 'The company location Id provided does not exists!'
		RETURN 0;
	END	

IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId AND ysnLocationActive = 1)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The company location provided is not active!', 16, 1);
		SET @ErrorMessage = 'The company location provided is not active!'
		RETURN 0;
	END	

IF NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) LEFT OUTER JOIN [tblEMEntityLocation] EL ON ARC.[intEntityId] = EL.[intEntityId] AND EL.[ysnDefaultLocation] = 1 WHERE ISNULL(ARC.[intTermsId], EL.[intTermsId]) IS NOT NULL AND ARC.[intEntityId] = @EntityCustomerId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Customer has no Term setup!' , 16, 1);
		SET @ErrorMessage = 'Customer has no Term setup!' 
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblEMEntity WHERE intEntityId = @EntityId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The entity Id provided does not exists!', 16, 1);	
		SET @ErrorMessage = 'The entity Id provided does not exists!'
		RETURN 0;
	END

IF @CurrencyId IS NOT NULL
	SET @DefaultCurrency = @CurrencyId
ELSE
	SET @DefaultCurrency = [dbo].[fnARGetCustomerDefaultCurrency](@EntityCustomerId)

--IF @TransactionType = 'Credit Memo'
--	SET @ImpactInventory = 1

IF @ItemDescription like 'Washout net diff: Original Contract%' and @TransactionType = 'Credit Memo'
BEGIN
	SET @ImpactInventory = 0
END

IF ISNULL(@CurrencyId,0) <> 0 AND NOT EXISTS(SELECT NULL FROM tblSMCurrency WHERE [intCurrencyID] = @CurrencyId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The currency Id provided does not exists!', 16, 1);
		SET @ErrorMessage = 'The currency Id provided does not exists!'
		RETURN 0;
	END
 
IF ISNULL(@DefaultCurrency,0) = 0
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('There is no setup for default currency in the Company Configuration.', 16, 1);
			SET @ErrorMessage = 'There is no setup for default currency in the Company Configuration.'
		RETURN 0;
	END

IF (@TransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment', 'Proforma Invoice'))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('%s is not a valid transaction type!', 16, 1, @TransactionType);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('%s is not a valid transaction type!', @TransactionType, DEFAULT)
		RETURN 0;
	END

IF (@Type NOT IN ('Meter Billing', 'Standard', 'POS', 'Store Checkout', 'Software', 'Tank Delivery', 'Provisional', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling', 'CF Tran', 'CF Invoice', 'Cash Refund'))
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('%s is not a valid invoice type!', 16, 1, @TransactionType);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('%s is not a valid invoice type!', @TransactionType, DEFAULT)
		RETURN 0;
	END

IF (@UseOriginIdAsInvoiceNumber = 1 AND EXISTS (SELECT TOP 1 NULL FROM tblARInvoice WHERE strInvoiceNumber = @InvoiceOriginId))
	BEGIN
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Transaction with Invoice Number - %s is already existing.', 16, 1, @InvoiceOriginId);
		SET @ErrorMessage = [dbo].[fnARFormatMessage]('Transaction with Invoice Number - %s is already existing.', @InvoiceOriginId, DEFAULT)
		RETURN 0;
	END
	
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE	@ImpactForProvisional BIT

SELECT TOP 1
	 @ImpactForProvisional = CASE WHEN @Type = 'Provisional' THEN ISNULL([ysnImpactForProvisional], 0) ELSE 0 END
FROM
	tblARCompanyPreference

DECLARE  @NewId INT
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	INSERT INTO [tblARInvoice]
		([strInvoiceNumber]
		,[strTransactionType]
		,[strType]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intAccountId]
		,[intCurrencyId]
		,[intTermId]
		,[intSourceId]
		,[intPeriodsToAccrue] 
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[dtmCalculated]
		,[dtmPostDate]
		,[dblInvoiceSubtotal]
		,[dblShipping]
		,[dblTax]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[intEntitySalespersonId]
		,[intEntityContactId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strMobileBillingShiftNo]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[strFooterComments]
		,[intShipToLocationId]
		,[strShipToLocationName]
		,[strShipToAddress]
		,[strShipToCity]
		,[strShipToState]
		,[strShipToZipCode]
		,[strShipToCountry]
		,[intBillToLocationId]
		,[strBillToLocationName]
		,[strBillToAddress]
		,[strBillToCity]
		,[strBillToState]
		,[strBillToZipCode]
		,[strBillToCountry]
		,[strImportFormat]
		,[ysnPosted]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		,[ysnPaid]
		,[ysnPaidCPP]
		,[ysnRecurring]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[ysnImpactInventory]
		,[ysnFromProvisional]
        ,[ysnProvisionalWithGL]
		,[ysnServiceChargeCredit]
		,[intPaymentId]
		,[intSplitId]
		,[intLoadDistributionHeaderId]
		,[strActualCostId]
		,[intShipmentId]
		,[intTransactionId]
		,[intMeterReadingId]
		,[intContractHeaderId]
		,[intOriginalInvoiceId]
		,[intLoadId]
		,[intEntityId]
		,[intTruckDriverId]
		,[intTruckDriverReferenceId]
		,[intDocumentMaintenanceId]
		,[intConcurrencyId]
		,[intLineOfBusinessId]
		,[intICTId]
		,[intSalesOrderId])
	SELECT [strInvoiceNumber]			= CASE WHEN @UseOriginIdAsInvoiceNumber = 1 THEN @InvoiceOriginId ELSE NULL END
		,[strTransactionType]			= @TransactionType
		,[strType]						= @Type
		,[intEntityCustomerId]			= C.[intEntityId]
		,[intCompanyLocationId]			= @CompanyLocationId
		,[intAccountId]					= @ARAccountId
		,[intCurrencyId]				= @DefaultCurrency
		,[intTermId]					= ISNULL(ISNULL(@TermId, C.[intTermsId]), EL.[intTermsId])
		,[intSourceId]					= @SourceId
		,[intPeriodsToAccrue]			= ISNULL(@PeriodsToAccrue, 1)
		,[dtmDate]						= CASE WHEN @Type = 'Transport Delivery' THEN ISNULL(@InvoiceDate, @DateOnly) ELSE ISNULL(CAST(@InvoiceDate AS DATE), @DateOnly) END
		,[dtmDueDate]					= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly), ISNULL(ISNULL(@TermId, C.[intTermsId]),0)) AS DATE)))
		,[dtmShipDate]					= ISNULL(@ShipDate, ISNULL(CAST(@PostDate AS DATE),@DateOnly))
		,[dtmCalculated]				= CAST(@CalculatedDate AS DATE)
		,[dtmPostDate]					= ISNULL(CAST(@PostDate AS DATE),ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly))
		,[dblInvoiceSubtotal]			= @ZeroDecimal
		,[dblShipping]					= @ZeroDecimal
		,[dblTax]						= @ZeroDecimal
		,[dblInvoiceTotal]				= @ZeroDecimal
		,[dblDiscount]					= @ZeroDecimal
		,[dblAmountDue]					= @ZeroDecimal
		,[dblPayment]					= @ZeroDecimal
		
		,[intEntitySalespersonId]		= ISNULL(@EntitySalespersonId, C.[intSalespersonId])
		,[intEntityContactId]			= @EntityContactId
		,[intFreightTermId]				= ISNULL(@FreightTermId, ISNULL(SL.[intFreightTermId],SL1.[intFreightTermId]))
		,[intShipViaId]					= ISNULL(@ShipViaId, EL.[intShipViaId])
		,[intPaymentMethodId]			= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE intPaymentMethodID = @PaymentMethodId)
		,[strInvoiceOriginId]			= @InvoiceOriginId
		,[strMobileBillingShiftNo]		= @MobileBillingShiftNo
		,[strPONumber]					= @PONumber
		,[strBOLNumber]					= @BOLNumber
		,[strComments]					= CASE WHEN ISNULL(@Comment, '') = '' THEN dbo.fnARGetDefaultComment(@CompanyLocationId, C.[intEntityId], @TransactionType, @Type, 'Header', NULL, 0) ELSE @Comment END
		,[strFooterComments]			= CASE WHEN ISNULL(@FooterComment, '') = '' THEN dbo.fnARGetDefaultComment(@CompanyLocationId, C.[intEntityId], @TransactionType, @Type, 'Footer', NULL, 0) ELSE @FooterComment END
		,[intShipToLocationId]			= ISNULL(@ShipToLocationId, ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId]))
		,[strShipToLocationName]		= ISNULL(SL.[strLocationName], ISNULL(SL1.[strLocationName], EL.[strLocationName]))
		,[strShipToAddress]				= ISNULL(SL.[strAddress], ISNULL(SL1.[strAddress], EL.[strAddress]))
		,[strShipToCity]				= ISNULL(SL.[strCity], ISNULL(SL1.[strCity], EL.[strCity]))
		,[strShipToState]				= ISNULL(SL.[strState], ISNULL(SL1.[strState], EL.[strState]))
		,[strShipToZipCode]				= ISNULL(SL.[strZipCode], ISNULL(SL1.[strZipCode], EL.[strZipCode]))
		,[strShipToCountry]				= ISNULL(SL.[strCountry], ISNULL(SL1.[strCountry], EL.[strCountry]))
		,[intBillToLocationId]			= ISNULL(@BillToLocationId, ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId]))
		,[strBillToLocationName]		= ISNULL(BL.[strLocationName], ISNULL(BL1.[strLocationName], EL.[strLocationName]))
		,[strBillToAddress]				= ISNULL(BL.[strAddress], ISNULL(BL1.[strAddress], EL.[strAddress]))
		,[strBillToCity]				= ISNULL(BL.[strCity], ISNULL(BL1.[strCity], EL.[strCity]))
		,[strBillToState]				= ISNULL(BL.[strState], ISNULL(BL1.[strState], EL.[strState]))
		,[strBillToZipCode]				= ISNULL(BL.[strZipCode], ISNULL(BL1.[strZipCode], EL.[strZipCode]))
		,[strBillToCountry]				= ISNULL(BL.[strCountry], ISNULL(BL1.[strCountry], EL.[strCountry]))
		,[strImportFormat]				= @ImportFormat
		,[ysnPosted]					= (CASE WHEN @TransactionType IN ('Overpayment', 'Customer Prepayment') 
													THEN @Posted 
												WHEN (@TransactionType IN ('Invoice') AND @ImportedFromOrigin = 1) 
													THEN  1 
												ELSE 0 END)
		,[ysnImportedFromOrigin]		= ISNULL(@ImportedFromOrigin, 0)
		,[ysnImportedAsPosted]			= ISNULL(@ImportedAsPosted, 0)
		,[ysnPaid]						= 0
		,[ysnPaidCPP]					= @PaidCPP
		,[ysnTemplate]					= ISNULL(@Template,0)
		,[ysnForgiven]					= ISNULL(@Forgiven,0) 
		,[ysnCalculated]				= ISNULL(@Calculated,0)
		,[ysnSplitted]					= ISNULL(@Splitted,0)		
		,[ysnImpactInventory]			= ISNULL(@ImpactInventory, CAST(1 AS BIT))	
		,[ysnFromProvisional]			= ISNULL(@FromProvisional, 0)
		,[ysnProvisionalWithGL]			= ISNULL(@ImpactForProvisional, 0)	
		,[ysnServiceChargeCredit]		= ISNULL(@ServiceChargeCredit, 0)
		,[intPaymentId]					= @PaymentId 
		,[intSplitId]					= @SplitId 
		,[intLoadDistributionHeaderId]	= @LoadDistributionHeaderId 
		,[strActualCostId]				= @ActualCostId 
		,[intShipmentId]				= @ShipmentId 
		,[intTransactionId]				= @TransactionId
		,[intMeterReadingId]			= @MeterReadingId
		,[intContractHeaderId]			= @ItemContractHeaderId
		,[intOriginalInvoiceId]			= @OriginalInvoiceId
		,[intLoadId]                    = @LoadId
		,[intEntityId]					= @EntityId
		,[intTruckDriverId]				= @TruckDriverId
		,[intTruckDriverReferenceId]	= @TruckDriverReferenceId
		,[intDocumentMaintenanceId]		= @DocumentMaintenanceId
		,[intConcurrencyId]				= 0
		,[intLineOfBusinessId]			= @intLineOfBusinessId
		,[intICTId]						= @intICTId
		,[intSalespersonId]				= @intSalesOrderId
	FROM	
		tblARCustomer C
	LEFT OUTER JOIN
					(	SELECT 
							 [intEntityLocationId]
							,[strLocationName]
							,[strAddress]
							,[intEntityId] 
							,[strCountry]
							,[strState]
							,[strCity]
							,[strZipCode]
							,[intTermsId]
							,[intShipViaId]
						FROM 
							[tblEMEntityLocation]
						WHERE
							ysnDefaultLocation = 1
					) EL
						ON C.[intEntityId] = EL.[intEntityId]
	LEFT OUTER JOIN
		[tblEMEntityLocation] SL
			ON ISNULL(@ShipToLocationId, 0) <> 0
			AND @ShipToLocationId = SL.intEntityLocationId
	LEFT OUTER JOIN
		[tblEMEntityLocation] SL1
			ON C.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN
		[tblEMEntityLocation] BL
			ON ISNULL(@BillToLocationId, 0) <> 0
			AND @BillToLocationId = BL.intEntityLocationId		
	LEFT OUTER JOIN
		[tblEMEntityLocation] BL1
			ON C.intBillToId = BL1.intEntityLocationId	
	WHERE C.[intEntityId] = @EntityCustomerId
	
	SET @NewId = SCOPE_IDENTITY()
	
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



--IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @EntityCustomerId AND [ysnPORequired] = 1 AND LEN(LTRIM(RTRIM(ISNULL(@PONumber,'')))) <= 0)
--	BEGIN
--		DECLARE  @ShipToId	INT
--				,@NewPONumber	NVARCHAR(200)
--		SET @ShipToId = (SELECT [intShipToLocationId] FROM tblARInvoice WHERE intInvoiceId = @NewId)
		
--		BEGIN TRY
--		EXEC dbo.[uspARGetPONumber]  
--			 @ShipToId  
--			,@CompanyLocationId
--			,@InvoiceDate
--			,@NewPONumber OUT
			
--		UPDATE
--			tblARInvoice
--		SET
--			[strPONumber] = @NewPONumber
--		WHERE
--			[intInvoiceId] = @NewId
			
--		END TRY
--		BEGIN CATCH
--			IF ISNULL(@RaiseError,0) = 0
--				ROLLBACK TRANSACTION
--			SET @ErrorMessage = ERROR_MESSAGE();
--			IF ISNULL(@RaiseError,0) = 1
--				RAISERROR(@ErrorMessage, 16, 1);
--			RETURN 0;
--		END CATCH
				
--	END

BEGIN TRY
	EXEC [dbo].[uspARAddItemToInvoice]
		 @InvoiceId						= @NewId	
		,@ItemId						= @ItemId
		,@ItemPrepayTypeId				= @ItemPrepayTypeId
		,@ItemPrepayRate				= @ItemPrepayRate
		,@ItemIsInventory				= @ItemIsInventory
		,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
		,@ErrorMessage					= @AddDetailError	OUTPUT
		,@RaiseError					= @RaiseError
		,@ItemDocumentNumber			= @ItemDocumentNumber
		,@ItemDescription				= @ItemDescription
		,@ItemOrderUOMId				= @ItemOrderUOMId
		,@ItemQtyOrdered				= @ItemQtyOrdered
		,@ItemUOMId						= @ItemUOMId
		,@ItemPriceUOMId				= @ItemPriceUOMId
		,@ItemQtyShipped				= @ItemQtyShipped
		,@ItemDiscount					= @ItemDiscount
		,@ItemTermDiscount				= @ItemTermDiscount
		,@ItemTermDiscountBy			= @ItemTermDiscountBy
		,@ItemPrice						= @ItemPrice
		,@ItemUnitPrice					= @ItemUnitPrice
		,@RefreshPrice					= @RefreshPrice
		,@AllowRePrice					= @AllowRePrice
		,@ItemMaintenanceType			= @ItemMaintenanceType
		,@ItemFrequency					= @ItemFrequency
		,@ItemMaintenanceDate			= @ItemMaintenanceDate
		,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
		,@ItemLicenseAmount				= @ItemLicenseAmount
		,@ItemTaxGroupId				= @ItemTaxGroupId
		,@ItemStorageLocationId			= @ItemStorageLocationId 
		,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId 
		,@RecomputeTax					= @RecomputeTax
		,@ItemSCInvoiceId				= @ItemSCInvoiceId
		,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
		,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
		,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
		,@ItemShipmentNumber			= @ItemShipmentNumber
		,@ItemSubFormula				= @ItemSubFormula
		,@ItemRecipeItemId				= @ItemRecipeItemId
		,@ItemRecipeId					= @ItemRecipeId
		,@ItemSublocationId				= @ItemSublocationId
		,@ItemCostTypeId				= @ItemCostTypeId
		,@ItemMarginById				= @ItemMarginById
		,@ItemCommentTypeId				= @ItemCommentTypeId
		,@ItemMargin					= @ItemMargin
		,@ItemRecipeQty					= @ItemRecipeQty		
		,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
		,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
		,@ItemContractHeaderId			= @ItemContractHeaderId
		,@ItemContractDetailId			= @ItemContractDetailId
		,@ItemShipmentId				= @ShipmentId
		,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
		,@ItemWeightUOMId				= @ItemWeightUOMId
		,@ItemWeight					= @ItemWeight
		,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
		,@ItemShipmentTareWt			= @ItemShipmentTareWt
		,@ItemShipmentNetWt				= @ItemShipmentNetWt
		,@ItemTicketId					= @ItemTicketId
		,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
		,@ItemCustomerStorageId			= @ItemCustomerStorageId
		,@ItemSiteDetailId				= @ItemSiteDetailId
		,@ItemLoadDetailId				= @ItemLoadDetailId
		,@ItemLotId						= @ItemLotId
		,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
		,@ItemSiteId					= @ItemSiteId
		,@ItemBillingBy					= @ItemBillingBy
		,@ItemPercentFull				= @ItemPercentFull
		,@ItemNewMeterReading			= @ItemNewMeterReading
		,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
		,@ItemConversionFactor			= @ItemConversionFactor
		,@ItemPerformerId				= @ItemPerformerId
		,@ItemLeaseBilling				= @ItemLeaseBilling
		,@ItemVirtualMeterReading		= @ItemVirtualMeterReading
		,@ItemConversionAccountId		= @ItemConversionAccountId
		,@ItemSalesAccountId			= @ItemSalesAccountId
		,@ItemSubCurrencyId				= @ItemSubCurrencyId
		,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
		,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
		,@ItemDestinationGradeId		= @ItemDestinationGradeId
		,@ItemDestinationWeightId		= @ItemDestinationWeightId
        ,@ItemAddonDetailKey            = @ItemAddonDetailKey
        ,@ItemAddonParent               = @ItemAddonParent
        ,@ItemAddOnQuantity             = @ItemAddOnQuantity

		IF LEN(ISNULL(@AddDetailError,'')) > 0
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

				SET @ErrorMessage = @AddDetailError;
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

	
BEGIN TRY
	SET @SourceId = dbo.[fnARGetValidInvoiceSourceId](@NewId)
	IF ISNULL(@SourceId,0) <> 0
	BEGIN
		UPDATE tblARInvoice
			SET [intSourceId] = @SourceId
		WHERE
			[intInvoiceId] = @NewId
			AND ISNULL([intSourceId],0) <> 0
	END
	
	if @RecomputeTax = 1 or @ItemTaxGroupId is not null
		EXEC [dbo].[uspARReComputeInvoiceTaxes] @NewId
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

SET @NewInvoiceId = @NewId

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

SET @ErrorMessage = NULL;
RETURN 1;
	
END
GO


