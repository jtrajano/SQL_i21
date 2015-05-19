CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
	@SalesOrderId	INT = 0,
	@UserId			INT = 0,
	@InvoiceId		INT = NULL OUTPUT

	AS
BEGIN

	DECLARE @NewInvoiceId INT,
			@DateOnly DATETIME
			
	SELECT @DateOnly = CAST(GETDATE() as date)
	
	INSERT INTO tblARInvoice
		([intEntityCustomerId]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmPostDate]
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
		,[intPaymentMethodId]
		,[intAccountId]
		,[intEntityId]
		,[strShipToLocationName]
		,[strShipToAddress]
		,[strShipToCity]
		,[strShipToState]
		,[strShipToZipCode]
		,[strShipToCountry]
		,[strBillToLocationName]
		,[strBillToAddress]
		,[strBillToCity]
		,[strBillToState]
		,[strBillToZipCode]
		,[strBillToCountry]
	)
	SELECT
		[intEntityCustomerId]
		,@DateOnly --Date
		,[dbo].fnGetDueDateBasedOnTerm(@DateOnly,intTermId) --Due Date
		,@DateOnly --Post Date
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intEntitySalespersonId]
		,@DateOnly --Ship Date
		,[intShipViaId]
		,[strPONumber]
		,[intTermId]
		,ROUND([dblSalesOrderSubtotal],2)
		,ROUND([dblShipping],2)
		,ROUND([dblTax],2)
		,ROUND([dblSalesOrderTotal],2)
		,ROUND([dblDiscount],2)
		,ROUND([dblAmountDue],2)
		,ROUND([dblPayment],2)
		,'Invoice'
		,0 --Payment Method
		,[intAccountId]
		,@UserId
		,[strShipToLocationName]
		,[strShipToAddress]
		,[strShipToCity]
		,[strShipToState]
		,[strShipToZipCode]
		,[strShipToCountry]
		,[strBillToLocationName]
		,[strBillToAddress]
		,[strBillToCity]
		,[strBillToState]
		,[strBillToZipCode]
		,[strBillToCountry]
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewInvoiceId = SCOPE_IDENTITY()
	
	
	DECLARE @OrderDetails TABLE(intSalesOrderDetailId INT)
		
	INSERT INTO @OrderDetails
		([intSalesOrderDetailId])
	SELECT 	
		 [intSalesOrderDetailId]
	FROM
		tblSOSalesOrderDetail
	WHERE
		[intSalesOrderId] = @SalesOrderId
	ORDER BY
		[intSalesOrderDetailId]
						
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderDetails)
		BEGIN
			DECLARE @SalesOrderDetailId INT
					,@InvoiceDetailId INT
					
			SELECT TOP 1 @SalesOrderDetailId = [intSalesOrderDetailId] FROM @OrderDetails ORDER BY [intSalesOrderDetailId]
			
			INSERT INTO [tblARInvoiceDetail]
				([intInvoiceId]
				,[intItemId]
				,[strItemDescription]
				,[intItemUOMId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblPrice]
				,[dblTotalTax]
				,[dblTotal]
				,[intAccountId]
				,[intCOGSAccountId]
				,[intSalesAccountId]
				,[intInventoryAccountId]
				,[intConcurrencyId])
			SELECT 	
				 @NewInvoiceId				--[intInvoiceId]
				,[intItemId]				--[intItemId]
				,[strItemDescription]		--[strItemDescription]
				,[intItemUOMId]				--[intItemUOMId]
				,[dblQtyOrdered]			--[dblQtyOrdered]
				,[dblQtyOrdered]			--[dblQtyShipped]
				,[dblPrice]					--[dblPrice]
				,[dblTotalTax]				--[dblTotalTax]
				,[dblTotal]					--[dblTotal]
				,[intAccountId]				--[intAccountId]
				,[intCOGSAccountId]			--[intCOGSAccountId]
				,[intSalesAccountId]		--[intSalesAccountId]
				,[intInventoryAccountId]	--[intInventoryAccountId]
				,0							--[intConcurrencyId]
			FROM
				tblSOSalesOrderDetail
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
												
			SET @InvoiceDetailId = SCOPE_IDENTITY()
						
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
			    @InvoiceDetailId
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
				[tblSOSalesOrderDetailTax]
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
			   	
           			
			DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
		END
			
	
	UPDATE tblSOSalesOrder SET strOrderStatus = 'Complete', ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId
	
	
	SET @InvoiceId  = @NewInvoiceId
END
