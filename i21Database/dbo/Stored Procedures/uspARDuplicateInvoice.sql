﻿CREATE PROCEDURE dbo.uspARDuplicateInvoice
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
			DECLARE @InvoiceDetailId INT
					,@NewInvoiceDetailId INT
					
			SELECT TOP 1 @InvoiceDetailId = [intInvoiceDetailId] FROM @InvoiceDetails ORDER BY [intInvoiceDetailId]
			
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
				,[intConcurrencyId])
			SELECT 	
				 @NewId						--[intInvoiceId]
				,[intItemId]				--[intItemId]
				,[strItemDescription]		--[strItemDescription]
				,[intItemUOMId]				--[intItemUOMId]
				,[dblQtyShipped]			--[dblQtyOrdered]
				,[dblQtyShipped]			--[dblQtyShipped]
				,[dblDiscount] 				--[[dblDiscount]]
				,[dblPrice]					--[dblPrice]
				,[dblTotalTax]				--[dblTotalTax]
				,[dblTotal]					--[dblTotal]
				,[intAccountId]				--[intAccountId]
				,[intCOGSAccountId]			--[intCOGSAccountId]
				,[intSalesAccountId]		--[intSalesAccountId]
				,[intInventoryAccountId]	--[intInventoryAccountId]
				,0							--[intConcurrencyId]
			FROM
				[tblARInvoiceDetail]
			WHERE
				[intInvoiceDetailId] = @InvoiceDetailId
												
			SET @NewInvoiceDetailId = SCOPE_IDENTITY()
						
			INSERT INTO [tblARInvoiceDetailTax]
				([intInvoiceDetailId]
				,[intTaxGroupMasterId]
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
				,[intConcurrencyId])
			SELECT
			    @NewInvoiceDetailId
			   ,[intTaxGroupMasterId]
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
			   ,0
			FROM 
				[tblARInvoiceDetailTax]
			WHERE
				[intInvoiceDetailId] = @InvoiceDetailId
			   	
           			
			DELETE FROM @InvoiceDetails WHERE [intInvoiceDetailId] = @InvoiceDetailId
		END		

	SET  @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewId)

	Return @NewId
END
