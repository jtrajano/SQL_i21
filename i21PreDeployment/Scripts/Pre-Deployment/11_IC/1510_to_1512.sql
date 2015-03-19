PRINT N'BEGIN INVENTORY PATH from 15.10.x.x to 15.12.x.x'

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICLot'))
BEGIN
	IF	NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICLot') AND name = 'intLocationId')
		AND EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICLot') AND name = 'intItemLocationId')
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

PRINT N'END INVENTORY PATH from 15.10.x.x to 15.12.x.x'