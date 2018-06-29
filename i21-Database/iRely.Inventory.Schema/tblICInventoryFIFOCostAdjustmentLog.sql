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
		[intInventoryTransactionId] INT NOT NULL, 
		[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
		[dblQty] NUMERIC(38, 20) NULL,
		[dblCost] NUMERIC(38, 20) NULL,
		[dblValue] NUMERIC(38, 20) NULL,
		[ysnIsUnposted] BIT DEFAULT 0,
		[dtmCreated] DATETIME NULL, 
		[strRelatedTransactionId] NVARCHAR(50), 
		[intRelatedTransactionId] INT,
		[intRelatedTransactionDetailId] INT,
		[intRelatedInventoryTransactionId] INT,
		[intOtherChargeItemId] INT,
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFOCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryFIFOCostAdjustmentLog_tblICInventoryFIFO] FOREIGN KEY ([intInventoryFIFOId]) REFERENCES [tblICInventoryFIFO]([intInventoryFIFOId])
	)
GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOCostAdjustmentLog_intInventoryFIFOId]
	--	ON [dbo].[tblICInventoryFIFOCostAdjustmentLog]([intId] ASC)
	--	INCLUDE (dblQty, dblCost);
	--GO 

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOCostAdjustmentLog]
	--	ON [dbo].[tblICInventoryFIFOCostAdjustmentLog]([intInventoryFIFOId] ASC)
	--	INCLUDE ([dblQty], [dblCost], [dblValue], [ysnIsUnposted], [intInventoryCostAdjustmentTypeId]);

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOCostAdjustmentLog]
		ON [dbo].[tblICInventoryFIFOCostAdjustmentLog]([intInventoryTransactionId] ASC)
		INCLUDE ([dblQty], [dblCost], [dblValue], [ysnIsUnposted], [intInventoryCostAdjustmentTypeId]);
GO
