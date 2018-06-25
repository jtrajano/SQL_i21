/*
	This is a user-defined table type used in the manual scale ticket distribution for inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ScaleDestinationStagingTable] AS TABLE
(
	[intTicketId] INT NOT NULL								-- scale ticket id
	,[intEntityId] INT NOT NULL								-- Vendor/Customer Id. 
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NULL							-- The location where the item is stored.
	,[intItemUOMId] INT NOT NULL							-- The UOM used for the item.
	,[dtmDate] DATETIME NOT NULL							-- The scale date of the transaction
    ,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
	,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1			-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0			-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
	,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
	,[intContractHeaderId] INT NULL							-- contract detail id. 
	,[intContractDetailId] INT NULL							-- contract detail id. 
	,[intTransactionHeaderId] INT NULL						-- EX. inventory shipment, inventory receipt
	,[intTransactionDetailId] INT NULL						-- EX. inventory shipment item, inventory receipt item
	,[strCostMethod] NVARCHAR(40) NULL						-- costing method
	,[intScaleSetupId] INT NULL								-- scale setup 
	,[dblFreightRate] NUMERIC(38, 20) NOT NULL DEFAULT 0	-- Freight Rate
	,[dblTicketFees] NUMERIC(38, 20) NOT NULL DEFAULT 0		-- Fees Rate
	,[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL -- to group the charges per line item
	,[dblGross] NUMERIC(38, 20) NULL						-- Gross Unit of Scale Ticket
	,[dblTare] NUMERIC(38, 20) NULL							-- Shrink Unit of Scale Ticket
	,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
)