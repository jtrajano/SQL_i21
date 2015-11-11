CREATE PROCEDURE dbo.uspARDuplicateInvoice
	 @InvoiceId			INT
	,@InvoiceDate		DATETIME
	,@UserId			INT
	,@SplitDetailId		INT = NULL	
	,@NewInvoiceNumber	NVARCHAR(25) = NULL	OUTPUT
AS

BEGIN

	DECLARE @EntityId		  INT
		  , @intSplitEntityId INT
		  , @dblSplitPercent  NUMERIC(18,6)
		  , @ZeroDecimal      NUMERIC(18,6)

--THIS IS THE ORIGINAL BEFORE THE MERGE KINDLY CHECK
	--SET @EntityId = ISNULL((SELECT TOP 1 intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @UserId), 0)
	
	SET @ZeroDecimal = 0.000000
	SET @EntityId = ISNULL((SELECT TOP 1 [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId), 0)

	IF ISNULL(@SplitDetailId, 0) > 0 
		BEGIN
			SELECT @intSplitEntityId = intEntityId
			      ,@dblSplitPercent = dblSplitPercent/100
			FROM tblEntitySplitDetail 
			WHERE intSplitDetailId = @SplitDetailId
		END

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
		,ysnSplitted
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
		 CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN strInvoiceNumber ELSE strInvoiceOriginId END 
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
		,strComments
		,intAccountId
		,@InvoiceDate
		,0
		,0
		,CASE WHEN ISNULL(@SplitDetailId, 0) > 0 THEN 1 ELSE 0 END
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
								,[intConcurrencyId])
							SELECT
								 @NewId
								,[intItemId] 
								,[strItemDescription]
								,[intItemUOMId]
								,[dblQtyShipped] * @dblSplitPercent
								,[dblQtyShipped] * @dblSplitPercent
								,[dblDiscount]	  * @dblSplitPercent
								,[dblPrice]      * @dblSplitPercent
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
								,[numRate]
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
								,[numRate]
								,[intSalesTaxAccountId]
								,[dblTax] * @dblSplitPercent
								,[dblAdjustedTax] * @dblSplitPercent
								,[ysnTaxAdjusted]
								,[ysnSeparateOnInvoice]
								,[ysnCheckoffTax]
								,[ysnTaxExempt]
								,[strNotes] 
								,1
							FROM tblARInvoiceDetailTax 
							WHERE intInvoiceDetailId = @InvoiceDetailId
				END
			ELSE
				BEGIN
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
           		END

			DELETE FROM @InvoiceDetails WHERE [intInvoiceDetailId] = @InvoiceDetailId
		END		
	
	IF ISNULL(@SplitDetailId, 0) = 0 
		EXEC dbo.uspARReComputeInvoiceAmounts @NewId

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewId)

	Return @NewId
END
