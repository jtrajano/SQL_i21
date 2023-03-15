/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ItemInTransitValueOnlyTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NULL							-- The location where the item is stored.	
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
	,[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0 	
    ,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
	,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
	,[intLotId] INT NULL									-- Place holder field for lot numbers
    ,[intSourceTransactionId] INT NULL						-- The int id of the Inventory Shipment
	,[strSourceTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- The string id of the Inventory Shipment
    ,[intSourceTransactionDetailId] INT NULL				-- The int id of the Inventory Shipment detail. 
	,[intFobPointId] TINYINT NULL 
	,[intInTransitSourceLocationId] INT NULL 
	,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
	,[intForexRateTypeId] INT NULL
	,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1 
	,[intSourceEntityId] INT NULL
	,[strSourceType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strSourceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strBOLNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[intTicketId] INT NULL 
	,[intOtherChargeItemId] INT NULL						-- This is the Other Charge. 
)
