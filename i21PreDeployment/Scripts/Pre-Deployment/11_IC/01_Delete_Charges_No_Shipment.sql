PRINT N'Deleting inventory shipment charges without references to shipment...'

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryShipmentCharge'))
BEGIN
	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryShipment'))
	BEGIN
		EXEC ('DELETE c FROM tblICInventoryShipmentCharge c LEFT JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = c.intInventoryShipmentId');
	END
END