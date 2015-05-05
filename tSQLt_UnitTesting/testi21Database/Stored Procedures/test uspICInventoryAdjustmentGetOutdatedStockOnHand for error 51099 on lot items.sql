CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentGetOutdatedStockOnHand for error 51099 on lot items]
AS
BEGIN
	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	-- Arrange 
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(50) = 'ADJ-2'
		DECLARE @ysnPassed AS BIT

		EXEC testi21Database.[Fake data for inventory adjustment table];

		-- Intentionally change the qty of the lot table. 
		UPDATE dbo.tblICLot
		SET dblQty += 10		
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51099;
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICInventoryAdjustmentGetOutdatedStockOnHand 
			@strTransactionId
			,@ysnPassed OUTPUT 
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals 0, @ysnPassed, 'Output parameter @ysnPassed must return false (0).'; 
	END
END 
