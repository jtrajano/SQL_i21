CREATE PROCEDURE [testi21Database].[test uspICProcessToItemReceipt for errors thrown by uspICGetItemsForItemReceipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICGetItemsForItemReceipt AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICGetItemsForItemReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICGetItemsForItemReceipt', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICIncreaseOnOrderQty is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 

		EXEC dbo.uspICProcessToItemReceipt
			 @intSourceTransactionId = NULL
			 ,@strSourceType = NULL
			 ,@intUserId = NULL
			 ,@InventoryReceiptId = NULL 

		-- Assert
		BEGIN 
			-- Check if uspICGetItemsForItemReceipt was called 
			SELECT	@isCalledUspICGetItemsForItemReceipt = 1 
			FROM	uspICGetItemsForItemReceipt_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICGetItemsForItemReceipt;			
		END		
	END 
END