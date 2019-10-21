/*
## Overview
Tracks all non-company owned stocks in a LIFO manner. Records are physically arranged in a LIFO manner using a CLUSTERED index. 

## Fields, description, and mapping. 
*	[intInventoryLIFOStorageId] INT NOT NULL IDENTITY
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
	CREATE TABLE [dbo].[tblICInventoryLIFOStorage]
	(
		[intInventoryLIFOStorageId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblStockIn] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblStockOut] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL,		
		[intTransactionDetailId] INT NULL,		
		[ysnIsUnposted] BIT NOT NULL DEFAULT 0, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL,
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLIFOStorage] PRIMARY KEY NONCLUSTERED ([intInventoryLIFOStorageId]) 
	)
	GO

	CREATE CLUSTERED INDEX [IDX_tblICInventoryLIFOStorage]
		ON [dbo].[tblICInventoryLIFOStorage]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOStorageId] DESC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOStorage_intItemId_intLocationId]
		ON [dbo].[tblICInventoryLIFOStorage]([intItemId] ASC, [intItemLocationId] ASC)
		INCLUDE (dtmDate, dblStockIn, dblStockOut, dblCost);
	GO
