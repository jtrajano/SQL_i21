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
		CONSTRAINT [PK_tblICInventoryLotCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryLotCostAdjustmentLog_tblICInventoryLot] FOREIGN KEY ([intInventoryLotId]) REFERENCES [tblICInventoryLot]([intInventoryLotId])
	)
	GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotCostAdjustmentLog_intInventoryLotId]
	--	ON [dbo].[tblICInventoryLotCostAdjustmentLog]([intId] ASC)
	--	INCLUDE (dblQty, dblCost);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotCostAdjustmentLog]
		ON [dbo].[tblICInventoryLotCostAdjustmentLog]([intInventoryTransactionId] ASC)
		INCLUDE ([dblQty], [dblCost], [dblValue], [ysnIsUnposted], [intInventoryCostAdjustmentTypeId]);
	GO
