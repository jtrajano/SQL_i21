-- Remove duplicate feed stock uom
PRINT N'Deleting inventory shipment charges without references to shipment...'

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryShipmentCharge'))
BEGIN
	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryShipment'))
	BEGIN
		EXEC ('DELETE sc FROM tblICInventoryShipmentCharge sc LEFT JOIN tblICInventoryShipment s ON sc.intInventoryShipmentId = s.intInventoryShipmentId WHERE s.intInventoryShipmentId IS NULL');
	END
END


IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryReceiptChargePerItem'))
BEGIN
	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryReceiptCharge'))
	BEGIN
		EXEC ('DELETE rci FROM tblICInventoryReceiptChargePerItem rci LEFT JOIN tblICInventoryReceiptCharge rc ON rci.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId WHERE rc.intInventoryReceiptId IS NULL');
	END
END