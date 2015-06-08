﻿CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToInventoryReceipt for errors thrown by uspSMGetStartingNumber]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspSMGetStartingNumber'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspSMGetStartingNumber', @errorCommand;
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50031 
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICAddPurchaseOrderToInventoryReceipt
			@PurchaseOrderId = NULL
			,@intUserId = NULL
			,@InventoryReceiptId = NULL 
	END 

	-- Assert
	-- Nothing to assert
END