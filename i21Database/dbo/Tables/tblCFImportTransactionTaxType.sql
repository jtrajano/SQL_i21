
CREATE TABLE [dbo].[tblCFImportTransactionTaxType](
	[dblTaxCalculatedAmount] numeric(18, 6) NULL,
	[dblTaxOriginalAmount] numeric(18, 6) NULL,
	[intTaxCodeId] int NULL,
	[dblTaxRate] numeric(18, 6) NULL,
	[strTaxCode] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intTaxGroupId] int NULL,
	[strTaxGroup] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxExempt] bit NULL,
	[dblTaxCalculatedExemptAmount] numeric(18, 6) NULL,
	[intTransactionId] int NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intUserId] int NULL
)