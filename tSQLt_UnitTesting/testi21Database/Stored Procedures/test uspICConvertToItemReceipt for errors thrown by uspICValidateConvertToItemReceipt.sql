﻿CREATE PROCEDURE [testi21Database].[test uspICConvertToItemReceipt for errors thrown by uspICValidateConvertToItemReceipt]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @isCalledUspICValidateConvertToItemReceipt AS BIT

		DECLARE @errorCommand AS NVARCHAR(MAX)
		DECLARE @command AS NVARCHAR(MAX)
		SET @errorCommand = 'RAISERROR(''Error raised inside uspICValidateConvertToItemReceipt'', 16, 1);';

		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateConvertToItemReceipt', @errorCommand;
		
		DECLARE @Items AS ItemCostingTableType		
		
		INSERT @Items (
				intItemId
				, intLocationId
				, dtmDate
				, dblUnitQty
				, dblUOMQty
				, dblCost
				, dblSalesPrice
				, intCurrencyId
				, dblExchangeRate
				, intTransactionId
				, strTransactionId
				, intTransactionTypeId
				, intLotId
		)
		SELECT	intItemId = 1
				, intLocationId = 1
				, dtmDate = GETDATE()
				, dblUnitQty = 1
				, dblUOMQty = 1
				, dblCost = 1.00
				, dblSalesPrice = 2.00
				, intCurrencyId = 1
				, dblExchangeRate = 1
				, intTransactionId = 1
				, strTransactionId = 'TRANSACTION-ID'
				, intTransactionTypeId = 1
				, intLotId = 1
	END 
	
	-- Test case 1: Test error handling when uspICValidateConvertToItemReceipt raise an error. 
	BEGIN 
		-- Act
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50000 
		EXEC dbo.uspICConvertToItemReceipt 
			@ItemsToReceive = @Items
			,@SourceTransactionId = ''
			,@SourceType = ''
			,@intUserId = 1

		-- Assert
		-- CALLED
		BEGIN 
			-- Check if the validate costing on post is CALLED. 
			SELECT	@isCalledUspICValidateConvertToItemReceipt = 1 
			FROM	uspICValidateCostingOnPost_SpyProcedureLog 
			WHERE	_id_ = 1 
					AND CAST(ItemsToValidate AS NVARCHAR(MAX)) = (SELECT * FROM @Items FOR XML PATH(''))

			EXEC tSQLt.AssertEquals 1 ,@isCalledUspICValidateConvertToItemReceipt;			
		END		
	END 
END