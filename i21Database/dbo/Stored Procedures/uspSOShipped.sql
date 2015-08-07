CREATE PROCEDURE [dbo].[uspSOShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
    ,@ysnPost            BIT = 0

AS

BEGIN	
	DECLARE @intTransactionId INT
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT, dblQuantity NUMERIC (18, 6));


	SELECT TOP 1 @intTransactionId = intShipmentId FROM @ItemsFromInventoryShipment

	INSERT INTO @OrderToUpdate(intSalesOrderId, dblQuantity)
    SELECT DISTINCT intOrderId, dblQuantity 
		FROM tblICInventoryShipmentItem 
	WHERE intInventoryShipmentId = @intTransactionId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT;
		DECLARE @qtyToPost NUMERIC (18, 6);

					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @qtyToPost = dblQuantity FROM @OrderToUpdate ORDER BY intSalesOrderId        

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId

		EXEC dbo.[uspSOUpdateCommitted] @intSalesOrderId, @ysnPost ,@qtyToPost
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId
	END 
END