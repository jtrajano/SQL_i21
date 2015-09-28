CREATE TABLE [dbo].[tblICTransactionDetailLog]
(
	[intTransactionDetailLogId] INT NOT NULL IDENTITY, 
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [intTransactionDetailId] INT NOT NULL, 
    [intOrderNumberId] INT NULL, 
	[intOrderType] INT NOT NULL DEFAULT((0)),
    [intSourceNumberId] INT NULL, 
	[intSourceType] INT NOT NULL DEFAULT((0)),
    [intLineNo] INT NULL, 
    [intItemId] INT NULL, 
    [intItemUOMId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICTransactionDetailLog] PRIMARY KEY ([intTransactionDetailLogId]) 
)
