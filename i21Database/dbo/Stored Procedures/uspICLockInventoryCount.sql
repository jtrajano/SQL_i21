CREATE PROCEDURE [dbo].[uspICLockInventoryCount]
	@intInventoryCountId INT,
	@ysnLock BIT
AS

DECLARE @intLockType INT
DECLARE @intSecurityUserId INT

SELECT @intLockType = c.intLockType, @intSecurityUserId = c.intEntityId
FROM tblICInventoryCount c
WHERE c.intInventoryCountId = @intInventoryCountId

EXEC dbo.[uspICLockInventoryLocation] @intLockType, @intInventoryCountId, @ysnLock, @intSecurityUserId, 0