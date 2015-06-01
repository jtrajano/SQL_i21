CREATE PROCEDURE [testi21Database].[test uspICProcessToInventoryShipment for errors thrown by uspICGetItemsForInventoryShipment]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICGetItemsForInventoryShipment AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICGetItemsForInventoryShipment'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICGetItemsForInventoryShipment', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICGetItemsForInventoryShipment is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException 
			@ExpectedMessage = 'Error raised inside uspICGetItemsForInventoryShipment'

		EXEC dbo.uspICProcessToInventoryShipment
			 @intSourceTransactionId = NULL
			 ,@strSourceType = NULL
			 ,@intUserId = NULL
			 ,@InventoryShipmentId = NULL 

		-- Assert
		BEGIN 
			-- Check if uspICGetItemsForInventoryShipment was called 
			SELECT	@isCalledUspICGetItemsForInventoryShipment = 1 
			FROM	uspICGetItemsForInventoryShipment_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICGetItemsForInventoryShipment;			
		END		
	END 
END