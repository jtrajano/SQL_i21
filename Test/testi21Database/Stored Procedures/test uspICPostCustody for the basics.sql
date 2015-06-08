CREATE PROCEDURE [testi21Database].[test uspICPostCustody for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC [testi21Database].[Fake transactions for item custody]

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20);
		DECLARE @intUserId AS INT = 1;

		-- Setup the items to post
		-- (None for the basic setup)
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END 

	-- Act
	BEGIN 	
		-- Call uspICPostCustody to process stocks for custody. 
		EXEC dbo.uspICPostCustody
			@ItemsToPost
			,@strBatchId 
			,@intUserId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 
