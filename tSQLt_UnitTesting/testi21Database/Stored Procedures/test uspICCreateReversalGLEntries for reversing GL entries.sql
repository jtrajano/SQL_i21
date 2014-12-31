CREATE PROCEDURE [testi21Database].[test uspICCreateReversalGLEntries for reversing GL entries]
AS
--BEGIN
	---- Arrange 
	--BEGIN 
	--	DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
	--	DECLARE @AUTO_NEGATIVE_TransactionType AS NVARCHAR(50) = 'Inventory Auto Negative';
	--	DECLARE @WRITEOFF_SOLD_TransactionType AS NVARCHAR(50) = 'Inventory Write-Off Sold';
	--	DECLARE @REVALUE_SOLD_TransactionType AS NVARCHAR(50) = 'Inventory Revalue Sold';
	--	DECLARE @ITEM_COSTING_TransactionType AS NVARCHAR(50) = 'Inventory Costing';

	--	DECLARE @InventoryAdjustment_TransactionType AS INT = 1;

	--	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	--	EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;

	--	-- Create the variables for the internal transaction types used by costing. 
	--	DECLARE @WRITE_OFF_SOLD AS INT = -1
	--	DECLARE @REVALUE_SOLD AS INT = -2
	--	DECLARE @AUTO_NEGATIVE AS INT = -3

	--	DECLARE @PurchaseType AS INT = 1

	--	-- Declare the variables for grains (item)
	--	DECLARE @WetGrains AS INT = 1
	--			,@StickyGrains AS INT = 2
	--			,@PremiumGrains AS INT = 3
	--			,@ColdGrains AS INT = 4
	--			,@HotGrains AS INT = 5
	--			,@InvalidItem AS INT = -1

	--	-- Declare the variables for location
	--	DECLARE @Default_Location AS INT = 1
	--			,@NewHaven AS INT = 2
	--			,@BetterHaven AS INT = 3
	--			,@InvalidLocation AS INT = -1

	--	-- Declare the variables for the currencies
	--	DECLARE @USD AS INT = 1;

	--	-- Add fake data to the inventory transaction table
	--	INSERT INTO dbo.tblICInventoryTransaction (
	--			strBatchId
	--			,intItemId
	--			,intLocationId
	--			,dblUnitQty
	--			,dblCost
	--			,dblValue
	--			,intTransactionTypeId
	--			,intTransactionId
	--			,strTransactionId
	--			,intRelatedInventoryTransactionId
	--			,strRelatedInventoryTransactionId
	--	)
	--	SELECT	strBatchId = 'BATCH-000001'
	--			,intItemId = @WetGrains
	--			,intLocationId = @NewHaven
	--			,dblUnitQty = 100
	--			,dblCost = 2.40
	--			,dblValue = 0
	--			,intTransactionTypeId 
	--			,intTransactionId
	--			,strTransactionId
	--			,intRelatedInventoryTransactionId
	--			,strRelatedInventoryTransactionId

	--	-- There are no records in tblGLDetail
	--	-- INSERT INTO tblGLDetail

	--	-- Create the expected and actual tables. 
	--	DECLARE @recap AS dbo.RecapTableType		
	--	SELECT * INTO expected FROM @recap		
	--	SELECT * INTO actual FROM @recap

	--	-- Remove the column dtmDateEntered. We don't need to assert it. 
	--	ALTER TABLE expected
	--	DROP COLUMN dtmDateEntered
	--END 
	
	---- Act
	--BEGIN 
	--	DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
	--			,@intTransactionId AS INT 
	--			,@strTransactionId AS NVARCHAR(40)
	--			,@intUserId AS INT 

	--	INSERT INTO actual 
	--	EXEC dbo.uspICCreateReversalGLEntries
	--		@strBatchId
	--		,@intTransactionId
	--		,@strTransactionId
	--		,@intUserId

	--	-- Remove the column dtmDateEntered. We don't need to assert it. 
	--	ALTER TABLE actual 
	--	DROP COLUMN dtmDateEntered
	--END 

	---- Assert
	--BEGIN 
	--	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	--END

	---- Clean-up: remove the tables used in the unit test
	--IF OBJECT_ID('actual') IS NOT NULL 
	--	DROP TABLE actual

	--IF OBJECT_ID('expected') IS NOT NULL 
	--	DROP TABLE dbo.expected
--END