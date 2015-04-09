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

	INSERT INTO [dbo].[tblARInvoiceDetail]
	   ([intInvoiceId]
	   ,[intCompanyLocationId]
	   ,[intItemId]
	   ,[strItemDescription]
	   ,[intItemUOMId]
	   ,[dblQtyOrdered]
	   ,[dblQtyShipped]
	   ,[dblPrice]
	   ,[dblTotal]
	   ,[intAccountId]
	   ,[intCOGSAccountId]
	   ,[intSalesAccountId]
	   ,[intInventoryAccountId]
	   )		
	SELECT 
		 @NewInvoiceId
		,intCompanyLocationId
		,intItemId
		,strItemDescription
		,intItemUOMId
		,dblQtyOrdered
		,dblQtyOrdered
		,ROUND(dblPrice,2)
		,ROUND(dblTotal,2)
		,intAccountId
	    ,intCOGSAccountId
		,intSalesAccountId
	    ,intInventoryAccountId
	FROM
	tblSOSalesOrderDetail
	WHERE intSalesOrderId = @SalesOrderId
	
	UPDATE tblSOSalesOrder SET strOrderStatus = 'Complete', ysnProcessed = 1 WHERE intSalesOrderId = @SalesOrderId
	
	
	SET @InvoiceId  = @NewInvoiceId
END