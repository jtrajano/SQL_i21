/*
## Overview
	This table tracks all the cost adjustment to a specific fifo cost bucket. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryFIFOCostAdjustmentLog]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryFIFOId] INT NOT NULL, 
		[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0,
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFOCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryFIFOCostAdjustmentLog_tblICInventoryFIFO] FOREIGN KEY ([intInventoryFIFOId]) REFERENCES [tblICInventoryFIFO]([intInventoryFIFOId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOCostAdjustmentLog_intInventoryFIFOId]
		ON [dbo].[tblICInventoryFIFOCostAdjustmentLog]([intId] ASC)
		INCLUDE (dblQty, dblCost);
	GO
