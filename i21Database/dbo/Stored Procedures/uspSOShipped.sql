CREATE PROCEDURE [dbo].[uspSOShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intTransactionId INT

SELECT TOP 1 @intTransactionId = intShipmentId FROM @ItemsFromInventoryShipment

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