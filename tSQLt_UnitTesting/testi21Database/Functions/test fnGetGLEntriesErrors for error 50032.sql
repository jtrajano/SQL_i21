CREATE PROCEDURE testi21Database.[test fnGetGLEntriesErrors for error 50032]
AS 
BEGIN
	-- Arrange
	BEGIN 	
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
		EXEC testi21Database.[Fake data for simple COA];

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