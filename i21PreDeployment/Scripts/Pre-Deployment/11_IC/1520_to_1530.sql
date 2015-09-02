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
		AND EXISTS(SELECT * FROM sys.columns WHERE name = 'intCategoryUOMId' AND object_id = OBJECT_ID('tblICCategoryUOM'))
	BEGIN
		EXEC ('
			UPDATE tblICCategory
			SET intUOMId = NULL
			WHERE intUOMId NOT IN (SELECT intCategoryUOMId FROM tblICCategoryUOM WHERE intCategoryId = tblICCategory.intCategoryId)
		')
	END

PRINT N'END Update all existing Category Standard UOM to reference Category UOM'

PRINT N'BEGIN Update all existing Category Standard UOM to reference Category UOM'

	IF EXISTS(SELECT * FROM sys.sysconstraints WHERE constid = OBJECT_ID('FK_tblICItemStock_tblSMCompanyLocationSubLocation'))
	BEGIN
		EXEC ('
			ALTER TABLE tblICItemStock
			DROP CONSTRAINT FK_tblICItemStock_tblSMCompanyLocationSubLocation
		')
	END

	IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intSubLocationId' AND object_id = OBJECT_ID('tblICItemStock'))
	BEGIN
		EXEC ('
			ALTER TABLE tblICItemStock
			DROP COLUMN intSubLocationId
		')
	END

PRINT N'END Update all existing Category Standard UOM to reference Category UOM'


PRINT N'BEGIN Add dtmDate in tblICInventoryLot'

	IF NOT EXISTS(SELECT * FROM sys.columns WHERE name = 'dtmDate' AND object_id = OBJECT_ID('tblICInventoryLot'))
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE object_id = OBJECT_ID('tblICInventoryLot'))
		BEGIN

			EXEC ('
				ALTER TABLE tblICInventoryLot ADD dtmDate DATETIME NULL 
			')

			EXEC ('
				UPDATE LotFIFO
				SET dtmDate = (
					SELECT	TOP 1 
							dtmDate 
					FROM	dbo.tblICInventoryTransaction
					WHERE	tblICInventoryTransaction.intTransactionId = LotFIFO.intTransactionId
							AND tblICInventoryTransaction.strTransactionId = LotFIFO.strTransactionId
				)
				FROM	dbo.tblICInventoryLot LotFIFO
				WHERE	LotFIFO.dtmDate IS NULL 		
			')

		END
	END

PRINT N'END Add dtmDate in tblICInventoryLot'

PRINT N'BEGIN Migrate intTaxGroupId to intSalesTaxGroupId field'

	IF EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE object_id = OBJECT_ID('tblICItem'))
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intTaxGroupId' AND object_id = OBJECT_ID('tblICItem'))
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intSalesTaxGroupId' AND object_id = OBJECT_ID('tblICItem')) 
			BEGIN
				EXEC ('
					ALTER TABLE tblICItem ADD intSalesTaxGroupId INT NULL 
				')
			
				EXEC ('
					UPDATE tblICItem
					SET intSalesTaxGroupId = intTaxGroupId
				')
			END
		END
	END

PRINT N'END Migrate intTaxGroupId to intSalesTaxGroupId field'