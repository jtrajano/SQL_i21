
IF NOT EXISTS (
	SELECT 
		i.name
	FROM
		sys.tables t
	INNER JOIN 
		sys.indexes i ON t.object_id = i.object_id
	WHERE
		i.index_id = 1  -- clustered index    
		AND i.name = 'IX_tblICInventoryTransaction_valuation'
)
BEGIN 

	IF EXISTS (
		SELECT f.name FROM sys.foreign_keys f WHERE f.name = 'FK_tblICInventoryFIFORevalueOutStock_tblICInventoryTransaction'	
	)
	BEGIN 
		EXEC('
			ALTER TABLE tblICInventoryFIFORevalueOutStock
			DROP CONSTRAINT FK_tblICInventoryFIFORevalueOutStock_tblICInventoryTransaction	
		')
	END 

	IF EXISTS (
		SELECT f.name FROM sys.foreign_keys f WHERE f.name = 'FK_tblICItemStockPath_tblICInventoryTransaction_Descendant'	
	)
	BEGIN 
		EXEC('
			ALTER TABLE tblICItemStockPath
			DROP CONSTRAINT FK_tblICItemStockPath_tblICInventoryTransaction_Descendant	
		')
	END 

	IF EXISTS (
		SELECT f.name FROM sys.foreign_keys f WHERE f.name = 'FK_tblICItemStockPath_tblICInventoryTransaction_Ancestor'	
	)
	BEGIN 
		EXEC('
			ALTER TABLE tblICItemStockPath
			DROP CONSTRAINT FK_tblICItemStockPath_tblICInventoryTransaction_Ancestor	
		')
	END 

	IF EXISTS (
		SELECT i.name FROM sys.tables t INNER JOIN sys.indexes i ON t.object_id = i.object_id WHERE i.name = 'PK_tblICInventoryTransaction'	
	)
	BEGIN 
		EXEC('
			ALTER TABLE tblICInventoryTransaction
			DROP CONSTRAINT PK_tblICInventoryTransaction	
		')
	END 
END 

GO