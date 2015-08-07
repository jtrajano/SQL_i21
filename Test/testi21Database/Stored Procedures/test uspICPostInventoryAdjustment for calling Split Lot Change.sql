CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for calling Split Lot Change]
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
		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'ADJ-7'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1

		EXEC [testi21Database].[Fake data for inventory adjustment table];

		-- Set the adjustment type
		UPDATE dbo.tblICInventoryAdjustment
		SET intAdjustmentType = @ADJUSTMENT_TYPE_LOT_ID_CHANGE					
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectNoException;
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustment 
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intUserId
			,@intEntityId
	END 
END  