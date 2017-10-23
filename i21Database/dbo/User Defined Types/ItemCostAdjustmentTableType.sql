﻿/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ItemCostAdjustmentTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NULL							-- The location where the item is stored.
	,[intItemUOMId] INT NULL								-- The UOM used for the item.
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
	,[dblQty] NUMERIC(38, 20) NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
	,[dblUOMQty] NUMERIC(38, 20) NULL DEFAULT 1				-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
	,[intCostUOMId] INT NULL								-- The uom related to the cost of the item. Ex: A box can be priced as $4 per LB. 
	,[dblVoucherCost] NUMERIC(38, 20) NULL DEFAULT 0		-- Cost of the item. It must be related to the cost uom. Ex: $4/LB. 
	,[dblNewValue] NUMERIC(38, 20) NULL
	,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
	--,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
	,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
	,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
	,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
	,[intLotId] INT NULL									-- Place holder field for lot numbers
	,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
	,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
	,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
	,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- If there is a value, this means the item is used in Actual Costing. 
	,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
	,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
	,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
	,[intRelatedInventoryTransactionId] INT NULL 
	,[intFobPointId] TINYINT NULL
	,[intInTransitSourceLocationId] INT NULL 
)
