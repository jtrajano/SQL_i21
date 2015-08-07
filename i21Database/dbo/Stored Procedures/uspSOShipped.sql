CREATE PROCEDURE [dbo].[uspSOShipped]
	@intTransactionId	INT
	,@ysnPost			BIT = 0
AS
BEGIN	
	DECLARE @OrderToUpdate TABLE (intSalesOrderId INT, dblQuantity NUMERIC (18, 6));
	DECLARE @forDelete BIT


	INSERT INTO @OrderToUpdate(intSalesOrderId, dblQuantity)
	SELECT DISTINCT intSourceId, dblQuantity 
		FROM tblICInventoryShipmentItem 
	WHERE intInventoryShipmentId = @intTransactionId
	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
	BEGIN				
		DECLARE @intSalesOrderId INT;
		DECLARE @qtyToPost INT;
					
		SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @qtyToPost = dblQuantity FROM @OrderToUpdate ORDER BY intSalesOrderId		

		EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId		
		
		EXEC dbo.[uspSOUpdateCommitted] @intSalesOrderId, @ysnPost ,@qtyToPost
			
		DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId
	END 
END