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
    [dblQuantity] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
	[ysnLoad] BIT NULL DEFAULT((0)),
	[intLoadReceive] INT NULL DEFAULT ((0)),
	[dblNet] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[intSourceInventoryDetailId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICTransactionDetailLog] PRIMARY KEY ([intTransactionDetailLogId]) 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICTransactionDetailLog]
	ON [dbo].[tblICTransactionDetailLog]([strTransactionType] ASC, [intTransactionId] ASC);
GO
