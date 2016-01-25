CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId				INT
	,@CompanyLocationId				INT
	,@CurrencyId					INT				= NULL
	,@TermId						INT				= NULL
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
	,@Template						BIT				= 0			
	,@Forgiven						BIT				= 0			
	,@Calculated					BIT				= 0			
	,@Splitted						BIT				= 0			
	,@PaymentId						INT				= NULL
	,@SplitId						INT				= NULL
	,@DistributionHeaderId			INT				= NULL
	,@ActualCostId					NVARCHAR(50)	= ''			
	,@ShipmentId					INT				= NULL
	,@TransactionId					INT				= NULL
	,@OriginalInvoiceId				INT				= NULL
		
	,@ItemId						INT				= NULL
	,@ItemIsInventory				BIT				= 0
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemUOMId						INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
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
	,@RecomputeTax					BIT				= 0
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
	,@ItemShipmentUOMId				INT				= NULL	
	,@ItemShipmentQtyShipped		NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentGrossWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentTareWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentNetWt				NUMERIC(18,6)	= 0.000000			
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL		
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
SET @DefaultCurrency = ISNULL((SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)

IF @DeliverPickUp IS NULL OR LTRIM(RTRIM(@DeliverPickUp)) = ''
	SET @DeliverPickUp = ISNULL((SELECT TOP 1 strDeliverPickupDefault FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')
	
IF @Comment IS NULL OR LTRIM(RTRIM(@Comment)) = ''
	SET @Comment = ISNULL((SELECT TOP 1 ISNULL(strInvoiceComments,'') FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')


IF(@ARAccountId IS NULL OR @ARAccountId = 0)
	BEGIN
		SET @ErrorMessage = 'There is no setup for AR Account in the Company Preference.';
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId)
	BEGIN
		SET @ErrorMessage = 'The customer Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId AND ysnActive = 1)
	BEGIN
		SET @ErrorMessage = 'The customer provided is not active!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The company location Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);		
		RETURN 0;
	END	

IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId AND ysnLocationActive = 1)
	BEGIN
		SET @ErrorMessage = 'The company location provided is not active!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);		
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblEntity WHERE intEntityId = @EntityId)
	BEGIN
		SET @ErrorMessage = 'The entity Id provided does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);		
		RETURN 0;
	END
	
IF ISNULL(@RaiseError,0) = 0	
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
		,[intTermId]
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
		,[ysnPosted]
		,[ysnPaid]
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
		,[intOriginalInvoiceId] 
		,[intEntityId]
		,[intConcurrencyId])
	SELECT
		 [strTransactionType]			= @TransactionType
		,[strType]						= CASE WHEN ISNULL(@DistributionHeaderId, 0) > 0 THEN 'Transport Delivery' ELSE @Type END
		,[intEntityCustomerId]			= C.[intEntityCustomerId]
		,[intCompanyLocationId]			= @CompanyLocationId
		,[intAccountId]					= @ARAccountId
		,[intCurrencyId]				= ISNULL(@CurrencyId, ISNULL(C.[intCurrencyId], @DefaultCurrency))	
		,[intTermId]					= ISNULL(@TermId, EL.[intTermsId])
		,[dtmDate]						= CAST(@InvoiceDate AS DATE)
		,[dtmDueDate]					= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, ISNULL(ISNULL(@TermId, EL.[intTermsId]),0)) AS DATE)))
		,[dtmShipDate]					= @ShipDate
		,[dtmPostDate]					= CASE WHEN @PostDate IS NULL THEN CAST(@InvoiceDate AS DATE) ELSE @PostDate END
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
		,[strComments]					= @Comment
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
		,[ysnPosted]					= (CASE WHEN @PostDate IS NULL THEN 0 ELSE 1 END)
		,[ysnPaid]						= 0
		,[ysnTemplate]					= ISNULL(@Template,0)
		,[ysnForgiven]					= ISNULL(@Forgiven,0) 
		,[ysnCalculated]				= ISNULL(@Calculated,0)
		,[ysnSplitted]					= ISNULL(@Splitted,0)		
		,[intPaymentId]					= @PaymentId 
		,[intSplitId]					= @SplitId 
		,[intDistributionHeaderId]		= @DistributionHeaderId 
		,[strActualCostId]				= @ActualCostId 
		,[intShipmentId]				= @ShipmentId 
		,[intTransactionId]				= @TransactionId 
		,[intOriginalInvoiceId]			= @OriginalInvoiceId
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
							tblEntityLocation
						WHERE
							ysnDefaultLocation = 1
					) EL
						ON C.[intEntityCustomerId] = EL.[intEntityId]
	LEFT OUTER JOIN
		tblEntityLocation SL
			ON ISNULL(@ShipToLocationId, 0) <> 0
			AND @ShipToLocationId = SL.intEntityLocationId
	LEFT OUTER JOIN
		tblEntityLocation SL1
			ON C.intShipToId = SL1.intEntityLocationId
	LEFT OUTER JOIN
		tblEntityLocation BL
			ON ISNULL(@BillToLocationId, 0) <> 0
			AND @BillToLocationId = BL.intEntityLocationId		
	LEFT OUTER JOIN
		tblEntityLocation BL1
			ON C.intShipToId = BL1.intEntityLocationId
	WHERE C.[intEntityCustomerId] = @EntityCustomerId
	
	SET @NewId = SCOPE_IDENTITY()
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
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
		,@ItemIsInventory				= @ItemIsInventory
		,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
		,@ErrorMessage					= @AddDetailError	OUTPUT
		,@RaiseError					= @RaiseError
		,@ItemDocumentNumber			= @ItemDocumentNumber
		,@ItemDescription				= @ItemDescription
		,@ItemUOMId						= @ItemUOMId
		,@ItemQtyOrdered				= @ItemQtyShipped
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
		,@RecomputeTax					= @RecomputeTax
		,@ItemSCInvoiceId				= @ItemSCInvoiceId
		,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
		,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
		,@ItemShipmentNumber			= @ItemShipmentNumber
		,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
		,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
		,@ItemContractHeaderId			= @ItemContractHeaderId
		,@ItemContractDetailId			= @ItemContractDetailId
		,@ItemShipmentId				= @ShipmentId
		,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
		,@ItemShipmentUOMId				= @ItemShipmentUOMId
		,@ItemShipmentQtyShipped		= @ItemShipmentQtyShipped
		,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
		,@ItemShipmentTareWt			= @ItemShipmentTareWt
		,@ItemShipmentNetWt				= @ItemShipmentNetWt
		,@ItemTicketId					= @ItemTicketId
		,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
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
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
BEGIN TRY
	EXEC [dbo].[uspARReComputeInvoiceAmounts] @NewId
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

SET @NewInvoiceId = @NewId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END