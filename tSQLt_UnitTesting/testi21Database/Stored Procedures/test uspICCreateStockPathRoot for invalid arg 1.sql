CREATE PROCEDURE [testi21Database].[test uspICCreateStockPathRoot for invalid arg 1]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake Item Stock Path]
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%conflicted with the FOREIGN KEY constraint "FK_tblICItemStockPath_tblICItem"%', @ExpectedSeverity = NULL, @ExpectedState = NULL;	
	END
	
	-- Act
	BEGIN 
		DECLARE @intItemId AS INT = -1 -- Invalid arg 1
		DECLARE @intItemLocationId AS INT = 1		

		-- Act on the stored procedure under test 
		EXEC dbo.uspICCreateStockPathRoot
			@intItemId
			,@intItemLocationId

	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END