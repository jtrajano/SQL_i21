﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentLotMerge for calling uspICCreateLotNumberOnInventoryAdjustmentSplitLot]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];

		DECLARE 
			@intTransactionId INT = 7
			,@strBatchId NVARCHAR(50) = 'BATCH-XXXX1'
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50) = 'Inventory Adjustment'
			,@intEntityUserSecurityId INT = 1
			,@strAdjustmentDescription AS NVARCHAR(255) = ''

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	

		CREATE TABLE actual (
			intTransactionId INT
			,intEntityUserSecurityId INT
		)
		
		CREATE TABLE expected (
			intTransactionId INT
			,intEntityUserSecurityId INT
		)

		-- Add a spy for uspICCreateLotNumberOnInventoryAdjustmentSplitLot
		EXEC tSQLt.SpyProcedure 'dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot';		

		-- Setup the expected parameter for uspICPostInventoryAdjustment
		INSERT INTO expected (intTransactionId, intEntityUserSecurityId) VALUES (@intTransactionId, @intEntityUserSecurityId)
	END 

	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
			,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
			,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
			,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
			,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
			,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6
			,@ADJUSTMENT_TYPE_LotMerge AS INT = 7
			,@ADJUSTMENT_TYPE_LotMove AS INT = 8

	-- Change the all split lot into lot merge type
	UPDATE dbo.tblICInventoryAdjustment
	SET intAdjustmentType = @ADJUSTMENT_TYPE_LotMerge
	WHERE intAdjustmentType = @ADJUSTMENT_TYPE_SplitLot	

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotMerge
				@intTransactionId
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strAdjustmentDescription
	END 

	-- Assert 
	BEGIN 
		-- Get the actual 
		INSERT INTO actual (
			intTransactionId
			,intEntityUserSecurityId 
		) 
		SELECT	intTransactionId
				,intEntityUserSecurityId
		FROM	dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot_SpyProcedureLog	

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 	

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
