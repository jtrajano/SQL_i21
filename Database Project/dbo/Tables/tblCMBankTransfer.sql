CREATE TABLE [dbo].[tblCMBankTransfer] (
    [intTransactionId]			INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionId]			NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [dtmDate]					DATETIME        NOT NULL,
    [intBankTransactionTypeId]	INT             NOT NULL,
    [dblAmount]					DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [strDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intBankAccountIdFrom]		INT             NOT NULL,
    [intGLAccountIdFrom]		INT             NOT NULL,
    [strReferenceFrom]			NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [intBankAccountIdTo]       INT             NOT NULL,
    [intGLAccountIdTo]         INT             NOT NULL,
    [strReferenceTo]           NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]                BIT             NOT NULL DEFAULT 0,
    [intCreatedUserId]         INT             NULL,
    [dtmCreated]               DATETIME        NULL,
    [intLastModifiedUserId]    INT             NULL,
    [dtmLastModified]          DATETIME        NULL,
    [intConcurrencyId]         INT             NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankTransfer] PRIMARY KEY CLUSTERED ([intTransactionId]),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_From] FOREIGN KEY ([intBankAccountIdFrom]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_To] FOREIGN KEY ([intBankAccountIdTo]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_strTransactionId]
    ON [dbo].[tblCMBankTransfer]([strTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intBankAccountIDTo]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIdTo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intBankAccountIDFrom]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIdFrom] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intGLAccountIdFrom]
    ON [dbo].[tblCMBankTransfer]([intGLAccountIdFrom] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intGLAccountIdTo]
    ON [dbo].[tblCMBankTransfer]([intGLAccountIdTo] ASC);

GO