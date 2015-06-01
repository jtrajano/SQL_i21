CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentUpdateOutdatedStockOnHand for updating a lot item in the adjustment detail]
AS
BEGIN
	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	DECLARE @ManualLotGrains AS INT = 6

	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake data for inventory adjustment table];
		
		DECLARE @strTransactionId AS NVARCHAR(50) = 'ADJ-2'		

		-- Intentionally change the qty of the lot table. 
		UPDATE dbo.tblICLot
		SET dblQty += 10		

		CREATE TABLE expected (
			intItemId INT 
			,dblQuantity NUMERIC(18,6)
		)

		CREATE TABLE actual (
			intItemId INT 
			,dblQuantity NUMERIC(18,6)
		)

		-- Setup the expected data
		INSERT INTO expected (intItemId, dblQuantity) VALUES (@ManualLotGrains, 1000 + 10)
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