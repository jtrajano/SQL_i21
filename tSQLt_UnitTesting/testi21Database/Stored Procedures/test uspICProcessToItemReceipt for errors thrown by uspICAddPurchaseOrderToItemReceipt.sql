CREATE PROCEDURE [testi21Database].[test uspICProcessToItemReceipt for errors thrown by uspICAddPurchaseOrderToItemReceipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICAddPurchaseOrderToItemReceipt AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICAddPurchaseOrderToItemReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICAddPurchaseOrderToItemReceipt', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICAddPurchaseOrderToItemReceipt is handled properly. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 

		EXEC dbo.uspICProcessToItemReceipt
			 @intSourceTransactionId = NULL
			 ,@strSourceType = 'Purchase Order'
			 ,@intUserId = NULL
			 ,@InventoryReceiptId = NULL 

		-- Assert
		BEGIN 
			-- Check if uspICAddPurchaseOrderToItemReceipt was called. 
			SELECT	@isCalledUspICAddPurchaseOrderToItemReceipt = 1 
			FROM	uspICAddPurchaseOrderToItemReceipt_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICAddPurchaseOrderToItemReceipt;			
		END		
	END 
END