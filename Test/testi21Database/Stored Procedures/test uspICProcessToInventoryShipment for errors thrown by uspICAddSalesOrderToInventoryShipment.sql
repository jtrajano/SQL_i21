CREATE PROCEDURE [testi21Database].[test uspICProcessToInventoryShipment for errors thrown by uspICAddSalesOrderToInventoryShipment]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalleduspICAddSalesOrderToInventoryShipment AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICAddSalesOrderToInventoryShipment'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICAddSalesOrderToInventoryShipment', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICAddSalesOrderToInventoryShipment is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException 
			@ExpectedMessage = 'Error raised inside uspICAddSalesOrderToInventoryShipment'

		EXEC dbo.uspICProcessToInventoryShipment
			 @intSourceTransactionId = NULL
			 ,@strSourceType = 'Sales Order'
			 ,@intUserId = NULL
			 ,@InventoryShipmentId = NULL 

		-- Assert
		BEGIN 
			-- Check if uspICAddSalesOrderToInventoryShipment was called. 
			SELECT	@isCalleduspICAddSalesOrderToInventoryShipment = 1 
			FROM	uspICAddSalesOrderToInventoryShipment_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalleduspICAddSalesOrderToInventoryShipment;			
		END		
	END 
END