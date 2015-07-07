/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ReceiptStagingTable] AS TABLE
(
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[strReceiptType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL 
	,[intEntityVendorId] INT NOT NULL						-- The Vendor. 
	,[intShipFromId] INT NOT NULL						    -- The Vendor Location. 
	,[intLocationId] INT NOT NULL                           -- Company Location
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NOT NULL						-- The location where the item is stored.
	,[intItemUOMId] INT NOT NULL							-- The UOM used for the item.
	,[strBillOfLadding] nvarchar(50) COLLATE Latin1_General_CI_AS NULL --Bill of Ladding Number
	,[intContractDetailId] INT NULL                         -- Contract
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
	,[intShipViaId] INT NULL                                -- ShipVia
    ,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
  --,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1			-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
    ,[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0			-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
  --,[dblValue] NUMERIC(18, 6) NOT NULL DEFAULT 0 
  --,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0		-- The sales price of selling an item per UOM. Sales price is always in base currency. 
	,[intCurrencyId] INT NULL								-- The currency id used in a tranaction. 
	,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
  --  ,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
  --  ,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
  --  ,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
  --,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
	,[intLotId] INT NULL									-- Place holder field for lot numbers
	,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
	,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
	,[ysnIsCustody] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Custody table. 
    ,[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0         -- Freight Rate 
	,[intSourceId] INT NULL                                 -- Source Id of the Originated Transaction
	

)
