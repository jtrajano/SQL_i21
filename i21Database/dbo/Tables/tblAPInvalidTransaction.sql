CREATE TABLE [dbo].[tblAPInvalidTransaction] (
    [intId]              INT            IDENTITY (1, 1) NOT NULL,
    [strError]           NVARCHAR (100) NULL,
    [strTransactionType] NVARCHAR (50)  NULL,
    [strTransactionId]   NVARCHAR (50)  NULL,
    [strBatchNumber] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED ([intId] ASC)
);

