CREATE PROCEDURE [dbo].[uspARUpdateRemoveSalesOrderStatus]
	  @intInvoiceId			INT = NULL
AS
BEGIN
	DECLARE @tblSOToUpdate			Id;


	INSERT INTO @tblSOToUpdate
	SELECT DISTINCT SOD.intSalesOrderId FROM [tblARTransactionDetail] TD
	INNER JOIN tblSOSalesOrderDetail SOD
	ON 
	SOD.intSalesOrderDetailId =TD.intSalesOrderDetailId
	WHERE strTransactionType = 'Invoice'
	AND intTransactionId = @intInvoiceId AND TD.intSalesOrderDetailId is not Null


	WHILE EXISTS (SELECT TOP 1 NULL FROM @tblSOToUpdate)
		BEGIN
			DECLARE @intSOToUpdate		INT = NULL		
		   
			SELECT TOP 1 @intSOToUpdate = intId 
			FROM @tblSOToUpdate

			EXEC dbo.[uspSOUpdateOrderShipmentStatus] @intSOToUpdate, 'Sales Order', 0

			DELETE FROM @tblSOToUpdate WHERE intId = @intSOToUpdate

		END
END




