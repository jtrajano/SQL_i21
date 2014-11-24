CREATE PROCEDURE [testi21Database].[test uspICProcessToItemReceipt for errors thrown by uspICIncreaseOnOrderQty]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICIncreaseOnOrderQty AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICIncreaseOnOrderQty'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICIncreaseOnOrderQty', @errorCommand;		
	END 
	
	-- Test if error/s raised by uspICIncreaseOnOrderQty is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 

		EXEC dbo.uspICProcessToItemReceipt
			 @intSourceTransactionId = NULL
			 ,@strSourceType = 'Purchase Order'
			 ,@intUserId = NULL

		-- Assert
		BEGIN 
			-- Check if uspICIncreaseOnOrderQty was called
			SELECT	@isCalledUspICIncreaseOnOrderQty = 1 
			FROM	uspICIncreaseOnOrderQty_SpyProcedureLog 
			WHERE	_id_ = 1 					

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICIncreaseOnOrderQty;			
		END		
	END 
END