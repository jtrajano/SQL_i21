CREATE PROCEDURE testi21Database.[test fnGetGLEntriesErrors for error 50032]
AS 
BEGIN
	-- Arrange
	BEGIN 	
		-- Declare the account ids
		DECLARE @Inventory_Default AS INT = 1000
		DECLARE @CostOfGoods_Default AS INT = 2000
		DECLARE @APClearing_Default AS INT = 3000
		DECLARE @WriteOffSold_Default AS INT = 4000
		DECLARE @RevalueSold_Default AS INT = 5000 
		DECLARE @AutoNegative_Default AS INT = 6000
		DECLARE @InventoryInTransit_Default AS INT = 7000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001
		DECLARE @InventoryInTransit_NewHaven AS INT = 7001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002
		DECLARE @InventoryInTransit_BetterHaven AS INT = 7002

		-- Declare the account segment ids 
		DECLARE @SegmentId_INVENTORY_WHEAT AS INT = 1
		DECLARE @SegmentId_COST_OF_GOODS_WHEAT AS INT = 2
		DECLARE @SegmentId_AP_Clearing_WHEAT AS INT = 3
		DECLARE @SegmentId_WRITE_OFF_SOLD_WHEAT AS INT = 4
		DECLARE @SegmentId_REVALUE_SOLD_WHEAT AS INT = 5
		DECLARE @SegmentId_AUTO_NEGATIVE_WHEAT AS INT = 6
		DECLARE @SegmentId_INVENTORY_IN_TRANSIT AS INT = 7

		DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
		DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
		DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102

		CREATE TABLE expected (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		DECLARE @GLEntries AS RecapTableType

		-- Call the fake data for GL Account 
		EXEC [testi21Database].[Fake COA used for fake inventory items]

		INSERT INTO expected (
				strTransactionId
				,strText
				,intErrorCode
		)
		SELECT	strTransactionId = NULL 
				,strText = 'G/L entries are expected. Cannot continue because it is missing.'
				,intErrorCode = 50032
	END 

	-- Act
	BEGIN
		-- Try to validate an empty @GLEntries
		INSERT INTO actual
		SELECT * FROM dbo.fnGetGLEntriesErrors(@GLEntries)
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