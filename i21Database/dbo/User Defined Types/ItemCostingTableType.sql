/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/

CREATE TYPE [dbo].[ItemCostingTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
	[intItemId] INT NOT NULL, -- The PK of the item. 
	[intLocationId] INT NOT NULL, -- The location-store where the item is found or served.
	[dtmDate] DATETIME NOT NULL, -- The date of the transaction
    [dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, -- The unit quantity of an item in relation to its UOM (ex: 10 boxes). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
	[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1, -- The quantity of an item per UOM (ex. 1 box can contain 100 individual pieces of an item)
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, -- The cost of purchasing an item. Cost is always in base currency. 
	[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, -- The sales price of selling an item. Sales price is always in base currency. 
	[intCurrencyId] INT NULL, -- The currency id. 
	[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL, -- The exchange rate used in the transaction. Used to convert the cost or sales price to the foreign currency value.
    [intTransactionId] INT NOT NULL, -- The id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, -- The string id of the source transaction. 
	[intTransactionTypeId] INT NOT NULL, -- The transaction type. Source table for the types are found in tblICInventoryTransactionType
	[intLotId] INT NULL -- Place holder field for lot numbers
)
