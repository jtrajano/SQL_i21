﻿CREATE PROCEDURE testi21Database.[test fnGetGLEntriesErrors for error 50001]
AS 
BEGIN
	-- Arrange
	BEGIN 	
		CREATE TABLE expected (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
			,strModuleName NVARCHAR(50)
		)

		CREATE TABLE actual (
			strTransactionId NVARCHAR(40)
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
			,strModuleName NVARCHAR(50)
		)

		DECLARE @GLEntries AS RecapTableType

		-- Insert data in GL Entries
		INSERT INTO @GLEntries (
			dtmDate
			,dblExchangeRate
			,dtmDateEntered
			,ysnIsUnposted
			,intConcurrencyId
			,intAccountId
			,strTransactionId 
			,strModuleName 
			,strTransactionType
			,strTransactionForm
		)
		SELECT 
			dtmDate = GETDATE()
			,dblExchangeRate = 1
			,dtmDateEntered = GETDATE()
			,ysnIsUnposted = 0
			,intConcurrencyId = 1
			,intAccountId = NULL
			,strTransactionId = 'DUMMY-00001'
			,strModuleName = 'Inventory'
			,strTransactionType = 'Inventory Receipt'
			,strTransactionForm = 'Inventory Receipt'

		-- Insert the expected data 
		INSERT INTO expected (
			strTransactionId
			,strText
			,intErrorCode
			,strModuleName
		)
		VALUES ('DUMMY-00001', 'Invalid G/L account id found.', 60001, 'Inventory')

		-- Call the fake data for GL Account 
		EXEC testi21Database.[Fake COA used for fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
	END 

	-- Act
	BEGIN
		INSERT INTO actual
		SELECT * FROM dbo.fnGetGLEntriesErrors(@GLEntries, 1)
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