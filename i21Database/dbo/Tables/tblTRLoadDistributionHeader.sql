CREATE TABLE [dbo].[tblTRLoadDistributionHeader]
(
	[intLoadDistributionHeaderId] INT NOT NULL IDENTITY,
	[intLoadHeaderId] INT NOT NULL,
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
	CONSTRAINT [PK_tblTRLoadDistributionHeader] PRIMARY KEY ([intLoadDistributionHeaderId]),
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblTRLoadHeader_intLoadHeaderId] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [dbo].[tblTRLoadHeader] ([intLoadHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblEMEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
	CONSTRAINT [FK_tblTRLoadDistributionHeader_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId])			
)
