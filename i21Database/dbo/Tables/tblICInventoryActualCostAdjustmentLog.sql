/*
## Overview
	This table tracks all the cost adjustment to a specific Actual Cost bucket. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryActualCostAdjustmentLog]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryActualCostId] INT NOT NULL, 
		[intInventoryTransactionId] INT NOT NULL, 
		[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0,
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0,
		[ysnIsUnposted] BIT DEFAULT 0,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryActualCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryActualCostAdjustmentLog_tblICInventoryLot] FOREIGN KEY ([intInventoryActualCostId]) REFERENCES [tblICInventoryActualCost]([intInventoryActualCostId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryActualCostAdjustmentLog_intInventoryActualCostId]
		ON [dbo].[tblICInventoryActualCostAdjustmentLog]([intId] ASC)
		INCLUDE (dblQty, dblCost);
	GO
