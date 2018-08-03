CREATE TABLE [dbo].[tblMBILInvoiceSite](
	[intInvoiceSiteId] INT IDENTITY(1,1) NOT NULL,
	[intInvoiceId] INT NOT NULL,
	[intSiteId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NOT NULL,
	CONSTRAINT [PK_tblMBILInvoiceSite] PRIMARY KEY CLUSTERED ([intInvoiceSiteId] ASC), 
    CONSTRAINT [FK_tblMBILInvoiceSite_tblMBILInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblMBILInvoice]([intInvoiceId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBILInvoiceSite_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [tblTMSite]([intSiteID])
)