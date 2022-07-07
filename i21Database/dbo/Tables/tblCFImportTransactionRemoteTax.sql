
CREATE TABLE [dbo].[tblCFImportTransactionRemoteTax](
	[intTransactionId] int NULL,
	[intTransactionDetailTaxId] int NULL,
	[intInvoiceDetailId] int NULL,
	[intTransactionDetailId] int NULL,
	[intTaxGroupMasterId] int NULL,
	[intTaxGroupId] int NULL,
	[intTaxCodeId] int NULL,
	[intTaxClassId] int NULL,
	[strTaxableByOtherTaxes] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[dblRate] numeric(18, 10) NULL,
	[dblBaseRate] numeric(18, 10) NULL,
	[dblTax] numeric(18, 10) NULL,
	[dblAdjustedTax] numeric(18, 10) NULL,
	[dblExemptionPercent] numeric(18, 10) NULL,
	[intSalesTaxAccountId] int NULL,
	[intTaxAccountId] int NULL,
	[ysnSeparateOnInvoice] bit NULL,
	[ysnCheckoffTax] bit NULL,
	[strTaxCode] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxExempt] bit NULL,
	[ysnInvalidSetup] bit NULL,
	[strTaxGroup] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[ysnInvalid] bit NULL,
	[strReason] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strNotes] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strTaxExemptReason] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[dblCalculatedTax] numeric(18, 10) NULL,
	[dblOriginalTax] numeric(18, 10) NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intUserId] int NULL
)