CREATE TABLE [dbo].[tblTRTransactionDetailLog]
(
	[intTransactionDetailLogId] INT NOT NULL IDENTITY, 
    [strTransactionType] NVARCHAR(50) NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [intTransactionDetailId] INT NOT NULL, 
    [strSourceType] NVARCHAR(50) NULL, 
    [intSourceId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intItemId] INT NULL,
	[intItemUOMId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRTransactionDetailLog] PRIMARY KEY ([intTransactionDetailLogId]) 
)
