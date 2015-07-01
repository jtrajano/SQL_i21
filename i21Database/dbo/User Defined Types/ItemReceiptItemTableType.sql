/*
	This is a user-defined table type for the inventory receipt. It is used as a common variable for the other modules to integrate with inventory receipt. 
*/
CREATE TYPE [dbo].[ItemReceiptItemTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	
	-- Header
    ,[intInventoryReceiptId] INT NOT NULL										-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	,[strInventoryReceiptId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
	,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intSourceType] INT NOT NULL DEFAULT ((0))
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction. Required. 
	,[intCurrencyId] INT NULL								-- The currency id used in a tranaction. 
	,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.

	-- Detail 
	,[intInventoryReceiptDetailId] INT NULL					-- Link id to the receipt detail. 	
	,[intItemId] INT NOT NULL								-- The item id. Required. 
	,[intLotId] INT NULL									-- Lot id of an item. Optional.
	,[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Lot id of an item. Optional.
	,[intLocationId] INT NOT NULL							-- The company location where the item is stored. Added for convenience. Required. 
	,[intItemLocationId] INT NOT NULL						-- The item location where the item is stored. Required. 
	,[intSubLocationId] INT NULL							-- Sub Location. Optional 
	,[intStorageLocationId] INT NULL						-- Storage Location. Optional 
	,[intItemUOMId] INT NOT NULL							-- UOM of an item. Required. 
	,[intWeightUOMId] INT NULL								-- If item is received by weights, then this field has a value. Optional 	
    ,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0				-- The quantity received in terms of intItemUOMId. Default to zero. Required.
	,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1			-- The unit qty in terms intItemUOMId. Required.
	,[dblNetWeight] NUMERIC(18, 6) NULL						-- The net weight of an item. Optional.
    ,[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0			-- The cost of the item received in terms of intItemUOMId. 
	,[intContainerId] INT NULL								-- If item has a container id or not. 
	,[intOwnershipType] INT NOT NULL DEFAULT ((1))			-- Ownership type of the item. Required. Default to 1 (Own)
	,[intOrderId] INT NULL									-- Link id to PO or Contract. Ex: if Receipt type is "Purchase Order", this field links to the PO table. Optional.
	,[intSourceId] INT NULL									-- Link id to Scale. Optional.
	,[intLineNo] INT NOT NULL DEFAULT ((1))					-- Link id to the detail id of the PO detail or Contract detail. Default to zero. Optional. 
)
