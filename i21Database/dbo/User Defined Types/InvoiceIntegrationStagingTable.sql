﻿/*
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
																											-- "Prepayment"
	,[strType]								NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
																											-- "Standard" - Default
																											-- "Software"
																											-- "Tank Delivery", 
																											-- "Provisional Invoice"
																											-- "Service Charge"
																											-- "Transport Delivery"
																											-- "Meter Billing"
																											-- "Store"
	,[strSourceTransaction]					NVARCHAR(250)									NOT NULL	-- Valid values 
																											-- 0. "Direct"
																											-- 1. "Sales Order"
																											-- 2. "Invoice", "Provisional Invoice", 
																											-- 3. "Transport Load"
																											-- 4. "Inbound Shipment"
																											-- 5. "Inventory Shipment"
																											-- 6. "Card Fueling Transaction"
																											-- 7. "Transfer Storage"
																											-- 8. "Sale OffSite"
																											-- 9. "Settle Storage"
																											-- 10. "Process Grain Storage"
																											-- 11. "Consumption Site"
																											-- 12. "Meter Billing"
																											-- 13. "Load/Shipment Schedules"
																											-- 14. "Credit Card Reconciliation"
	,[intSourceId]							INT												NULL		-- Id of the source transaction
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[intInvoiceId]							INT												NULL		-- Invoice Id(Insert new Invoice if NULL, else Update existing) 
	,[intEntityCustomerId]					INT												NOT NULL	-- Entity Id of Customer (tblARCustomer.intEntityCustomerId)	
	,[intCompanyLocationId]					INT												NOT NULL	-- Company Location Id (tblSMCompanyLocation.intCompanyLocationId)
	,[intCurrencyId]						INT												NOT NULL	-- Currency Id	
	,[intSubCurrencyCents]					INT												NULL		-- Subcurrency Rate
	,[intTermId]							INT												NULL		-- Term Id(If NULL, customer's default will be used)	
	,[intPeriodsToAccrue]					INT												NULL		-- Default(1) Period to Accrue	
	,[dtmDate]								DATETIME										NOT NULL	-- Invoice Date
	,[dtmDueDate]							DATETIME										NULL		-- Due Date(If NULL will be computed base on Term) 	
	,[dtmShipDate]							DATETIME										NULL		-- Ship Date
	,[intEntitySalespersonId]				INT												NULL		-- Entity Id of SalesPerson(If NULL, customer's default will be used)	
	,[intFreightTermId]						INT												NULL		-- Freight Term Id
	,[intShipViaId]							INT												NULL		-- Entity Id of ShipVia
	,[intPaymentMethodId]					INT												NULL		-- NULL
	,[strInvoiceOriginId]					NVARCHAR(8)		COLLATE Latin1_General_CI_AS	NULL		-- Reference to the original/parent record
	,[strPONumber]							NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Purchase Order Number
	,[strBOLNumber]							NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- BOL Number	
	,[strDeliverPickup]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Pickup or Deliver
	,[strComments]							NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL		-- Comments		
	,[intShipToLocationId]					INT												NULL		-- Customer Ship To Location Id(If NULL, customer's default location will be used)
	,[intBillToLocationId]					INT												NULL		-- Customer Bill To Location Id(If NULL, customer's default location will be used)
	,[ysnTemplate]							BIT												NULL		
	,[ysnForgiven]							BIT												NULL		
	,[ysnCalculated]						BIT												NULL		
	,[ysnSplitted]							BIT												NULL	
	,[intPaymentId]							INT												NULL		-- Key Value from tblARPayment (Prepayment/Overpayment) 
	,[intSplitId]							INT												NULL		-- Key Value from tblEMEntitySplit (Customer Split) 
	,[intLoadDistributionHeaderId]			INT												NULL		-- Key Value from tblTRLoadDistributionHeader (Transport Load-New Screen) 
	,[strActualCostId]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Used by Transport Load for Costing
	,[intShipmentId]						INT												NULL		-- Key Value from tblLGShipment (Inbound Shipment) 	
	,[intTransactionId]						INT												NULL		-- Key Value from tblCFTransaction (Card Fueling  Transaction) 	
	,[intMeterReadingId]						INT												NULL		-- Key Value from tblMBMeterReading (Meter Reading)
	,[intOriginalInvoiceId]					INT												NULL		-- Key Value from tblARInvoice (Provisional Invoice/ Duplicate/ Import/ Recurring) 	
	,[intEntityId]							INT												NOT NULL	-- Key Value from tblEMEntity			
	,[ysnResetDetails]						BIT												NULL		-- Indicate whether detail records will be deleted and recreated
	,[ysnRecap]								BIT												NULL		-- If [ysnRecap] = 1 > Recap Invoices
	,[ysnPost]								BIT												NULL		-- If [ysnPost] = 1 > New and Existing unposted Invoices will be posted
																										-- If [ysnPost] = 0 > Existing posted Invoices will be unposted
																										-- If [ysnPost] IS NULL > No action will be made
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
	,[strDocumentNumber]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Document Number (Transaction Number(Provisional Invoice/Inbound Shipment/Inventory Shipment))
    ,[strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Line Item Description(If NULL the item's description will be used)
	,[intOrderUOMId]						INT												NULL		-- The order UOM Id
    ,[dblQtyOrdered]						NUMERIC(18, 6)									NULL		-- The quantity ordered
	,[intItemUOMId]							INT												NULL		-- The UOM Id
    ,[dblQtyShipped]						NUMERIC(18, 6)									NULL		-- The quantity to ship
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- (%) The discount to apply to a line item
	,[dblItemWeight]						NUMERIC(18, 6)									NULL
	,[intItemWeightUOMId]					INT												NULL	
    ,[dblPrice]								NUMERIC(18, 6)									NULL		-- The line item price
    ,[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
    ,[ysnRefreshPrice]						BIT												NULL		-- Indicate whether to recompute for Price based on the available pricing setup	
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
	,[strShipmentNumber]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Inventory Shipment Number (Inventory Shipment)
	,[intSalesOrderDetailId]				INT												NULL		-- Key Value from tblSOSalesOrderDetail (Sales Order)
	,[strSalesOrderNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Sales Order Number (Sales Order)
	,[intContractHeaderId]					INT												NULL		-- Key Value from tblCTContractHeader(If NULL, it will be populated using [intContractDetailId])
	,[intContractDetailId]					INT												NULL		-- Key Value from tblCTContractDetail (Sales Contract)
	,[intShipmentPurchaseSalesContractId]	INT												NULL		-- Key Value from tblLGShipmentPurchaseSalesContract (Inbound Shipment)
	,[dblShipmentGrossWt]					NUMERIC(18, 6)									NULL
	,[dblShipmentTareWt]					NUMERIC(18, 6)									NULL
	,[dblShipmentNetWt]						NUMERIC(18, 6)									NULL
	,[intTicketId]							INT												NULL		-- Key Value from tblSCTicket (Scale Ticket)
	,[intTicketHoursWorkedId]				INT												NULL		-- Key Value from tblHDTicketHoursWorked (Help Desk)
	,[intCustomerStorageId]					INT												NULL		-- Key Value from tblGRCustomerStorage (Grain)
	,[intSiteDetailId]						INT												NULL		-- Key Value from tblCCSiteDetail (Credit Card Reconciliation)
	,[intLoadDetailId]						INT												NULL		-- Key Value from tblLGLoadDetail (Load/Shipment Schedules)
	,[intOriginalInvoiceDetailId]			INT												NULL		-- Key Value from tblARInvoiceDetail (Provisional Invoice)
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
	,[ysnSubCurrency]						BIT												NULL		-- Indicates whether the line item price is on sub currency

)
