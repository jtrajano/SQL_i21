/*
## Overview
	This table tracks all the cost adjustment to a specific Lot cost bucket. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotCostAdjustmentLog]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryLotId] INT NOT NULL, 
		[intInventoryTransactionId] INT NOT NULL, 
		[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0,
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0,
		[ysnIsUnposted] BIT DEFAULT 0,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLotCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryLotCostAdjustmentLog_tblICInventoryLot] FOREIGN KEY ([intInventoryLotId]) REFERENCES [tblICInventoryLot]([intInventoryLotId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotCostAdjustmentLog_intInventoryLotId]
		ON [dbo].[tblICInventoryLotCostAdjustmentLog]([intId] ASC)
		INCLUDE (dblQty, dblCost);
	GO
