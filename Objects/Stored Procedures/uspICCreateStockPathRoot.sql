/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICCreateStockPathRoot]
	@intItemId AS INT
	,@intItemLocationId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
		,intAncestorId = NULL
		,intDescendantId = NULL 
		,intDepth = 0
		,intConcurrencyId = 1
WHERE	NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemStockPath WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId)
		AND @intItemId IS NOT NULL 
		AND @intItemLocationId IS NOT NULL 