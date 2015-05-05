CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentGetOutdatedStockOnHand for error 51100 on non-lot items]
AS
BEGIN
	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	DECLARE @WetGrains AS INT = 1
	DECLARE @WetGrains_DefaultLocation AS INT = 1

	-- Arrange 
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(50) = 'ADJ-5'
		DECLARE @ysnPassed AS BIT

		EXEC testi21Database.[Fake data for inventory adjustment table];

		-- Add a dummy stock on hand for the WetGrains
		INSERT INTO dbo.tblICItemStock (
			intItemId
			,intItemLocationId
			,dblUnitOnHand
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,dblUnitOnHand = 100 + 10 

	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51100;
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
