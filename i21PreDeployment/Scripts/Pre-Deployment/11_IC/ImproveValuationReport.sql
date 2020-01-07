
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