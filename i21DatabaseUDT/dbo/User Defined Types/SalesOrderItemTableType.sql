/*
	This is a user-defined table type for sales order. It is used as a common variable for the other modules to integrate with sales order. 
*/
CREATE TYPE [dbo].[SalesOrderItemTableType] AS TABLE
(
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	
		-- Header
		,[intSalesOrderId]				INT             NOT NULL
		,[strSalesOrderNumber]			NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
		,[intEntityCustomerId]			INT             NULL
		,[dtmDate]						DATETIME        NOT NULL
		,[intCurrencyId]				INT             NOT NULL
		,[intCompanyLocationId]			INT             NULL
		,[intQuoteTemplateId]			INT             NULL

		-- Detail 
		,[intSalesOrderDetailId]		INT             NOT NULL
		,[intItemId]					INT             NULL
		,[strItemDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL
		,[intItemUOMId]					INT             NULL
		,[dblQtyOrdered]				NUMERIC (18, 6) NULL
		,[dblQtyAllocated]				NUMERIC (18, 6) NULL
		,[dblQtyShipped]				NUMERIC (18, 6) NULL
		,[dblDiscount]					NUMERIC (18, 6) NULL
		,[intTaxId]						INT				NULL
		,[dblPrice]						NUMERIC (18, 6) NULL
		,[dblTotalTax]					NUMERIC (18, 6) NULL
		,[dblTotal]						NUMERIC (18, 6) NULL
		,[strComments]					NVARCHAR (500)  COLLATE Latin1_General_CI_AS  NULL		
		,[strMaintenanceType]           NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL
		,[strFrequency]                 NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL
		,[dtmMaintenanceDate]           DATETIME        NULL
		,[dblMaintenanceAmount]         NUMERIC(18, 6)  NULL 
		,[dblLicenseAmount]             NUMERIC(18, 6)  NULL  
		,[intContractHeaderId]			INT				NULL
		,[intContractDetailId]			INT				NULL 
		,[intStorageLocationId]			INT				NULL 
)
