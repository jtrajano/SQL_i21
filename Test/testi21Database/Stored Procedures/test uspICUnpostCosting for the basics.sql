﻿CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake posted transactions for testing the unposting];

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

		-- There are no records in tblICInventoryTransaction
		-- INSERT INTO tblICInventoryTransaction...

		-- There are no records in tblGLDetail
		-- INSERT INTO tblGLDetail

		-- Create the expected and actual tables. 
		DECLARE @recap AS dbo.RecapTableType		
		SELECT * INTO expected FROM @recap		
		SELECT * INTO actual FROM @recap

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE expected
		DROP COLUMN dtmDateEntered
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-000001'
				,@intTransactionId AS INT 
				,@strTransactionId AS NVARCHAR(40)
				,@intEntityUserSecurityId AS INT 

		INSERT INTO actual 
		EXEC dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intEntityUserSecurityId

		-- Remove the column dtmDateEntered. We don't need to assert it. 
		ALTER TABLE actual 
		DROP COLUMN dtmDateEntered
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