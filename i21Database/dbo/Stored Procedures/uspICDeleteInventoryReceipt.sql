CREATE PROCEDURE [dbo].[uspICDeleteInventoryReceipt]
	 @InventoryReceiptId INT
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
DECLARE @strReceiptNumber AS NVARCHAR(50) 

SELECT	TOP 1 
		@strReceiptNumber = strReceiptNumber
FROM	dbo.tblICInventoryReceipt 
WHERE	intInventoryReceiptId = @InventoryReceiptId 
		AND ISNULL(ysnPosted, 0) = 1

IF @strReceiptNumber IS NOT NULL 
BEGIN 
	-- 'Delete is not allowed. %s is posted.'
	RAISERROR('Delete is not allowed. %s is posted.', 11, 1, @strReceiptNumber)  
	RETURN -1; 
END 

--------------------------------------------------------------------
-- Delete the record
--------------------------------------------------------------------
DELETE FROM	dbo.tblICInventoryReceipt 
WHERE intInventoryReceiptId = @InventoryReceiptId

--------------------------------------------------------------------
-- Audit Log          
--------------------------------------------------------------------
EXEC	dbo.uspSMAuditLog 
		@keyValue = @InventoryReceiptId							-- Primary Key Value of the Inventory Receipt. 
		,@screenName = 'Inventory.view.InventoryReceipt'        -- Screen Namespace
		,@entityId = @intEntityUserSecurityId					-- Entity Id.
		,@actionType = 'Deleted'								-- Action Type
		,@changeDescription = ''								-- Description
		,@fromValue = ''										-- Previous Value
		,@toValue = ''											-- New Value
