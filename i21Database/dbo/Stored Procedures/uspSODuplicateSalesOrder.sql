﻿CREATE PROCEDURE [dbo].[uspSODuplicateSalesOrder]
	@TransactionType	NVARCHAR(20) = '',
	@SalesOrderId		INT = 0,
	@OrderStatus		NVARCHAR(20) = '',
	@UserId				INT = 0,
	@SalesOrderDate     DATETIME = NULL,
	@NewSalesOrderId	INT = NULL OUTPUT,
	@NewSalesOrderNo	NVARCHAR(20) = NULL OUTPUT
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
		   ,[strType]
           ,[strOrderStatus]
           ,[intAccountId]
           ,[dtmProcessDate]
           ,[ysnProcessed]
		   ,[ysnRecurring]
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
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
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
		   ,[strType]
           ,@OrderStatus
           ,[intAccountId]
           ,NULL --Processed Date
           ,0 --Processed
		   ,0 --Recurring
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
		   ,[intQuoteTemplateId]
		   ,[ysnPreliminaryQuote]
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

	EXEC dbo.[uspSOUpdateOrderIntegrations] @NewSalesOrderId, 0, @UserId
	
END