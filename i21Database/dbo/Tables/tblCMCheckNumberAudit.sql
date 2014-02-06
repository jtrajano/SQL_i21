CREATE TABLE [dbo].[tblCMCheckNumberAudit] (
    [intCheckNumberAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [intBankAccountId]      INT            NOT NULL,
    [strCheckNo]            NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intCheckNoStatus]      INT            DEFAULT 1 NOT NULL,
    [strRemarks]            NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionId]      NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]      INT            NULL,
    [intUserId]             INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [dtmCheckPrinted]       DATETIME       NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMCheckNumberAudit] PRIMARY KEY CLUSTERED ([intCheckNumberAuditId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_intBankAccountId]
    ON [dbo].[tblCMCheckNumberAudit]([intBankAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_intTransactionId]
    ON [dbo].[tblCMCheckNumberAudit]([intTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strCheckNo]
    ON [dbo].[tblCMCheckNumberAudit]([strCheckNo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strTransactionId]
    ON [dbo].[tblCMCheckNumberAudit]([strTransactionId] ASC);

