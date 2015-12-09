﻿CREATE PROCEDURE [testi21Database].[test uspICCreateGLEntries for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake COA used for fake inventory items]

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

		-- Create the variables for the internal transaction types used by costing. 
		DECLARE @WRITE_OFF_SOLD AS INT = -1
		DECLARE @REVALUE_SOLD AS INT = -2
		DECLARE @AUTO_NEGATIVE AS INT = -3

		DECLARE @PurchaseType AS INT = 1

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		-- There are no records in tblICInventoryTransaction
		--INSERT INTO tblICInventoryTransaction...

		-- Create the expected and actual tables. 
		DECLARE @recap AS dbo.RecapTableType		
		SELECT * INTO expected FROM @recap		
		SELECT * INTO actual FROM @recap

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE expected
		DROP COLUMN dtmDateEntered
	END 
	
	-- Act
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
				,@intEntityUserSecurityId AS INT = 1

		INSERT INTO actual 
		EXEC dbo.uspICCreateGLEntries
			@strBatchId
			,@UseGLAccount_ContraInventory
			,@intEntityUserSecurityId
			,NULL

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE actual 
		DROP COLUMN dtmDateEntered
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END