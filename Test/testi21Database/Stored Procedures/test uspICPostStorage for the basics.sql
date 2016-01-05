CREATE PROCEDURE [testi21Database].[test uspICPostStorage for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the fake data
		EXEC [testi21Database].[Fake transactions for item Storage]

		-- Declare the variables used by uspICPostCosting
		DECLARE @ItemsToPost AS ItemCostingTableType;
		DECLARE @strBatchId AS NVARCHAR(20);
		DECLARE @intEntityUserSecurityId AS INT = 1;

		-- Setup the items to post
		-- (None for the basic setup)
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END 

	-- Act
	BEGIN 	
		-- Call uspICPostStorage to process stocks for Storage. 
		EXEC dbo.uspICPostStorage
			@ItemsToPost
			,@strBatchId 
			,@intEntityUserSecurityId
	END 
END 
