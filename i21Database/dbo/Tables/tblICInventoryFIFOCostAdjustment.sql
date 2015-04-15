/*
## Overview
	This table tracks all the cost adjustment to a specific fifo cost bucket. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
	Primay key. 
	Maps: None 


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryFIFOCostAdjustment]
	(
		[intInventoryCostAdjustmentId] INT NOT NULL IDENTITY, 
		[intInventoryFIFOId] INT NOT NULL, 
		[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0,
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL,			
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFOCostAdjustment] PRIMARY KEY CLUSTERED ([intInventoryCostAdjustmentId]),
		CONSTRAINT [FK_tblICInventoryFIFOCostAdjustment_tblICInventoryFIFO] FOREIGN KEY ([intInventoryFIFOId]) REFERENCES [tblICInventoryFIFO]([intInventoryFIFOId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOCostAdjustment_intInventoryFIFOId]
		ON [dbo].[tblICInventoryFIFOCostAdjustment]([intInventoryCostAdjustmentId] ASC)
		INCLUDE (strTransactionId, intTransactionId);
	GO
