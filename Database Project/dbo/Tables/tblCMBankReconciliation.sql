CREATE TABLE [dbo].[tblCMBankReconciliation] (
    [intBankAccountId]           INT             NOT NULL,
    [dtmDateReconciled]          DATETIME        NOT NULL,
    [dblStatementOpeningBalance] DECIMAL (18, 6) NOT NULL,
    [dblDebitCleared]            DECIMAL (18, 6) NOT NULL,
    [dblCreditCleared]           DECIMAL (18, 6) NOT NULL,
    [dblBankAccountBalance]      DECIMAL (18, 6) NOT NULL,
    [dblStatementEndingBalance]  DECIMAL (18, 6) NOT NULL,
    [intCreatedUserId]           INT             NULL,
    [dtmCreated]                 DATETIME        NULL,
    [intLastModifiedUserId]      INT             NULL,
    [dtmLastModified]            DATETIME        NULL,
    [intConcurrencyId]           INT             NOT NULL DEFAULT 1,
    [ysnImported] BIT NULL , 
    CONSTRAINT [PK_tblCMBankReconciliation] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC, [dtmDateReconciled] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankReconciliation] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);

