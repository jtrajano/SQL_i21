CREATE TYPE [dbo].[InvoiceEAStagingTable] AS TABLE 
(	 
	 [intId]								INT															--IDENTITY PRIMARY KEY CLUSTERED                        
	,[strTransactionType]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
	,[strType]								NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
	,[strSourceTransaction]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Valid values 
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[strCustomerNumber]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	
	,[strCompanyLocation]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[dtmDate]								DATETIME										NOT NULL	-- Invoice Date
	,[dtmDueDate]							DATETIME										NULL		-- Due Date(If NULL will be computed base on Term) 	
	,[dtmShipDate]							DATETIME										NULL		-- Ship Date
	,[dtmPostDate]							DATETIME										NULL		-- Post Date
	,[strInvoiceOriginId]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL	
	,[strComments]							NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL	
	,[ysnImpactInventory]					BIT												NULL        -- Default(1) Impact Inventory

	--Detail																																															
    ,[strItemNo]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
    ,[strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Line Item Description(If NULL the item's description will be used)
	,[intItemUOMId]							INT												NULL		-- Item UOM Id
	,[intUnitMeasureId]						INT												NULL		-- UOM Id
    ,[dblQtyShipped]						NUMERIC(38, 20)									NULL		-- The quantity to ship
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- (%) The discount to apply to a line item
    ,[dblPrice]								NUMERIC(18, 6)									NULL		-- The line item price
    ,[ysnRefreshPrice]						BIT												NULL		-- Indicate whether to recompute for Price based on the available pricing setup	
    ,[ysnAllowRePrice]						BIT												NULL		-- Indicate whether Reprice is allowed after import
	,[ysnRecomputeTax]						BIT												NULL		-- Indicate whether to recompute for Taxes based on the current Tax setup	
	,[strSubFormula]	    				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	,[ysnConvertToStockUOM]					BIT                                             NULL		-- If true, intItemUOMId will be converted to Stock UOM
)