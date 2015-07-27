CREATE PROCEDURE [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId				INT
	,@InvoiceDate					DATETIME
	,@CompanyLocationId				INT
	,@EntityId						INT
	,@NewInvoiceId					INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(50)	= NULL			OUTPUT
	,@ShipDate						DATETIME		= NULL
	,@TransactionType				NVARCHAR(50)	= 'Invoice'
	,@Type							NVARCHAR(200)	= 'General'
	,@Comment						NVARCHAR(500)	= ''
	,@DistributionHeaderId			INT				= NULL
	,@PaymentMethodId				INT				= 0
	,@FreightTermId					INT				= NULL
	,@DeliverPickUp					NVARCHAR(100)	= NULL
	,@ItemId						INT				= NULL
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemSiteId					INT				= NULL												
	,@ItemBillingBy					NVARCHAR(200)	= NULL
	,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId				INT				= NULL
	,@ItemLeaseBilling				BIT				= 0
	,@TaxMasterId					INT				= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000		
	,@ItemTicketId					INT				= NULL		
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemServiceChargeAccountId	INT				= NULL
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME
		,@Currency INT
		,@ARAccountId INT
		

SET @ZeroDecimal = 0.000000	
SET @Currency = ISNULL((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency'),0)
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)

IF @DeliverPickUp IS NULL OR LTRIM(RTRIM(@DeliverPickUp)) = ''
	SET @DeliverPickUp = ISNULL((SELECT TOP 1 strDeliverPickupDefault FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')
	
IF @Comment IS NULL OR LTRIM(RTRIM(@Comment)) = ''
	SET @Comment = ISNULL((SELECT TOP 1 ISNULL(strInvoiceComments,'') FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId),'')


IF(@ARAccountId IS NULL OR @ARAccountId = 0)
	BEGIN
		SET @ErrorMessage = 'There is no setup for AR Account in the Company Preference.';
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @EntityCustomerId)
	BEGIN
		SET @ErrorMessage = 'The customer Id provided does not exists!'
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN
		SET @ErrorMessage = 'The company location Id provided does not exists!'
		RETURN 0;
	END	
	
IF NOT EXISTS(SELECT NULL FROM tblEntity WHERE intEntityId = @EntityId)
	BEGIN
		SET @ErrorMessage = 'The entity Id provided does not exists!'
		RETURN 0;
	END
	
BEGIN TRANSACTION

DECLARE  @NewId INT
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)

BEGIN TRY
	INSERT INTO [tblARInvoice]
		([intEntityCustomerId]
		,[dtmDate]
		,[dtmDueDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intEntitySalespersonId]
		,[dtmShipDate]
		,[intShipViaId]
		,[strPONumber]
		,[intTermId]
		,[dblInvoiceSubtotal]
		,[dblShipping]
		,[dblTax]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[strTransactionType]
		,[strType]
		,[intPaymentMethodId]
		,[strComments]
		,[intAccountId]
		,[dtmPostDate]
		,[ysnPosted]
		,[ysnPaid]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[intFreightTermId]
		,[strDeliverPickup]
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
		,[intDistributionHeaderId]
		,[intConcurrencyId]
		,[intEntityId])

	SELECT			
		 [intEntityCustomerId]			= C.[intEntityCustomerId]
		,[dtmDate]						= CAST(@InvoiceDate AS DATE)
		,[dtmDueDate]					= CAST(dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, ISNULL(EL.[intTermsId],0)) AS DATE) 
		,[intCurrencyId]				= ISNULL(C.[intCurrencyId], @Currency)
		,[intCompanyLocationId]			= @CompanyLocationId
		,[intEntitySalespersonId]		= C.[intSalespersonId]
		,[dtmShipDate]					= @ShipDate
		,[intShipViaId]					= EL.[intShipViaId]
		,[strPONumber]					= NULL
		,[intTermId]					= EL.[intTermsId]
		,[dblInvoiceSubtotal]			= @ZeroDecimal
		,[dblShipping]					= @ZeroDecimal
		,[dblTax]						= @ZeroDecimal
		,[dblInvoiceTotal]				= @ZeroDecimal
		,[dblDiscount]					= @ZeroDecimal
		,[dblAmountDue]					= @ZeroDecimal
		,[dblPayment]					= @ZeroDecimal
		,[strTransactionType]			= @TransactionType
		,[strType]						= @Type 
		,[intPaymentMethodId]			= @PaymentMethodId
		,[strComments]					= @Comment
		,[intAccountId]					= @ARAccountId
		,[dtmPostDate]					= NULL
		,[ysnPosted]					= 0
		,[ysnPaid]						= 0
		,[ysnTemplate]					= 0
		,[ysnForgiven]					= 0
		,[ysnCalculated]				= 0
		,[intFreightTermId]				= @FreightTermId
		,[strDeliverPickup]				= @DeliverPickUp
		,[intShipToLocationId]			= ISNULL(SL.[intEntityLocationId], EL.[intEntityLocationId])
		,[strShipToLocationName]		= ISNULL(SL.[strLocationName], EL.[strLocationName])
		,[strShipToAddress]				= ISNULL(SL.[strAddress], EL.[strAddress])
		,[strShipToCity]				= ISNULL(SL.[strCity], EL.[strCity])
		,[strShipToState]				= ISNULL(SL.[strState], EL.[strState])
		,[strShipToZipCode]				= ISNULL(SL.[strZipCode], EL.[strZipCode])
		,[strShipToCountry]				= ISNULL(SL.[strCountry], EL.[strCountry])
		,[intBillToLocationId]			= ISNULL(BL.[intEntityLocationId], EL.[intEntityLocationId])
		,[strBillToLocationName]		= ISNULL(BL.[strLocationName], EL.[strLocationName])
		,[strBillToAddress]				= ISNULL(BL.[strAddress], EL.[strAddress])
		,[strBillToCity]				= ISNULL(BL.[strCity], EL.[strCity])
		,[strBillToState]				= ISNULL(BL.[strState], EL.[strState])
		,[strBillToZipCode]				= ISNULL(BL.[strZipCode], EL.[strZipCode])
		,[strBillToCountry]				= ISNULL(BL.[strCountry], EL.[strCountry])
		,[intDistributionHeaderId]		= @DistributionHeaderId
		,[intConcurrencyId]				= 1
		,[intEntityId]					= @EntityId
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
			ON C.intShipToId = SL.intEntityLocationId
	LEFT OUTER JOIN
		tblEntityLocation BL
			ON C.intShipToId = BL.intEntityLocationId
	WHERE C.[intEntityCustomerId] = @EntityCustomerId
	
	SET @NewId = SCOPE_IDENTITY()
	
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	RETURN 0;
END CATCH



IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @EntityCustomerId AND [ysnPORequired] = 1)
	BEGIN
		DECLARE  @ShipToId	INT
				,@PONumber	NVARCHAR(200)
		SET @ShipToId = (SELECT [intShipToLocationId] FROM tblARInvoice WHERE intInvoiceId = @NewId)
		
		BEGIN TRY
		EXEC dbo.[uspARGetPONumber]  
			 @ShipToId  
			,@CompanyLocationId
			,@InvoiceDate
			,@PONumber OUT
			
		UPDATE
			tblARInvoice
		SET
			[strPONumber] = @PONumber
		WHERE
			[intInvoiceId] = @NewId
			
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SET @ErrorMessage = ERROR_MESSAGE();
			RETURN 0;
		END CATCH
				
	END
	

IF (@ItemId IS NOT NULL OR @ItemId <> 0)
	BEGIN
		BEGIN TRY
		EXEC [dbo].[uspARAddInventoryItemToInvoice]
			 @InvoiceId						= @NewId	
			,@ItemId						= @ItemId
			,@NewInvoiceDetailId			= @NewDetailId	OUTPUT 
			,@ErrorMessage					= @AddDetailError	OUTPUT
			,@ItemUOMId						= @ItemUOMId
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemPrice						= @ItemPrice
			,@ItemDescription				= @ItemDescription
			,@ItemSiteId					= @ItemSiteId											
			,@ItemBillingBy					= @ItemBillingBy
			,@ItemPercentFull				= @ItemPercentFull
			,@ItemNewMeterReading			= @ItemNewMeterReading
			,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
			,@ItemConversionFactor			= @ItemConversionFactor
			,@ItemPerformerId				= @ItemPerformerId
			,@ItemLeaseBilling				= @ItemLeaseBilling
			,@TaxMasterId					= @TaxMasterId
			,@ItemContractHeaderId			= @ItemContractHeaderId
			,@ItemContractDetailId			= @ItemContractDetailId
			,@ItemMaintenanceType			= @ItemMaintenanceType
			,@ItemFrequency					= @ItemFrequency
			,@ItemMaintenanceDate			= @ItemMaintenanceDate
			,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
			,@ItemLicenseAmount				= @ItemLicenseAmount	
			,@ItemTicketId					= @ItemTicketId	
			,@ItemSCInvoiceId				= @ItemSCInvoiceId
			,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
			,@ItemServiceChargeAccountId	= @ItemServiceChargeAccountId
			
			IF (@AddDetailError IS NOT NULL AND RTRIM(LTRIM(@AddDetailError)) = '')
				BEGIN
					ROLLBACK TRANSACTION
					SET @ErrorMessage = @AddDetailError;
					RETURN 0;
				END
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SET @ErrorMessage = ERROR_MESSAGE();
			RETURN 0;
		END CATCH
	END


BEGIN TRY
	EXEC [dbo].[uspARReComputeInvoiceAmounts] @NewId
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	RETURN 0;
END CATCH

SET @NewInvoiceId = @NewId

COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END