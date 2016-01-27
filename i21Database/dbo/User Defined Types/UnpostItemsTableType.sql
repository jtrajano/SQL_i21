﻿/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/

CREATE TYPE [dbo].[UnpostItemsTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intItemId] INT NOT NULL -- The PK of the item. 
	,[intItemLocationId] INT NOT NULL -- The location-store where the item is found or served.
	,[intItemUOMId] INT NOT NULL 
	,[intLotId] INT NULL 
	,[intSubLocationId] INT NULL 
	,[intStorageLocationId] INT NULL 
    ,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
	,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 	
	,[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0 
	,[intTransactionTypeId] INT NULL
	,[intInventoryTransactionId] INT NOT NULL 	
)
