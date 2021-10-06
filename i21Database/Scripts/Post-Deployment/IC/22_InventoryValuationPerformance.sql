PRINT N'START- IC Improve Inventory Valuation Performance'
GO

UPDATE t
SET 
	t.intCompanyLocationId = x.intCompanyLocationId
FROM 
	tblICInventoryTransaction t 	
	OUTER APPLY dbo.fnICGetCompanyLocation(t.intItemLocationId, t.intInTransitSourceLocationId) x
WHERE
	t.intCompanyLocationId IS NULL 

GO

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
		-- Drop the primary key constraint
		EXEC('
			ALTER TABLE tblICInventoryTransaction
			DROP CONSTRAINT PK_tblICInventoryTransaction	
		')
	END 
	
	-- Create a new clustered index. 
	EXEC ('
		CREATE CLUSTERED INDEX [IX_tblICInventoryTransaction_valuation]
			ON [dbo].[tblICInventoryTransaction]([intItemId] ASC, [intCompanyLocationId] ASC, [dtmDate] ASC, [intInventoryTransactionId] ASC);	
	')
	
	-- Create a new PK Index. 
	EXEC ('
		ALTER TABLE tblICInventoryTransaction
		ADD CONSTRAINT [PK_tblICInventoryTransaction] PRIMARY KEY ([intInventoryTransactionId])	
	')
END 
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryDailyTransaction)	OR NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryStockAsOfDate)
BEGIN
	EXEC uspICPostStockDailyQuantity
		@ysnRebuild = 1
END 
GO 

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryStorageAsOfDate)
BEGIN
	EXEC uspICPostStorageDailyQuantity
		@ysnRebuild = 1
END 
GO 

PRINT N'END - IC Improve Inventory Valuation Performance'
GO