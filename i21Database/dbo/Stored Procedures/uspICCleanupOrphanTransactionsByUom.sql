CREATE PROCEDURE [dbo].[uspICCleanupOrphanTransactionsByUom] (@ids OriginImportOptions READONLY)
AS
BEGIN
	DELETE d 
	FROM tblICItemStockUOM d
	INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId

	DELETE d 
	FROM tblICItemStockDetail d
	INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId

	DELETE d 
	FROM tblICItemUOM d
	INNER JOIN @ids i ON CAST(i.Value AS INT) = d.intItemUOMId

    IF EXISTS(SELECT * FROM @ids WHERE [Value] = '-1')
    BEGIN
        DECLARE @intItemId INT
        SELECT TOP 1 @intItemId = CAST([Value] AS INT) FROM @ids WHERE [Value] <> '-1'
        EXEC dbo.uspICCleanupOrphanTransactionsByItem @intItemId
    END
END

GO