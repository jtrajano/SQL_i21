CREATE PROCEDURE dbo.uspICFixBundleInvalidUOMs
	(@intParentItemId INT = NULL)
AS
BEGIN
	UPDATE b
	SET b.intItemUnitMeasureId = v.intAlternativeUOMId
	FROM tblICItemBundle b
		INNER JOIN vyuICGetInvalidBundleItemUom v ON v.intId = b.intItemBundleId
	WHERE b.intItemId = @intParentItemId OR @intParentItemId IS NULL
END