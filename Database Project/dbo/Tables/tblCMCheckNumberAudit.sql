CREATE TABLE [dbo].[tblCMCheckNumberAudit] (
	[cntID] INT NOT NULL IDENTITY, 
	[intBankAccountID]     INT            NOT NULL,
    [strCheckNo]           NVARCHAR(20)            NOT NULL,    
    [intCheckNoStatus] INT            NOT NULL,
    [strRemarks]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionID] NVARCHAR(40) NULL, 
    [intUserID] INT NULL, 
    [dtmCreated] DATETIME NULL, 
    [dtmCheckPrinted] DATETIME NULL, 
    [intConcurrencyID] INT NULL,     
    CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID]), 
    CONSTRAINT [PK_tblCMCheckNumberAudit] PRIMARY KEY ([cntID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMCheckNumberAudit]
    ON [dbo].[tblCMCheckNumberAudit]([intBankAccountID] ASC);

