CREATE TABLE [dbo].[tblSMStartingNumber] (
    [cntID]                INT            IDENTITY (1, 1) NOT NULL,
    [strTransactionType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPrefix]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intNumber]            INT            NULL,
    [intTransactionTypeID] INT            NULL,
    [strModule]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnEnable]            BIT            NULL,
    [intConcurrencyId]     INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblSMStartingNumber] PRIMARY KEY CLUSTERED ([strTransactionType] ASC)
);

