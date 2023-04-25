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
		CONSTRAINT [PK_tblICInventoryActualCostAdjustmentLog] PRIMARY KEY CLUSTERED ([intId]),
		CONSTRAINT [FK_tblICInventoryActualCostAdjustmentLog_tblICInventoryActualCost] FOREIGN KEY ([intInventoryActualCostId]) REFERENCES [tblICInventoryActualCost]([intInventoryActualCostId])
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