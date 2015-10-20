/*
	This is a user-defined table type used in creating/updating invoices for integration. 
*/
CREATE TYPE [dbo].[InvoiceIntegrationStagingTable] AS TABLE
(
	 [intId]								INT				IDENTITY PRIMARY KEY CLUSTERED                        
	 --Header
	,[strSourceTransaction]					NVARCHAR(250)									NOT NULL	-- Valid values "Invoice", "Transport Load" and "Inbound Shipment"
	,[intSourceId]							INT												NOT NULL	-- Id of the source transaction
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[intInvoiceId]							INT												NULL		-- Invoice Id(Insert new Invoice if NULL, else Update existing) 
	,[intEntityCustomerId]					INT												NOT NULL	-- Entity Id of Customer	
	,[intCompanyLocationId]					INT												NOT NULL	-- Company Location Id
	,[intCurrencyId]						INT												NOT NULL	-- Currency Id	
	,[intTermId]							INT												NULL		-- Term Id(If NULL, customer's default will be used)	
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
	,[intSplitId]							INT												NULL		-- Key Value from tblEntitySplit (Customer Split) 
	,[intDistributionHeaderId]				INT												NULL		-- Key Value from tblTRDistributionHeader (Transport Load) 
	,[strActualCostId]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Used by Transport Load for Costing
	,[intShipmentId]						INT												NULL		-- Key Value from tblLGShipment (Inbound Shipment) 	
	,[intEntityId]							INT												NOT NULL	-- Key Value from tblEntity			
	,[ysnResetDetails]						BIT												NULL		-- Indicate whether detail records will be deleted and recreated
	,[ysnPost]								BIT												NULL		-- If [ysnPost] = 1 > New and Existing unposted Invoices will be posted
																										-- If [ysnPost] = 0 > Existing posted Invoices will be unposted
																										-- If [ysnPost] IS NULL > No action will be made
	--Detail																																															
	,[intInvoiceDetailId]					INT												NULL		-- Invoice Detail Id(Insert new Invoice if NULL, else Update existing)
    ,[intItemId]							INT												NULL		-- The Item Id 
    ,[ysnInventory]							BIT												NULL		-- Indicate whether the line item is a inventory item or a miscellaneous item
    ,[strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Line Item Description(If NULL the item's description will be used)
	,[intItemUOMId]							INT												NULL		-- The UOM Id
    ,[dblQtyOrdered]						NUMERIC(18, 6)									NULL		-- The quantity ordered
    ,[dblQtyShipped]						NUMERIC(18, 6)									NULL		-- The quantity to ship
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- (%) The discount to apply to a line item
    ,[dblPrice]								NUMERIC(18, 6)									NULL		-- The line item price
    ,[ysnRefreshPrice]						BIT												NULL		-- Indicate whether to recompute for Price based on the available pricing setup	
	,[strMaintenanceType]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    ,[strFrequency]							NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    ,[dtmMaintenanceDate]					DATETIME										NULL
    ,[dblMaintenanceAmount]					NUMERIC(18, 6)									NULL
    ,[dblLicenseAmount]						NUMERIC(18, 6)									NULL
	,[intTaxGroupId]						INT												NULL		-- Key Value from tblSMTaxGroup (Taxes)
	,[ysnRecomputeTax]						BIT												NULL		-- Indicate whether to recompute for Taxes based on the current Tax setup	
	,[intSCInvoiceId]						INT												NULL		-- Service Charge Invoice Id
	,[strSCInvoiceNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Service Charge Invoice Number	
	,[intInventoryShipmentItemId]			INT												NULL		-- Key Value from tblICInventoryShipmentItem (Inventory Shipment)
	,[strShipmentNumber]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Inventory Shipment Number (Inventory Shipment)
	,[intSalesOrderDetailId]				INT												NULL		-- Key Value from tblSOSalesOrderDetail (Sales Order)
	,[strSalesOrderNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Sales Order Number (Sales Order)
	,[intContractHeaderId]					INT												NULL		-- Key Value from tblCTContractHeader(If NULL, it will be populated using [intContractDetailId])
	,[intContractDetailId]					INT												NULL		-- Key Value from tblCTContractDetail (Sales Contract)
	,[intShipmentPurchaseSalesContractId]	INT												NULL		-- Key Value from tblLGShipmentPurchaseSalesContract (Inbound Shipment)
	,[intTicketId]							INT												NULL		-- Key Value from tblSCTicket (Scale Ticket)
	,[intTicketHoursWorkedId]				INT												NULL		-- Key Value from tblHDTicketHoursWorked (Help Desk)
	,[intSiteId]							INT												NULL		-- Key Value from tblTMSite (Tank MAnagement)
	,[strBillingBy]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- tblTMSite.[strBillingBy] (Tank MAnagement)
	,[dblPercentFull]						NUMERIC(18, 6)									NULL
	,[dblNewMeterReading]					NUMERIC(18, 6)									NULL		
	,[dblPreviousMeterReading]				NUMERIC(18, 6)									NULL		-- tblTMSite.[dblLastMeterReading] (Tank MAnagement)
	,[dblConversionFactor]					NUMERIC(18, 8)									NULL		-- tblTMMeterType.[dblConversionFactor] (Tank MAnagement)
	,[intPerformerId]						INT												NULL		    		
	,[ysnLeaseBilling]						BIT												NULL
	,[ysnVirtualMeterReading]				BIT												NULL

)
