CREATE PROCEDURE [testi21Database].[test uspICCalculateInventoryReceiptOtherCharges for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptChargePerItem', @Identity = 1;

		CREATE TABLE expected
		(
			[intInventoryReceiptId] INT NOT NULL,
			[intInventoryReceiptChargeId] INT NOT NULL, 
			[intInventoryReceiptItemId] INT NOT NULL, 
			[intChargeId] INT NOT NULL, 
			[intEntityVendorId] INT NOT NULL, 
			[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)) 
		)

		CREATE TABLE actual
		(
			[intInventoryReceiptId] INT NOT NULL,
			[intInventoryReceiptChargeId] INT NOT NULL, 
			[intInventoryReceiptItemId] INT NOT NULL, 
			[intChargeId] INT NOT NULL, 
			[intEntityVendorId] INT NOT NULL, 
			[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)) 
		)

		DECLARE @intInventoryReceiptId AS INT
	END 
	
	-- Act
	BEGIN 		
		EXEC [dbo].[uspICCalculateInventoryReceiptOtherCharges]
			@intInventoryReceiptId
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intChargeId]
			,[intEntityVendorId]
			,[dblCalculatedAmount]
		)
		SELECT
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intChargeId]
			,[intEntityVendorId]
			,[dblCalculatedAmount]
		FROM	dbo.tblICInventoryReceiptChargePerItem
		WHERE	intInventoryReceiptId = @intInventoryReceiptId

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END