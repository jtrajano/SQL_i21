/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICCreateStockPathNode]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intInventoryTransactionId_Ancestor AS INT
	,@intInventoryTransactionId_Descendant AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create a root node (if none exists)
EXEC dbo.uspICCreateStockPathRoot @intItemId, @intItemLocationId

-- Build the ancestry
INSERT INTO dbo.tblICItemStockPath (
		intItemId
		,intItemLocationId
		,intAncestorId
		,intDescendantId
		,intDepth
		,intConcurrencyId
)
SELECT	Ancestors.intItemId 
		,Ancestors.intItemLocationId 
		,Ancestors.intAncestorId 
		,@intInventoryTransactionId_Descendant
		,Ancestors.intDepth + 1
		,intConcurrencyId = 1
FROM	dbo.tblICItemStockPath Ancestors
WHERE	Ancestors.intItemId = @intItemId AND @intItemId IS NOT NULL 
		AND Ancestors.intItemLocationId = @intItemLocationId AND @intItemLocationId IS NOT NULL 
		AND ISNULL(Ancestors.intDescendantId, '') = ISNULL(@intInventoryTransactionId_Ancestor, '')
		AND NOT EXISTS (
			SELECT  TOP 1 1
			FROM	dbo.tblICItemStockPath Existence
			WHERE	Existence.intItemId = Ancestors.intItemId
					AND Existence.intItemLocationId = Ancestors.intItemLocationId
					AND ISNULL(Existence.intAncestorId, '') = ISNULL(Ancestors.intAncestorId, '')
					AND ISNULL(Existence.intDescendantId, '') = ISNULL(@intInventoryTransactionId_Descendant, '')
		)

-- Add pointer to itself
INSERT INTO dbo.tblICItemStockPath (
		intItemId
		,intItemLocationId
		,intAncestorId
		,intDescendantId
		,intDepth
		,intConcurrencyId
)
SELECT	intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intAncestorId = @intInventoryTransactionId_Descendant
		,intDescendantId = @intInventoryTransactionId_Descendant 
		,intDepth = 0
		,intConcurrencyId = 1
WHERE	@intItemId IS NOT NULL 
		AND @intItemLocationId IS NOT NULL 
		AND @intInventoryTransactionId_Descendant IS NOT NULL 
		AND NOT EXISTS (
			SELECT  TOP 1 1
			FROM	dbo.tblICItemStockPath Existence
			WHERE	Existence.intItemId = @intItemId
					AND Existence.intItemLocationId = @intItemLocationId
					AND ISNULL(Existence.intAncestorId, '') = ISNULL(@intInventoryTransactionId_Descendant, '')
					AND ISNULL(Existence.intDescendantId, '') = ISNULL(@intInventoryTransactionId_Descendant, '')
		)