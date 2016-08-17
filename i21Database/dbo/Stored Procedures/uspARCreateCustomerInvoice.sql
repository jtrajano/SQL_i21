﻿CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId				INT
	,@CompanyLocationId				INT
	,@CurrencyId					INT				= NULL
	,@SubCurrencyCents				INT				= NULL
	,@TermId						INT				= NULL
	,@AccountId						INT				= NULL
	,@EntityId						INT
	,@InvoiceDate					DATETIME	
	,@DueDate						DATETIME		= NULL
	,@ShipDate						DATETIME		= NULL	
	,@PostDate						DATETIME		= NULL
	,@TransactionType				NVARCHAR(50)	= 'Invoice'
	,@Type							NVARCHAR(200)	= 'Standard'
	,@NewInvoiceId					INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0			
	,@EntitySalespersonId			INT				= NULL				
	,@FreightTermId					INT				= NULL
	,@ShipViaId						INT				= NULL
	,@PaymentMethodId				INT				= NULL
	,@InvoiceOriginId				NVARCHAR(16)	= NULL
	,@PONumber						NVARCHAR(50)	= ''
	,@BOLNumber						NVARCHAR(50)	= ''
	,@DeliverPickUp					NVARCHAR(100)	= NULL
	,@Comment						NVARCHAR(500)	= ''			
	,@ShipToLocationId				INT				= NULL
	,@BillToLocationId				INT				= NULL
	,@Posted						BIT				= 0			
	,@Template						BIT				= 0			
	,@Forgiven						BIT				= 0			
	,@Calculated					BIT				= 0			
	,@Splitted						BIT				= 0			
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
	,@ItemId						INT				= NULL
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@ItemIsInventory				BIT				= 0
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@OrderUOMId					INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000	
	,@RefreshPrice					BIT				= 0
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000
	,@ItemTaxGroupId				INT				= NULL
	,@ItemStorageLocationId			INT				= NULL
	,@ItemCompanyLocationSubLocationId	INT				= NULL
	,@RecomputeTax					BIT				= 0
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemRecipeItemId				INT				= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
	,@ItemWeightUOMId				INT				= NULL	
	,@ItemWeight					NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentGrossWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentTareWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentNetWt				NUMERIC(18,6)	= 0.000000			
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL		
	,@ItemCustomerStorageId			INT				= NULL		
	,@ItemSiteDetailId				INT				= NULL		
	,@ItemLoadDetailId				INT				= NULL		
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
	,@SubCurrency					BIT				= 0
	,@DocumentMaintenanceId			INT				= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@DefaultCurrency INT
		,@ARAccountId INT		

SET @ZeroDecimal = 0.000000
SELECT @DateOnly = CAST(GETDATE() AS DATE)

IF @DeliverPickUp IS NULL OR LTRIM(RTRIM(@DeliverPickUp)) = ''
	SET @DeliverPickUp = ISNULL((SELECT TOP 1 strDeliverPickupDefault FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')
	
IF @Comment IS NULL
	BEGIN
		EXEC	[dbo].[uspARGetDefaultComment]
					@intCompanyLocationId = @CompanyLocationId,
					@intEntityCustomerId = @EntityCustomerId,
					@strTransactionType = @TransactionType,
					@strType = @Type,
					@strDefaultComment = @Comment OUTPUT,
					@DocumentMaintenanceId = @DocumentMaintenanceId
	END


	


IF ISNULL(@TransactionType, '') = ''
	SET @TransactionType = 'Invoice'

IF ISNULL(@Type, '') = ''
	SET @Type = 'Standard'


IF @AccountId IS NOT NULL
	SET @ARAccountId = @AccountId
ELSE
	SET @ARAccountId = [dbo].[fnARGetInvoiceTypeAccount](@TransactionType, @CompanyLocationId)


IF @ARAccountId IS NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
BEGIN
	RAISERROR(120005, 16, 1);
	GOTO _ExitTransaction
END

IF @ARAccountId IS NOT NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund') AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'AR Account' AND [intAccountId] =  @ARAccountId)
BEGIN
	RAISERROR(120062, 16, 1);
	GOTO _ExitTransaction
END

DECLARE @CompanyLocation NVARCHAR(250)
SELECT TOP 1 @CompanyLocation = [strLocationName] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId

IF @ARAccountId IS NULL AND @TransactionType IN ('Cash', 'Cash Refund')
BEGIN				
	RAISERROR(120063, 16, 1, @CompanyLocation);
	GOTO _ExitTransaction
END

IF @ARAccountId IS NOT NULL AND @TransactionType IN ('Cash', 'Cash Refund') AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'Undeposited Funds' AND [intAccountId] =  @ARAccountId)
BEGIN	
	RAISERROR(120064, 16, 1);
	GOTO _ExitTransaction
END

IF @ARAccountId IS NULL AND @TransactionType = 'Customer Prepayment'
BEGIN		
	RAISERROR(120065, 16, 1, @CompanyLocation);
	GOTO _ExitTransaction
END

IF  @TransactionType = 'Customer Prepayment' AND NOT EXISTS (SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'Customer Prepayments' AND [intAccountId] =  @ARAccountId)
BEGIN
		RAISERROR(120066, 16, 1);
		GOTO _ExitTransaction
END
	
IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId)
BEGIN
	RAISERROR(120025, 16, 1);
	GOTO _ExitTransaction
END

IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId AND ysnActive = 1)
BEGIN
	RAISERROR(120026, 16, 1);
	GOTO _ExitTransaction
END	
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
BEGIN
	RAISERROR(120027, 16, 1);		
	GOTO _ExitTransaction
END	

IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId AND ysnLocationActive = 1)
BEGIN
	RAISERROR(120028, 16, 1);		
	GOTO _ExitTransaction
END	
	
IF NOT EXISTS(SELECT NULL FROM tblEMEntity WHERE intEntityId = @EntityId)
BEGIN
	RAISERROR(120029, 16, 1);		
	GOTO _ExitTransaction
END

IF @CurrencyId IS NOT NULL
	SET @DefaultCurrency = @CurrencyId
ELSE
	SET @DefaultCurrency = [dbo].[fnARGetCustomerDefaultCurreny](@EntityCustomerId)

IF ISNULL(@CurrencyId,0) <> 0 AND NOT EXISTS(SELECT NULL FROM tblSMCurrency WHERE [intCurrencyID] = @CurrencyId)
BEGIN
	RAISERROR(120030, 16, 1);
	GOTO _ExitTransaction
END
 
IF ISNULL(@DefaultCurrency,0) = 0
BEGIN
	RAISERROR(120067, 16, 1);
	GOTO _ExitTransaction
END

IF (@TransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment'))
BEGIN
	RAISERROR(120068, 16, 1, @TransactionType);		
	GOTO _ExitTransaction
END

IF (@Type NOT IN ('Meter Billing', 'Standard', 'Software', 'Tank Delivery', 'Provisional Invoice', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling'))
BEGIN		
	RAISERROR(120069, 16, 1, @TransactionType);		
	GOTO _ExitTransaction
END
	
BEGIN TRANSACTION

DECLARE  @NewId INT
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	INSERT INTO [tblARInvoice]
		([strTransactionType]
		,[strType]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intAccountId]
		,[intCurrencyId]
		,[intSubCurrencyCents]
		,[intTermId]
		,[intSourceId]
		,[intPeriodsToAccrue] 
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[dtmPostDate]
		,[dblInvoiceSubtotal]
		,[dblShipping]
		,[dblTax]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strDeliverPickup]
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
		,[ysnPaid]
		,[ysnRecurring]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
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
		,[intConcurrencyId])
	SELECT
		 [strTransactionType]			= @TransactionType
		,[strType]						= @Type
		,[intEntityCustomerId]			= C.[intEntityCustomerId]
		,[intCompanyLocationId]			= @CompanyLocationId
		,[intAccountId]					= @ARAccountId
		,[intCurrencyId]				= @DefaultCurrency
		,[intSubCurrencyCents]			= (CASE WHEN ISNULL(@SubCurrencyCents,0) = 0 THEN ISNULL((SELECT intCent FROM tblSMCurrency WHERE intCurrencyID = @DefaultCurrency),1) ELSE @SubCurrencyCents END)
		,[intTermId]					= ISNULL(@TermId, EL.[intTermsId])
		,[intSourceId]					= @SourceId
		,[intPeriodsToAccrue]			= ISNULL(@PeriodsToAccrue, 1)
		,[dtmDate]						= ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly)
		,[dtmDueDate]					= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly), ISNULL(ISNULL(@TermId, EL.[intTermsId]),0)) AS DATE)))
		,[dtmShipDate]					= ISNULL(@ShipDate, DATEADD(month, 1, ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly)))
		,[dtmPostDate]					= ISNULL(CAST(@PostDate AS DATE),ISNULL(CAST(@InvoiceDate AS DATE),@DateOnly))
		,[dblInvoiceSubtotal]			= @ZeroDecimal
		,[dblShipping]					= @ZeroDecimal
		,[dblTax]						= @ZeroDecimal
		,[dblInvoiceTotal]				= @ZeroDecimal
		,[dblDiscount]					= @ZeroDecimal
		,[dblAmountDue]					= @ZeroDecimal
		,[dblPayment]					= @ZeroDecimal
		
		,[intEntitySalespersonId]		= ISNULL(@EntitySalespersonId, C.[intSalespersonId])
		,[intFreightTermId]				= @FreightTermId
		,[intShipViaId]					= ISNULL(@ShipViaId, EL.[intShipViaId])
		,[intPaymentMethodId]			= @PaymentMethodId
		,[strInvoiceOriginId]			= @InvoiceOriginId
		,[strPONumber]					= @PONumber
		,[strBOLNumber]					= @BOLNumber
		,[strDeliverPickup]				= @DeliverPickUp
		,[strComments]					= CASE WHEN (@Comment IS NULL OR @Comment = '') THEN (SELECT TOP 1 strMessage FROM tblSMDocumentMaintenanceMessage WHERE intDocumentMaintenanceId = @DocumentMaintenanceId AND strHeaderFooter NOT IN ('Footer')) ELSE @Comment END
		,[strFooterComments]			= dbo.fnARGetFooterComment(@CompanyLocationId, C.intEntityCustomerId, 'Invoice Footer')
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
		,[ysnPosted]					= (CASE WHEN @TransactionType IN ('Overpayment', 'Customer Prepayment') THEN @Posted ELSE 0 END)
		,[ysnPaid]						= 0
		,[ysnTemplate]					= ISNULL(@Template,0)
		,[ysnForgiven]					= ISNULL(@Forgiven,0) 
		,[ysnCalculated]				= ISNULL(@Calculated,0)
		,[ysnSplitted]					= ISNULL(@Splitted,0)		
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
		,[intConcurrencyId]				= 0
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
						ON C.[intEntityCustomerId] = EL.[intEntityId]
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
	WHERE C.[intEntityCustomerId] = @EntityCustomerId
	
	SET @NewId = SCOPE_IDENTITY()
	
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT') 
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
		,@OrderUOMId					= @OrderUOMId
		,@ItemQtyOrdered				= @ItemQtyOrdered
		,@ItemUOMId						= @ItemUOMId
		,@ItemQtyShipped				= @ItemQtyShipped
		,@ItemDiscount					= @ItemDiscount
		,@ItemPrice						= @ItemPrice
		,@RefreshPrice					= @RefreshPrice
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
		,@ItemShipmentNumber			= @ItemShipmentNumber
		,@ItemRecipeItemId				= @ItemRecipeItemId		
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
		,@SubCurrency					= @SubCurrency

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT') 
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

	EXEC [dbo].[uspARReComputeInvoiceAmounts] @NewId
END TRY
BEGIN CATCH
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT') 
END CATCH

SET @NewInvoiceId = @NewId

IF @@ERROR = 0 GOTO _CommitTransaction

_RollBackTransaction:
ROLLBACK TRANSACTION
GOTO _ExitTransaction

_CommitTransaction: 
COMMIT TRANSACTION
GOTO _ExitTransaction

_ExitTransaction:
	
END