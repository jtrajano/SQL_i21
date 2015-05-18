CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment for errors thrown by uspSMGetStartingNumber]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspSMGetStartingNumber'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspSMGetStartingNumber', @errorCommand;		
	END
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException 
			@ExpectedMessage = 'Error raised inside uspSMGetStartingNumber' 
			,@ExpectedErrorNumber = 50000 
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICAddSalesOrderToInventoryShipment
			@SalesOrderId = NULL
			,@intUserId = NULL
			,@InventoryShipmentId = NULL 
	END 
END