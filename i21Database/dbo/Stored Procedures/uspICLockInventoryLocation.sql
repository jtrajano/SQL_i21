/**
Lock Type
1 - Item Location
2 - Lot
3 - Storage Location
4 - Sub Location

Status
1 - Open
2 - Count Sheet Printed
3 - Locked
4 - Closed
**/

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

IF @intLockType = 2
BEGIN
    UPDATE l
	SET l.ysnLockedInventory = @ysnLocked
    FROM tblICLot l
		INNER JOIN tblICInventoryCountDetail cd ON cd.intLotId = l.intLotId
    WHERE cd.intInventoryCountId = @intTransactionId
END
ELSE IF @intLockType = 4
BEGIN
	IF @ysnLocked = 1
	BEGIN
		INSERT INTO tblICLockedSubLocation(intTransactionId, strTransactionId, intSubLocationId, dtmDateCreated, intUserSecurityId)
		SELECT intInventoryCountId, strCountNo, intSubLocationId, GETDATE(), @intSecurityUserId
		FROM tblICInventoryCount
		WHERE intInventoryCountId = @intTransactionId
			AND intSubLocationId IS NOT NULL
	END
	ELSE
	BEGIN
		DELETE ll
		FROM tblICLockedSubLocation ll
		WHERE ll.intTransactionId = @intTransactionId
	END
END
ELSE IF @intLockType = 3
BEGIN
	IF @ysnLocked = 1
	BEGIN
		INSERT INTO tblICLockedStorageLocation(intTransactionId, strTransactionId, intStorageLocationId, dtmDateCreated, intUserSecurityId)
		SELECT intInventoryCountId, strCountNo, intStorageLocationId, GETDATE(), @intSecurityUserId
		FROM tblICInventoryCount
		WHERE intInventoryCountId = @intTransactionId
			AND intStorageLocationId IS NOT NULL
	END
	ELSE
	BEGIN
		DELETE ll
		FROM tblICLockedStorageLocation ll
		WHERE ll.intTransactionId = @intTransactionId
	END
END
ELSE
BEGIN
	UPDATE il SET il.ysnLockedInventory = @ysnLocked
	FROM tblICItemLocation il
		INNER JOIN tblICInventoryCount ic ON ic.intLocationId = il.intLocationId
		INNER JOIN tblICInventoryCountDetail icd ON icd.intInventoryCountId = ic.intInventoryCountId
			AND il.intItemId = icd.intItemId
    WHERE ic.intInventoryCountId = @intTransactionId
END

END