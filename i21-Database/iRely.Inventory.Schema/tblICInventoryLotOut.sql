/*
## Overview
When a stock is sold from tblICInventoryLot, this is when dblStockOut is increased, and the Lot-Out table will map it to the inventory transaction. 
This table is also used to map the negative Lot stock buckets it was able to revalue after receiving a new stock. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None


*	[intInventoryLotId] INT NULL
	Foreign key to tblICInventoryLot. It links source of the stock. 
	Maps: None


*	[intInventoryTransactionId] INT NOT NULL
	Foreign key to tblICInventoryTransaction. It links to the inventory transaction. 
	Maps: None


*	[intRevalueFifoId] INT NULL
	Foreign key to tblICInventoryFIFO. It links to the cost bucket that was revalued. 
	Maps: None


*	[dblQty] NUMERIC(38, 20) NOT NULL
	Qty, in base units, that was sold or revalued. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotOut]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryLotId] INT NULL, 
		[intInventoryTransactionId] INT NOT NULL,
		[intRevalueLotId] INT NULL,
		[dblQty] NUMERIC(38, 20) NOT NULL,
		[dblCostAdjustQty] NUMERIC(38, 20) NULL,
		[dblQtyReturned] NUMERIC(38, 20) NULL,
		CONSTRAINT [PK_tblICInventoryLotOut] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryLotOut_tblICInventoryLot] FOREIGN KEY ([intInventoryLotId]) REFERENCES [tblICInventoryLot]([intInventoryLotId]) 
	)
	GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotOut_intInventoryTransactionId]
	--	ON [dbo].[tblICInventoryLotOut]([intInventoryTransactionId] ASC)
	--	INCLUDE(intInventoryLotId);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotOut]
		ON [dbo].[tblICInventoryLotOut]([intInventoryLotId] ASC, [intInventoryTransactionId] ASC)
	GO