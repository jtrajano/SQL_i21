/*
	This is a user-defined table type used in the Invoice Creation stored procedures. 
*/
CREATE TYPE [dbo].[InvoiceStagingTable] AS TABLE
(
	 [intId]				INT  
	,[intInvoiceId]			INT				NULL									-- The id of the Invoice, if it exists. 
	,[intEntityCustomerId]	INT				NOT NULL								-- The Customer. 	
	,[intLocationId]		INT				NOT NULL								-- Company Location
	,[intItemId]			INT				NOT NULL								-- The item. 
	,[intItemUOMId]			INT				NOT NULL								-- The UOM used for the item.
	,[dtmDate]				DATETIME		NOT NULL								-- The date of the transaction
	,[intContractDetailId]	INT				NULL									-- Contract
	,[intShipViaId]			INT				NULL									-- ShipVia
	,[intSalesPersonId]		INT				NULL									-- SalesPerson
    ,[dblQty]				NUMERIC(18,6)	NOT NULL DEFAULT 0						-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
    ,[dblPrice]				NUMERIC(18,6)	NOT NULL DEFAULT 0						-- The Price of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
	,[intCurrencyId]		INT				NULL									-- The currency id used in a tranaction. 
	,[dblExchangeRate]		DECIMAL(38,20)	NOT NULL DEFAULT 1						-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
    ,[dblFreightRate]		DECIMAL(18,6)	NULL DEFAULT 0							-- Freight Rate 
	,[strComments]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL		-- Comments
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS NOT NULL	-- Source Transaction Number of the Originated Transaction
    ,[intSourceId]			INT				NOT NULL					            -- Key Value of the source Id
    ,[strPurchaseOrder]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS  NULL		-- Purchase Order Number
	,[strDeliverPickup]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS  NULL		-- Pickup or Deliver
	,[dblSurcharge]			DECIMAL(18,6)	NULL DEFAULT 0							-- Fuel Surcharge
	,[ysnFreightInPrice]	BIT				NULL DEFAULT 0							-- Freight in price
	,[intTaxGroupId]		INT				NULL									-- Tax Group
	,[strActualCostId]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	,[intShipToLocationId]	INT				NULL									-- SalesPerson	
	,[strBOLNumber]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
    ,[strSourceScreenName]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL       -- Name of the screen name where the transaction is coming from
)