CREATE PROCEDURE dbo.uspARSplitInvoice
	 @InvoiceId			INT
	,@InvoiceDate		DATETIME		= NULL
	,@UserId			INT				= NULL
	,@SplitDetailId		INT				= NULL	
	,@NewInvoiceNumber	NVARCHAR(25)	= NULL OUTPUT
	,@NewInvoiceId		INT				= NULL OUTPUT
AS

BEGIN

	DECLARE @EntityId				INT
		  , @intSplitEntityId		INT
		  , @dblSplitPercent		NUMERIC(18,6)
		  , @ZeroDecimal			NUMERIC(18,6)
		  , @InvoiceType			NVARCHAR(50)
		  , @TransactionType		NVARCHAR(50)
		  , @DistributionHeaderId	INT
		  , @errorMsg				NVARCHAR(500)
		  , @ysnTaxExempt			BIT
	SELECT @ysnTaxExempt = ysnTaxExempt FROM vyuARCustomerSearch WHERE intEntityCustomerId = @intSplitEntityId
	SET @ZeroDecimal	= 0.000000
	SET @EntityId		= ISNULL((SELECT TOP 1 [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), 0)
	SET @InvoiceDate	= ISNULL(@InvoiceDate, CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GETDATE()))))

	DECLARE @SplitId 				INT
	DECLARE @SplitNumber			NVARCHAR(50)
	DECLARE @NewDocumentId			INT
	IF ISNULL(@SplitDetailId, 0) > 0 
		BEGIN
			SELECT @intSplitEntityId = intEntityId
			      ,@dblSplitPercent = dblSplitPercent/100
				  ,@SplitId = intSplitId
			FROM [tblEMEntitySplitDetail]
			WHERE intSplitDetailId = @SplitDetailId
			
		END

	IF ISNULL(@InvoiceId, 0) = 0
		BEGIN
			RAISERROR('Invoice Id is required.', 16, 1)
			RETURN 0
		END

	IF ISNULL(@EntityId, 0) = 0
		BEGIN
			RAISERROR('Invalid User Id.', 16, 1)
			RETURN 0
		END
	
	SELECT TOP 1 
		  @InvoiceType			= strType
		, @TransactionType		= strTransactionType
		, @DistributionHeaderId	= ISNULL(intDistributionHeaderId, intLoadDistributionHeaderId)
	FROM tblARInvoice
	WHERE intInvoiceId = @InvoiceId
	
	--VALIDATE INVOICE TYPES
	IF @TransactionType NOT IN ('Invoice', 'Credit Memo') AND @InvoiceType <> 'Standard'  AND ISNULL(@SplitDetailId, 0) = 0
		BEGIN			
			RAISERROR('Unable to duplicate %s Invoice Type.', 16, 1, @InvoiceType)
			RETURN 0
		END

	IF ISNULL(@DistributionHeaderId, 0) > 0 OR @InvoiceType = 'Transport Delivery'
		BEGIN
			RAISERROR('Duplicating of Transport Delivery Invoice type is not allowed.', 16, 1)
			RETURN 0
		END

	--VALIDATE INVOICES THAT HAS CONTRACTS
	IF EXISTS(SELECT NULL FROM tblARInvoiceDetail ID 
				INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
				INNER JOIN tblCTContractHeader CH ON ID.intContractHeaderId = CH.intContractHeaderId
				WHERE ID.intInvoiceId = @InvoiceId
					AND CH.ysnUnlimitedQuantity = 0
					AND ISNULL(CD.dblBalance, @ZeroDecimal) - ID.dblQtyShipped < @ZeroDecimal)
		BEGIN
			RAISERROR('There are items that will exceed the contract quantity.', 16, 1)
			RETURN 0
		END

	--VALIDATE INVOICES THAT WILL EXCEED SHIPPED QTY
	IF EXISTS(SELECT NULL FROM tblARInvoiceDetail ID
				INNER JOIN tblICInventoryShipmentItem ISHI ON ID.intInventoryShipmentItemId = ISHI.intInventoryShipmentItemId AND ID.intSalesOrderDetailId = ISHI.intLineNo
				WHERE ID.intInvoiceId = @InvoiceId
				  AND ((ID.dblQtyShipped + ID.dblQtyShipped) * @dblSplitPercent) > ISNULL(ISHI.dblQuantity, @ZeroDecimal)) AND ISNULL(@SplitDetailId, 0) = 0
		BEGIN
			RAISERROR('There are items that will exceed the shipped quantity.', 16, 1)
			RETURN 0
		END

	INSERT INTO tblARInvoice(
		strInvoiceOriginId
		,intOriginalInvoiceId
		,intEntityCustomerId
		,dtmDate
		,dtmDueDate
		,intCurrencyId
		,intCompanyLocationId
		,intEntitySalespersonId
		,dtmShipDate
		,intShipViaId
		,strPONumber
		,intTermId
		,intEntityContactId
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
		,strFooterComments
		,intAccountId
		,intSplitId
		,dtmPostDate
		,ysnPosted
		,ysnPaid
		,ysnSplitted
		,dblSplitPercent 
		,intFreightTermId
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
		,strBOLNumber
		,intConcurrencyId
		,intEntityId)
	SELECT 
		 strInvoiceOriginId		= I.strInvoiceNumber
		,intOriginalInvoiceId	= I.intInvoiceId
		,intEntityCustomerId	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intEntityCustomerId ELSE I.intEntityCustomerId END
		,dtmDate				= @InvoiceDate
		,dtmDueDate				= dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intTermsId ELSE I.intTermId END)
		,intCurrencyId			= I.intCurrencyId
		,intCompanyLocationId	= I.intCompanyLocationId
		,intEntitySalespersonId	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intSalespersonId ELSE I.intEntitySalespersonId END
		,dtmShipDate			= @InvoiceDate
		,intShipViaId			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intShipViaId ELSE I.intShipViaId END
		,strPONumber			= I.strPONumber
		,intTermId				= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intTermsId ELSE I.intTermId END
		,intEntityContactId		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intEntityContactId ELSE I.intEntityContactId END
		,dblInvoiceSubtotal		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceSubtotal * @dblSplitPercent ELSE dblInvoiceSubtotal END 
		,dblShipping			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblShipping * @dblSplitPercent ELSE dblShipping END 
		,dblTax					= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblTax * @dblSplitPercent ELSE dblTax END 
		,dblInvoiceTotal		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceTotal * @dblSplitPercent ELSE dblInvoiceTotal END 
		,dblDiscount			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblDiscount * @dblSplitPercent ELSE dblDiscount END 
		,dblAmountDue			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceTotal * @dblSplitPercent ELSE dblInvoiceTotal END 
		,dblPayment				= 0
		,strTransactionType		= I.strTransactionType
		,strType				= I.strType
		,intPaymentMethodId		= I.intPaymentMethodId
		,strComments			= I.strComments + ' Split: ' + I.strInvoiceNumber
		,strFooterComments		= I.strFooterComments
		,intAccountId			= I.intAccountId
		,intSplitId				= I.intSplitId
		,dtmPostDate			= @InvoiceDate
		,ysnPosted				= 0
		,ysnPaid				= 0
		,ysnSplitted			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN 1 ELSE 0 END
		,dblSplitPercent		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN ISNULL(@dblSplitPercent,1) ELSE 1 END
		,intFreightTermId		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intFreightTermId ELSE I.intFreightTermId END
		,intShipToLocationId	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intShipToId ELSE I.intShipToLocationId END
		,strShipToLocationName	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToLocationName ELSE I.strShipToLocationName END
		,strShipToAddress		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToAddress ELSE I.strShipToAddress END
		,strShipToCity			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToCity ELSE I.strShipToCity END
		,strShipToState			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToState ELSE I.strShipToState END
		,strShipToZipCode		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToZipCode ELSE I.strShipToZipCode END
		,strShipToCountry		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strShipToCountry ELSE I.strShipToCountry END
		,intBillToLocationId	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.intBillToId ELSE I.intBillToLocationId END
		,strBillToLocationName	= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToLocationName ELSE I.strBillToLocationName END
		,strBillToAddress		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToAddress ELSE I.strBillToAddress END
		,strBillToCity			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToCity ELSE I.strBillToCity END
		,strBillToState			= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToState ELSE I.strBillToState END
		,strBillToZipCode		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToZipCode ELSE I.strBillToZipCode END
		,strBillToCountry		= CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN SPLITENTITY.strBillToCountry ELSE I.strBillToCountry END
		,strBOLNumber			= I.strBOLNumber
		,intConcurrencyId		= 0
		,intEntityId			= @EntityId
	FROM tblARInvoice I
	LEFT JOIN (
		SELECT intEntityCustomerId
			 , intShipViaId
			 , intTermsId
			 , intSalespersonId
			 , intBillToId
			 , intShipToId
			 , intFreightTermId
			 , intEntityContactId
			 , strShipToLocationName
			 , strShipToAddress
			 , strShipToCity
			 , strShipToState
			 , strShipToZipCode
			 , strShipToCountry
			 , strBillToLocationName
			 , strBillToAddress
			 , strBillToCity
			 , strBillToState
			 , strBillToZipCode
			 , strBillToCountry
		FROM vyuARCustomerSearch
	) SPLITENTITY ON SPLITENTITY.intEntityCustomerId = @intSplitEntityId
	WHERE
		intInvoiceId = @InvoiceId
				
	SET @NewInvoiceId = SCOPE_IDENTITY()
	
	IF ISNULL(@SplitId, 0) > 0
	BEGIN
		SELECT TOP 1 @SplitNumber =  strSplitNumber FROM tblEMEntitySplit WHERE intSplitId = @SplitId

		IF ISNULL(@SplitNumber, '') <> ''
		BEGIN

			DECLARE @DocumentHeader AS NVARCHAR(MAX)
			DECLARE @DocumentMessage AS NVARCHAR(MAX)
			DECLARE @CustomerId		AS INT
			DECLARE @CompanyId 		AS INT
			DECLARE @DocumentId		AS INT
			SELECT TOP 1 
				@DocumentHeader = 'Split: ' + I.strInvoiceNumber,
				@DocumentMessage = 'Split: ' + I.strInvoiceNumber + '<br/> ' + @SplitNumber ,
				@CustomerId = I.intEntityCustomerId,
				@CompanyId = I.intCompanyLocationId
			FROM tblARInvoice I where I.intInvoiceId = @InvoiceId

			

			
			exec [uspSMCreateDocumentMaintenance] 
				@title = @DocumentHeader,
				@companyLocation = @CompanyId,
				@customerId	= @CustomerId,
				@source = 'Invoice',
				@message = @DocumentMessage,
				@newId = @DocumentId output

			UPDATE tblARInvoice 
				SET intDocumentMaintenanceId = @DocumentId,
						strComments = @DocumentMessage
					WHERE intInvoiceId = @NewInvoiceId

		END	
	END

	


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
					,@ItemOrderUOMId				INT
					,@ItemQtyOrdered				NUMERIC(18,6)
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
					,@ItemDocumentNumber			NVARCHAR(100)
					,@ItemInventoryShipmentItemId	INT
					,@ItemShipmentNumber			NVARCHAR(50)
					,@ItemSalesOrderDetailId		INT
					,@ItemSalesOrderNumber			NVARCHAR(50)
					,@ItemWeight					NUMERIC(18,6)
					,@EntitySalespersonId			INT
					,@ItemSubCurrencyId				INT
					,@ItemSubCurrencyRate			NUMERIC(18,8)
					,@ItemSubLocationId				INT
					,@ItemStorageLocationId			INT

			SELECT TOP 1 @InvoiceDetailId = [intInvoiceDetailId] FROM @InvoiceDetails ORDER BY [intInvoiceDetailId]
			
			IF ISNULL(@SplitDetailId, 0) > 0 
				BEGIN
					INSERT INTO [tblARInvoiceDetail]
								([intInvoiceId]
								,[intItemId]
								,[strItemDescription]
								,[strDocumentNumber]
								,[intOrderUOMId]
								,[intItemUOMId]
								,[dblQtyOrdered]
								,[dblQtyShipped]
								,[dblDiscount]
								,[dblPrice]
								,[strPricing]
								,[dblTotalTax]
								,[dblTotal]
								,[intAccountId]
								,[intCOGSAccountId]
								,[intSalesAccountId]
								,[intInventoryAccountId]
								,[intServiceChargeAccountId]
								,[intInventoryShipmentItemId]
								,[strShipmentNumber]
								,[intSalesOrderDetailId]
								,[strSalesOrderNumber]
								,[intSiteId]
								,[strBillingBy]
								,[dblPercentFull]
								,[dblNewMeterReading]
								,[dblPreviousMeterReading]
								,[dblConversionFactor]
								,[intPerformerId]
								,[intContractHeaderId]
								,[strMaintenanceType]
								,[strFrequency]
								,[dtmMaintenanceDate]
								,[dblMaintenanceAmount]
								,[dblLicenseAmount]
								,[intContractDetailId]
								,[intTicketId]
								,[ysnLeaseBilling]
								,[intTaxGroupId]
								,[intSubCurrencyId]
								,[dblSubCurrencyRate]
								,[intStorageLocationId]
								,[intCompanyLocationSubLocationId]
								,[intSubLocationId]
								,[intConcurrencyId])
							SELECT
								 @NewInvoiceId
								,[intItemId] 
								,[strItemDescription]
								,[strDocumentNumber]
								,[intOrderUOMId]
								,[intItemUOMId]
								,(CASE WHEN  @TransactionType='Invoice' 
										AND ((intInventoryShipmentItemId is not null OR intSalesOrderDetailId is not null))
			                            THEN dblQtyShipped * @dblSplitPercent  ELSE 0 END)
								,[dblQtyShipped] * @dblSplitPercent
								,[dblDiscount]	  
								,[dblPrice]
								,[strPricing]
								,[dblTotalTax]   * @dblSplitPercent
								,[dblTotal]      * @dblSplitPercent
								,[intAccountId] 
								,[intCOGSAccountId] 
								,[intSalesAccountId]
								,[intInventoryAccountId]
								,[intServiceChargeAccountId]
								,[intInventoryShipmentItemId]
								,[strShipmentNumber]
								,[intSalesOrderDetailId]
								,[strSalesOrderNumber]
								,[intSiteId]
								,[strBillingBy]
								,[dblPercentFull]
								,[dblNewMeterReading]
								,[dblPreviousMeterReading]
								,[dblConversionFactor]
								,[intPerformerId]
								,[intContractHeaderId]
								,[strMaintenanceType]
								,[strFrequency]
								,[dtmMaintenanceDate]
								,[dblMaintenanceAmount]
								,[dblLicenseAmount]
								,[intContractDetailId]
								,[intTicketId]
								,[ysnLeaseBilling]
								,[intTaxGroupId]
								,[intSubCurrencyId]
								,[dblSubCurrencyRate]
								,[intStorageLocationId]
								,[intCompanyLocationSubLocationId]
								,[intSubLocationId]
								,1
							FROM
								tblARInvoiceDetail
							WHERE
								[intInvoiceDetailId] = @InvoiceDetailId
												
							SET @NewInvoiceDetailId = SCOPE_IDENTITY()

							INSERT INTO tblARInvoiceDetailTax
								([intInvoiceDetailId]
								,[intTaxGroupId]
								,[intTaxCodeId]
								,[intTaxClassId]
								,[strTaxableByOtherTaxes]
								,[strCalculationMethod]
								,[dblRate]
								,[dblBaseRate]
								,[intSalesTaxAccountId]
								,[dblTax]
								,[dblAdjustedTax]
								,[ysnTaxAdjusted]
								,[ysnSeparateOnInvoice]
								,[ysnCheckoffTax]
								,[ysnTaxExempt]
								,[ysnInvalidSetup]
								,[strNotes] 
								,[intConcurrencyId])
							SELECT @NewInvoiceDetailId
								,[intTaxGroupId]
								,[intTaxCodeId]
								,[intTaxClassId]
								,[strTaxableByOtherTaxes]
								,[strCalculationMethod]
								,[dblRate]
								,[dblBaseRate]
								,[intSalesTaxAccountId]
								,[dblTax] * @dblSplitPercent
								,[dblAdjustedTax] * @dblSplitPercent
								,[ysnTaxAdjusted]
								,[ysnSeparateOnInvoice]
								,[ysnCheckoffTax]
								,@ysnTaxExempt
								,[ysnInvalidSetup]
								,[strNotes] 
								,1
							FROM tblARInvoiceDetailTax 
							WHERE intInvoiceDetailId = @InvoiceDetailId
				END
			ELSE
				BEGIN
					SELECT
						 @ItemId						= [intItemId]		
						,@ItemOrderUOMId				= [intOrderUOMId]	
						,@ItemUOMId						= [intItemUOMId]
						,@ItemQtyOrdered				= [dblQtyOrdered]
						,@ItemQtyShipped				= [dblQtyShipped]
						,@ItemDescription				= [strItemDescription]
						,@ItemPrice						= [dblPrice]						
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
						,@ItemDocumentNumber			= [strDocumentNumber]
						,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
						,@ItemShipmentNumber			= [strShipmentNumber]
						,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
						,@ItemSalesOrderNumber			= [strSalesOrderNumber]
						,@ItemWeight					= [dblItemWeight]
						,@EntitySalespersonId			= [intEntitySalespersonId]
						,@ItemSubCurrencyId				= [intSubCurrencyId]
						,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
						,@ItemSubLocationId				= [intSubLocationId]
						,@ItemStorageLocationId			= [intStorageLocationId]
					FROM
						tblARInvoiceDetail
					WHERE
						[intInvoiceDetailId] = @InvoiceDetailId

					BEGIN TRY
					EXEC [dbo].[uspARAddItemToInvoice]
						 @InvoiceId						= @NewInvoiceId	
						,@ItemId						= @ItemId
						,@NewInvoiceDetailId			= @NewInvoiceDetailId	OUTPUT 
						,@ErrorMessage					= @ErrorMessage	OUTPUT
						,@ItemOrderUOMId				= @ItemOrderUOMId
						,@ItemUOMId						= @ItemUOMId
						,@ItemQtyOrdered				= @ItemQtyOrdered
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
						,@ItemSubCurrencyId				= @ItemSubCurrencyId
						,@ItemSubCurrencyRate			= @ItemSubCurrencyRate	
						,@ItemSublocationId				= @ItemSubLocationId
						,@ItemStorageLocationId			= @ItemStorageLocationId

						IF LEN(ISNULL(@ErrorMessage,'')) > 0
							BEGIN
								RAISERROR(@ErrorMessage, 11, 1);
								RETURN 0;
							END				
					END TRY
					BEGIN CATCH
						SET @ErrorMessage = ERROR_MESSAGE();
						RAISERROR(@ErrorMessage, 11, 1);
						RETURN 0;
					END CATCH									   	
           		END

			DELETE FROM @InvoiceDetails WHERE [intInvoiceDetailId] = @InvoiceDetailId
		END		
	
	EXEC dbo.uspARReComputeInvoiceTaxes @NewInvoiceId
	EXEC dbo.uspARInsertTransactionDetail @NewInvoiceId, @UserId
	--EXEC dbo.[uspSOUpdateOrderShipmentStatus] @NewInvoiceId, 'Invoice', 1
	EXEC dbo.uspARUpdateInvoiceIntegrations @NewInvoiceId, 0, @UserId		

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId)

END