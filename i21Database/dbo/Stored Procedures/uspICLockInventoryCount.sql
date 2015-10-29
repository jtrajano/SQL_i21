CREATE PROCEDURE [dbo].[uspICLockInventoryCount]
	@intInventoryCountId INT,
	@ysnLock BIT = 1
AS
	UPDATE tblICItemLocation
	SET ysnLockedInventory = @ysnLock
	FROM (
		SELECT DISTINCT intItemId, intItemLocationId
		FROM tblICInventoryCountDetail
		WHERE intInventoryCountId = @intInventoryCountId
	) tblPatch
	WHERE tblPatch.intItemId = tblICItemLocation.intItemId
		AND tblPatch.intItemLocationId = tblICItemLocation.intItemLocationId
		AND ysnLockedInventory <> @ysnLock

	UPDATE tblICInventoryCount
	SET intStatus = (
		CASE WHEN @ysnLock = 1 THEN 3
			ELSE 2
		END)
	WHERE intInventoryCountId = @intInventoryCountId

RETURN 0
