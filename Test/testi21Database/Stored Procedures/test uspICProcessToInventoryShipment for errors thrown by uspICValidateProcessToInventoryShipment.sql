CREATE PROCEDURE [testi21Database].[test uspICProcessToInventoryShipment for errors thrown by uspICValidateProcessToInventoryShipment]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICValidateProcessToInventoryShipment AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICValidateProcessToItemReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateProcessToInventoryShipment', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICValidateProcessToInventoryShipment is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 

		EXEC dbo.uspICProcessToInventoryShipment
			 @intSourceTransactionId = NULL
			 ,@strSourceType = NULL
			 ,@intUserId = NULL
			 ,@InventoryShipmentId = NULL 

		-- Assert
		BEGIN 
			-- Check if uspICValidateProcessToInventoryShipment was called. 
			SELECT	@isCalledUspICValidateProcessToInventoryShipment = 1 
			FROM	uspICValidateProcessToInventoryShipment_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICValidateProcessToInventoryShipment;			
		END		
	END 
END