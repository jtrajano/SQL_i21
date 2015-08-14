IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intOrderId' AND object_id = OBJECT_ID('tblICInventoryReceiptItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = OBJECT_ID('tblICInventoryShipmentItem'))
	BEGIN

		EXEC('
			ALTER TABLE tblICInventoryReceiptItem
			ADD intOrderId INT NULL
		')
		IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intSourceId' AND object_id = OBJECT_ID('tblICInventoryReceiptItem'))
		BEGIN
			EXEC ('
				UPDATE tblICInventoryReceiptItem
				SET intOrderId = intSourceId
				WHERE ISNULL(intOrderId, '''') = ''''
			')
			EXEC ('
				UPDATE tblICInventoryReceiptItem
				SET intSourceId = NULL
			')
		END

	END
END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intOrderId' AND object_id = OBJECT_ID('tblICInventoryShipmentItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = OBJECT_ID('tblICInventoryShipmentItem'))
	BEGIN
	
		EXEC('
			ALTER TABLE tblICInventoryShipmentItem
			ADD intOrderId INT NULL
		')
		IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intSourceId' AND object_id = OBJECT_ID('tblICInventoryShipmentItem'))
		BEGIN
			EXEC ('
				UPDATE tblICInventoryShipmentItem
				SET intOrderId = intSourceId
				WHERE ISNULL(intOrderId, '''') = ''''
			')
			EXEC ('
				UPDATE tblICInventoryShipmentItem
				SET intSourceId = NULL
			')
		END

	END
	
END
GO