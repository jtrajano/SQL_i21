CREATE PROCEDURE [testi21Database].[test uspICCreateStockPathRoot for valid arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake Item Stock Path]

		SELECT * INTO expected FROM dbo.tblICItemStockPath WHERE 1 = 0
		SELECT * INTO actual FROM dbo.tblICItemStockPath WHERE 1 = 0	
	END 
	
	-- Act
	BEGIN 
		DECLARE @intItemId AS INT = 1
		DECLARE @intItemLocationId AS INT = 1

		-- Act on the stored procedure under test 
		EXEC dbo.uspICCreateStockPathRoot
			@intItemId
			,@intItemLocationId

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,intAncestorId
				,intDescendantId
				,intDepth		
		)
		SELECT	intItemId = @intItemId
				,intItemLocationId  = @intItemLocationId
				,intAncestorId = NULL
				,intDescendantId = NULL
				,intDepth = 0
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,intAncestorId
				,intDescendantId
				,intDepth
		)
		SELECT	intItemId
				,intItemLocationId
				,intAncestorId
				,intDescendantId
				,intDepth
		FROM	dbo.tblICItemStockPath
	
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END