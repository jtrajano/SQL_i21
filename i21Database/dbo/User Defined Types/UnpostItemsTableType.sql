/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/

CREATE TYPE [dbo].[UnpostItemsTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intItemId] INT NOT NULL -- The PK of the item. 
	,[intItemLocationId] INT NOT NULL -- The location-store where the item is found or served.
    ,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
	,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
	,[intItemUOMId] INT NOT NULL 
)
