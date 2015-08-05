CREATE PROCEDURE [dbo].[uspSOShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
AS

BEGIN	
	DECLARE @intTransactionId INT
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT);

	SELECT TOP 1 @intTransactionId = intShipmentId FROM @ItemsFromInventoryShipment

	INSERT INTO @OrderToUpdate(intSalesOrderId)
	SELECT DISTINCT intOrderId 
		FROM tblICInventoryShipmentItem 
	WHERE intInventoryShipmentId = @intTransactionId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @OrderToUpdate ORDER BY intSalesOrderId

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId
	END 
END