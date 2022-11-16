CREATE PROCEDURE [dbo].uspICCacheItem(@intItemId INT)
AS
BEGIN
	IF EXISTS(SELECT TOP 1 * FROM tblICItemCache WHERE intItemId = @intItemId)
		UPDATE tblICItemCache SET dtmDateLastUpdated = GETUTCDATE() WHERE intItemId = @intItemId
	ELSE IF @intItemId IS NOT NULL
		INSERT INTO tblICItemCache (intItemId, dtmDateLastUpdated) VALUES (@intItemId, GETUTCDATE())
END