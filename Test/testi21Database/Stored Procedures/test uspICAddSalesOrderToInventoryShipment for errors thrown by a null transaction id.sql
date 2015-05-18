CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment for errors thrown by a null transaction id]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50031
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICAddSalesOrderToInventoryShipment
			@SalesOrder = NULL
			,@intUserId = NULL
			,@InventoryShipmentId = NULL 
	END 

	-- Assert
	-- Nothing to assert
END