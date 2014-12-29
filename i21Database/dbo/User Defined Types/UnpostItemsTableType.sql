/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/

CREATE TYPE [dbo].[UnpostItemsTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intItemId] INT NOT NULL -- The PK of the item. 
	,[intLocationId] INT NOT NULL -- The location-store where the item is found or served.
    ,[dblTotalQty] NUMERIC(18, 6) NOT NULL DEFAULT 0 
)
