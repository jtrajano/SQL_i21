CREATE PROCEDURE [testi21Database].[Inventory Shipment expected tables]
AS
BEGIN	

	-- Header table (tblICInventoryShipment)
	BEGIN 
		SELECT * 
		INTO expected_tblICInventoryShipment
		FROM tblICInventoryShipment
		WHERE 1 = 0 

		SELECT * 
		INTO actual_tblICInventoryShipment
		FROM tblICInventoryShipment
		WHERE 1 = 0 
	END 

	-- Detail Item table (tblICInventoryShipmentItem)
	BEGIN 
		SELECT * 
		INTO expected_tblICInventoryShipmentItem
		FROM tblICInventoryShipmentItem
		WHERE 1 = 0 

		SELECT * 
		INTO actual_tblICInventoryShipmentItem
		FROM tblICInventoryShipmentItem
		WHERE 1 = 0 
	END 
END