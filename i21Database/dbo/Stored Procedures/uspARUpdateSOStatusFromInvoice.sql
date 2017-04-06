CREATE PROCEDURE [dbo].[uspARUpdateSOStatusFromInvoice]
	@intInvoiceId INT = 0,
	@ForDelete	  BIT = 0
AS
BEGIN	
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT);

	INSERT INTO @OrderToUpdate(intSalesOrderId)
	SELECT DISTINCT intSalesOrderId 
	FROM tblSOSalesOrderDetail WITH (NOLOCK)
		WHERE intSalesOrderDetailId IN (SELECT DISTINCT intSalesOrderDetailId 
											FROM tblARInvoiceDetail WITH (NOLOCK)			
											WHERE intInvoiceId = @intInvoiceId)
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @OrderToUpdate ORDER BY intSalesOrderId

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId, 0, @ForDelete
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId
	END 
END