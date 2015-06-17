PRINT N'BEGIN Update all existing Item Locations and set Allow Negative Inventory to Yes'

	IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intAllowNegativeInventory' AND object_id = OBJECT_ID('tblICItemLocation'))
	BEGIN
		EXEC ('UPDATE tblICItemLocation
				SET intAllowNegativeInventory = 1
				WHERE ISNULL(intAllowNegativeInventory, 0) = 0')
	END

PRINT N'END Update all existing Item Locations and set Allow Negative Inventory to Yes'
