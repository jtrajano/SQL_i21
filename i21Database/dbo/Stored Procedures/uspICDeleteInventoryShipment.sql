CREATE PROCEDURE [dbo].[uspICDeleteInventoryShipment]
	 @InventoryShipmentId INT
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
DECLARE @strShipmentNumber AS NVARCHAR(50) 

SELECT	TOP 1 
		@strShipmentNumber = strShipmentNumber
FROM	dbo.tblICInventoryShipment 
WHERE	intInventoryShipmentId = @InventoryShipmentId 
		AND ISNULL(ysnPosted, 0) = 1

IF @strShipmentNumber IS NOT NULL 
BEGIN 
	-- 'Delete is not allowed. %s is posted.'
	RAISERROR(80070, 11, 1, @strShipmentNumber)  
	RETURN -1; 
END 

--------------------------------------------------------------------
-- Delete the record
--------------------------------------------------------------------
DELETE FROM	dbo.tblICInventoryShipment 
WHERE intInventoryShipmentId = @InventoryShipmentId

--------------------------------------------------------------------
-- Audit Log          
--------------------------------------------------------------------
EXEC	dbo.uspSMAuditLog 
		@keyValue = @InventoryShipmentId						-- Primary Key Value of the Inventory Shipment. 
		,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
		,@entityId = @intEntityUserSecurityId					-- Entity Id.
		,@actionType = 'Deleted'								-- Action Type
		,@changeDescription = ''								-- Description
		,@fromValue = ''										-- Previous Value
		,@toValue = ''											-- New Value
