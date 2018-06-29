/*
## Overview
	This table tracks all the out stocks revalued after a cost adjustment. 

## Fields, description, and mapping. 
*	[intInventoryFIFORevalueOutStocksId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 

## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryFIFORevalueOutStock]
	(
		[intInventoryFIFORevalueOutStockId] INT NOT NULL IDENTITY, 
		[intInventoryFIFOId] INT NOT NULL, 
		[intInventoryTransactionId] INT NOT NULL, 
		[intInventoryCostAdjustmentId] INT NOT NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFORevalueOutStock] PRIMARY KEY CLUSTERED ([intInventoryFIFORevalueOutStockId]),
		CONSTRAINT [FK_tblICInventoryFIFORevalueOutStock_tblICInventoryFIFO] FOREIGN KEY ([intInventoryFIFOId]) REFERENCES [tblICInventoryFIFO]([intInventoryFIFOId]),
		CONSTRAINT [FK_tblICInventoryFIFORevalueOutStock_tblICInventoryTransaction] FOREIGN KEY ([intInventoryTransactionId]) REFERENCES [tblICInventoryTransaction]([intInventoryTransactionId]),
		CONSTRAINT [FK_tblICInventoryFIFORevalueOutStock_tblICInventoryFIFOCostAdjustmentLog] FOREIGN KEY ([intInventoryCostAdjustmentId]) REFERENCES [tblICInventoryFIFOCostAdjustmentLog]([intId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFORevalueOutStock_intInventoryFIFOId_intInventoryCostAdjustmentId]
		ON [dbo].[tblICInventoryFIFORevalueOutStock]([intInventoryFIFOId] ASC, intInventoryCostAdjustmentId ASC)
		INCLUDE (intInventoryFIFORevalueOutStockId, intInventoryTransactionId);
	GO