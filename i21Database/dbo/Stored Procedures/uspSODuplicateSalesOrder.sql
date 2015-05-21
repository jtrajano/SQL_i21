CREATE PROCEDURE [dbo].[uspSODuplicateSalesOrder]
	@SalesOrderId	INT = 0,
	@UserId			INT = 0,
	@NewSalesOrderId INT = NULL OUTPUT

	AS
BEGIN
		
	INSERT INTO tblSOSalesOrder
		(   [intEntityCustomerId]
           ,[dtmDate]
           ,[dtmDueDate]
           ,[intCurrencyId]
           ,[intCompanyLocationId]
           ,[intEntitySalespersonId]
           ,[intShipViaId]
           ,[strPONumber]
           ,[intTermId]
           ,[dblSalesOrderSubtotal]
           ,[dblShipping]
           ,[dblTax]
           ,[dblSalesOrderTotal]
           ,[dblDiscount]
           ,[dblAmountDue]
           ,[dblPayment]
           ,[strTransactionType]
           ,[strOrderStatus]
           ,[intAccountId]
           ,[dtmProcessDate]
           ,[ysnProcessed]
           ,[strComments]
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
           ,[intEntityId]
        )
	SELECT
			[intEntityCustomerId]
           ,GETDATE() --Date
		   ,[dbo].fnGetDueDateBasedOnTerm(GETDATE(),intTermId) --Due Date
           ,[intCurrencyId]
           ,[intCompanyLocationId]
           ,[intEntitySalespersonId]
           ,[intShipViaId]
           ,[strPONumber]
           ,[intTermId]
           ,[dblSalesOrderSubtotal]
           ,[dblShipping]
           ,[dblTax]
           ,[dblSalesOrderTotal]
           ,[dblDiscount]
           ,[dblAmountDue]
           ,[dblPayment]
           ,[strTransactionType]
           ,'Pending'
           ,[intAccountId]
           ,NULL --Processed Date
           ,0 --Processed
           ,[strComments] + ' DUP: ' + [strSalesOrderNumber]
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
           ,@UserId
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewSalesOrderId = SCOPE_IDENTITY()
	
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
					,@NewSalesOrderDetailId INT
					
			SELECT TOP 1 @SalesOrderDetailId = [intSalesOrderDetailId] FROM @OrderDetails ORDER BY [intSalesOrderDetailId]
			
			INSERT INTO [tblSOSalesOrderDetail]
			   (	[intSalesOrderId]
				   ,[intItemId]
				   ,[strItemDescription]
				   ,[intItemUOMId]
				   ,[dblQtyOrdered]
				   ,[dblQtyAllocated]
				   ,[dblDiscount]
				   ,[intTaxId]
				   ,[dblPrice]
				   ,[dblTotalTax] 
				   ,[dblTotal]
				   ,[strComments]
				   ,[intAccountId]
				   ,[intCOGSAccountId]
				   ,[intSalesAccountId]
				   ,[intInventoryAccountId]
				   ,[intStorageLocationId]
				)
			SELECT 
					@NewSalesOrderId
				   ,[intItemId]
				   ,[strItemDescription]
				   ,[intItemUOMId]
				   ,[dblQtyOrdered]
				   ,[dblQtyAllocated]
				   ,[dblDiscount]
				   ,[intTaxId]
				   ,[dblPrice]
				   ,[dblTotalTax]
				   ,[dblTotal]
				   ,[strComments]
				   ,[intAccountId]
				   ,[intCOGSAccountId]
				   ,[intSalesAccountId]
				   ,[intInventoryAccountId]
				   ,[intStorageLocationId]
			FROM
				[tblSOSalesOrderDetail]
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
												
			SET @NewSalesOrderDetailId = SCOPE_IDENTITY()
						
			INSERT INTO [tblSOSalesOrderDetailTax]
				([intSalesOrderDetailId]
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
			    @NewSalesOrderDetailId
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

	
END