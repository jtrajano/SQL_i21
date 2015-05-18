﻿CREATE PROCEDURE [testi21Database].[test uspICProcessToItemReceipt for errors thrown by uspICAddPurchaseOrderToInventoryReceipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalleduspICAddPurchaseOrderToInventoryReceipt AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICAddPurchaseOrderToInventoryReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICAddPurchaseOrderToInventoryReceipt', @errorCommand;
	END 
	
	-- Test if error/s raised by uspICAddPurchaseOrderToInventoryReceipt is handled properly. 
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
			-- Check if uspICAddPurchaseOrderToInventoryReceipt was called. 
			SELECT	@isCalleduspICAddPurchaseOrderToInventoryReceipt = 1 
			FROM	uspICAddPurchaseOrderToInventoryReceipt_SpyProcedureLog 
			WHERE	_id_ = 1 

			EXEC tSQLt.AssertEquals 1 ,@isCalleduspICAddPurchaseOrderToInventoryReceipt;			
		END		
	END 
END