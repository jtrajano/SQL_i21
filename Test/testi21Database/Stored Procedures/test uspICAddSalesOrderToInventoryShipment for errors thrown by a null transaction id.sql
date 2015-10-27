﻿CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment for errors thrown by a null transaction id]
AS
BEGIN
	-- Arrange 
	-- n/a 

	-- Assert 
	BEGIN 
		-- Expect No errors
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 80029
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICAddSalesOrderToInventoryShipment
			@SalesOrderId = NULL
			,@intEntityUserSecurityId = NULL
			,@InventoryShipmentId = NULL 
	END 
END