
-- Note: This stored procedure is monolithic (huge)
-- Unit test involved here is to check if the stored procedures called by this SP is called correctly. 

CREATE PROCEDURE [testi21Database].[test the basics of uspICProcessCosting stored procedure]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICValidateCostingOnPost AS BIT = 0
		DECLARE @isCalledUspICPostCosting AS BIT = 0 
		DECLARE @isCalledUspICValidateCostingOnUnpost AS BIT = 0 
		DECLARE @isCalledUspICUnpostCosting AS BIT = 0 

		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateCostingOnPost';
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostCosting';
		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateCostingOnUnpost';
		EXEC tSQLt.SpyProcedure 'dbo.uspICUnpostCosting';

		DECLARE @Items AS ItemCostingTableType
		
		INSERT @Items (intItemId, intLocationId, dtmDate, dblUnitQty, dblUOMQty, dblCost, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, intTransactionTypeId, intLotId)
		SELECT intItemId = 1, intLocationId = 1, dtmDate = GETDATE(), dblUnitQty = 1, dblUOMQty = 1, dblCost = 1.00, dblSalesPrice = 2.00 , intCurrencyId = 1, dblExchangeRate = 1, intTransactionId = 1, strTransactionId = 'TRANSACTION-ID', intTransactionTypeId = 1, intLotId = 1
	END 
	
	-- Test case 1: Basic test for posting 
	BEGIN 
		-- Act
		EXEC dbo.uspICProcessCosting 
			@ItemsToPostOrUnpost = @Items
			,@strBatchId = 'BATCH-XXXX'
			,@ysnPost = 1
			,@strAccountToCounterInventory = ''
			,@intUserId = 1;
			
		-- Assert
		-- Check if the validate costing on post is CALLED. 
		SELECT	@isCalledUspICValidateCostingOnPost = 1 
		FROM	uspICValidateCostingOnPost_SpyProcedureLog 
		WHERE	_id_ = 1 
				AND CAST(ItemsToValidate AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))

		EXEC tSQLt.AssertEquals 1 ,@isCalledUspICValidateCostingOnPost;

		-- Check if the post costing sp is CALLED. 
		SELECT	@isCalledUspICPostCosting = 1 
		FROM	uspICPostCosting_SpyProcedureLog 
		WHERE	_id_ = 1 
				AND CAST(ItemsToPost AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))
				AND strBatchId = 'BATCH-XXXX'

		EXEC tSQLt.AssertEquals 1, @isCalledUspICPostCosting;	
		
		-- Check if the Validate Costing on unpost sp is NOT called. 
		SELECT	@isCalledUspICValidateCostingOnUnpost = 1 
		FROM	uspICValidateCostingOnUnpost_SpyProcedureLog 
		WHERE	_id_ = 1
			
		EXEC tSQLt.AssertEquals 0, @isCalledUspICValidateCostingOnUnpost;
		
		-- Check if the Unpost Costing is NOT called 
		SELECT	@isCalledUspICUnpostCosting = 1 
		FROM	uspICUnpostCosting_SpyProcedureLog 
		WHERE	_id_ = 1
				AND strBatchId = 'BATCH-XXXX'
		
		EXEC tSQLt.AssertEquals 0, @isCalledUspICUnpostCosting;
	END 	

	-- Test case 2: Basic test for unposting 
	BEGIN 
		-- Arrange
		SET @isCalledUspICValidateCostingOnPost = 0 
		SET @isCalledUspICPostCosting = 0 
		SET @isCalledUspICValidateCostingOnUnpost = 0 
		SET @isCalledUspICUnpostCosting = 0 
		
		DELETE FROM uspICValidateCostingOnPost_SpyProcedureLog
		DELETE FROM uspICPostCosting_SpyProcedureLog
		DELETE FROM uspICValidateCostingOnUnpost_SpyProcedureLog
		DELETE FROM uspICUnpostCosting_SpyProcedureLog

		-- Act
		EXEC dbo.uspICProcessCosting 
			@ItemsToPostOrUnpost = @Items
			,@strBatchId = 'BATCH-YYYY'
			,@ysnPost = 0
			,@strAccountToCounterInventory = ''
			,@intUserId = 1;

		-- Assert
		-- Check if the validate costing on post is NOT called. 
		SELECT	@isCalledUspICValidateCostingOnPost = 1
		FROM	uspICValidateCostingOnPost_SpyProcedureLog 
		WHERE	_id_ = 1 
				AND CAST(ItemsToValidate AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))

		--EXEC tSQLt.AssertEquals 0 ,@isCalledUspICValidateCostingOnPost;

		-- Check if the post costing sp is NOT called. 
		SELECT	@isCalledUspICPostCosting = 1 
		FROM	uspICPostCosting_SpyProcedureLog 
		WHERE	_id_ = 1 
				AND CAST(ItemsToPost AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))
				AND strBatchId = 'BATCH-YYYY'

		EXEC tSQLt.AssertEquals 0, @isCalledUspICPostCosting;		
	
		-- Check if the Validate Costing on unpost sp is CALLED. 
		SELECT	@isCalledUspICValidateCostingOnUnpost = 1 
		FROM	uspICValidateCostingOnUnpost_SpyProcedureLog 
		WHERE	_id_ = 1
			
		EXEC tSQLt.AssertEquals 1, @isCalledUspICValidateCostingOnUnpost;
		
		-- Check if the Unpost Costing is CALLED 
		SELECT	@isCalledUspICUnpostCosting = 1 
		FROM	uspICUnpostCosting_SpyProcedureLog 
		WHERE	_id_ = 1
				AND strBatchId = 'BATCH-YYYY'
		
		EXEC tSQLt.AssertEquals 1, @isCalledUspICUnpostCosting;
	END 
END