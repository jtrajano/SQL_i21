CREATE TABLE [dbo].[tblCFTransactionPriceType] (
    [strTransactionPriceId]  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblTaxOriginalAmount]   NUMERIC (18, 6) NULL,
    [dblTaxCalculatedAmount] NUMERIC (18, 6) NULL
);

