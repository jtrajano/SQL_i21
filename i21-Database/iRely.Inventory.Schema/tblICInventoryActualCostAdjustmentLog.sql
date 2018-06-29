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
		CONSTRAINT [PK_tblICInventoryActualCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryActualCostAdjustmentLog_tblICInventoryLot] FOREIGN KEY ([intInventoryActualCostId]) REFERENCES [tblICInventoryActualCost]([intInventoryActualCostId])
	)
GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryActualCostAdjustmentLog_intInventoryActualCostId]
	--	ON [dbo].[tblICInventoryActualCostAdjustmentLog]([intId] ASC)
	--	INCLUDE (dblQty, dblCost);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryActualCostAdjustmentLog]
		ON [dbo].[tblICInventoryActualCostAdjustmentLog]([intInventoryTransactionId] ASC)
		INCLUDE ([dblQty], [dblCost], [dblValue], [ysnIsUnposted], [intInventoryCostAdjustmentTypeId]);
GO