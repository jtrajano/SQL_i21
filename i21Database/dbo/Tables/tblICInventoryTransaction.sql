/*
## Overview
In VisionCore, we called this table as tblGLVoucher. This table will be used to hold all the details of an item related to the posted transaction. 
It will include the stock quantity, cost, and sales prices. It is very relevant to the items costing method and valuation. 
Records from this table will be used to generate the GL entries and later on for the inventory valuation report. 

All inbound stock records can have related record/s in tblICInventoryFIFO or tblICInventoryLIFO. Additional records in the costing bucket may be added to 
track accrual of the cost. 

Accrual of the cost means additional cost are added to an item after it has been received. Cost used during receiving may be an estimate cost (usually the last cost of the item). 
This is common as when the final bill is received from the Vendor, only when the final cost is determined. These additional cost can be freight charges, duties, foreign exchange rates, levies, taxes, and/or other kinds of costs. 
Such costs need to be considered and must make-up the cost of the item. 

Outbound (sold) items before the final cost is determined are recomputed to include the accrued costs. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryTransaction]
	(
		[intInventoryTransactionId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(18, 6) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
		[intTransactionId] INT NOT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 
		[intLotId] INT NULL, 
		[ysnIsUnposted] BIT NULL,
		[intRelatedInventoryTransactionId] INT NULL,
		[intRelatedTransactionId] INT NULL,
		[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryTransaction] PRIMARY KEY ([intInventoryTransactionId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_strBatchId]
		ON [dbo].[tblICInventoryTransaction]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryTransaction]([intItemId] ASC, [intItemLocationId] ASC);