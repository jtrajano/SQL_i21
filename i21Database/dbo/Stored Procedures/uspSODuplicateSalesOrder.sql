CREATE PROCEDURE [dbo].[uspSODuplicateSalesOrder]
	@TransactionType	NVARCHAR(20) = '',
	@SalesOrderId		INT = 0,
	@OrderStatus		NVARCHAR(20) = '',
	@UserId				INT = 0,
	@SalesOrderDate     DATETIME = NULL,
	@NewSalesOrderId	INT = NULL OUTPUT,
	@NewSalesOrderNo	NVARCHAR(20) = NULL OUTPUT,
	@ForRecurring		BIT	= 0
AS

BEGIN
	SET @SalesOrderDate = CASE WHEN @SalesOrderDate IS NULL THEN GETDATE() ELSE @SalesOrderDate END
		
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
		   ,[intOrderedById]
		   ,[intSplitId]
		   ,[intFreightTermId]
		   ,[strBOLNumber]
           ,[dblSalesOrderSubtotal]
           ,[dblShipping]
           ,[dblTax]
           ,[dblSalesOrderTotal]
           ,[dblDiscount]
           ,[dblAmountDue]
           ,[dblPayment]
           ,[strTransactionType]
		   ,[strQuoteType]
		   ,[strType]
           ,[strOrderStatus]
           ,[intAccountId]
           ,[dtmProcessDate]
           ,[ysnProcessed]
		   ,[ysnRecurring]
           ,[strComments]
		   ,[strFooterComments]
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
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
		   ,[ysnQuote]
		   ,[strLostQuoteComment]
		   ,[strLostQuoteCompetitor]
		   ,[strLostQuoteReason]
        )
	SELECT
			[intEntityCustomerId]
           ,@SalesOrderDate--Date
		   ,[dbo].fnGetDueDateBasedOnTerm(@SalesOrderDate,intTermId) --Due Date
           ,[intCurrencyId]
           ,[intCompanyLocationId]
           ,[intEntitySalespersonId]
           ,[intShipViaId]
           ,[strPONumber]
           ,[intTermId]
		   ,[intOrderedById]
		   ,[intSplitId]
		   ,[intFreightTermId]
		   ,[strBOLNumber]
           ,[dblSalesOrderSubtotal]
           ,[dblShipping]
           ,[dblTax]
           ,[dblSalesOrderTotal]
           ,[dblDiscount]
           ,[dblAmountDue]
           ,[dblPayment]
           ,[strTransactionType]
		   ,[strQuoteType]
		   ,[strType]
           ,@OrderStatus
           ,[intAccountId]
           ,NULL --Processed Date
           ,0 --Processed
		   ,CASE WHEN [ysnRecurring] = 1 AND @ForRecurring = 1
				THEN 0     
				ELSE [ysnRecurring]     
			END   
		   ,CASE WHEN [ysnRecurring] = 1 AND @ForRecurring = 1
				THEN [strComments]
				ELSE [strComments] + ' DUP: ' + [strSalesOrderNumber] 
			END
		   ,[strFooterComments]
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
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
		   ,[ysnQuote]
		   ,[strLostQuoteComment]
		   ,[strLostQuoteCompetitor]
		   ,[strLostQuoteReason]
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewSalesOrderId = SCOPE_IDENTITY()
	SELECT @NewSalesOrderNo = strSalesOrderNumber FROM tblSOSalesOrder WHERE intSalesOrderId = @NewSalesOrderId
	
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
				   ,[dblItemTermDiscount] 
				   ,[intTaxId]
				   ,[dblPrice]
				   ,[strPricing]
				   ,[dblTotalTax] 
				   ,[dblTotal]
				   ,[strComments]
				   ,[intAccountId]
				   ,[intCOGSAccountId]
				   ,[intSalesAccountId]
				   ,[intInventoryAccountId]
				   ,[intStorageLocationId]
				   ,[strMaintenanceType]
				   ,[strFrequency]
	               ,[dtmMaintenanceDate]				   
	               ,[dblMaintenanceAmount]
	               ,[dblLicenseAmount]
				   ,[intContractHeaderId]
				   ,[intContractDetailId]
				   ,[intTaxGroupId] 	
				)
			SELECT 
					@NewSalesOrderId
				   ,[intItemId]
				   ,[strItemDescription]
				   ,[intItemUOMId]
				   ,[dblQtyOrdered]
				   ,[dblQtyAllocated]
				   ,[dblDiscount]
				   ,[dblItemTermDiscount] 
				   ,[intTaxId]
				   ,[dblPrice]
				   ,[strPricing]
				   ,[dblTotalTax]
				   ,[dblTotal]
				   ,[strComments]
				   ,[intAccountId]
				   ,[intCOGSAccountId]
				   ,[intSalesAccountId]
				   ,[intInventoryAccountId]
				   ,[intStorageLocationId]
				   ,[strMaintenanceType]
				   ,[strFrequency]
	               ,[dtmMaintenanceDate]
	               ,[dblMaintenanceAmount]
	               ,[dblLicenseAmount]
				   ,[intContractHeaderId]
				   ,[intContractDetailId]
				   ,[intTaxGroupId] 	
			FROM
				[tblSOSalesOrderDetail]
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
												
			SET @NewSalesOrderDetailId = SCOPE_IDENTITY()
						
			INSERT INTO [tblSOSalesOrderDetailTax]
				([intSalesOrderDetailId]
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
				,[strNotes] 
				,[intConcurrencyId])
			SELECT
			    @NewSalesOrderDetailId
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
			   ,[strNotes] 
			   ,0
			FROM 
				[tblSOSalesOrderDetailTax]
			WHERE
				[intSalesOrderDetailId] = @SalesOrderDetailId
			   	
           			
			DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
		END	

	EXEC dbo.[uspSOUpdateOrderIntegrations] @NewSalesOrderId, 0, 0, @UserId
	
END