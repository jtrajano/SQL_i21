CREATE TABLE [dbo].[tblARInvoiceDeliveryFee]
(
	[intInvoiceDeliveryFeeId]		INT NOT NULL IDENTITY, 
    [intInvoiceId]					INT NOT NULL,     
    [intTaxGroupId]					INT NULL, 
    [intTaxCodeId]					INT NOT NULL, 
    [dblTax]						NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblBaseTax]					NUMERIC(18, 6) NULL DEFAULT 0,
    [intConcurrencyId]				INT CONSTRAINT [DF_tblARInvoiceDeliveryFee_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblARInvoiceDeliveryFee_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDeliveryFee_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblARInvoiceDeliveryFee_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
)

GO

CREATE INDEX [IX_tblARInvoiceDeliveryFee_intInvoiceId] ON [dbo].[tblARInvoiceDeliveryFee] ([intInvoiceId])
GO

CREATE INDEX [IX_tblARInvoiceDeliveryFee_dblTax] ON [dbo].[tblARInvoiceDeliveryFee] ([dblTax])
GO