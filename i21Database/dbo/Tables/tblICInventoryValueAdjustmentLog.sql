/*
## Overview
	This table tracks all the cost adjustment to a specific Lot cost bucket. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryValueAdjustmentLog]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryTransactionId] INT NOT NULL, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intLotId] INT NULL, 
		[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
		[dblValue] NUMERIC(38, 20) NULL,
		[dblForexValue] NUMERIC(38, 20) NULL,
		[ysnIsUnposted] BIT DEFAULT 0,
		[intCurrencyId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NULL, 
		[dtmCreated] DATETIME NOT NULL, 
		[strRelatedTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
		[intRelatedTransactionId] INT,
		[intRelatedTransactionDetailId] INT,
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		[intOtherChargeItemId] INT NULL,
		[intOtherChargeCurrencyId] INT NULL,
		[intOtherChargeForexRateTypeId] INT NULL,
		[dblOtherChargeForexRate] NUMERIC(38, 20) NULL DEFAULT 1,
		CONSTRAINT [PK_tblICInventoryLotValueAdjustmentLog] PRIMARY KEY CLUSTERED ([intId])		
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryValueAdjustmentLog]
		ON [dbo].[tblICInventoryValueAdjustmentLog](
			[intItemId] ASC
			, [intItemLocationId] ASC
			, [intLotId] ASC
			, [strActualCostId] ASC
		)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryValueAdjustmentLog_Posting]
		ON [dbo].[tblICInventoryValueAdjustmentLog](
			[intInventoryTransactionId] ASC
		)
	GO