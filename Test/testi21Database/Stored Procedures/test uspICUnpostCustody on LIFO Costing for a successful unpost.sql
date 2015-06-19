CREATE PROCEDURE [testi21Database].[test uspICUnpostCustody on LIFO Costing for a successful unpost]
AS
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@CornCommodity AS INT = 8
			,@InvalidItem AS INT = -1

	-- Declare Item-Locations
	DECLARE @WetGrains_DefaultLocation AS INT = 1
			,@StickyGrains_DefaultLocation AS INT = 2
			,@PremiumGrains_DefaultLocation AS INT = 3
			,@ColdGrains_DefaultLocation AS INT = 4
			,@HotGrains_DefaultLocation AS INT = 5

			,@WetGrains_NewHaven AS INT = 6
			,@StickyGrains_NewHaven AS INT = 7
			,@PremiumGrains_NewHaven AS INT = 8
			,@ColdGrains_NewHaven AS INT = 9
			,@HotGrains_NewHaven AS INT = 10

			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15

			,@ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

			,@CornCommodity_DefaultLocation AS INT = 18
			,@CornCommodity_NewHaven AS INT = 19
			,@CornCommodity_BetterHaven AS INT = 20

			,@ManualLotGrains_NewHaven AS INT = 21
			,@SerializedLotGrains_NewHaven AS INT = 22

BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake transactions for item custody];
			
		-- Declare the variables for the currencies
		DECLARE @USD AS INT = 1;

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
		BEGIN 
			CREATE TABLE #tmpInventoryTransactionStockToReverse (
				intInventoryTransactionInCustodyId INT NOT NULL 
				,intTransactionId INT NULL 
				,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
				,intTransactionTypeId INT NOT NULL 
				,intInventoryCostBucketInCustodyId INT 
				,dblQty NUMERIC(38,20)
			)
		END 

		CREATE TABLE expected (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,dblQty NUMERIC(38,20)
		)

		CREATE TABLE actual (
			intInventoryTransactionInCustodyId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,dblQty NUMERIC(38,20)
		)
	END 				
		
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-100001'
				,@intTransactionId AS INT = 11
				,@strTransactionId AS NVARCHAR(40) = 'INVRCT-00011'
				,@intUserId AS INT = 1

		EXEC dbo.uspICUnpostCustody
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId

		-- Setup the expected data
		DECLARE @intTransactionTypeId AS INT
		SELECT	TOP 1 
				@intTransactionTypeId = intTransactionTypeId
		FROM dbo.tblICInventoryTransactionType
		WHERE strName = 'Inventory Receipt'

		INSERT INTO expected (
				intInventoryTransactionInCustodyId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 
		)
		SELECT	intInventoryTransactionInCustodyId		= 11
				,intTransactionId						= 11
				,strTransactionId						= 'INVRCT-00011'
				,intTransactionTypeId					= @intTransactionTypeId
				,dblQty									= 1200
		UNION ALL
		SELECT	intInventoryTransactionInCustodyId		= 16
				,intTransactionId						= 11
				,strTransactionId						= 'INVRCT-00011'
				,intTransactionTypeId					= @intTransactionTypeId
				,dblQty									= -1200

		-- Get the actual data
		INSERT INTO actual (
				intInventoryTransactionInCustodyId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 		
		)
		SELECT
				intInventoryTransactionInCustodyId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 	
		FROM	tblICInventoryTransactionInCustody
		WHERE	intTransactionId						= 11
				AND strTransactionId					= 'INVRCT-00011'
				AND intTransactionTypeId				= @intTransactionTypeId

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 