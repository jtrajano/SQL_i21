﻿/*
## Overview
When a stock is sold from tblICInventory, this is when dblStockOut is increased, the fifo out table will map it to the inventory transaction. 
This table is also used to map the negative fifo stock buckets it was able to revalue after receiving a new stock. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None


*	[intInventoryFIFOId] INT NULL
	Foreign key to tblICInventoryFIFO. It links source of the stock. 
	Maps: None


*	[intInventoryTransactionId] INT NOT NULL
	Foreign key to tblICInventoryTransaction. It links to the inventory transaction. 
	Maps: None


*	[intRevalueFifoId] INT NULL
	Foreign key to tblICInventoryFIFO. It links to the cost bucket that was revalued. 
	Maps: None


*	[dblQty] NUMERIC(18, 6) NOT NULL
	Qty, in base units, that was sold or revalued. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryFIFOStorageOut]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryFIFOStorageId] INT NULL, 
		[intInventoryTransactionId] INT NOT NULL,
		[intRevalueFifoId] INT NULL,
		[dblQty] NUMERIC(18, 6) NOT NULL,
		[dblCostAdjustQty] NUMERIC(18, 6) NULL,
		CONSTRAINT [PK_tblICInventoryFIFOStorageOut] PRIMARY KEY CLUSTERED ([intId])    
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOStorageOut_intInventoryTransactionId]
		ON [dbo].[tblICInventoryFIFOStorageOut]([intInventoryTransactionId] ASC)
		INCLUDE(intInventoryFIFOStorageId);
	GO