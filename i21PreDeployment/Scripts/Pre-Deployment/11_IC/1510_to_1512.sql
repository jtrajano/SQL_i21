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

PRINT N'BEGIN Update of all Allow Purchase/Sale Fields set to True to Start 15.2'

IF NOT EXISTS (SELECT * FROM tblSMBuildNumber WHERE strVersionNo = '15.2')
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE (name = 'ysnAllowPurchase' OR name = 'ysnAllowSale') AND object_id = OBJECT_ID('tblICItemUOM'))
	BEGIN
		EXEC ('UPDATE tblICItemUOM
				SET ysnAllowPurchase = 1,
				ysnAllowSale = 1')
	END
	
	IF EXISTS(SELECT * FROM sys.columns WHERE (name = 'ysnAllowPurchase' OR name = 'ysnAllowSale') AND object_id = OBJECT_ID('tblICCategoryUOM'))
	BEGIN
		EXEC ('UPDATE tblICCategoryUOM
				SET ysnAllowPurchase = 1,
				ysnAllowSale = 1')
	END
	
END

PRINT N'END Update of all Allow Purchase/Sale Fields set to True to Start 15.2'

