CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
	@SalesOrderId	INT = 0,
	@UserId			INT = 0,
	@IsSoftware     BIT = 0,
	@InvoiceId		INT = NULL OUTPUT

	AS
BEGIN

	DECLARE @NewInvoiceId INT,
			@DateOnly DATETIME
			
	SELECT @DateOnly = CAST(GETDATE() as date)
	
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
		,[strOrderType]
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
		,[strOrderType]
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewInvoiceId = SCOPE_IDENTITY()
	
	--INSERT TO INVOICE DETAIL AND INVOICE DETAIL TAX
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
				,[dblDiscount]
				,[dblPrice]
				,[dblTotalTax]
				,[dblTotal]
				,[intAccountId]
				,[intCOGSAccountId]
				,[intSalesAccountId]
				,[intInventoryAccountId]
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
			
	
	UPDATE tblSOSalesOrder SET strOrderStatus = 'Closed', ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId
	
	
	SET @InvoiceId  = @NewInvoiceId

	IF (@IsSoftware = 1)
	BEGIN		
		--INSERT TO RECURRING TRANSACTION
		INSERT INTO [tblSMRecurringTransaction]
			([intTransactionId]
			,[strTransactionNumber]
			,[strTransactionType]
			,[strFrequency]
			,[dtmLastProcess]
			,[dtmNextProcess]
			,[ysnDue]
			,[strDayOfMonth]
			,[dtmStartDate]
			,[dtmEndDate]
			,[ysnActive]
			,[intIteration]
			,[intUserId])
		SELECT 
			 @InvoiceId
			,[strInvoiceNumber]
			,'Invoice'
			,'Monthly'
			,[dtmDate]
			,DATEADD(MONTH, 1, [dtmDate])
			,CASE WHEN GETDATE() > [dtmDueDate] THEN 1 ELSE 0 END
			,CONVERT(NVARCHAR(2), DAY([dtmDate]))
			,DATEADD(MONTH, 1, [dtmDate])
			,DATEADD(MONTH, 1, [dtmDate])
			,1
			,1
			,@UserId FROM tblARInvoice
		WHERE intInvoiceId = @InvoiceId
	END
END
