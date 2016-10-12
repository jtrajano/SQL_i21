CREATE PROCEDURE [dbo].[uspICLockInventoryCount]
	@intInventoryCountId INT,
	@ysnLock BIT
AS

/*	UPDATE tblICItemLocation
	SET ysnLockedInventory = @ysnLock
	FROM (
		SELECT DISTINCT intItemId, intItemLocationId
		FROM tblICInventoryCountDetail
		WHERE intInventoryCountId = @intInventoryCountId
	) tblPatch
	WHERE tblPatch.intItemId = tblICItemLocation.intItemId
		AND tblPatch.intItemLocationId = tblICItemLocation.intItemLocationId
		AND ysnLockedInventory <> @ysnLock*/

	UPDATE il SET il.ysnLockedInventory = @ysnLock
	FROM tblICItemLocation il
		INNER JOIN tblICInventoryCount ic ON ic.intLocationId = il.intLocationId
		INNER JOIN tblICInventoryCountDetail icd ON icd.intInventoryCountId = ic.intInventoryCountId
			AND il.intItemId = icd.intItemId
	WHERE ic.intInventoryCountId = @intInventoryCountId


	UPDATE tblICInventoryCount
	SET intStatus = (
		CASE WHEN @ysnLock = 1 THEN 3
			ELSE 2
		END)
	WHERE intInventoryCountId = @intInventoryCountId

RETURN 0
