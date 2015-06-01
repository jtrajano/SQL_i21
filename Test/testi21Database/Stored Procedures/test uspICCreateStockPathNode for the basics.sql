CREATE PROCEDURE [testi21Database].[test uspICCreateStockPathNode for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for Item Stock Path]

		SELECT * INTO expected FROM dbo.tblICItemStockPath WHERE 1 = 0
		SELECT * INTO actual FROM dbo.tblICItemStockPath WHERE 1 = 0		
	END 
	
	-- Act
	BEGIN 
		DECLARE @intItemId AS INT
				,@intItemLocationId AS INT
				,@ancestorId AS INT
				,@descendantId AS INT

		EXEC dbo.uspICCreateStockPathNode
			@intItemId
			,@intItemLocationId
			,@ancestorId
			,@descendantId
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