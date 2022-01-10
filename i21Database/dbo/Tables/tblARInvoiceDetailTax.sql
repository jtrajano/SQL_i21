CREATE TABLE [dbo].[tblARInvoiceDetailTax]
(
	[intInvoiceDetailTaxId]			INT NOT NULL IDENTITY, 
    [intInvoiceDetailId]			INT NOT NULL,     
    [intTaxGroupId]					INT NULL, 
    [intTaxCodeId]					INT NOT NULL, 
    [intTaxClassId]					INT NOT NULL, 
	[strTaxableByOtherTaxes]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate]						NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblBaseRate]					NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblExemptionPercent]			NUMERIC(18, 6) NULL DEFAULT 0, 
    [intSalesTaxAccountId]			INT NULL,
	[intSalesTaxExemptionAccountId] INT NULL,
    [dblTax]						NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblAdjustedTax]				NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblBaseAdjustedTax]			NUMERIC(18, 6) NULL DEFAULT 0, 
	[ysnTaxAdjusted]				BIT NULL DEFAULT ((0)), 
	[ysnSeparateOnInvoice]			BIT NULL DEFAULT ((0)), 
	[ysnCheckoffTax]				BIT NULL DEFAULT ((0)), 
	[ysnTaxExempt]					BIT NULL DEFAULT ((0)), 
	[ysnInvalidSetup]				BIT NULL DEFAULT ((0)), 
	[ysnTaxOnly]					BIT	NOT NULL DEFAULT 0,
	[ysnAddToCost]					BIT NULL DEFAULT ((0)),
	[strNotes]						NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
	[intUnitMeasureId]				INT NULL,
	[intCompanyId]					INT NULL,
    [intConcurrencyId]				INT CONSTRAINT [DF_tblARInvoiceDetailTax_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailTax_intInvoiceDetailTaxId] PRIMARY KEY CLUSTERED ([intInvoiceDetailTaxId] ASC),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail] ([intInvoiceDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblGLAccount_intSalesTaxExemptionAccountId] FOREIGN KEY ([intSalesTaxExemptionAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetailTax_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])
)

GO

CREATE INDEX [IX_tblARInvoiceDetailTax_intInvoiceDetailId] ON [dbo].[tblARInvoiceDetailTax] ([intInvoiceDetailId])
GO

CREATE INDEX [IX_tblARInvoiceDetailTax_intTaxCodeId] ON [dbo].[tblARInvoiceDetailTax] ([intTaxCodeId])
GO

CREATE INDEX [IX_tblARInvoiceDetailTax_dblTax] ON [dbo].[tblARInvoiceDetailTax] ([dblTax])
GO
