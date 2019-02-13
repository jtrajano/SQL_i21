CREATE TABLE [dbo].[tblMBILInvoiceTaxCode](
	 [intInvoiceTaxId]			INT				IDENTITY(1,1) NOT NULL
	,[intInvoiceItemId]			INT				NOT NULL
	,[intItemId]					INT				NOT NULL
	,[intTransactionDetailTaxId]	INT
	,[intInvoiceDetailId]			INT
	,[intTaxGroupMasterId]			INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[strCalculationMethod]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[dblRate]						NUMERIC(18, 6)
	,[dblExemptionPercent]			NUMERIC(18, 6)
	,[dblTax]						NUMERIC(18, 6)
	,[dblAdjustedTax]				NUMERIC(18, 6)
	,[dblBaseAdjustedTax]			NUMERIC(18, 6)
	,[intSalesTaxAccountId]			INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[strTaxGroup]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[strNotes]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[intUnitMeasureId]				INT
	,[strUnitMeasure]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[intConcurrencyId]				INT				DEFAULT 1 NOT NULL
	CONSTRAINT [PK_tblMBILInvoiceTaxCode] PRIMARY KEY CLUSTERED ([intInvoiceTaxId] ASC),
	CONSTRAINT [FK_tblMBILInvoiceTaxCode_tblMBILInvoiceItem] FOREIGN KEY([intInvoiceItemId]) REFERENCES [dbo].[tblMBILInvoiceItem] ([intInvoiceItemId]) ON DELETE CASCADE
)