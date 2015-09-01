/*
## Overview
When a stock is sold from tblICInventory, this is when dblStockOut is increased, the ActualCost out table will map it to the inventory transaction. 
This table is also used to map the negative ActualCost stock buckets it was able to revalue after receiving a new stock. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None


*	[intInventoryActualCostId] INT NULL
	Foreign key to tblICInventoryActualCost. It links source of the stock. 
	Maps: None


*	[intInventoryTransactionId] INT NOT NULL
	Foreign key to tblICInventoryTransaction. It links to the inventory transaction. 
	Maps: None


*	[intRevalueActualCostId] INT NULL
	Foreign key to tblICInventoryActualCost. It links to the cost bucket that was revalued. 
	Maps: None


*	[dblQty] NUMERIC(18, 6) NOT NULL
	Qty, in base units, that was sold or revalued. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryActualCostOut]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryActualCostId] INT NULL, 
		[intInventoryTransactionId] INT NOT NULL,
		[intRevalueActualCostId] INT NULL,
		[dblQty] NUMERIC(18, 6) NOT NULL,
		CONSTRAINT [PK_tblICInventoryActualCostOut] PRIMARY KEY CLUSTERED ([intId])    
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryActualCost_intInventoryTransactionId]
		ON [dbo].[tblICInventoryActualCostOut]([intInventoryTransactionId] ASC)
		INCLUDE([intInventoryActualCostId]);
	GO