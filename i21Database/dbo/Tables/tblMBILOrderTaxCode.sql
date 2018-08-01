CREATE TABLE [dbo].[tblMBILOrderTaxCode](
	 [intOrderTaxId]			INT				IDENTITY(1,1) NOT NULL
	,[intOrderItemId]			INT				NOT NULL
	,[intItemId]					INT				NOT NULL
	,[intTransactionDetailTaxId]	INT
	,[intInvoiceDetailId]			INT
	,[intTaxGroupMasterId]			INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(MAX)
	,[dblRate]						NUMERIC(18, 6)
	,[dblExemptionPercent]			NUMERIC(18, 6)
	,[dblTax]						NUMERIC(18, 6)
	,[dblAdjustedTax]				NUMERIC(18, 6)
	,[dblBaseAdjustedTax]			NUMERIC(18, 6)
	,[intSalesTaxAccountId]			INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(MAX)
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[strTaxGroup]					NVARCHAR(MAX)
	,[strNotes]						NVARCHAR(MAX)
	,[intUnitMeasureId]				INT
	,[strUnitMeasure]				NVARCHAR(MAX)
	,[intConcurrencyId]				INT				DEFAULT 1 NOT NULL
	CONSTRAINT [PK_tblMBILOrderTaxCode] PRIMARY KEY CLUSTERED ([intOrderTaxId] ASC),
	CONSTRAINT [FK_tblMBILOrderTaxCode_tblMBILOrderItem] FOREIGN KEY([intOrderItemId]) REFERENCES [dbo].[tblMBILOrderItem] ([intOrderItemId]) ON DELETE CASCADE
)