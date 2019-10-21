CREATE TABLE [dbo].[tblVRSubmitted](
	[intSubmittedId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceDetailId] [int] NOT NULL,
	[intVendorEntityId] [int] NOT NULL,
	[dblUnits] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRSubmitted_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRSubmitted] PRIMARY KEY CLUSTERED([intSubmittedId] ASC), 
    CONSTRAINT [FK_tblVRSubmitted_tblARInvoiceDetail] FOREIGN KEY (intInvoiceDetailId) REFERENCES [tblARInvoiceDetail]([intInvoiceDetailId]),
);
GO