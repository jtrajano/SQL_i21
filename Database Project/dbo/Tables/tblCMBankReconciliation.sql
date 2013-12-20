CREATE TABLE [dbo].[tblCMBankReconciliation] (
    [intBankAccountID]           INT             NOT NULL,
    [dtmDateReconciled]          DATETIME        NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18, 6) NOT NULL,
    [dblDebitCleared]            DECIMAL (18, 6) NOT NULL,
    [dblCreditCleared]           DECIMAL (18, 6) NOT NULL,
    [dblBankAccountBalance]      DECIMAL (18, 6) NOT NULL,
    [dblStatementEndingBalance]  DECIMAL (18, 6) NOT NULL,
    [intCreatedUserID]           INT             NULL,
    [dtmCreated]                 DATETIME        NULL,
    [intLastModifiedUserID]      INT             NULL,
    [dtmLastModified]            DATETIME        NULL,
    [intConcurrencyID]           INT             NOT NULL,
    CONSTRAINT [PK_tblCMBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountID] ASC, [dtmDateReconciled] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankReconciliation] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID])
);

