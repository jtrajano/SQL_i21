CREATE TABLE [dbo].[tblCMCheckNumberAudit] (
	[intCheckNumberAuditId]					INT NOT NULL IDENTITY, 
	[intBankAccountId]		INT NOT NULL,
    [strCheckNo]			NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL,    
    [intCheckNoStatus]		INT NOT NULL DEFAULT 1,
    [strRemarks]			NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionId]		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[intTransactionId]		INT NULL, 
    [intUserId]				INT NULL, 
    [dtmCreated]			DATETIME NULL, 
    [dtmCheckPrinted]		DATETIME NULL, 
    [intConcurrencyId]		INT NOT NULL DEFAULT 1,     
    CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]), 
    CONSTRAINT [PK_tblCMCheckNumberAudit] PRIMARY KEY ([intCheckNumberAuditId]) 
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_intBankAccountId]
    ON [dbo].[tblCMCheckNumberAudit]([intBankAccountId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strCheckNo]
    ON [dbo].[tblCMCheckNumberAudit]([strCheckNo] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strTransactionId]
    ON [dbo].[tblCMCheckNumberAudit]([strTransactionId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_intTransactionId]
    ON [dbo].[tblCMCheckNumberAudit]([intTransactionId] ASC);

GO