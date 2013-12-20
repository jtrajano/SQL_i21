CREATE TABLE [dbo].[tblCMCurrentBankReconciliation] (
    [intBankAccountID]           INT          NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18) NULL,
    [dblStatementEndingBalance]  DECIMAL (18) NULL,
    [intLastModifiedUserID]      INT          NOT NULL,
    [dtmLastModified]            DATETIME     NOT NULL,
    [intConcurrencyID]           INT          NULL,
    CONSTRAINT [PK_tblCMCurrentBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountID] ASC)
);

