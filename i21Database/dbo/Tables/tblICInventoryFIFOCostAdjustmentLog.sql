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
		[dblForexCost] NUMERIC(38, 20) NULL,
		[dblValue] NUMERIC(38, 20) NULL,
		[dblForexValue] NUMERIC(38, 20) NULL,
		[intCurrencyId] INT NULL,
		[intForexRateTypeId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NULL,		
		[ysnIsUnposted] BIT DEFAULT 0,
		[dtmCreated] DATETIME NOT NULL, 
		[strRelatedTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
		[intRelatedTransactionId] INT,
		[intRelatedTransactionDetailId] INT,
		[intRelatedInventoryTransactionId] INT,
		[intOtherChargeItemId] INT,
		[intOtherChargeCurrencyId] INT NULL,
		[intOtherChargeForexRateTypeId] INT NULL,
		[dblOtherChargeForexRate] NUMERIC(38, 20) NULL DEFAULT 1,
		[dblOtherChargeValue] NUMERIC(38, 20) NULL,
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
