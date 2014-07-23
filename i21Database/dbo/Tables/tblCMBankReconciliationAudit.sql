CREATE TABLE [dbo].[tblCMBankReconciliationAudit]
(
	[intBankReconciliationAuditId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intBankAccountId] INT NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnClr] INT NULL, 
    [dblAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intUserId] INT NULL, 
    [dtmDateReconciled] DATETIME NOT NULL, 
    [dtmLog] DATETIME NOT NULL, 
    [intConcurrencyId] INT NULL
)
