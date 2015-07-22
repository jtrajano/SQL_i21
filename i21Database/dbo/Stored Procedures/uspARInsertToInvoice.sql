CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
	@SalesOrderId	  INT = 0,
	@UserId			  INT = 0,
	@HasInventoryItem BIT = 0,
	@InvoiceId		  INT = NULL OUTPUT

	AS
BEGIN

	DECLARE @NewInvoiceId INT,
			@DateOnly DATETIME,
			@dblSalesOrderSubtotal NUMERIC(18, 6),			
			@dblTax	NUMERIC(18, 6),
			@dblSalesOrderTotal NUMERIC(18, 6),
			@dblDiscount NUMERIC(18, 6)

	SELECT @DateOnly = CAST(GETDATE() as date)

	DECLARE @OrderDetails TABLE(intSalesOrderDetailId INT, 
								dblDiscount NUMERIC(18,6), 
								dblTotalTax NUMERIC(18,6), 
								dblPrice NUMERIC(18,6), 
								dblTotal NUMERIC(18,6))
		
	INSERT INTO @OrderDetails (intSalesOrderDetailId, dblDiscount, dblTotalTax, dblPrice, dblTotal)
	SELECT intSalesOrderDetailId
		 , ROUND(dblDiscount,2)
		 , ROUND(dblTotalTax,2)
		 , ROUND(dblPrice,2)
		 , ROUND(dblTotal,2)
		FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId
		WHERE intSalesOrderId = @SalesOrderId AND I.strType = 'Software'
		ORDER BY intSalesOrderDetailId
	
	SELECT @dblSalesOrderSubtotal = SUM(dblPrice)
	     , @dblTax = SUM(dblTotalTax)
		 , @dblSalesOrderTotal = SUM(dblTotal)
		 , @dblDiscount = SUM(dblDiscount)
	FROM @OrderDetails

	--INSERT TO INVOICE HEADER
	INSERT INTO tblARInvoice
		([intEntityCustomerId]
		,[strInvoiceOriginId]
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
		,[strType]
		,[intPaymentMethodId]
		,[intAccountId]
		,[intFreightTermId]
		,[intEntityId]
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
	)
	SELECT
		[intEntityCustomerId]
		,[strSalesOrderNumber] --origin Id
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
		,@dblSalesOrderSubtotal --ROUND([dblSalesOrderSubtotal],2)
		,ROUND([dblShipping],2)
		,@dblTax--ROUND([dblTax],2)
		,@dblSalesOrderTotal--ROUND([dblSalesOrderTotal],2)
		,@dblDiscount--ROUND([dblDiscount],2)
		,ROUND([dblAmountDue],2)
		,ROUND([dblPayment],2)
		,'Invoice'
		,[strType]
		,0 --Payment Method
		,[intAccountId]
		,[intFreightTermId]
		,@UserId
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
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewInvoiceId = SCOPE_IDENTITY()
	
	--INSERT TO INVOICE DETAIL AND INVOICE DETAIL TAX	
						
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
				,[dblDiscount]
				,[dblPrice]
				,[dblTotalTax]
				,[dblTotal]
				,[intAccountId]
				,[intCOGSAccountId]
				,[intSalesAccountId]
				,[intInventoryAccountId]
				,[intSalesOrderDetailId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[strMaintenanceType]
				,[strFrequency]
				,[dblMaintenanceAmount]
				,[dblLicenseAmount]
				,[dtmMaintenanceDate]
				,[intConcurrencyId])
			SELECT 	
				 @NewInvoiceId				--[intInvoiceId]
				,[intItemId]				--[intItemId]
				,[strItemDescription]		--[strItemDescription]
				,[intItemUOMId]				--[intItemUOMId]
				,[dblQtyOrdered]			--[dblQtyOrdered]
				,[dblQtyOrdered]			--[dblQtyShipped]
				,[dblDiscount]              --[dblDiscount]
				,[dblPrice]					--[dblPrice]
				,[dblTotalTax]				--[dblTotalTax]
				,[dblTotal]					--[dblTotal]
				,[intAccountId]				--[intAccountId]
				,[intCOGSAccountId]			--[intCOGSAccountId]
				,[intSalesAccountId]		--[intSalesAccountId]
				,[intInventoryAccountId]	--[intInventoryAccountId]
				,[intSalesOrderDetailId]    --[intSalesOrderDetailId]
				,[intContractHeaderId]		--[intContractHeaderId]
				,[intContractDetailId]		--[intContractDetailId]
				,[strMaintenanceType]		--[strMaintenanceType]
				,[strFrequency]		        --[strFrequency]
				,[dblMaintenanceAmount]		--[dblMaintenanceAmount]
				,[dblLicenseAmount]			--[dblLicenseAmount]
				,[dtmMaintenanceDate]		--[dtmMaintenanceDate]
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
			
	IF (@HasInventoryItem = 0)
		BEGIN
			UPDATE tblSOSalesOrder SET strOrderStatus = 'Closed', ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId
		END

	SET @InvoiceId  = @NewInvoiceId
			
	--INSERT TO RECURRING TRANSACTION
	EXEC dbo.uspARInsertRecurringInvoice @InvoiceId, @UserId
END
