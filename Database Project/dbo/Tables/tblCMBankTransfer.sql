CREATE TABLE [dbo].[tblCMBankTransfer] (
    [cntID]                    INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionID]         NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate]                  DATETIME        NOT NULL,
    [intBankTransactionTypeID] INT             NOT NULL,
    [dblAmount]                DECIMAL (18, 6) NOT NULL,
    [strDescription]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountIDFrom]     INT             NOT NULL,
    [intGLAccountIDFrom]       INT             NOT NULL,
    [strReferenceFrom]         NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountIDTo]       INT             NOT NULL,
    [intGLAccountIDTo]         INT             NOT NULL,
    [strReferenceTo]           NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnPosted]                BIT             NOT NULL,
    [intCreatedUserID]         INT             NULL,
    [dtmCreated]               DATETIME        NULL,
    [intLastModifiedUserID]    INT             NULL,
    [dtmLastModified]          DATETIME        NULL,
    [intConcurrencyID]         INT             NOT NULL,
    CONSTRAINT [PK_tblCMBankTransfer] PRIMARY KEY CLUSTERED ([strTransactionID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_From] FOREIGN KEY ([intBankAccountIDFrom]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID]),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_To] FOREIGN KEY ([intBankAccountIDTo]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMBankTransfer_To]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIDTo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMBankTransfer_From]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIDFrom] ASC);

