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

	SET @ZeroDecimal	= 0.000000
	SET @EntityId		= ISNULL((SELECT TOP 1 [intEntityUserSecurityId] FROM tblSMUserSecurity WITH (NOLOCK)  WHERE [intEntityUserSecurityId] = @UserId), 0)
	SET @InvoiceDate	= ISNULL(@InvoiceDate, CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GETDATE()))))

	IF ISNULL(@SplitDetailId, 0) > 0 
		BEGIN
			SELECT @intSplitEntityId = intEntityId
			      ,@dblSplitPercent = dblSplitPercent/100
			FROM [tblEMEntitySplitDetail] WITH (NOLOCK)
			WHERE intSplitDetailId = @SplitDetailId
		END

	IF ISNULL(@InvoiceId, 0) = 0
		BEGIN
			RAISERROR(120047, 16, 1)
			RETURN 0
		END

	IF ISNULL(@EntityId, 0) = 0
		BEGIN
			RAISERROR(120048, 16, 1)
			RETURN 0
		END
	
	SELECT TOP 1 
		  @InvoiceType			= strType
		, @TransactionType		= strTransactionType
		, @DistributionHeaderId	= ISNULL(intDistributionHeaderId, intLoadDistributionHeaderId)
	FROM tblARInvoice WITH (NOLOCK)
	WHERE intInvoiceId = @InvoiceId
	
	--VALIDATE INVOICE TYPES
	IF @TransactionType NOT IN ('Invoice', 'Credit Memo') AND @InvoiceType <> 'Standard'  AND ISNULL(@SplitDetailId, 0) = 0
		BEGIN			
			RAISERROR(120072, 16, 1, @InvoiceType)
			RETURN 0
		END

	IF ISNULL(@DistributionHeaderId, 0) > 0 OR @InvoiceType = 'Transport Delivery'
		BEGIN
			RAISERROR(120037, 16, 1)
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
			RAISERROR(120038, 16, 1)
			RETURN 0
		END

	--VALIDATE INVOICES THAT WILL EXCEED SHIPPED QTY
	IF EXISTS(SELECT NULL FROM tblARInvoiceDetail ID
				INNER JOIN tblICInventoryShipmentItem ISHI ON ID.intInventoryShipmentItemId = ISHI.intInventoryShipmentItemId AND ID.intSalesOrderDetailId = ISHI.intLineNo
				WHERE ID.intInvoiceId = @InvoiceId
				  AND ((ID.dblQtyShipped + ID.dblQtyShipped) * @dblSplitPercent) > ISNULL(ISHI.dblQuantity, @ZeroDecimal)) AND ISNULL(@SplitDetailId, 0) = 0
		BEGIN
			RAISERROR(120039, 16, 1)
			RETURN 0
		END

	INSERT INTO tblARInvoice(
		strInvoiceOriginId
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
		,strBOLNumber
		,intConcurrencyId
		,intEntityId)
	SELECT 
		 strInvoiceNumber
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN @intSplitEntityId ELSE intEntityCustomerId END
		,@InvoiceDate
		,dbo.fnGetDueDateBasedOnTerm(@InvoiceDate, intTermId)
		,intCurrencyId
		,intCompanyLocationId
		,[intEntitySalespersonId]
		,@InvoiceDate
		,intShipViaId
		,strPONumber
		,intTermId
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceSubtotal * @dblSplitPercent ELSE dblInvoiceSubtotal END 
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblShipping * @dblSplitPercent ELSE dblShipping END 
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblTax * @dblSplitPercent ELSE dblTax END 
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceTotal * @dblSplitPercent ELSE dblInvoiceTotal END 
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblDiscount * @dblSplitPercent ELSE dblDiscount END 
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN dblInvoiceTotal * @dblSplitPercent ELSE dblInvoiceTotal END 
		,0
		,strTransactionType
		,strType
		,intPaymentMethodId
		,strComments + ' Split: ' + strInvoiceNumber
		,strFooterComments
		,intAccountId
		,intSplitId
		,@InvoiceDate
		,0
		,0
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN 1 ELSE 0 END
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN ISNULL(@dblSplitPercent,1) ELSE 1 END
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
		,strBOLNumber
		,0
		,@EntityId
	FROM 
		tblARInvoice WITH (NOLOCK)
	WHERE
		intInvoiceId = @InvoiceId
				
	SET @NewInvoiceId = SCOPE_IDENTITY()
	
	DECLARE @InvoiceDetails TABLE(intInvoiceDetailId INT)
		
	INSERT INTO @InvoiceDetails
		([intInvoiceDetailId])
	SELECT 	
		 [intInvoiceDetailId]
	FROM
		tblARInvoiceDetail WITH (NOLOCK)
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

			SELECT TOP 1 @InvoiceDetailId = [intInvoiceDetailId] FROM @InvoiceDetails ORDER BY [intInvoiceDetailId]
			
			IF ISNULL(@SplitDetailId, 0) > 0 
				BEGIN
					INSERT INTO [tblARInvoiceDetail]
								([intInvoiceId]
								,[intItemId]
								,[strItemDescription]
								,[intItemUOMId]
								,[dblQtyOrdered]
								,[dblQtyShipped]
								,[dblDiscount]
								,[dblPrice]
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
								,[intConcurrencyId])
							SELECT
								 @NewInvoiceId
								,[intItemId] 
								,[strItemDescription]
								,[intItemUOMId]
								--,[dblQtyShipped] * @dblSplitPercent
								,(CASE WHEN  @TransactionType='Invoice' 
										AND ((intInventoryShipmentItemId is not null OR intSalesOrderDetailId is not null) 
										OR (intInventoryShipmentItemId is null OR intSalesOrderDetailId is null))
			                            THEN dblQtyShipped * @dblSplitPercent  ELSE 0 END)
								,[dblQtyShipped] * @dblSplitPercent
								,[dblDiscount]	  
								,[dblPrice]      --* @dblSplitPercent -- AR-2505
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
								,1
							FROM
								tblARInvoiceDetail WITH (NOLOCK)
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
								,[intSalesTaxAccountId]
								,[dblTax]
								,[dblAdjustedTax]
								,[ysnTaxAdjusted]
								,[ysnSeparateOnInvoice]
								,[ysnCheckoffTax]
								,[ysnTaxExempt]
								,[strNotes] 
								,[intConcurrencyId])
							SELECT @NewInvoiceDetailId
								,[intTaxGroupId]
								,[intTaxCodeId]
								,[intTaxClassId]
								,[strTaxableByOtherTaxes]
								,[strCalculationMethod]
								,[dblRate]
								,[intSalesTaxAccountId]
								,[dblTax] * @dblSplitPercent
								,[dblAdjustedTax] * @dblSplitPercent
								,[ysnTaxAdjusted]
								,[ysnSeparateOnInvoice]
								,[ysnCheckoffTax]
								,[ysnTaxExempt]
								,[strNotes] 
								,1
							FROM tblARInvoiceDetailTax WITH (NOLOCK)
							WHERE intInvoiceDetailId = @InvoiceDetailId
				END
			ELSE
				BEGIN
					SELECT
						 @ItemId						= [intItemId]			
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
						,@ItemSubCurrencyId				= [dblSubCurrencyRate]
					FROM
						tblARInvoiceDetail WITH (NOLOCK)
					WHERE
						[intInvoiceDetailId] = @InvoiceDetailId

					BEGIN TRY
					EXEC [dbo].[uspARAddItemToInvoice]
						 @InvoiceId						= @NewInvoiceId	
						,@ItemId						= @ItemId
						,@NewInvoiceDetailId			= @NewInvoiceDetailId	OUTPUT 
						,@ErrorMessage					= @ErrorMessage	OUTPUT
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
	
	IF ISNULL(@SplitDetailId, 0) = 0 
		EXEC dbo.uspARReComputeInvoiceAmounts @NewInvoiceId
	
	EXEC dbo.uspARInsertTransactionDetail @NewInvoiceId
	EXEC dbo.uspARUpdateInvoiceIntegrations @NewInvoiceId, 0, @UserId		

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId)

END