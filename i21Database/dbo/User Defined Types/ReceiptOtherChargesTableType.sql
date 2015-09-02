/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ReceiptOtherChargesTableType] AS TABLE
(
	
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED

	-- Linking fields to the Header 
	,[intEntityVendorId] INT NOT NULL														-- The Vendor. 
	,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL						-- Bill of Ladding Number
	,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL						-- Receipt type. It can be a 'Purchase Contract', 'Purchase Order', 'Transfer Order', or 'Direct'. 
	,[intLocationId] INT NOT NULL															-- Company Location	
	,[intShipViaId] INT NULL																-- ShipVia
	,[intShipFromId] INT NOT NULL															-- The Vendor Location. 
	,[intCurrencyId] INT NULL																-- The currency id used in a tranaction. 	

	-- Other Charges Fields		
	,[intChargeId] INT NOT NULL																-- The item id of Other Charge type. 
    ,[ysnInventoryCost] BIT NULL DEFAULT ((0))												-- True if allocated cost is included in the stock cost. False if not. 
    ,[strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit')	-- Additional charge can be calculated by 'Per Unit', 'Percentage', or 'Amount'. 
    ,[dblRate] NUMERIC(18, 6) NULL DEFAULT ((0))											-- Used if Cost method used is 'Per Unit' or 'Percentage'. This indicates the dollar amount per UOM or percentage per UOM. 
    ,[intCostUOMId] INT NULL																-- Used with Cost Method 'Per Unit'. It is the dollar amount per UOM. 
    ,[intOtherChargeEntityVendorId] INT NULL												-- Used if Other Charge is a surcharge. It works with 'On Cost Type'. 'On Cost Type' is configured in the item setup. 
    ,[dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0))											-- Used if Cost method is 'Amount'. The additional charge applied per line item, regardless of Qty or Cost. 
    ,[strAllocateCostBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Unit')	-- Determines how the computed other charges are allocated per item. It can be allocated by 'Unit', 'Weight', or 'Cost'. 
    --,[strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Vendor')	-- Determines if the computed charge is billed by the inventory receipt vendor, a third party vendor, or by no one. 
	,[ysnAccrue] BIT NULL 
	,[ysnPrice] BIT NULL 
	,[intContractDetailId] INT NULL															-- Contract
)
