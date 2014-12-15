CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToItemReceipt for errors thrown by uspSMGetStartingNumber]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspSMGetStartingNumber'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspSMGetStartingNumber', @errorCommand;
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICAddPurchaseOrderToItemReceipt
			@PurchaseOrderId = NULL
			,@intUserId = NULL
			,@InventoryReceiptId = NULL 
	END 

	-- Assert
	-- Nothing to assert
END