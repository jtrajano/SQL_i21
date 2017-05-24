CREATE PROCEDURE [dbo].[uspARUpdateSOStatusFromInvoices]
	@InvoiceIds		InvoiceId	READONLY
AS
BEGIN	
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT, ysnForDelete BIT);

	INSERT INTO @OrderToUpdate(intSalesOrderId, ysnForDelete)
	SELECT DISTINCT SOD.intSalesOrderId, ISNULL(II.ysnForDelete,0)
	FROM 
		tblSOSalesOrderDetail SOD
	INNER JOIN
		(SELECT intSalesOrderDetailId, intInvoiceId FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON SOD.intSalesOrderDetailId = ARID.intSalesOrderDetailId
	INNER JOIN
		@InvoiceIds II
			ON ARID.intInvoiceId = II.intHeaderId 

	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT, @ysnForDelete BIT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @ysnForDelete = ysnForDelete FROM @OrderToUpdate ORDER BY intSalesOrderId
		--AR-4146TODO -- eliminate looping in uspSOUpdateOrderShipmentStatus
		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId, 0, @ysnForDelete
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId
	END 
END
