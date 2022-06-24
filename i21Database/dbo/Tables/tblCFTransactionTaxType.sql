CREATE TABLE [dbo].[tblCFTransactionTaxType] (
    [dblTaxCalculatedAmount] NUMERIC (18, 6) NULL,
    [dblTaxOriginalAmount]   NUMERIC (18, 6) NULL,
    [intTaxCodeId]           INT             NULL,
    [dblTaxRate]             NUMERIC (18, 6) NULL,
    [strTaxCode]             NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
	[intTaxGroupId]			 INT			 NULL,
	[strTaxGroup]			 NVARCHAR(100)	  COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod]	 NVARCHAR(100)	  COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxExempt]			 BIT			 NULL,
    [dblTaxCalculatedExemptAmount] NUMERIC (18, 6) NULL
);

