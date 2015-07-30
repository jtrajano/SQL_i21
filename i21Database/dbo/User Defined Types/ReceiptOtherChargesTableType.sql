/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ReceiptOtherChargesTableType] AS TABLE
(
	
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED

	-- Linking fields to the Header 
	,[intEntityVendorId] INT NOT NULL						-- The Vendor. 
	,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL --Bill of Ladding Number
	,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
	,[intLocationId] INT NOT NULL                           -- Company Location	
	,[intShipViaId] INT NULL                                -- ShipVia
	,[intShipFromId] INT NOT NULL						    -- The Vendor Location. 
	,[intCurrencyId] INT NULL								-- The currency id used in a tranaction. 

	-- Other Charges Fields
	,[intChargeId] INT NOT NULL 
    ,[ysnInventoryCost] BIT NULL DEFAULT ((0)) 
    ,[strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit')
    ,[dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)) 
    ,[intCostUOMId] INT NULL 
    ,[intOtherChargeEntityVendorId] INT NULL 
    ,[dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)) 
    ,[strAllocateCostBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('') 
    ,[strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Vendor') 
)
