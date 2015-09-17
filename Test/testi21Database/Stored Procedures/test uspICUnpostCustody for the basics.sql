﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCustody for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake transactions for item custody];		

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
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException
			@ExpectedMessage = 'A consigned or custodial item is no longer available. Unable to continue and unpost the transaction.'
			,@ExpectedErrorNumber = 80038
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@intTransactionId AS INT 
				,@strTransactionId AS NVARCHAR(40)
				,@intUserId AS INT 

		EXEC dbo.uspICUnpostCustody
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intUserId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 