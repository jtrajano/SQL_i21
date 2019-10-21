CREATE PROCEDURE [dbo].[uspICCleanupOrphanTransactionsByUom] (@ids OriginImportOptions READONLY)
AS
BEGIN
	DELETE d 
	FROM tblICItemStockUOM d
	INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId
	
	DELETE d 
	FROM tblICItemStockDetail d
	INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId

    IF EXISTS(SELECT * FROM @ids WHERE [Value] = '-1')
    BEGIN
        DECLARE @intItemId INT
        SELECT TOP 1 @intItemId = CAST([Value] AS INT) FROM @ids WHERE [Value] <> '-1'
		
        EXEC dbo.uspICCleanupOrphanTransactionsByItem @intItemId
    END

	UPDATE l
	SET l.intIssueUOMId = NULL
	FROM tblICItemLocation l
		INNER JOIN tblICItem i ON i.intItemId = l.intItemId
		INNER JOIN tblICItemUOM uom ON uom.intItemId = i.intItemId
		INNER JOIN @ids id ON CAST([Value] AS INT) = uom.intItemUOMId
			AND uom.intItemUOMId = l.intIssueUOMId

	UPDATE l
	SET l.intReceiveUOMId = NULL
	FROM tblICItemLocation l
		INNER JOIN tblICItem i ON i.intItemId = l.intItemId
		INNER JOIN tblICItemUOM uom ON uom.intItemId = i.intItemId
		INNER JOIN @ids id ON CAST([Value] AS INT) = uom.intItemUOMId
			AND uom.intItemUOMId = l.intReceiveUOMId

	--DELETE d 
	--FROM tblICItemUOM d
	--INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId
END
