CREATE TABLE [dbo].[tblARPostResult] (
    [intId]              INT            IDENTITY (1, 1) NOT NULL,
    [strMessage]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionId]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strBatchNumber]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]   INT            CONSTRAINT [DF_tblARPostResult_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    [intTransactionId]   INT            NULL,
    CONSTRAINT [PK_tblARPostResult] PRIMARY KEY CLUSTERED ([intId] ASC)
);

