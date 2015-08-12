CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
	@SalesOrderId	     INT = 0,
	@UserId			     INT = 0,
	@HasNonSoftwareItems BIT = 0,
	@InvoiceId		     INT = NULL OUTPUT

AS
BEGIN

	DECLARE @customerId             INT,
			@DateOnly				DATETIME,
			@dblSalesOrderSubtotal	NUMERIC(18, 6),			
			@dblTax					NUMERIC(18, 6),
			@dblSalesOrderTotal		NUMERIC(18, 6),
			@dblDiscount			NUMERIC(18, 6)

	SELECT @DateOnly = CAST(GETDATE() AS DATE)

	--COMPUTE INVOICE TOTAL AMOUNTS FOR SOFTWARE
	DECLARE @OrderDetails TABLE(intSalesOrderDetailId	INT, 
								dblDiscount				NUMERIC(18,6), 
								dblTotalTax				NUMERIC(18,6), 
								dblPrice				NUMERIC(18,6), 
								dblTotal				NUMERIC(18,6))

	INSERT INTO @OrderDetails (intSalesOrderDetailId, dblDiscount, dblTotalTax, dblPrice, dblTotal)
	SELECT intSalesOrderDetailId
		 , 0
		 , 0
		 , ROUND(dblMaintenanceAmount,2)
		 , ROUND(dblMaintenanceAmount,2) * dblQtyOrdered
	FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId
		WHERE intSalesOrderId = @SalesOrderId AND ICI.strType = 'Software'
		ORDER BY intSalesOrderDetailId

	SELECT @dblSalesOrderSubtotal = SUM(dblPrice)
	     , @dblTax				  = SUM(dblTotalTax)
		 , @dblSalesOrderTotal	  = SUM(dblTotal)
		 , @dblDiscount			  = SUM(dblDiscount)
	FROM @OrderDetails

	--GET EXISTING RECURRING INVOICE RECORD OF CUSTOMER
	SELECT @customerId = intEntityCustomerId FROM tblSOSalesOrder WHERE intSalesOrderId = @SalesOrderId
	
	IF EXISTS(SELECT NULL FROM tblARInvoice WHERE intEntityCustomerId = @customerId AND ysnTemplate = 1)
		BEGIN
			--UPDATE EXISTING RECURRING INVOICE
			SELECT @InvoiceId = intInvoiceId FROM tblARInvoice WHERE intEntityCustomerId = @customerId AND ysnTemplate = 1
						
			UPDATE tblARInvoice 
			SET dblInvoiceSubtotal = dblInvoiceSubtotal + @dblSalesOrderSubtotal
			  , dblTax			   = dblTax + @dblTax
			  , dblInvoiceTotal    = dblInvoiceTotal + @dblSalesOrderTotal
			  , dblDiscount		   = dblDiscount + @dblDiscount
			  , dtmDate			   = @DateOnly
			  , ysnTemplate		   = 1
			  , strType			   = 'Software'
			  , ysnPosted		   = 1
			WHERE intInvoiceId = @InvoiceId
		END
	ELSE
		BEGIN
			--INSERT TO INVOICE HEADER FOR RECURRING
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
				,[ysnTemplate]
				,[ysnPosted]
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
				,'Software'
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
				,1
				,1
			FROM
			tblSOSalesOrder
			WHERE intSalesOrderId = @SalesOrderId

			SET @InvoiceId = SCOPE_IDENTITY()
		END		
	
	--INSERT TO RECURRING INVOICE DETAIL AND INVOICE DETAIL TAX						
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
				 @InvoiceId					--[intInvoiceId]
				,[intItemId]				--[intItemId]
				,[strItemDescription]		--[strItemDescription]
				,[intItemUOMId]				--[intItemUOMId]
				,[dblQtyOrdered]			--[dblQtyOrdered]
				,[dblQtyOrdered]			--[dblQtyShipped]
				,0							--[dblDiscount]
				,[dblMaintenanceAmount]		--[dblPrice]
				,0							--[dblTotalTax]
				,[dblMaintenanceAmount] * [dblQtyOrdered] --[dblTotal]
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
				,0							--[dblLicenseAmount]
				,[dtmMaintenanceDate]		--[dtmMaintenanceDate]
				,0							--[intConcurrencyId]
			FROM
				tblSOSalesOrderDetail
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
												
			SET @InvoiceDetailId = SCOPE_IDENTITY()
				
			DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
		END
			
	IF (@HasNonSoftwareItems = 0)
		BEGIN
			UPDATE tblSOSalesOrder SET strOrderStatus = 'Closed', ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId
		END
	
	--INSERT NEW INVOICE FOR NON-SOFTWARE ITEMS
	DECLARE @NewInvoiceId			INT			
	DELETE FROM @OrderDetails
	SELECT @dblSalesOrderSubtotal = 0.000000
			, @dblTax				  = 0.000000
			, @dblSalesOrderTotal	  = 0.000000
			, @dblDiscount			  = 0.000000

	INSERT INTO @OrderDetails(intSalesOrderDetailId, dblDiscount, dblTotalTax, dblPrice, dblTotal)
	SELECT intSalesOrderDetailId
			, ROUND(dblDiscount,2)
			, ROUND(dblTotalTax,2)
			, CASE WHEN ICI.strType <> 'Software' THEN ROUND(dblPrice,2) ELSE ROUND(dblLicenseAmount, 2) END
			, CASE WHEN ICI.strType <> 'Software' THEN ROUND(dblTotal,2) ELSE ROUND(dblLicenseAmount, 2) * dblQtyOrdered END
	FROM tblSOSalesOrderDetail SOD LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId 
		WHERE SOD.intSalesOrderId = @SalesOrderId AND (ICI.strType IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') OR ICI.strType IS NULL)
		ORDER BY intSalesOrderDetailId

	SELECT @dblSalesOrderSubtotal = SUM(dblPrice)
			, @dblTax				  = SUM(dblTotalTax)
			, @dblSalesOrderTotal	  = SUM(dblTotal)
			, @dblDiscount			  = SUM(dblDiscount)
	FROM @OrderDetails

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
		,[ysnTemplate]
	)
	SELECT
		[intEntityCustomerId]
		,[strSalesOrderNumber]
		,@DateOnly
		,[dbo].fnGetDueDateBasedOnTerm(@DateOnly,intTermId)
		,@DateOnly
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intEntitySalespersonId]
		,@DateOnly
		,[intShipViaId]
		,[strPONumber]
		,[intTermId]
		,@dblSalesOrderSubtotal
		,ROUND([dblShipping],2)
		,@dblTax
		,@dblSalesOrderTotal
		,@dblDiscount
		,ROUND([dblAmountDue],2)
		,ROUND([dblPayment],2)
		,'Invoice'
		,'Software'
		,0
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
		,0
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewInvoiceId = SCOPE_IDENTITY()

	--INSERT TO RECURRING INVOICE DETAIL AND INVOICE DETAIL TAX						
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderDetails)
		BEGIN
			DECLARE @intSODetailId		INT
					, @intInvoiceDetailId	INT
					
			SELECT TOP 1 @intSODetailId = [intSalesOrderDetailId] FROM @OrderDetails ORDER BY [intSalesOrderDetailId]
			
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
				,SOD.[intItemId]				--[intItemId]
				,[strItemDescription]		--[strItemDescription]
				,[intItemUOMId]				--[intItemUOMId]
				,[dblQtyOrdered]			--[dblQtyOrdered]
				,[dblQtyOrdered]			--[dblQtyShipped]
				,[dblDiscount]              --[dblDiscount]
				,CASE WHEN ICI.strType <> 'Software' THEN [dblPrice] ELSE [dblLicenseAmount] END --[dblPrice]
				,[dblTotalTax]				--[dblTotalTax]
				,CASE WHEN ICI.strType <> 'Software' THEN [dblTotal] ELSE [dblLicenseAmount] * [dblQtyOrdered] END --[dblTotal]
				,[intAccountId]				--[intAccountId]
				,[intCOGSAccountId]			--[intCOGSAccountId]
				,[intSalesAccountId]		--[intSalesAccountId]
				,[intInventoryAccountId]	--[intInventoryAccountId]
				,[intSalesOrderDetailId]    --[intSalesOrderDetailId]
				,[intContractHeaderId]		--[intContractHeaderId]
				,[intContractDetailId]		--[intContractDetailId]
				,[strMaintenanceType]		--[strMaintenanceType]
				,[strFrequency]		        --[strFrequency]
				,0							--[dblMaintenanceAmount]
				,[dblLicenseAmount]			--[dblLicenseAmount]
				,[dtmMaintenanceDate]		--[dtmMaintenanceDate]
				,0							--[intConcurrencyId]
			FROM
				tblSOSalesOrderDetail SOD
					LEFT JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId
			WHERE
				[intSalesOrderDetailId] = @intSODetailId
												
			SET @intInvoiceDetailId = SCOPE_IDENTITY()
						
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
				@intInvoiceDetailId
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
				[intSalesOrderDetailId] = @intSODetailId			   	
           			
			DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @intSODetailId
		END
	
	--INSERT TO RECURRING TRANSACTION
	IF @InvoiceId <> NULL OR @InvoiceId <> 0
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMRecurringTransaction WHERE intTransactionId = @InvoiceId)
				BEGIN
					EXEC dbo.uspARInsertRecurringInvoice @InvoiceId, @UserId
				END
		END	

END