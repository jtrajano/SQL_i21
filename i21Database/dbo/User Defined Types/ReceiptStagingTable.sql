/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ReceiptStagingTable] AS TABLE
(
	
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED

	 -- Header
	,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
	,[intEntityVendorId] INT NULL							-- The Vendor. 
	,[intShipFromId] INT NOT NULL						    -- The Vendor Location. 
	,[intLocationId] INT NOT NULL                           -- Company Location	
	,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL --Bill of Ladding Number
	,[intContractHeaderId] INT NULL							-- Contract Header Id
	,[intContractDetailId] INT NULL                         -- Contract Detail Id
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
	,[intShipViaId] INT NULL                                -- ShipVia
	,[intCurrencyId] INT NULL								-- The currency id used in a tranaction. 
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
	,[intSourceId] INT NULL                                 -- Source Id of the Originated Transaction
	,[intFreightTermId] INT NULL
	,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Direct Cost Id
	,[strVendorRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Vendor Reference No. 
	,[intTaxGroupId] INT NULL								-- Overriding Tax Group Id, if you want to override the Tax Group that will be used from the Ship From Location setup.
	,[intSubCurrencyCents] INT NULL DEFAULT 1
	,[intTransferorId] INT NULL 

	-- Detail 
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NOT NULL						-- The location where the item is stored.
	,[intItemUOMId] INT NOT NULL							-- The UOM used for the item.	
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0			-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
	,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
	,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
	,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
	,[intGrossNetUOMId] INT NULL							-- The Gross/Net UOM used for the item.
	,[dblGross] NUMERIC(38, 20) NULL 
	,[dblNet] NUMERIC(38, 20) NULL 
	,[dblSurcharge] DECIMAL(18, 6) NULL DEFAULT 0			-- Fuel Surcharge	
	,[ysnFreightInPrice] BIT NULL DEFAULT 0					-- Freight should be included In Price
	,[intCostUOMId] INT NULL								-- Cost UOM
	,[intDiscountSchedule] INT NULL							-- Discount Schedule field. (Quality module).
	,[ysnSubCurrency] BIT NULL 
	,[intPaymentOn] INT NULL								-- Reserved for PaymentOn option
	,[intForexRateTypeId] INT NULL							-- Currency Forex Rate Type Id
	,[dblForexRate] NUMERIC(18, 6) NULL						-- Forex Rate (Exchange Rate)
	,[intContainerId] INT NULL								-- Container id. Used by LG Inbound Shipment. 

	-- Detail Lot
	,[intLotId] INT NULL									-- Place holder field for lot numbers	
	,[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0         -- Freight Rate 
	,[intSourceType] INT NULL                               -- FOR TRANSPORTS ITS 3

	-- Integration Field
	,[intInventoryReceiptId] INT NULL						-- Existing id of an Inventory Receipt. 
	,[strSourceId] NVARCHAR(50) NULL						-- String Id of the source transaction. 
	,[strSourceScreenName] NVARCHAR(50) NULL				-- Name of the screen name where the transaction is coming from.
)
