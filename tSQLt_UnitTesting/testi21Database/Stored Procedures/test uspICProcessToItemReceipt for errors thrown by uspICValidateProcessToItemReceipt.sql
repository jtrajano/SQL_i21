CREATE PROCEDURE [testi21Database].[test uspICProcessToItemReceipt for errors thrown by uspICValidateProcessToItemReceipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICValidateProcessToItemReceipt AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICValidateProcessToItemReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateProcessToItemReceipt', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICIncreaseOnOrderQty is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 

		EXEC dbo.uspICProcessToItemReceipt
			 @intSourceTransactionId = NULL
			 ,@strSourceType = NULL
			 ,@intUserId = NULL

		-- Assert
		BEGIN 
			-- Check if uspICValidateProcessToItemReceipt was called. 
			SELECT	@isCalledUspICValidateProcessToItemReceipt = 1 
			FROM	uspICValidateProcessToItemReceipt_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICValidateProcessToItemReceipt;			
		END		
	END 
END