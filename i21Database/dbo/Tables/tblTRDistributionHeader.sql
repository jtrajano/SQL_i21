CREATE TABLE [dbo].[tblTRDistributionHeader]
(
	[intDistributionHeaderId] INT NOT NULL IDENTITY,
	[intTransportReceiptId] INT NOT NULL,
	[strDestination] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityCustomerId] INT NULL,	
	[intShipToLocationId] INT NULL,
    [intCompanyLocationId] INT NOT NULL,	
	[intEntitySalespersonId] INT NULL,	
	[strPurchaseOrder] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strComments] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[dtmInvoiceDateTime]  DATETIME   NULL,
	[intInvoiceId] INT NULL,	
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRDistributionHeader] PRIMARY KEY ([intDistributionHeaderId]),
	CONSTRAINT [FK_tblTRDistributionHeader_tblTRTransportReceipt_intTransportReceiptId] FOREIGN KEY ([intTransportReceiptId]) REFERENCES [dbo].[tblTRTransportReceipt] ([intTransportReceiptId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRDistributionHeader_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblTRDistributionHeader_tblEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblTRDistributionHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblTRDistributionHeader_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntitySalespersonId]),
	CONSTRAINT [FK_tblTRDistributionHeader_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId])			
)
