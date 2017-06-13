CREATE PROCEDURE [dbo].[uspARUpdateSOStatusFromInvoices]
	@InvoiceIds		InvoiceId	READONLY
AS
BEGIN	
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT, ysnForDelete BIT, ysnProcessed BIT);

	INSERT INTO @OrderToUpdate(intSalesOrderId, ysnForDelete, ysnProcessed)
	SELECT DISTINCT SOD.intSalesOrderId, ISNULL(II.ysnForDelete,0), 0
	FROM 
		tblSOSalesOrderDetail SOD
	INNER JOIN
		(SELECT intSalesOrderDetailId, intInvoiceId FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON SOD.intSalesOrderDetailId = ARID.intSalesOrderDetailId
	INNER JOIN
		@InvoiceIds II
			ON ARID.intInvoiceId = II.intHeaderId 

	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate WHERE [ysnProcessed] = 0 ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT, @ysnForDelete BIT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @ysnForDelete = ysnForDelete FROM @OrderToUpdate WHERE [ysnProcessed] = 0 ORDER BY intSalesOrderId
		--AR-4146TODO -- eliminate looping in uspSOUpdateOrderShipmentStatus
		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId, 0, @ysnForDelete
			
		UPDATE @OrderToUpdate SET [ysnProcessed] = 1  WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId
	END 
END
