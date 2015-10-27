﻿CREATE PROCEDURE [dbo].[uspICLockInventoryCount]
	@intInventoryCountId int
AS
	UPDATE tblICItemLocation
	SET ysnLockedInventory = 1
	FROM (
		SELECT DISTINCT intItemId, intItemLocationId
		FROM tblICInventoryCountDetail
		WHERE intInventoryCountId = @intInventoryCountId
	) tblPatch
	WHERE tblPatch.intItemId = tblICItemLocation.intItemId
		AND tblPatch.intItemLocationId = tblICItemLocation.intItemLocationId
		AND ysnLockedInventory <> 1

	UPDATE tblICInventoryCount
	SET intStatus = 3
	WHERE intInventoryCountId = @intInventoryCountId

RETURN 0
