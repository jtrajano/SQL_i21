/*
## Overview
When stock is returned, this table will log the transactions that returned the stock. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None

## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReturned]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryFIFOId] INT NULL, 
		[intInventoryLIFOId] INT NULL, 
		[intInventoryLotId] INT NULL, 
		[intInventoryActualCostId] INT NULL, 
		[intInventoryTransactionId] INT NOT NULL,
		[intOutId] INT NULL, 
		[dblQtyReturned] NUMERIC(38, 20) NOT NULL,
		[dblCost] NUMERIC(38, 20) NOT NULL,
		[intTransactionId] INT NOT NULL,
		[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL,
		[intTransactionTypeId] INT NOT NULL,
		[intTransactionDetailId] INT NULL,
		CONSTRAINT [PK_tblICInventoryReturned] PRIMARY KEY CLUSTERED ([intId])    
	)
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReturned_intInventoryTransactionId]
		ON [dbo].[tblICInventoryReturned]([intInventoryTransactionId] ASC)
		INCLUDE(intInventoryFIFOId);
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReturned_intInventoryFIFOOutId]
		ON [dbo].[tblICInventoryReturned]([intInventoryFIFOId] ASC)
		INCLUDE([intOutId]);
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReturned_intInventoryLIFOId]
		ON [dbo].[tblICInventoryReturned]([intInventoryLIFOId] ASC)
		INCLUDE([intOutId]);
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReturned_intInventoryLotId]
		ON [dbo].[tblICInventoryReturned]([intInventoryLotId] ASC)
		INCLUDE([intOutId]);
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReturned_intInventoryActualCostId]
		ON [dbo].[tblICInventoryReturned]([intInventoryActualCostId] ASC)
		INCLUDE([intOutId]);
	GO
