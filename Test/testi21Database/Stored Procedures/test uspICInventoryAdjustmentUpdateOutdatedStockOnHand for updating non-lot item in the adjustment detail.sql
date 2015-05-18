CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentUpdateOutdatedStockOnHand for updating non-lot item in the adjustment detail]
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

		CREATE TABLE expected (
			intItemId INT 
			,dblQuantity NUMERIC(18,6)
		)

		CREATE TABLE actual (
			intItemId INT 
			,dblQuantity NUMERIC(18,6)
		)

		-- Setup the expected data
		INSERT INTO expected (intItemId, dblQuantity) VALUES (@WetGrains, 110)
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICInventoryAdjustmentUpdateOutdatedStockOnHand @strTransactionId

		-- Get the actual data
		INSERT INTO actual (intItemId, dblQuantity)
		SELECT	Detail.intItemId, dblQuantity 
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
		WHERE	Header.strAdjustmentNo = @strTransactionId
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
