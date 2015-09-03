CREATE PROCEDURE dbo.uspARDuplicateInvoice
	 @InvoiceId			int
	,@InvoiceDate		datetime
	,@UserId			int
	,@NewInvoiceNumber	nvarchar(25) = NULL		OUTPUT
AS

BEGIN

	DECLARE @EntityId int

	SET @EntityId = ISNULL((SELECT TOP 1 intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @UserId), 0)

	INSERT INTO tblARInvoice(
		strInvoiceOriginId
		,[intEntityCustomerId]
		,dtmDate
		,dtmDueDate
		,intCurrencyId
		,intCompanyLocationId
		,[intEntitySalespersonId]
		,dtmShipDate
		,intShipViaId
		,strPONumber
		,intTermId
		,dblInvoiceSubtotal
		,dblShipping
		,dblTax
		,dblInvoiceTotal
		,dblDiscount
		,dblAmountDue
		,dblPayment
		,strTransactionType
		,strType
		,intPaymentMethodId
		,strComments
		,intAccountId
		,dtmPostDate
		,ysnPosted
		,ysnPaid
		,intFreightTermId
		,strDeliverPickup 
		,intShipToLocationId
		,strShipToLocationName
		,strShipToAddress
		,strShipToCity
		,strShipToState
		,strShipToZipCode
		,strShipToCountry
		,intBillToLocationId
		,strBillToLocationName 
		,strBillToAddress
		,strBillToCity
		,strBillToState
		,strBillToZipCode
		,strBillToCountry
		,intConcurrencyId
		,intEntityId)
	SELECT 
		strInvoiceOriginId
		,[intEntityCustomerId]
		,@InvoiceDate
		,dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, intTermId)
		,intCurrencyId
		,intCompanyLocationId
		,[intEntitySalespersonId]
		,@InvoiceDate
		,intShipViaId
		,strPONumber
		,intTermId
		,dblInvoiceSubtotal
		,dblShipping
		,dblTax
		,dblInvoiceTotal
		,dblDiscount
		,dblInvoiceTotal
		,0
		,strTransactionType
		,strType
		,intPaymentMethodId
		,strComments
		,intAccountId
		,@InvoiceDate
		,0
		,0
		,intFreightTermId
		,strDeliverPickup 
		,intShipToLocationId
		,strShipToLocationName
		,strShipToAddress
		,strShipToCity
		,strShipToState
		,strShipToZipCode
		,strShipToCountry
		,intBillToLocationId
		,strBillToLocationName 
		,strBillToAddress
		,strBillToCity
		,strBillToState
		,strBillToZipCode
		,strBillToCountry
		,0
		,@EntityId
	FROM 
		tblARInvoice
	WHERE
		intInvoiceId = @InvoiceId
		
		
	DECLARE @NewId int

	SET @NewId = SCOPE_IDENTITY()
	
	DECLARE @InvoiceDetails TABLE(intInvoiceDetailId INT)
		
	INSERT INTO @InvoiceDetails
		([intInvoiceDetailId])
	SELECT 	
		 [intInvoiceDetailId]
	FROM
		tblARInvoiceDetail
	WHERE
		[intInvoiceId] = @InvoiceId
	ORDER BY
		[intInvoiceDetailId]
						
	WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceDetails)
		BEGIN
			DECLARE @InvoiceDetailId				INT
					,@NewInvoiceDetailId			INT
					,@ErrorMessage					NVARCHAR(MAX)
					,@ItemId						INT
					,@ItemUOMId						INT
					,@ItemQtyShipped				NUMERIC(18,6)
					,@ItemPrice						NUMERIC(18,6)
					,@ItemDescription				NVARCHAR(500)
					,@ItemSiteId					INT
					,@ItemBillingBy					NVARCHAR(200)
					,@ItemPercentFull				NUMERIC(18,6)
					,@ItemNewMeterReading			NUMERIC(18,6)
					,@ItemPreviousMeterReading		NUMERIC(18,6)
					,@ItemConversionFactor			NUMERIC(18,8)
					,@ItemPerformerId				INT
					,@ItemLeaseBilling				BIT
					,@ItemContractHeaderId			INT
					,@ItemContractDetailId			INT
					,@ItemMaintenanceType			NVARCHAR(50)
					,@ItemFrequency					NVARCHAR(50)
					,@ItemMaintenanceDate			DATETIME
					,@ItemMaintenanceAmount			NUMERIC(18,6)
					,@ItemLicenseAmount				NUMERIC(18,6)
					,@ItemTaxGroupId				INT
					
			SELECT TOP 1 @InvoiceDetailId = [intInvoiceDetailId] FROM @InvoiceDetails ORDER BY [intInvoiceDetailId]

			SELECT
				 @ItemId						= [intItemId]			
				,@ItemUOMId						= [intItemUOMId]
				,@ItemQtyShipped				= [dblQtyShipped]
				,@ItemDescription				= [strItemDescription]
				,@ItemSiteId					= [intSiteId]
				,@ItemBillingBy					= [strBillingBy]
				,@ItemPercentFull				= [dblPercentFull]
				,@ItemNewMeterReading			= [dblNewMeterReading]
				,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
				,@ItemConversionFactor			= [dblConversionFactor]
				,@ItemPerformerId				= [intPerformerId]
				,@ItemLeaseBilling				= [ysnLeaseBilling]
				,@ItemContractHeaderId			= [intContractHeaderId]
				,@ItemContractDetailId			= [intContractDetailId]
				,@ItemMaintenanceType			= [strMaintenanceType]
				,@ItemFrequency					= [strFrequency]
				,@ItemMaintenanceDate			= [dtmMaintenanceDate]
				,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
				,@ItemLicenseAmount				= [dblLicenseAmount]
				,@ItemTaxGroupId				= [intTaxGroupId]
			FROM
				tblARInvoiceDetail
			WHERE
				[intInvoiceDetailId] = @InvoiceDetailId

			BEGIN TRY
			EXEC [dbo].[uspARAddInventoryItemToInvoice]
				 @InvoiceId						= @NewId	
				,@ItemId						= @ItemId
				,@NewInvoiceDetailId			= @NewInvoiceDetailId	OUTPUT 
				,@ErrorMessage					= @ErrorMessage	OUTPUT
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
				,@ItemContractHeaderId			= @ItemContractHeaderId
				,@ItemContractDetailId			= @ItemContractDetailId
				,@ItemMaintenanceType			= @ItemMaintenanceType
				,@ItemFrequency					= @ItemFrequency
				,@ItemMaintenanceDate			= @ItemMaintenanceDate
				,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
				,@ItemLicenseAmount				= @ItemLicenseAmount
				,@ItemTaxGroupId				= @ItemTaxGroupId					
			
				IF LEN(ISNULL(@ErrorMessage,'')) > 0
					BEGIN
						RAISERROR(@ErrorMessage, 16, 1);
						RETURN 0;
					END
			END TRY
			BEGIN CATCH
				SET @ErrorMessage = ERROR_MESSAGE();
				RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END CATCH									   	
           			
			DELETE FROM @InvoiceDetails WHERE [intInvoiceDetailId] = @InvoiceDetailId
		END		
	
	EXEC dbo.uspARReComputeInvoiceAmounts @NewId

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewId)

	Return @NewId
END
