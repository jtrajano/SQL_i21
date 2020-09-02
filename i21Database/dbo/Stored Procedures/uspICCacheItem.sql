CREATE PROCEDURE [dbo].uspICCacheItem(@intItemId INT)
AS
BEGIN
	IF EXISTS(SELECT *
	FROM tblICItemCache
	WHERE intItemId = @intItemId)
		UPDATE tblICItemCache SET dtmDateLastUpdated = GETUTCDATE() WHERE intItemId = @intItemId
	ELSE
		INSERT INTO tblICItemCache
		(intItemId, dtmDateLastUpdated)
	VALUES
		(@intItemId, GETUTCDATE())
END