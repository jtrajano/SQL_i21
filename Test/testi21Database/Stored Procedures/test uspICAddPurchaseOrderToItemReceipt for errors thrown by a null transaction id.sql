CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToInventoryReceipt for errors thrown by a null transaction id]
AS
BEGIN
	-- Arrange 
	BEGIN 
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