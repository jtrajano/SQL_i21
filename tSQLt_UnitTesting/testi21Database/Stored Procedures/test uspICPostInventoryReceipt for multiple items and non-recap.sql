CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for multiple items and non-recap]
AS
BEGIN
	-- Arrange 
	BEGIN 
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

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'Dummy-000001'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC [testi21Database].[Fake inventory items];
		EXEC testi21Database.[Fake data for the accounting period];

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;

		INSERT INTO tblICInventoryReceipt (
			strReceiptNumber
			,intLocationId
			,dtmReceiptDate
		)
		VALUES (
			@strTransactionId
			,@NewHaven
			,@dtmDate	
		);	
	
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblReceived,dblUnitCost) VALUES (1, @WetGrains, 10, 10, 12.50);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblReceived,dblUnitCost) VALUES (1, @StickyGrains, 20, 10, 13.50);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblReceived,dblUnitCost) VALUES (1, @PremiumGrains, 30, 10, 9.10);
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId,intItemId,dblOrderQty,dblReceived,dblUnitCost) VALUES (1, @WetGrains, 40, 10, 15.52);
		
		CREATE TABLE actual (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)
		
		CREATE TABLE expected (
			dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)

		DECLARE @amount AS NUMERIC(18,6) = 10 * 12.50;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 13.50;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 9.10;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)

		SET @amount = 10 * 15.52;
		INSERT INTO expected VALUES (@amount, 0)
		INSERT INTO expected VALUES (0, @amount)		
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
	 		,@intUserId
			,@intEntityId
			
		INSERT INTO actual (dblDebit, dblCredit) 
		SELECT dblDebit, dblCredit 
		FROM dbo.tblGLDetail
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END 