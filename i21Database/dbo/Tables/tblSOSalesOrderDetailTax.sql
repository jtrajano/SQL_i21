CREATE TABLE [dbo].[tblSOSalesOrderDetailTax]
(
	[intSalesOrderDetailTaxId]  INT NOT NULL IDENTITY, 
    [intSalesOrderDetailId]     INT NOT NULL, 
    [intTaxGroupId]             INT NOT NULL, 
    [intTaxCodeId]              INT NOT NULL, 
    [intTaxClassId]             INT NOT NULL, 
	[strTaxableByOtherTaxes]    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]      NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate]                   NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblBaseRate]               NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblExemptionPercent]       NUMERIC(18, 6) NULL DEFAULT 0, 
    [intSalesTaxAccountId]      INT NULL, 
    [dblTax]                    NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblAdjustedTax]            NUMERIC(18, 6) NULL DEFAULT 0, 
	[dblBaseAdjustedTax]        NUMERIC(18, 6) NULL DEFAULT 0, 
	[ysnTaxAdjusted]            BIT NULL DEFAULT ((0)), 
	[ysnSeparateOnInvoice]      BIT NULL DEFAULT ((0)), 
	[ysnCheckoffTax]            BIT NULL DEFAULT ((0)), 
	[ysnTaxExempt]              BIT NULL DEFAULT ((0)),
	[ysnInvalidSetup]           BIT NULL DEFAULT ((0)), 
	[ysnTaxOnly]				BIT	NOT NULL DEFAULT 0,
	[strNotes]                  NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
	[intUnitMeasureId]			INT NULL,
    [intConcurrencyId]          INT CONSTRAINT [DF_tblSOSalesOrderDetailTax_intConcurrencyId] DEFAULT ((0)) NOT NULL,	
    CONSTRAINT [PK_tblSOSalesOrderDetailTax_intSalesOrderDetailTaxId] PRIMARY KEY CLUSTERED ([intSalesOrderDetailTaxId] ASC),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSOSalesOrderDetail_intSalesOrderDetailId] FOREIGN KEY ([intSalesOrderDetailId]) REFERENCES [dbo].[tblSOSalesOrderDetail] ([intSalesOrderDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])
)

GO

CREATE INDEX [IX_tblSOSalesOrderDetailTax_dblAdjustedTax] ON [dbo].[tblSOSalesOrderDetailTax] ([dblAdjustedTax]) INCLUDE([intSalesOrderDetailId], [intTaxCodeId])

GO
