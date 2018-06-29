CREATE TABLE [dbo].[tblCFTransactionTaxType] (
    [dblTaxCalculatedAmount] NUMERIC (18, 6) NULL,
    [dblTaxOriginalAmount]   NUMERIC (18, 6) NULL,
    [intTaxCodeId]           INT             NULL,
    [dblTaxRate]             NUMERIC (18, 6) NULL,
    [strTaxCode]             NVARCHAR (MAX)  NULL
);

