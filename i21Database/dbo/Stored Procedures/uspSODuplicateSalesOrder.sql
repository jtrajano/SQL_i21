CREATE PROCEDURE [dbo].[uspSODuplicateSalesOrder]
	@SalesOrderId	INT = 0,
	@UserId			INT = 0,
	@NewSalesOrderId INT = NULL OUTPUT

	AS
BEGIN

	
	
	INSERT INTO tblSOSalesOrder
		(   [intCustomerId]
           ,[dtmDate]
           ,[dtmDueDate]
           ,[intCurrencyId]
           ,[intCompanyLocationId]
           ,[intSalespersonId]
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
           ,[intEntityId]
        )
	SELECT
			[intCustomerId]
           ,[dtmDate]
           ,[dtmDueDate]
           ,[intCurrencyId]
           ,[intCompanyLocationId]
           ,[intSalespersonId]
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
           ,@UserId
	FROM
	tblSOSalesOrder
	WHERE intSalesOrderId = @SalesOrderId

	SET @NewSalesOrderId = SCOPE_IDENTITY()

	INSERT INTO [dbo].[tblSOSalesOrderDetail]
	   (	[intSalesOrderId]
           ,[intCompanyLocationId]
           ,[intItemId]
           ,[strItemDescription]
           ,[intItemUOMId]
           ,[dblQtyOrdered]
           ,[dblQtyAllocated]
           ,[dblDiscount]
           ,[intTaxId]
           ,[dblPrice]
           ,[dblTotal]
           ,[strComments]
           ,[intAccountId]
           ,[intCOGSAccountId]
           ,[intSalesAccountId]
           ,[intInventoryAccountId]
        )
	SELECT 
			@NewSalesOrderId
		   ,[intCompanyLocationId]
           ,[intItemId]
           ,[strItemDescription]
           ,[intItemUOMId]
           ,[dblQtyOrdered]
           ,[dblQtyAllocated]
           ,[dblDiscount]
           ,[intTaxId]
           ,[dblPrice]
           ,[dblTotal]
           ,[strComments]
           ,[intAccountId]
           ,[intCOGSAccountId]
           ,[intSalesAccountId]
           ,[intInventoryAccountId]
	FROM
	tblSOSalesOrderDetail
	WHERE intSalesOrderId = @SalesOrderId
	
END