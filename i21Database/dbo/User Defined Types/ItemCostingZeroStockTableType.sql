/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ItemCostingZeroStockTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NULL							-- The location where the item is stored.
)
