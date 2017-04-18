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
	DECLARE @ysnRecurringDuplicate BIT = 0

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
		   ,[dblBaseSalesOrderSubtotal]
           ,[dblShipping]
		   ,[dblBaseShipping]
           ,[dblTax]
		   ,[dblBaseTax]
           ,[dblSalesOrderTotal]
		   ,[dblBaseSalesOrderTotal]
           ,[dblDiscount]
		   ,[dblBaseDiscount]
           ,[dblAmountDue]
		   ,[dblBaseAmountDue]
           ,[dblPayment]
		   ,[dblBasePayment]
           ,[strTransactionType]
		   ,[strQuoteType]
		   ,[strType]
           ,[strOrderStatus]
           ,[intAccountId]
           ,[dtmProcessDate]
		   ,[dtmExpirationDate]
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
		   ,[intEntityContactId]
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
		   ,[ysnQuote]
		   ,[strLostQuoteComment]
		   ,[strLostQuoteCompetitor]
		   ,[strLostQuoteReason]
		   ,[dblTotalWeight]
		   ,[dblTotalTermDiscount]
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
		   ,[dblBaseSalesOrderSubtotal]
           ,[dblShipping]
		   ,[dblBaseShipping]
           ,[dblTax]
		   ,[dblBaseTax]
           ,[dblSalesOrderTotal]
		   ,[dblBaseSalesOrderTotal]
           ,[dblDiscount]
		   ,[dblBaseDiscount]
           ,[dblAmountDue]
		   ,[dblBaseAmountDue]
           ,[dblPayment]
		   ,[dblBasePayment]
           ,[strTransactionType]
		   ,[strQuoteType]
		   ,[strType]
           ,CASE WHEN  @ForRecurring = 1 THEN 'Open' ELSE ISNULL(@OrderStatus, 'Open') END
           ,[intAccountId]
           ,NULL --Processed Date
		   ,[dtmExpirationDate]
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
		   ,[intEntityContactId]
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
		   ,[ysnQuote]
		   ,[strLostQuoteComment]
		   ,[strLostQuoteCompetitor]
		   ,[strLostQuoteReason]
		   ,[dblTotalWeight]
		   ,[dblTotalTermDiscount]
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
				   ,[dblBasePrice]
				   ,[strPricing]
				   ,[dblTotalTax] 
				   ,[dblBaseTotalTax] 
				   ,[dblTotal]
				   ,[dblBaseTotal]
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
				   ,[dblBaseMaintenanceAmount]
	               ,[dblLicenseAmount]
				   ,[dblBaseLicenseAmount]
				   ,[intContractHeaderId]
				   ,[intContractDetailId]
				   ,[intTaxGroupId] 
				   ,[dblItemWeight]	
				   ,[dblOriginalItemWeight]
				   ,[intItemWeightUOMId]
				   ,[intStorageScheduleTypeId]	
				   ,[intSubCurrencyId]
				   ,[dblSubCurrencyRate]
				   ,[strVFDDocumentNumber]
				   ,[intCurrencyExchangeRateTypeId]
				   ,[dblCurrencyExchangeRate]
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
				   ,[dblBasePrice]
				   ,[strPricing]
				   ,[dblTotalTax]
				   ,[dblBaseTotalTax]
				   ,[dblTotal]
				   ,[dblBaseTotal]
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
				   ,[dblBaseMaintenanceAmount]
	               ,[dblLicenseAmount]
				   ,[dblBaseLicenseAmount]
				   ,[intContractHeaderId]
				   ,[intContractDetailId]
				   ,[intTaxGroupId]
				   ,[dblItemWeight]	
				   ,[dblOriginalItemWeight]
				   ,[intItemWeightUOMId] 	
				   ,[intStorageScheduleTypeId]
				   ,[intSubCurrencyId]
				   ,[dblSubCurrencyRate]
				   ,[strVFDDocumentNumber]
				   ,[intCurrencyExchangeRateTypeId]
				   ,[dblCurrencyExchangeRate]
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
				,[dblBaseAdjustedTax]
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
			   ,[dblBaseAdjustedTax]
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
	
	SELECT 
		@ysnRecurringDuplicate = ysnRecurring 
	FROM 
		tblSOSalesOrder 
	WHERE
		intSalesOrderId = @NewSalesOrderId

	IF (@ysnRecurringDuplicate = 1)
	BEGIN
		IF NOT EXISTS(SELECT NULL FROM tblSMRecurringTransaction WHERE intTransactionId = @NewSalesOrderId)
		BEGIN
			EXEC dbo.[uspARInsertRecurringSalesOrder] @NewSalesOrderId, @UserId
		END		
	END 
	
END