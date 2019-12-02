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
	-- Drop the constraint 
	ALTER TABLE tblICInventoryTransaction
	DROP CONSTRAINT PK_tblICInventoryTransaction
	
	-- Create a new clustered index. 
	CREATE CLUSTERED INDEX [IX_tblICInventoryTransaction_valuation]
		ON [dbo].[tblICInventoryTransaction]([intItemId] ASC, [intCompanyLocationId] ASC, [dtmDate] ASC, [intInventoryTransactionId] ASC);
	
	-- Create a new PK Index. 
	ALTER TABLE tblICInventoryTransaction
	ADD CONSTRAINT [PK_tblICInventoryTransaction] PRIMARY KEY ([intInventoryTransactionId])
END 
GO

PRINT N'END - IC Improve Inventory Valuation Performance'
GO