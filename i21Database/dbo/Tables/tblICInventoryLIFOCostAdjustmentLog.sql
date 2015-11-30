/*
## Overview
	This table tracks all the cost adjustment to a specific LIFO cost bucket. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLIFOCostAdjustmentLog]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryLIFOId] INT NOT NULL, 
		[intInventoryTransactionId] INT NOT NULL, 
		[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0,
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0,
		[ysnIsUnposted] BIT DEFAULT 0,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLIFOCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryLIFOCostAdjustmentLog_tblICInventoryLIFO] FOREIGN KEY ([intInventoryLIFOId]) REFERENCES [tblICInventoryLIFO]([intInventoryLIFOId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOCostAdjustmentLog_intInventoryLIFOId]
		ON [dbo].[tblICInventoryLIFOCostAdjustmentLog]([intId] ASC)
		INCLUDE (dblQty, dblCost);
	GO
