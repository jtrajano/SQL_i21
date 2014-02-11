CREATE TABLE [dbo].[tblCMBankStatementImport]
(
	[intBankStatementImportId] INT IDENTITY (1, 1) NOT NULL,
	[strBankStatementImportId] NVARCHAR(40) NOT NULL, 
    [intBankAccountId] INT NOT NULL, 
    [dtmDate] DATETIME NULL, 
    [strPayee] NVARCHAR(300) NULL, 
    [strReferenceNo] NVARCHAR(20) NULL, 
    [strRTN] NVARCHAR(12) NULL, 
    [strBankAccountNo] NVARCHAR(20) NULL, 
    [dblAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDepositAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWithdrawalAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0,	
	[intImportStatus] INT NULL DEFAULT 0, 
    [intCreatedUserId] INT NULL DEFAULT 0, 
    [dtmCreated] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL, 
    [dtmLastModified] DATETIME NULL, 
    [intConcurrencyId] INT NULL,
	CONSTRAINT [PK_tblCMBankStatementImport] PRIMARY KEY CLUSTERED ([intBankStatementImportId] ASC),
	CONSTRAINT [FK_tblCMBankAccounttblCMBankStatementImport] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]), 
	UNIQUE NONCLUSTERED ([strBankStatementImportId] ASC)
)
