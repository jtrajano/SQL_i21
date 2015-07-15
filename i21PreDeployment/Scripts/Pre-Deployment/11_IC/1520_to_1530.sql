PRINT N'BEGIN Update all existing Item Locations and set Allow Negative Inventory to Yes'

	IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intAllowNegativeInventory' AND object_id = OBJECT_ID('tblICItemLocation'))
	BEGIN
		EXEC ('UPDATE tblICItemLocation
				SET intAllowNegativeInventory = 1
				WHERE ISNULL(intAllowNegativeInventory, 0) = 0')
	END

PRINT N'END Update all existing Item Locations and set Allow Negative Inventory to Yes'

PRINT N'BEGIN Update all existing Category Standard UOM to reference Category UOM'

	IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intUOMId' AND object_id = OBJECT_ID('tblICCategory'))
	BEGIN
		EXEC ('
			UPDATE tblICCategory
			SET intUOMId = NULL
			WHERE intUOMId NOT IN (SELECT intCategoryUOMId FROM tblICCategoryUOM WHERE intCategoryId = tblICCategory.intCategoryId)
		')
	END

PRINT N'END Update all existing Category Standard UOM to reference Category UOM'

PRINT N'BEGIN Update all existing Category Standard UOM to reference Category UOM'

	IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intSubLocationId' AND object_id = OBJECT_ID('tblICItemStock'))
	BEGIN
		EXEC ('
			ALTER TABLE tblICItemStock
			DROP CONSTRAINT FK_tblICItemStock_tblSMCompanyLocationSubLocation

			ALTER TABLE tblICItemStock
			DROP COLUMN intSubLocationId
		')
	END

PRINT N'END Update all existing Category Standard UOM to reference Category UOM'