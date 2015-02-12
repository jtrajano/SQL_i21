CREATE PROCEDURE [testi21Database].[test uspICCreateStockPathNode for SO-0002-2]
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
		
		-- Add node for PO-0001
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId(NULL, NULL) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('PO-0001', 1) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for INVRCPT-0001
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId('PO-0001', 1) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('INVRCPT-0001', 1) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for INVSHIP-0001
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId('INVRCPT-0001', 1) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0001', 1) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for SO-0001
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0001', 1) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('SO-0001', 1) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for INVSHIP-0002
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId(NULL, NULL) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0002', 2) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for SO-0002 (1 of 2)
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0002', 2) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('SO-0002', 2) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for INVRCPT-0002
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId(NULL, NULL) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('INVRCPT-0002', 2) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for INVSHIP-0003
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId(NULL, NULL) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0003', 3) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

		-- Add node for SO-0002 (2 of 2)
		BEGIN 
			SELECT	@ancestorId = NULL, @descendantId = NULL

			SELECT	@ancestorId = AncestorId.intInventoryTransactionId				
			FROM	dbo.fnGetInventoryTransactionId('INVSHIP-0003', 3) AncestorId	

			SELECT	@descendantId = DescendantId.intInventoryTransactionId 
			FROM	dbo.fnGetInventoryTransactionId('SO-0002', 2) DescendantId

			-- Act on the stored procedure under test. 
			EXEC dbo.uspICCreateStockPathNode
				@intItemId
				,@intItemLocationId
				,@ancestorId
				,@descendantId
		END 

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
		-- This is root link to INVRCPT-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 2
				,intDepth = 2
		-- This is root link to INVSHIP-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 3
				,intDepth = 3
		-- This is root link to SO-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 4
				,intDepth = 4
		-- This is root link to INVSHIP-0002
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 5
				,intDepth = 1
		-- This is root link to SO-0002
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 6
				,intDepth = 2
		-- This is root link to INVRCPT-0002
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 7
				,intDepth = 1
		-- This is root link to INVSHIP-0003
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = NULL 
				,intDescendantId = 8
				,intDepth = 1

		-------------------------------------------
		-- This is PO-0001 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 1
				,intDescendantId = 1
				,intDepth = 0
		-- This is PO-0001 linked to INVRCPT-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 1 
				,intDescendantId = 2
				,intDepth = 1
		-- This is PO-0001 linked to INVSHIP-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 1 
				,intDescendantId = 3
				,intDepth = 2
		-- This is PO-0001 linked to SO-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 1 
				,intDescendantId = 4
				,intDepth = 3

		-------------------------------------------
		-- This is INVRCPT-0001 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 2
				,intDescendantId = 2
				,intDepth = 0
		-- This is INVRCPT-0001 linked to INVSHIP-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 2 
				,intDescendantId = 3
				,intDepth = 1
		-- This is INVRCPT-0001 linked to SO-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 2 
				,intDescendantId = 4
				,intDepth = 2

		-------------------------------------------
		-- This is INVSHIP-0001 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 3
				,intDescendantId = 3
				,intDepth = 0
		-- This is INVSHIP-0001  linked to SO-0001
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 3
				,intDescendantId = 4
				,intDepth = 1

		-------------------------------------------
		-- This is SO-0001 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 4
				,intDescendantId = 4
				,intDepth = 0

		-------------------------------------------
		-- This is INVSHIP-0002 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 5
				,intDescendantId = 5
				,intDepth = 0
		-- This is INVSHIP-0002 linked to SO-0002
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 5
				,intDescendantId = 6
				,intDepth = 1

		-------------------------------------------
		-- This is SO-0002 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 6
				,intDescendantId = 6
				,intDepth = 0

		-------------------------------------------
		-- This is INVRCPT-0002 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 7
				,intDescendantId = 7
				,intDepth = 0

		-------------------------------------------
		-- This is INVSHIP-0003 as pointer to itself. 
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 8
				,intDescendantId = 8
				,intDepth = 0
		-- This is INVSHIP-0003 linked to SO-0002
		UNION ALL 
		SELECT	intItemId = 1
				,intItemLocationId = 6
				,intAncestorId = 8
				,intDescendantId = 6
				,intDepth = 1
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