CREATE PROCEDURE [dbo].[uspARInsertToSalesOrder]
	@SalesOrderId    INT = 0,
	@UserId		     INT = 0,
	@NewSalesOrderId INT = NULL OUTPUT
AS
BEGIN
	DECLARE @NewTransactionId INT,
			@DateOnly DATETIME

	SELECT @DateOnly = CAST(GETDATE() AS DATE)

	--HEADER
	INSERT INTO tblSOSalesOrder
		([strSalesOrderOriginId]
		,[intEntityCustomerId]
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
		,[intConcurrencyId]
		,[intEntityId]
		,[intOrderedById]
		,[strBOLNumber]
		,[intSplitId])
	SELECT 
		 [strSalesOrderNumber]
		,[intEntityCustomerId]
		,@DateOnly
		,[dtmDueDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intEntitySalespersonId]
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
		,'Order'
		,'Open'
		,[intAccountId]
		,[dtmProcessDate]
		,0
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
		,0
		,@UserId
		,[intOrderedById]
		,[strBOLNumber]
		,[intSplitId]
	FROM tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewTransactionId = SCOPE_IDENTITY()

	--DETAILS
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
		DECLARE @SalesOrderDetailId INT,
				@NewSalesOrderDetailId INT

		SELECT TOP 1 @SalesOrderDetailId = [intSalesOrderDetailId] FROM @OrderDetails ORDER BY [intSalesOrderDetailId]
		
		INSERT INTO tblSOSalesOrderDetail
			([intSalesOrderId]
			,[intItemId]
			,[strItemDescription]
			,[intItemUOMId]
			,[dblQtyOrdered]
			,[dblQtyAllocated]
			,[dblQtyShipped]
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
			,[intConcurrencyId]
			,[strMaintenanceType]
			,[strFrequency]
	        ,[dtmMaintenanceDate]
	        ,[dblMaintenanceAmount]
	        ,[dblLicenseAmount]
			,[intContractHeaderId]
			,[intContractDetailId])
		SELECT 
			@NewTransactionId
			,[intItemId]
			,[strItemDescription]
			,[intItemUOMId]
			,ROUND([dblQtyOrdered], 2)
			,ROUND([dblQtyAllocated], 2)
			,ROUND([dblQtyShipped], 2)
			,ROUND([dblDiscount], 2)
			,[intTaxId]
			,ROUND([dblPrice], 2)
			,ROUND([dblTotalTax], 2)
			,ROUND([dblTotal], 2)
			,[strComments]
			,[intAccountId]
			,[intCOGSAccountId]
			,[intSalesAccountId]
			,[intInventoryAccountId]
			,[intStorageLocationId]
			,0
			,[strMaintenanceType]
			,[strFrequency]
	        ,[dtmMaintenanceDate]
	        ,[dblMaintenanceAmount]
	        ,[dblLicenseAmount]
			,[intContractHeaderId]
			,[intContractDetailId]
		FROM tblSOSalesOrderDetail		
		WHERE [intSalesOrderDetailId] = @SalesOrderDetailId

		SET @NewSalesOrderDetailId = SCOPE_IDENTITY()

		--TAX DETAIL
		INSERT INTO tblSOSalesOrderDetailTax
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
		FROM tblSOSalesOrderDetailTax
		WHERE intSalesOrderDetailId = @SalesOrderDetailId
			
		DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
	END

	UPDATE tblSOSalesOrder SET ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId

	SET @NewSalesOrderId = @NewTransactionId
END