CREATE TABLE [dbo].[tblICPostResult] (
    [intId] INT IDENTITY (1, 1) NOT NULL,
    [strMessage] NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
	[intErrorId] INT NULL, 
    [strTransactionType] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionId] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strBatchNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intTransactionId] INT NULL, 
	[intItemId] INT NULL, 
	[intItemLocationId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED ([intId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_tblICPostResult_intTransactionId]
	ON [dbo].[tblICPostResult]([intTransactionId] ASC)
	INCLUDE ([strTransactionType], [strTransactionId], [strBatchNumber])
GO

CREATE NONCLUSTERED INDEX [IX_tblICPostResult_intItemId]
	ON [dbo].[tblICPostResult]([intItemId] ASC, [intItemLocationId] ASC)
	INCLUDE ([strTransactionType], [strTransactionId], [strBatchNumber])
GO

CREATE NONCLUSTERED INDEX [IX_tblICPostResult_strBatchNumber]
	ON [dbo].[tblICPostResult]([strBatchNumber] ASC)
	INCLUDE ([intErrorId])
GO