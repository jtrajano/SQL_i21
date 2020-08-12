/*
## Overview
Tracks all stocks in a FIFO manner. Records are physically arranged in a FIFO manner using a CLUSTERED index. 

## Fields, description, and mapping. 
*	[intInventoryFIFOId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None 


* 	[intItemId] INT NOT NULL
	Foreign key to tblICItem. It links to the item table. 
	Maps: None


* 	[intLocationId] INT NOT NULL
	Foreign key to tblSMCompanyLocation. It links to the company location table. 
	Maps: None


*	[dtmDate] DATETIME NOT NULL 
	Date when the stock is received or sold as a negative stock. 
	Maps: None


* 	[dblStockIn] NUMERIC(38, 20) NOT NULL DEFAULT 0
	Stock Qty, in base units, received from the transaction. 
	Maps: None


* 	[dblStockOut] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	Stock Qty, in base units, sold to the transaction. 
	Maps: None


* 	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	Cost of the stock per base units. 
	Maps: None


* 	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
	The string id of the transaction. 
	Maps: None


* 	[intTransactionId] INT NOT NULL
	The integer id of the transaction. 
	Maps: None


*	[dtmCreated] DATETIME NULL
	The date when the record is created in the server. This is different from the date of the transaction. 
	Maps: None


*	[ysnIsUnposted] BIT NOT NULL DEFAULT 0
	Flags if the cost bucket has been unposted. 
	Maps: None


*	[intCreatedUserId] INT NULL
	Internal field used to track the user id who created the cost bucket. 
	Maps: None


*	[intConcurrencyId] INT NOT NULL DEFAULT 1
	Internal field used to track the concurrency of the record. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryFIFO]
	(
		[intInventoryFIFOId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblStockIn] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblStockOut] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[dblNewCost] NUMERIC(38, 20) NULL,
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL,		
		[intTransactionDetailId] INT NULL,		
		[ysnIsUnposted] BIT NOT NULL DEFAULT 0, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL,
		[intCompanyId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFO] PRIMARY KEY NONCLUSTERED ([intInventoryFIFOId]) 
	)
	GO

	CREATE CLUSTERED INDEX [IDX_tblICInventoryFIFO]
		ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);
	GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO_intItemId_intLocationId]
	--	ON [dbo].[tblICInventoryFIFO]([intItemId] ASC, [intItemLocationId] ASC)
	--	INCLUDE (dtmDate, dblStockIn, dblStockOut, dblCost);
	--GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO_strTransactionId]
	--	ON [dbo].[tblICInventoryFIFO]([strTransactionId] ASC)
	--	INCLUDE (intTransactionId);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO]
		--ON [dbo].[tblICInventoryFIFO]([intItemId] ASC, [intItemLocationId] ASC, [strTransactionId] ASC, [intTransactionId] ASC, [ysnIsUnposted] ASC)
		ON [dbo].[tblICInventoryFIFO]([strTransactionId] ASC, [intTransactionId] ASC, [ysnIsUnposted] ASC)
		INCLUDE (dtmDate, intItemId, intItemLocationId, intItemUOMId, dblStockIn, dblStockOut, dblCost);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO_Posting]
		ON [dbo].[tblICInventoryFIFO]([intItemId] ASC, [intItemLocationId] ASC, [intItemUOMId] ASC)
		INCLUDE (dblStockIn, dblStockOut, dtmDate);
	GO