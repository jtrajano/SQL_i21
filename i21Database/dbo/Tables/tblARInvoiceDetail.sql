CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId]			INT             IDENTITY (1, 1) NOT NULL,
    [intInvoiceId]					INT             NOT NULL,
    [intItemId]						INT             NULL,
    [strItemDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL,
	[intSCInvoiceId]				INT				NULL,
	[strSCInvoiceNumber]			NVARCHAR (25)   COLLATE Latin1_General_CI_AS  NULL,
	[intItemUOMId]					INT             NULL,
    [dblQtyOrdered]					NUMERIC (18, 6) NULL,
    [dblQtyShipped]					NUMERIC (18, 6) NULL,
	[dblDiscount]					NUMERIC (18, 6) NULL,
    [dblPrice]						NUMERIC (18, 6) NULL,
	[dblTotalTax]					NUMERIC (18, 6) NULL,
    [dblTotal]						NUMERIC (18, 6) NULL,
	[intAccountId]					INT             NULL,
	[intCOGSAccountId]				INT             NULL,
	[intSalesAccountId]				INT             NULL,
	[intInventoryAccountId]			INT				NULL,
	[intServiceChargeAccountId]		INT				NULL,
	[intInventoryShipmentItemId]	INT				NULL,
	[strShipmentNumber]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[intSalesOrderDetailId]			INT				NULL,
	[strSalesOrderNumber]			NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
	[intSiteId]						INT				NULL,
	[strBillingBy]                  NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
	[dblPercentFull]				NUMERIC (18, 6) NULL,
	[dblNewMeterReading]			NUMERIC (18, 6) NULL,
	[dblPreviousMeterReading]		NUMERIC (18, 6) NULL,
	[dblConversionFactor]			NUMERIC (18, 8) NULL,
	[intPerformerId]				INT				NULL,
	[intContractHeaderId]			INT				NULL,
	[strMaintenanceType]            NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL,
    [strFrequency]                  NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL,
    [dtmMaintenanceDate]            DATETIME        NULL, 
    [dblMaintenanceAmount]          NUMERIC(18, 6)  NULL, 
    [dblLicenseAmount]              NUMERIC(18, 6)  NULL,  
    [intContractDetailId]			INT				NULL, 
	[intTicketId]					INT				NULL, 
	[intTicketHoursWorkedId]		INT				NULL,
	[ysnLeaseBilling]				BIT,
    [intConcurrencyId]				INT             CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,    
    CONSTRAINT [PK_tblARInvoiceDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICInventoryShipmentItem_intInventoryShipmentItemId] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [dbo].[tblICInventoryShipmentItem] ([intInventoryShipmentItemId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSOSalesOrderDetail_intSalesOrderDetailId] FOREIGN KEY ([intSalesOrderDetailId]) REFERENCES [dbo].[tblSOSalesOrderDetail] ([intSalesOrderDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblTMSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblSCTicket] ([intTicketId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblHDTicketHoursWorked_intTicketHoursWorkedId] FOREIGN KEY ([intTicketHoursWorkedId]) REFERENCES [dbo].[tblHDTicketHoursWorked] ([intTicketHoursWorkedId])
);








GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoiceDetail]([intInvoiceId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblQtyOrdered] ASC, [dblQtyShipped] ASC, [dblPrice] ASC, [dblTotal] ASC);

