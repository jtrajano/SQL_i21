CREATE PROCEDURE [dbo].[uspSOShipped]
	@intTransactionId INT
AS
BEGIN	
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT);

	INSERT INTO @OrderToUpdate(intSalesOrderId)
	SELECT DISTINCT intSourceId 
		FROM tblICInventoryShipmentItem 
	WHERE intInventoryShipmentId = @intTransactionId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @OrderToUpdate ORDER BY intSalesOrderId

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId
	END 
END