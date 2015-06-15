﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCustody for a successful unpost]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake transactions for item custody];
		
		-- Mark all item as lot items
		UPDATE dbo.tblICItem
		SET strLotTracking = 'Yes - Manual'			

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

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
		BEGIN 
			CREATE TABLE #tmpInventoryTransactionStockToReverse (
				intInventoryLotInCustodyTransactionId INT NOT NULL 
				,intTransactionId INT NULL 
				,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
				,intTransactionTypeId INT NOT NULL 
				,intInventoryLotInCustodyId INT 
				,dblQty NUMERIC(38,20)
			)
		END 

		CREATE TABLE expected (
			intInventoryLotInCustodyTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,dblQty NUMERIC(38,20)
		)

		CREATE TABLE actual (
			intInventoryLotInCustodyTransactionId INT NOT NULL 
			,intTransactionId INT NULL 
			,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionTypeId INT NOT NULL 
			,dblQty NUMERIC(38,20)
		)
	END 

	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@intTransactionId AS INT = 1
				,@strTransactionId AS NVARCHAR(40) = 'INVRCT-00001'
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
				intInventoryLotInCustodyTransactionId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 
		)
		SELECT	intInventoryLotInCustodyTransactionId	= 1
				,intTransactionId						= 1
				,strTransactionId						= 'INVRCT-00001'
				,intTransactionTypeId					= @intTransactionTypeId
				,dblQty									= 110
		UNION ALL
		SELECT	intInventoryLotInCustodyTransactionId	= 6
				,intTransactionId						= 1
				,strTransactionId						= 'INVRCT-00001'
				,intTransactionTypeId					= @intTransactionTypeId
				,dblQty									= -110

		-- Get the actual data
		INSERT INTO actual (
				intInventoryLotInCustodyTransactionId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 		
		)
		SELECT
				intInventoryLotInCustodyTransactionId 
				,intTransactionId 
				,strTransactionId 
				,intTransactionTypeId 
				,dblQty 	
		FROM	tblICInventoryLotInCustodyTransaction
		WHERE	intTransactionId						= 1
				AND strTransactionId					= 'INVRCT-00001'
				AND intTransactionTypeId				= @intTransactionTypeId

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
