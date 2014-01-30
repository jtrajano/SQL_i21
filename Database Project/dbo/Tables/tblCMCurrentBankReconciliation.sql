CREATE TABLE [dbo].[tblCMCurrentBankReconciliation] (
    [intBankAccountId]           INT          NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18) NOT NULL DEFAULT 0,
    [dblStatementEndingBalance]  DECIMAL (18) NOT NULL DEFAULT 0,
    [intLastModifiedUserId]      INT          NULL,
    [dtmLastModified]            DATETIME     NULL,
    [intConcurrencyId]           INT          NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMCurrentBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCurrentBankReconciliation_intBankAccountId]
    ON [dbo].[tblCMCurrentBankReconciliation]([intBankAccountId] ASC);