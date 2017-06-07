CREATE PROCEDURE [dbo].[uspICDeleteChargePerItemOnShipmentSave]
	@intShipmentNo INT
AS

-- Clear the records in tblICInventoryShipmentChargePerItem 
-- It will be re-created when the shipment is posted. 
BEGIN 
	DELETE	chargePerItem
	FROM	tblICInventoryShipmentChargePerItem chargePerItem INNER JOIN tblICInventoryShipment s 
				ON chargePerItem.intInventoryShipmentId = s.intInventoryShipmentId
	WHERE	s.intInventoryShipmentId = @intShipmentNo
END 

