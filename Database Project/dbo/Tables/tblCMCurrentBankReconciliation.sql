CREATE TABLE [dbo].[tblCMCurrentBankReconciliation] (
    [intBankAccountID]           INT          NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18) NULL,
    [dblStatementEndingBalance]  DECIMAL (18) NULL,
    [intLastModifiedUserID]      INT          NOT NULL,
    [dtmLastModified]            DATETIME     NOT NULL,
    [intConcurrencyId]           INT          NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMCurrentBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountID] ASC)
);

