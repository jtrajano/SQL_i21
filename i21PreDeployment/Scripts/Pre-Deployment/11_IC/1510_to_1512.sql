PRINT N'BEGIN INVENTORY PATH from 15.10.x.x to 15.12.x.x'

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICLot'))
BEGIN
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICLot') AND name = 'intLocationId')
	BEGIN
		-- Manually add the intLocationId as INT and NULLABLE field
		EXEC('
			ALTER TABLE tblICLot ADD intLocationId INT NULL
		')
		
		-- Populate the data for intLocationId 
		EXEC('
			UPDATE	tblICLot
			SET		intLocationId = ItemLocation.intLocationId
			FROM	tblICLot Lot INNER JOIN tblICItemLocation ItemLocation
						ON Lot.intItemLocationId = ItemLocation.intItemLocationId
		')
	END
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryReceiptItemLot'))
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICInventoryReceiptItemLot') AND name = 'strLotNumber')
	BEGIN
		-- Repopulate the missing strLotNumber value
		EXEC('
			UPDATE	ItemLot
			SET		strLotNumber = Lot.strLotNumber
			FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN tblICLot Lot
						ON ItemLot.intLotId = Lot.intLotId
			WHERE	ItemLot.intLotId IS NOT NULL 
					AND ISNULL(ItemLot.strLotNumber, '''') = ''''
		')
	END
END


PRINT N'END INVENTORY PATH from 15.10.x.x to 15.12.x.x'