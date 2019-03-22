CREATE PROCEDURE [dbo].[uspICDeleteInventoryTransfer]
	 @InventoryTransferId INT
	,@intEntityUserSecurityId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------
-- Validate
--------------------------------------------------------------------
DECLARE @strTransferNo AS NVARCHAR(50) 

SELECT	TOP 1 
		@strTransferNo = strTransferNo
FROM	dbo.tblICInventoryTransfer 
WHERE	intInventoryTransferId = @InventoryTransferId 
		AND ISNULL(ysnPosted, 0) = 1

IF @strTransferNo IS NOT NULL 
BEGIN 
	-- 'Delete is not allowed. %s is posted.'
	EXEC uspICRaiseError 80070, @strTransferNo;
	RETURN -1; 
END 

--------------------------------------------------------------------
-- Delete the record
--------------------------------------------------------------------
DELETE FROM dbo.tblICInventoryTransfer 
WHERE intInventoryTransferId = @InventoryTransferId

--------------------------------------------------------------------
-- Audit Log          
--------------------------------------------------------------------
EXEC	dbo.uspSMAuditLog 
		@keyValue = @InventoryTransferId						-- Primary Key Value of the Inventory Receipt. 
		,@screenName = 'Inventory.view.InventoryTransfer'       -- Screen Namespace
		,@entityId = @intEntityUserSecurityId					-- Entity Id.
		,@actionType = 'Deleted'								-- Action Type
		,@changeDescription = ''								-- Description
		,@fromValue = ''										-- Previous Value
		,@toValue = ''											-- New Value
