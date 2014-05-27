CREATE TABLE [dbo].[tblAPPostResult] (
    [intId]              INT            IDENTITY (1, 1) NOT NULL,
    [strMessage]           NVARCHAR (100) NULL,
    [strTransactionType] NVARCHAR (50)  NULL,
    [strTransactionId]   NVARCHAR (50)  NULL,
    [strBatchNumber] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intTransactionId] INT NULL, 
    PRIMARY KEY CLUSTERED ([intId] ASC)
);


GO

CREATE INDEX [IX_tblAPPostResult_intTransactionId] ON [dbo].[tblAPPostResult] ([intTransactionId])
