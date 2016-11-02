
-- This sp is called in the WEB API before the shipment record is deleted. 
CREATE PROCEDURE [dbo].[uspICBeforeShipmentDelete]
	@intShipmentId INT
AS
	
-- Update the SO or Scale status from deleted shipment records.
-- Usually, deleted records will "open" the status of the SO or Scale Ticket. 
BEGIN 
	EXEC uspICUpdateStatusOnShipmentSave 
			@intShipmentId = @intShipmentId
			,@ysnOpenStatus = 1 
END

-- Call the grain sp when deleting the shipment. 
-- This will delete the Grain History record. There is an FK constraint between the Grain History and Shipment Detail tables. 
BEGIN 
	EXEC uspGRDeleteStorageHistory 
		@strSourceType = 'InventoryShipment'
		,@IntSourceKey = @intShipmentId
END 