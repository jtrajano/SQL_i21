/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ItemReservationTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
	[intItemId] INT NOT NULL, -- The item. 
	[intItemLocationId] INT NOT NULL, -- The location where the item is stored.
	[intItemUOMId] INT NOT NULL, -- The UOM used for the item.
	[intLotId] INT NULL, -- Place holder field for lot numbers
    [dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, -- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
    [intTransactionId] INT NOT NULL, -- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, -- The string id of the source transaction. 
	[intTransactionTypeId] INT NOT NULL -- The transaction type. Source table for the types are found in tblICInventoryTransactionType	
)
