IF EXISTS(
	SELECT	TOP 1 1 
	FROM	sys.columns c INNER JOIN sys.tables t ON c.object_id = t.object_id 
	WHERE	c.name = 'dblDestinationGrossQty' 
			AND t.name = 'tblICInventoryShipmentItem'
	)
	EXEC ('
		ALTER TABLE tblICInventoryShipmentItem
		DROP COLUMN dblDestinationGrossQty	
	')	
GO
IF EXISTS(
	SELECT	TOP 1 1 
	FROM	sys.columns c INNER JOIN sys.tables t ON c.object_id = t.object_id 
	WHERE	c.name = 'dblDestinationNetQty' 
			AND t.name = 'tblICInventoryShipmentItem'
	)
	EXEC ('
		ALTER TABLE tblICInventoryShipmentItem
		DROP COLUMN dblDestinationNetQty	
	')	
GO
IF EXISTS(
	SELECT	TOP 1 1 
	FROM	sys.columns c INNER JOIN sys.tables t ON c.object_id = t.object_id 
	WHERE	c.name = 'intDestinationQtyUOMId' 
			AND t.name = 'tblICInventoryShipmentItem'
	)
	EXEC ('
		ALTER TABLE tblICInventoryShipmentItem
		DROP COLUMN intDestinationQtyUOMId	
	')	
GO