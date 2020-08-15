/*
	This is a user-defined table type for the inventory receipt. It is used as a common variable for the other modules to integrate with inventory receipt. 
*/
CREATE TYPE [dbo].[ShipmentItemTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	
	-- Header
    ,[intShipmentId] INT NOT NULL										-- The integer id of the source transaction. Required.
	,[strShipmentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. Required.
	,[intOrderType] INT NOT NULL							-- The sales order type. Required.
	,[intSourceType] INT NOT NULL DEFAULT ((0))				-- The source type id. Required.
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction. Required. 
	,[intCurrencyId] INT NULL								-- The currency id used in the transaction. 
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
	,[intEntityCustomerId] INT NOT NULL						-- It is usually the customer entity id. 

	-- Detail 
	,[intInventoryShipmentItemId] INT NULL					-- Link id to the shipment detail. 	
	,[intItemId] INT NOT NULL								-- The item id. Required. 
	,[intLotId] INT NULL									-- Lot id of an item. Optional.
	,[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Lot id of an item. Optional.
	,[intLocationId] INT NOT NULL							-- The company location where the item is stored. Added for convenience. Required. 
	,[intItemLocationId] INT NOT NULL						-- The item location where the item is stored. Required. 
	,[intSubLocationId] INT NULL							-- Sub Location. Optional 
	,[intStorageLocationId] INT NULL						-- Storage Location. Optional 
	,[intItemUOMId] INT NOT NULL							-- UOM of an item. Required. 
	,[intWeightUOMId] INT NULL								-- If item is received by weights, then this field has a value. Optional 	
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0			-- The quantity shipped in terms of intItemUOMId. Default to zero. Required.
	,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1			-- The unit qty in terms intItemUOMId. Required.
	,[dblNetWeight] NUMERIC(38, 20) NULL					-- The net weight of an item. Optional.
	,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0		-- The sales price of the item shipped in terms of intItemUOMId. 
	,[intDockDoorId] INT NULL								-- If item has a dock door id or not. 
	,[intOwnershipType] INT NOT NULL DEFAULT ((1))			-- Ownership type of the item. Required. Default to 1 (Own)
	,[intOrderId] INT NULL									-- Link id to PO or Contract. Ex: if Receipt type is "Purchase Order", this field links to the PO table. Optional.
	,[intSourceId] INT NULL									-- Link id to Scale. Optional.
	,[intLineNo] INT NOT NULL DEFAULT ((1))					-- Link id to the detail id of the PO detail or Contract detail. Default to zero. Optional. 
	,[intStorageScheduleTypeId] INT NULL					-- Storage Schedule Id from Grain. 
	,[ysnLoad] BIT NULL DEFAULT((0))						-- Flag that determines if Load Contract
	,[intLoadShipped] INT NULL								-- Load Shipped Qty. For Load Contracts
	,[intItemContractHeaderId] INT NULL								
	,[intItemContractDetailId] INT NULL								

)