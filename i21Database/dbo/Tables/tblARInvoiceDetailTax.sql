﻿CREATE TABLE [dbo].[tblARInvoiceDetailTax]
(
	[intInvoiceDetailTaxId] INT NOT NULL IDENTITY, 
    [intInvoiceDetailId] INT NOT NULL, 
    [intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [numRate] NUMERIC(18, 6) NULL, 
    [intSalesTaxAccountId] INT NULL, 
    [dblTax] NUMERIC(18, 6) NULL, 
    [dblAdjustedTax] NUMERIC(18, 6) NULL, 
	[ysnSeparateOnInvoice] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT CONSTRAINT [DF_tblARInvoiceDetailTax_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailTax_intInvoiceDetailTaxId] PRIMARY KEY CLUSTERED ([intInvoiceDetailTaxId] ASC),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail] ([intInvoiceDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxGroupMaster_intTaxGroupMasterId] FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [dbo].[tblSMTaxGroupMaster] ([intTaxGroupMasterId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
