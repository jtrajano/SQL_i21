/*
	This is a user-defined table type for the invoice. It is used as a common variable for the other modules to integrate with invoice. 
*/
CREATE TYPE [dbo].[InvoiceItemTableType] AS TABLE
(
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	
		-- Header
		,[intInvoiceId]					INT             NOT NULL
		,[strInvoiceNumber]				NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL
		,[intEntityCustomerId]			INT             NOT NULL
		,[dtmDate]						DATETIME        NOT NULL
		,[intCurrencyId]				INT             NOT NULL
		,[intCompanyLocationId]			INT             NULL
		,[intDistributionHeaderId]		INT             NULL

		-- Detail 
		,[intInvoiceDetailId]			INT             NOT NULL
		,[intItemId]					INT             NULL
		,[strItemNo]					NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL
		,[strItemDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL
		,[intSCInvoiceId]				INT				NULL
		,[strSCInvoiceNumber]			NVARCHAR (25)   COLLATE Latin1_General_CI_AS  NULL
		,[intItemUOMId]					INT             NULL
		,[dblQtyOrdered]				NUMERIC (18, 6) NULL
		,[dblQtyShipped]				NUMERIC (18, 6) NULL
		,[dblDiscount]					NUMERIC (18, 6) NULL
		,[dblPrice]						NUMERIC (18, 6) NULL
		,[dblTotalTax]					NUMERIC (18, 6) NULL
		,[dblTotal]						NUMERIC (18, 6) NULL		
		,[intServiceChargeAccountId]	INT				NULL
		,[intInventoryShipmentItemId]	INT				NULL		
		,[intSalesOrderDetailId]		INT				NULL
		,[intShipmentPurchaseSalesContractId]	INT		NULL				
		,[intSiteId]					INT				NULL
		,[strBillingBy]                 NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL
		,[dblPercentFull]				NUMERIC (18, 6) NULL
		,[dblNewMeterReading]			NUMERIC (18, 6) NULL
		,[dblPreviousMeterReading]		NUMERIC (18, 6) NULL
		,[dblConversionFactor]			NUMERIC (18, 8) NULL
		,[intPerformerId]				INT				NULL
		,[intContractHeaderId]			INT				NULL
		,[strContractNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
		,[strMaintenanceType]           NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL
		,[strFrequency]                 NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL
		,[dtmMaintenanceDate]           DATETIME        NULL
		,[dblMaintenanceAmount]         NUMERIC(18, 6)  NULL 
		,[dblLicenseAmount]             NUMERIC(18, 6)  NULL  
		,[intContractDetailId]			INT				NULL 
		,[intTicketId]					INT				NULL 
		,[intTicketHoursWorkedId]		INT				NULL
		,[intCustomerStorageId]			INT				NULL
		,[intSiteDetailId]				INT				NULL
		,[intLoadDetailId]				INT				NULL
		,[intOriginalInvoiceDetailId]	INT				NULL
		,[ysnLeaseBilling]				BIT				NULL
)
