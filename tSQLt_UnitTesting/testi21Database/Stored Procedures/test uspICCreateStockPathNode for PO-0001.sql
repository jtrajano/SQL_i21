CREATE PROCEDURE [testi21Database].[test uspICCreateStockPathNode for PO-0001]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for Item Stock Path]

		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,intAncestorId INT
			,intDescendantId INT
			,intDepth INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,intAncestorId INT
			,intDescendantId INT
			,intDepth INT
		)		
	END 
	
	-- Build fake data: inventory transactions
	/*
		WET GRAINS - NEW HAVEN (Root)
		----------------------
				|
				+--- PO-0001 (id: 1)
				|		|
				|		+---INVRCPT-0001 (id: 2)
				|				|
				|				+--- INVSHIP-0001 (id: 3)
				|						|
				|						+--- SO-0001 (id: 4)
				|
				+--- INVSHIP-0002 (id: 5, Partial shipment)
				|		|
				|		+--- SO-0002 (id 6, Big sales order)
				|
				+--- INVRCPT-0002 (id: 7)
				|
				+--- INVSHIP-0003 (id: 8, Another partial shipment for SO-0002)
						|
						+--- SO-0002 (id: 6)
	*/

	-- Act
	BEGIN 
		DECLARE @intItemId AS INT = 1
				,@intItemLocationId AS INT = 6
				,@ancestorId AS INT
				,@descendantId AS INT

		SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
		FROM	dbo.fnGetInventoryTransactionId(NULL, NULL, @intItemId, @intItemLocationId) AncestorId	

		SELECT	@descendantId = DescendantId.intInventoryTransactionId 
		FROM	dbo.fnGetInventoryTransactionId('PO-0001', 1, @intItemId, @intItemLocationId) DescendantId

		-- Act on the stored procedure under test. 
		EXEC dbo.uspICCreateStockPathNode
			@intItemId
			,@intItemLocationId
			,@ancestorId
			,@descendantId

		-- Setup the expected data. 
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,intAncestorId
				,intDescendantId
				,intDepth
		)
		-- This is root node linked to itself
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = NULL 		
				,intDepth = 0
		-- This is root link to PO-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 1
				,intDepth = 1
		-- This is PO-0001 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 1
				,intDescendantId = 1
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
