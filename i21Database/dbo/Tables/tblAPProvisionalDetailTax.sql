CREATE TABLE [dbo].[tblAPProvisionalDetailTax]
(
	[intBillDetailTaxId] INT NOT NULL IDENTITY, 
    [intBillDetailId] INT NOT NULL, 
    [intTaxGroupMasterId] INT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intAccountId] INT NOT NULL, 
    [dblTax] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblAdjustedTax] NUMERIC(18, 6) NOT NULL, 
	[ysnTaxAdjusted] BIT NOT NULL DEFAULT 0, 
	[ysnSeparateOnBill] BIT NOT NULL DEFAULT 0, 
	[ysnCheckOffTax] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT CONSTRAINT [DF_tblAPProvisionalDetailTax_intConcurrencyId] DEFAULT 0 NOT NULL,
    [ysnTaxExempt] BIT NOT NULL DEFAULT 0, 
    [ysnTaxOnly] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblAPProvisionalDetailTax_intBillDetailTaxId] PRIMARY KEY CLUSTERED ([intBillDetailTaxId] ASC),
	CONSTRAINT [FK_tblAPProvisionalDetailTax_tblAPProvisionalDetail_intBillDetailId] FOREIGN KEY ([intBillDetailId]) REFERENCES [dbo].[tblAPProvisionalDetail] ([intBillDetailId]) ON DELETE CASCADE,
	--CONSTRAINT [FK_tblAPBillDetailTax_tblSMTaxGroupMaster_intTaxGroupMasterId] FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [dbo].[tblSMTaxGroupMaster] ([intTaxGroupMasterId]),
	CONSTRAINT [FK_tblAPProvisionalDetailTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblAPProvisionalDetailTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblAPProvisionalDetailTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblAPProvisionalDetailTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetailTax_taxInfo]
		ON [dbo].[tblAPProvisionalDetailTax]([intBillDetailId],[intTaxClassId],[intTaxCodeId])
		INCLUDE (intBillDetailTaxId)
GO