CREATE PROCEDURE [dbo].[uspICLockInventoryLocation] (@intLockType INT = 1, @intTransactionId INT = 1, @ysnLocked BIT = 1, @intSecurityUserId INT = NULL, @ysnPosting BIT = 0)
AS
BEGIN

DECLARE @ysnPosted BIT
SELECT @ysnPosted = ysnPosted FROM tblICInventoryCount WHERE intInventoryCountId = @intTransactionId

UPDATE dbo.tblICInventoryCount 
SET intStatus = CASE @ysnPosting WHEN 1 THEN CASE @ysnPosted WHEN 1 THEN 4 ELSE 1 END
	ELSE 
		CASE @ysnLocked WHEN 1 THEN CASE WHEN (intStatus + 1) > 4 THEN 4 ELSE intStatus + 1 END ELSE CASE WHEN (intStatus - 1) < 1 THEN 1 ELSE (intStatus - 1) END END -- CASE stmts are used to get the min/max status
	END
WHERE intInventoryCountId = @intTransactionId

IF @ysnPosting = 1 AND @ysnPosted = 1
BEGIN
	SET @ysnLocked = 0
END

-- Lock Lots
UPDATE l
SET l.ysnLockedInventory = @ysnLocked
FROM tblICLot l
	INNER JOIN tblICInventoryCountDetail cd ON cd.intLotId = l.intLotId
WHERE cd.intInventoryCountId = @intTransactionId

-- Lock Non-Lotted Items by Company Location
UPDATE il
SET il.ysnLockedInventory = @ysnLocked
FROM tblICItemLocation il
	INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = cd.intInventoryCountId
		AND cd.intItemLocationId = il.intItemLocationId
	INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
WHERE cd.intInventoryCountId = @intTransactionId
	AND cd.intSubLocationId IS NULL
	AND cd.intStorageLocationId IS NULL
	AND cd.intItemLocationId IS NOT NULL
	AND i.strLotTracking = 'No'

-- Lock Non-lotted items by Sub Location
IF @ysnLocked = 1
BEGIN
	INSERT INTO tblICLockedSubLocation(intTransactionId, strTransactionId, intSubLocationId, dtmDateCreated, intUserSecurityId)
	SELECT c.intInventoryCountId, cd.strCountLine, cd.intSubLocationId, GETDATE(), @intSecurityUserId
	FROM tblICInventoryCount c
		INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
		INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
	WHERE c.intInventoryCountId = @intTransactionId
		AND (cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL)
		AND i.strLotTracking = 'No'
END
ELSE
BEGIN
	DELETE ll
	FROM tblICLockedSubLocation ll
	WHERE ll.intTransactionId = @intTransactionId
END

-- Lock Non-lotted items by Storage Location
IF @ysnLocked = 1
BEGIN
	INSERT INTO tblICLockedStorageLocation(intTransactionId, strTransactionId, intStorageLocationId, dtmDateCreated, intUserSecurityId)
	SELECT c.intInventoryCountId, cd.strCountLine, cd.intStorageLocationId, GETDATE(), @intSecurityUserId
	FROM tblICInventoryCount c
		INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
		INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
	WHERE c.intInventoryCountId = @intTransactionId
		AND cd.intStorageLocationId IS NOT NULL
		AND i.strLotTracking = 'No'
END
ELSE
BEGIN
	DELETE ll
	FROM tblICLockedStorageLocation ll
	WHERE ll.intTransactionId = @intTransactionId
END

END