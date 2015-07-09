CREATE PROCEDURE [testi21Database].[test uspICGetItemsFromItemReceipt for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @intReceiptId AS INT
		DECLARE @result AS ReceiptItemTableType
		
		-- Create the expected table. 
		SELECT *
		INTO expected
		FROM @result

		-- Create the actual table. 
		SELECT * 
		INTO actual 
		FROM @result 
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		INSERT INTO @result 
		EXEC dbo.uspICGetItemsFromItemReceipt
			@intReceiptId
	END 

	-- Assert
	BEGIN
		-- Get the result and insert it to the actual table. 
		INSERT INTO actual (
			-- Header 
			[intInventoryReceiptId] 
			,[strInventoryReceiptId] 
			,[strReceiptType] 
			,[intSourceType] 
			,[dtmDate] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			-- Detail 
			,[intInventoryReceiptDetailId] 
			,[intItemId] 
			,[intLotId] 
			,[strLotNumber] 
			,[intLocationId] 
			,[intItemLocationId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intWeightUOMId] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNetWeight] 
			,[dblCost] 
			,[intContainerId] 
			,[intOwnershipType] 
			,[intOrderId] 
			,[intSourceId] 
			,[intLineNo] 
		)
		SELECT 
			-- Header 
			[intInventoryReceiptId] 
			,[strInventoryReceiptId] 
			,[strReceiptType] 
			,[intSourceType] 
			,[dtmDate] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			-- Detail 
			,[intInventoryReceiptDetailId] 
			,[intItemId] 
			,[intLotId] 
			,[strLotNumber] 
			,[intLocationId] 
			,[intItemLocationId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intWeightUOMId] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNetWeight] 
			,[dblCost] 
			,[intContainerId] 
			,[intOwnershipType] 
			,[intOrderId] 
			,[intSourceId] 
			,[intLineNo] 
		FROM @result

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
