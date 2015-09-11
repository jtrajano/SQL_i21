
/****************** Begin Populate company location Id in tblICStockReservation.intLocationId field **************/
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tblICStockReservation'))
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intLocationId' AND object_id = object_id('tblICStockReservation'))
	BEGIN
		EXEC('
			ALTER TABLE tblICStockReservation
			ADD intLocationId INT NULL
		')

		EXEC ('
			UPDATE	StockReservation
			SET		intLocationId = tblICItemLocation.intLocationId 
			FROM	dbo.tblICStockReservation StockReservation INNER JOIN dbo.tblICItemLocation
						ON StockReservation.intItemLocationId = tblICItemLocation.intItemLocationId
			WHERE	StockReservation.intLocationId IS NULL
		')

	END	
END
GO
/****************** End Populate company location Id in tblICStockReservation.intLocationId field **************/