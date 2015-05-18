CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentGetOutdatedExpiryDate for error 51101]
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
		DECLARE @strTransactionId AS NVARCHAR(50) = 'ADJ-6'
		DECLARE @ysnPassed AS BIT

		EXEC testi21Database.[Fake data for inventory adjustment table];

		-- Intentionally change the qty of the lot table. 
		UPDATE dbo.tblICLot
		SET dtmExpiryDate = '12/12/2018'
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51101;
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICInventoryAdjustmentGetOutdatedExpiryDate 
			@strTransactionId
			,@ysnPassed OUTPUT 
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals 0, @ysnPassed, 'Output parameter @ysnPassed must return false (0).'; 
	END
END 
