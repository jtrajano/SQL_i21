CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for calling Item Change]
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
		DECLARE @strTransactionId AS NVARCHAR(40) = 'ADJ-1'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1

		-- Add a spy for uspICPostInventoryAdjustmentItemChange
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryAdjustmentItemChange';	

		EXEC [testi21Database].[Fake data for inventory adjustment table];

		-- Set the adjustment type
		UPDATE dbo.tblICInventoryAdjustment
		SET intAdjustmentType = @ADJUSTMENT_TYPE_ITEM_CHANGE					
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

	-- Assert
	BEGIN 
		--Assert uspICPostInventoryAdjustmentItemChange is called 
		IF @ysnPost = 1 AND NOT EXISTS (SELECT 1 FROM dbo.uspICPostInventoryAdjustmentItemChange_SpyProcedureLog)
			EXEC tSQLt.Fail 'A helper stored procedure uspICPostInventoryAdjustmentItemChange is expected to be called.'
	END
END 