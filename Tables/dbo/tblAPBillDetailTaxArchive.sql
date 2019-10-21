CREATE TABLE [dbo].[tblAPBillDetailTaxArchive]
(
	[intBillDetailTaxId] INT NOT NULL, 
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
    [intConcurrencyId] INT DEFAULT 0 NOT NULL,
    [ysnTaxExempt] BIT NOT NULL DEFAULT 0, 
    [ysnTaxOnly] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblAPBillDetailTaxArchive_intBillDetailTaxId] PRIMARY KEY CLUSTERED ([intBillDetailTaxId] ASC),
	CONSTRAINT [FK_tblAPBillDetailTaxArchive_tblAPBillDetailArchive_intBillDetailId] FOREIGN KEY ([intBillDetailId]) REFERENCES [dbo].[tblAPBillDetailArchive] ([intBillDetailId]) ON DELETE CASCADE
)
