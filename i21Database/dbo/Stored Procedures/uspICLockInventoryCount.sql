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

	UPDATE tblICItemLocation
	SET ysnLockedInventory = @ysnLock
	FROM tblICItemLocation ItemLocation
	LEFT JOIN tblICInventoryCount InvCount
	ON InvCount.intInventoryCountId = @intInventoryCountId AND InvCount.intLocationId = ItemLocation.intLocationId
	LEFT JOIN tblICInventoryCountDetail InvCountDetail
	ON InvCountDetail.intItemId = ItemLocation.intItemId


	UPDATE tblICInventoryCount
	SET intStatus = (
		CASE WHEN @ysnLock = 1 THEN 3
			ELSE 2
		END)
	WHERE intInventoryCountId = @intInventoryCountId

RETURN 0
