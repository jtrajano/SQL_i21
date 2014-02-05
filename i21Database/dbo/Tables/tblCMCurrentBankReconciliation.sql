CREATE TABLE [dbo].[tblCMCurrentBankReconciliation] (
    [intBankAccountId]           INT          NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18) DEFAULT 0 NOT NULL,
    [dblStatementEndingBalance]  DECIMAL (18) DEFAULT 0 NOT NULL,
    [intLastModifiedUserId]      INT          NULL,
    [dtmLastModified]            DATETIME     NULL,
    [intConcurrencyId]           INT          DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMCurrentBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCurrentBankReconciliation_intBankAccountId]
    ON [dbo].[tblCMCurrentBankReconciliation]([intBankAccountId] ASC);

