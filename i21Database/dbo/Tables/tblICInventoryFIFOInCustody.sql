﻿/*
## Overview
Tracks all non-company owned stocks in a FIFO manner. Records are physically arranged in a FIFO manner using a CLUSTERED index. 
Records must be maintained in this table even if the costing method for an item is average costing. 

## Fields, description, and mapping. 
*	[intInventoryFIFOInCustodyId] INT NOT NULL IDENTITY
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


* 	[dblStockIn] NUMERIC(18, 6) NOT NULL DEFAULT 0
	Stock Qty, in base units, received from the transaction. 
	Maps: None


* 	[dblStockOut] NUMERIC(18, 6) NOT NULL DEFAULT 0 
	Stock Qty, in base units, sold to the transaction. 
	Maps: None


* 	[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0 
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
	CREATE TABLE [dbo].[tblICInventoryFIFOInCustody]
	(
		[intInventoryFIFOInCustodyId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblStockIn] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblStockOut] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 		
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL,		
		[ysnIsUnposted] BIT NOT NULL DEFAULT 0, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryFIFOInCustody] PRIMARY KEY NONCLUSTERED ([intInventoryFIFOInCustodyId]) 
	)
	GO

	CREATE CLUSTERED INDEX [IDX_tblICInventoryFIFOInCustody]
		ON [dbo].[tblICInventoryFIFOInCustody]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOInCustodyId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOInCustody_intItemId_intLocationId]
		ON [dbo].[tblICInventoryFIFOInCustody]([intItemId] ASC, [intItemLocationId] ASC)
		INCLUDE (dtmDate, dblStockIn, dblStockOut, dblCost);
	GO
