CREATE TYPE [dbo].[SubLedgerTransactionsUdt] AS TABLE
(
  intId INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
  strSourceTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,     -- Transaction form ex: Invoice, Inventory Adjustment, Debit Memo, etc.
  strSourceTransactionNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL        -- The transaction no, ex: Invoice No., Adjustment No., etc.
)