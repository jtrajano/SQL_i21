﻿CREATE PROCEDURE [testi21Database].[test uspICAddPurchaseOrderToInventoryReceipt for errors thrown by a null transaction id]
AS
BEGIN
	-- Assert 
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50030
	END
	
	-- Act
	BEGIN 

		EXEC dbo.uspICAddPurchaseOrderToInventoryReceipt
			@PurchaseOrderId = NULL
			,@intUserId = NULL
			,@InventoryReceiptId = NULL 
	END 
END
