/*
	This is a user-defined table type used in creating/updating invoices for integration. 
*/
CREATE TYPE [dbo].[InvoiceIntegrationStagingTable] AS TABLE
(	 
	 [intId]								INT				IDENTITY PRIMARY KEY CLUSTERED                        
	 --Header
	,[strTransactionType]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
																											-- "Invoice" - Default
																											-- "Credit Memo"
																											-- "Debit Memo", 
																											-- "Cash"
																											-- "Cash Refund"
																											-- "Overpayment"
																											-- "Customer Prepayment"
	,[strType]								NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
																											-- "Standard" - Default
																											-- "Software"
																											-- "Tank Delivery", 
																											-- "Provisional"
																											-- "Service Charge"
																											-- "Transport Delivery"
																											-- "Meter Billing"
																											-- "Store"
																											-- "Card Fueling"
																											-- "POS"
																											-- "Store Checkout"
	,[strSourceTransaction]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Valid values 
																											-- 0. "Direct"
																											-- 1. "Sales Order"
																											-- 2. "Invoice", "Provisional", 
																											-- 3. "Transport Load"
																											-- 4. "Inbound Shipment"
																											-- 5. "Inventory Shipment"
																											-- 6. "Card Fueling Transaction" / "CF Tran"
																											-- 7. "Transfer Storage"
																											-- 8. "Sale OffSite"
																											-- 9. "Settle Storage"
																											-- 10. "Process Grain Storage"
																											-- 11. "Consumption Site"
																											-- 12. "Meter Billing"
																											-- 13. "Load/Shipment Schedules"
																											-- 14. "Credit Card Reconciliation"
																											-- 15. "Sales Contract"
																											-- 16. "Load Schedule"
																											-- 17. "CF Invoice"
																											-- 18. "Ticket Management"
	,[intSourceId]							INT												NULL		-- Id of the source transaction
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[intInvoiceId]							INT												NULL		-- Invoice Id(Insert new Invoice if NULL, else Update existing) 
	,[intEntityCustomerId]					INT												NOT NULL	-- Entity Id of Customer (tblARCustomer.intEntityCustomerId)	
	,[intCompanyLocationId]					INT												NOT NULL	-- Company Location Id (tblSMCompanyLocation.intCompanyLocationId)
	,[intAccountId]							INT												NULL		-- Key Value from tblGLAccount
	,[intCurrencyId]						INT												NULL		-- Currency Id (tblSMCurrency.intCurrencyID)
	,[intTermId]							INT												NULL		-- Term Id(If NULL, customer's default will be used)	
	,[intPeriodsToAccrue]					INT												NULL		-- Default(1) Period to Accrue	
	,[dtmDate]								DATETIME										NOT NULL	-- Invoice Date
	,[dtmDueDate]							DATETIME										NULL		-- Due Date(If NULL will be computed base on Term) 	
	,[dtmShipDate]							DATETIME										NULL		-- Ship Date
	,[dtmCalculated]						DATETIME										NULL		-- Calculated Date for Service Charge
	,[dtmPostDate]							DATETIME										NULL		-- Post Date
	,[intEntitySalespersonId]				INT												NULL		-- Entity Id of SalesPerson(If NULL, customer's default will be used)	
	,[intFreightTermId]						INT												NULL		-- Freight Term Id
	,[intShipViaId]							INT												NULL		-- Entity Id of ShipVia
	,[intPaymentMethodId]					INT												NULL		-- NULL
	,[strInvoiceOriginId]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Reference to the original/parent record
	,[ysnUseOriginIdAsInvoiceNumber]		BIT												NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
	,[strMobileBillingShiftNo]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Mobile Billing Shift Number
	,[strPONumber]							NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Purchase Order Number
	,[strBOLNumber]							NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- BOL Number	
	,[strPaymentInfo]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Check Number
	,[strComments]							NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL		-- Comments
	,[strFooterComments]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL		-- Footer Comments
	,[intDocumentMaintenanceId]				INT												NULL		-- Combobox Comment in Invoice Header
	,[intShipToLocationId]					INT												NULL		-- Customer Ship To Location Id(If NULL, customer's default location will be used)
	,[intBillToLocationId]					INT												NULL		-- Customer Bill To Location Id(If NULL, customer's default location will be used)
	,[ysnTemplate]							BIT												NULL		
	,[ysnForgiven]							BIT												NULL		
	,[ysnCalculated]						BIT												NULL		
	,[ysnSplitted]							BIT												NULL	
	,[ysnImpactInventory]					BIT												NULL        -- Default(1) Impact Inventory
	,[intPaymentId]							INT												NULL		-- Key Value from tblARPayment (Customer Prepayment/Overpayment) 
	,[intSplitId]							INT												NULL		-- Key Value from tblEMEntitySplit (Customer Split) 
	,[intLoadDistributionHeaderId]			INT												NULL		-- Key Value from tblTRLoadDistributionHeader (Transport Load-New Screen) 
	,[strActualCostId]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Used by Transport Load for Costing
	,[intShipmentId]						INT												NULL		-- Key Value from tblLGShipment (Inbound Shipment) 	
	,[intTransactionId]						INT												NULL		-- Key Value from tblCFTransaction (Card Fueling  Transaction) 	
	,[intMeterReadingId]					INT												NULL		-- Key Value from tblMBMeterReading (Meter Reading)
	,[intContractHeaderId]					INT												NULL		-- Key Value from tblCTContractHeader (Sales Contract)
	,[intLoadId]							INT												NULL		-- Key Value from tblLGLoad (Load Schedule)
	,[intOriginalInvoiceId]					INT												NULL		-- Key Value from tblARInvoice (Provisional/ Duplicate/ Import/ Recurring) 	
	,[intEntityId]							INT												NOT NULL	-- Key Value from tblEMEntity			
	,[intTruckDriverId]						INT												NULL		-- Key Value([intEntitySalespersonId]) from [tblARSalesperson] : strType = 'Driver'	
	,[intTruckDriverReferenceId]			INT												NULL		-- Key Value  from [tblSCTruckDriverReference]
	,[ysnResetDetails]						BIT												NULL		-- Indicate whether detail records will be deleted and recreated
	,[ysnRecap]								BIT												NULL		-- If [ysnRecap] = 1 > Recap Invoices
	,[ysnPost]								BIT												NULL		-- If [ysnPost] = 1 > New and Existing unposted Invoices will be posted
																										-- If [ysnPost] = 0 > Existing posted Invoices will be unposted
																										-- If [ysnPost] IS NULL > No action will be made
	,[ysnUpdateAvailableDiscount]			BIT												NULL		-- If [ysnUpdateAvailableDiscount] = 1 > Updates existing Posted/Unposted Invoice Available Discount Amount
	,[ysnImportedFromOrigin]				BIT												NULL
	,[ysnImportedAsPosted]					BIT												NULL
	,[ysnFromProvisional]					BIT												NULL
	,[ysnServiceChargeCredit]				BIT												NULL		-- For Credit Memo from Forgiven service charge

	--Detail																																															
	,[intInvoiceDetailId]					INT												NULL		-- Invoice Detail Id(Insert new Invoice if NULL, else Update existing)
    ,[intItemId]							INT												NULL		-- The Item Id 
	,[intPrepayTypeId]						INT												NULL		-- Valid values(prepaid) 
																											-- 0. ""
																											-- 1. "Standard"
																											-- 2. "Unit"
																											-- 3. "Percentage"	
	,[dblPrepayRate]						NUMERIC(18, 6)									NULL		-- Prepay Rate
    ,[ysnInventory]							BIT												NULL		-- Indicate whether the line item is a inventory item or a miscellaneous item
	,[strDocumentNumber]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Document Number (Transaction Number(Provisional/Inbound Shipment/Inventory Shipment))
    ,[strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Line Item Description(If NULL the item's description will be used)
	,[intOrderUOMId]						INT												NULL		-- The order UOM Id
    ,[dblQtyOrdered]						NUMERIC(38, 20)									NULL		-- The quantity ordered
	,[intItemUOMId]							INT												NULL		-- The UOM Id
	,[intPriceUOMId]						INT												NULL		-- The UOM Id From Contract Sequence/Inventory Shipment
	,[dblContractPriceUOMQty]				NUMERIC(18, 6)									NULL		-- The Contract Quantity based on Price UOM
    ,[dblQtyShipped]						NUMERIC(38, 20)									NULL		-- The quantity to ship
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- (%) The discount to apply to a line item
	,[dblItemTermDiscount]					NUMERIC(18, 6)									NULL		-- The Term discount to apply to a line item upon payment
	,[strItemTermDiscountBy]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values(Term Discount Calculation Method) 
																											-- 1. "Amount"
																											-- 2. "Percentage"	
	,[dblItemWeight]						NUMERIC(38, 20)									NULL
	,[intItemWeightUOMId]					INT												NULL	
    ,[dblPrice]								NUMERIC(18, 6)									NULL		-- The line item price
	,[dblUnitPrice]							NUMERIC(18, 6)									NULL		-- The line item unit price
    ,[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[strVFDDocumentNumber]					NVARCHAR(100) 	COLLATE Latin1_General_CI_AS	NULL
	,[strBOLNumberDetail]					NVARCHAR(50) 	COLLATE Latin1_General_CI_AS	NULL
    ,[ysnRefreshPrice]						BIT												NULL		-- Indicate whether to recompute for Price based on the available pricing setup	
    ,[ysnAllowRePrice]						BIT												NULL		-- Indicate whether Reprice is allowed after import
	,[strMaintenanceType]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    ,[strFrequency]							NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    ,[dtmMaintenanceDate]					DATETIME										NULL
    ,[dblMaintenanceAmount]					NUMERIC(18, 6)									NULL
    ,[dblLicenseAmount]						NUMERIC(18, 6)									NULL
	,[intTaxGroupId]						INT												NULL		-- Key Value from tblSMTaxGroup (Taxes)
	,[intStorageLocationId]					INT												NULL		-- Key Value from tblICStorageLocation (Storage Location)
	,[intCompanyLocationSubLocationId]		INT												NULL		-- Key Value from tblSMCompanyLocationSubLocation (Sub Location)
	,[ysnRecomputeTax]						BIT												NULL		-- Indicate whether to recompute for Taxes based on the current Tax setup	
	,[intSCInvoiceId]						INT												NULL		-- Service Charge Invoice Id
	,[strSCInvoiceNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Service Charge Invoice Number	
	,[intSCBudgetId]						INT												NULL		-- Service Charge Budget Id
	,[strSCBudgetDescription]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Service Charge Budget Description	
	,[intInventoryShipmentItemId]			INT												NULL		-- Key Value from tblICInventoryShipmentItem (Inventory Shipment)
	,[intInventoryShipmentChargeId]			INT												NULL		-- Key Value from tblICInventoryShipmentCharge (Inventory Shipment)
	,[strShipmentNumber]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Inventory Shipment Number (Inventory Shipment)
	,[strSubFormula]	    				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	,[intRecipeItemId]						INT												NULL		-- Key Value from tblMFRecipeItem (Manufacturing Cost)
	,[intRecipeId]							INT												NULL
	,[intSubLocationId]						INT												NULL
	,[intCostTypeId]						INT												NULL
	,[intMarginById]						INT												NULL
	,[intCommentTypeId]						INT												NULL
	,[dblMargin]							NUMERIC(18,6)									NULL
	,[dblRecipeQuantity]					NUMERIC(18,6)									NULL
	,[intSalesOrderDetailId]				INT												NULL		-- Key Value from tblSOSalesOrderDetail (Sales Order)
	,[strSalesOrderNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Sales Order Number (Sales Order)
	,[intContractDetailId]					INT												NULL		-- Key Value from tblCTContractDetail (Sales Contract)
	,[intShipmentPurchaseSalesContractId]	INT												NULL		-- Key Value from tblLGShipmentPurchaseSalesContract (Inbound Shipment)
	,[dblShipmentGrossWt]					NUMERIC(38, 20)									NULL
	,[dblShipmentTareWt]					NUMERIC(38, 20)									NULL
	,[dblShipmentNetWt]						NUMERIC(38, 20)									NULL
	,[intTicketId]							INT												NULL		-- Key Value from tblSCTicket (Scale Ticket)
	,[intTicketHoursWorkedId]				INT												NULL		-- Key Value from tblHDTicketHoursWorked (Help Desk)
	,[intCustomerStorageId]					INT												NULL		-- Key Value from tblGRCustomerStorage (Grain)
	,[intSiteDetailId]						INT												NULL		-- Key Value from tblCCSiteDetail (Credit Card Reconciliation)
	,[intLoadDetailId]						INT												NULL		-- Key Value from tblLGLoadDetail (Load/Shipment Schedules)
	,[intLotId]								INT												NULL		-- Key Value from tblICLot (Load/Shipment Schedules)
	,[intOriginalInvoiceDetailId]			INT												NULL		-- Key Value from tblARInvoiceDetail (Provisional)
	,[intSiteId]							INT												NULL		-- Key Value from tblTMSite (Tank MAnagement)
	,[strBillingBy]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- tblTMSite.[strBillingBy] (Tank MAnagement)
	,[dblPercentFull]						NUMERIC(18, 6)									NULL
	,[dblNewMeterReading]					NUMERIC(18, 6)									NULL		
	,[dblPreviousMeterReading]				NUMERIC(18, 6)									NULL		-- tblTMSite.[dblLastMeterReading] (Tank MAnagement)
	,[dblConversionFactor]					NUMERIC(18, 8)									NULL		-- tblTMMeterType.[dblConversionFactor] (Tank MAnagement)
	,[intPerformerId]						INT												NULL		    		
	,[ysnLeaseBilling]						BIT												NULL
	,[ysnVirtualMeterReading]				BIT												NULL
	,[ysnClearDetailTaxes]					BIT												NULL		-- Indicate whether to clear tax details before inserting tax details from LineItemTaxDetailStagingTable
	,[intTempDetailIdForTaxes]				INT												NULL		-- Temporary Id for linking line item detail taxes (LineItemTaxDetailStagingTable) which are also fro processing
	,[intCurrencyExchangeRateTypeId]		INT												NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
	,[intCurrencyExchangeRateId]			INT												NULL
	,[dblCurrencyExchangeRate]				NUMERIC(18, 6)									NULL		-- Forex Rate
	,[intSubCurrencyId]						INT												NULL		-- SubCurrency Id (tblSMCurrency.intCurrencyID) == tblARInvoice.[intCurrencyId] || tblSMCurrency.[intCurrencyID] WHERE tblSMCurrency.[intMainCurrencyId] = tblARInvoice.[intCurrencyId]
	,[dblSubCurrencyRate]					NUMERIC(18, 6)									NULL		-- SubCurrency Rate
	,[ysnBlended]							BIT												NULL		-- Indicates if a Finished Good item is already blended
	,[strImportFormat]						NVARCHAR(50)									NULL		-- Format Type used for importing invoices Carquest\Tank\Standard
	,[dblCOGSAmount]						NUMERIC(18, 6)									NULL		-- COGS Amount used for an item
    ,[intConversionAccountId]               INT												NULL        -- Key Value from tblGLAccount with category = 'General' and type = 'Asset'
	,[intSalesAccountId]					INT												NULL        -- Key Value from tblGLAccount with category = 'General' and type = 'Sales'

	,[intStorageScheduleTypeId]				INT												NULL		-- Indicates the Grain Bank of an Item
	,[intDestinationGradeId]				INT												NULL		-- Key Value from tblCTWeightGrade (Grain Destination - Grade)
	,[intDestinationWeightId]				INT												NULL		-- Key Value from tblCTWeightGrade (Grain Destination - Weight)

    ,[strAddonDetailKey]                    NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[ysnAddonParent]                       BIT                                             NULL
    ,[dblAddOnQuantity]                     NUMERIC(38, 20)                                  NULL
)
