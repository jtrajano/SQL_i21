
-- Note: This stored procedure is monolithic (huge)
-- Unit test involved here is to check if the stored procedures called by this SP is called correctly. 

CREATE PROCEDURE [testi21Database].[test uspICProcessCosting for errors thrown by uspICUnpostCosting]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICValidateCostingOnPost AS BIT
		DECLARE @isCalledUspICPostCosting AS BIT
		DECLARE @isCalledUspICValidateCostingOnUnpost AS BIT
		DECLARE @isCalledUspICUnpostCosting AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICUnpostCosting'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateCostingOnPost';
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostCosting';
		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateCostingOnUnpost';
		EXEC tSQLt.SpyProcedure 'dbo.uspICUnpostCosting', @errorCommand;


		DECLARE @Items AS ItemCostingTableType
		
		INSERT @Items (intItemId, intLocationId, dtmDate, dblUnitQty, dblUOMQty, dblCost, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, intTransactionTypeId, intLotId)
		SELECT intItemId = 1, intLocationId = 1, dtmDate = GETDATE(), dblUnitQty = 1, dblUOMQty = 1, dblCost = 1.00, dblSalesPrice = 2.00 , intCurrencyId = 1, dblExchangeRate = 1, intTransactionId = 1, strTransactionId = 'TRANSACTION-ID', intTransactionTypeId = 1, intLotId = 1
	END 
	
	-- Test case 1: Test error handling when uspICValidateCostingOnPost raise an error. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 
		EXEC dbo.uspICProcessCosting 
			@ItemsToPostOrUnpost = @Items
			,@strBatchId = 'BATCH-XXXX'
			,@ysnPost = 0
			,@strAccountToCounterInventory = ''
			,@intUserId = 1;
	
		-- Assert
		-- CALLED
		BEGIN 
			-- Check if the Validate Costing on unpost sp is NOT called. 
			SELECT	@isCalledUspICValidateCostingOnUnpost = 1 
			FROM	uspICValidateCostingOnUnpost_SpyProcedureLog 
			WHERE	_id_ = 1
					AND intTransactionId = 1
					AND intTransactionTypeId = 1
				
			EXEC tSQLt.AssertEquals 1, @isCalledUspICValidateCostingOnUnpost;			
			
			-- Check if the Unpost Costing is NOT called 
			SELECT	@isCalledUspICUnpostCosting = 1 
			FROM	uspICUnpostCosting_SpyProcedureLog 
			WHERE	_id_ = 1
					AND strBatchId = 'BATCH-XXXX'
					AND intTransactionId = 1
					AND intTransactionTypeId = 1	
			
			EXEC tSQLt.AssertEquals 1, @isCalledUspICUnpostCosting;				
		END
		
		-- NOT CALLED
		BEGIN 
			-- Check if the validate costing on post is CALLED. 
			SELECT	@isCalledUspICValidateCostingOnPost = 1 
			FROM	uspICValidateCostingOnPost_SpyProcedureLog 
			WHERE	_id_ = 1 
					AND CAST(ItemsToValidate AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))

			EXEC tSQLt.AssertEquals 0 ,@isCalledUspICValidateCostingOnPost;			

			-- Check if the post costing sp is NOT called. 
			SELECT	@isCalledUspICPostCosting = 1 
			FROM	uspICPostCosting_SpyProcedureLog 
			WHERE	_id_ = 1 
					AND CAST(ItemsToProcess AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))
					AND strBatchId = 'BATCH-XXXX'

			EXEC tSQLt.AssertEquals 0, @isCalledUspICPostCosting;
		END 
	END 
END