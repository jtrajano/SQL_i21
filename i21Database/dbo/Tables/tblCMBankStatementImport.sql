﻿CREATE TABLE [dbo].[tblCMBankStatementImport]
(
	[intBankStatementImportId] INT IDENTITY (1, 1) NOT NULL,
	[strBankStatementImportId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intBankAccountId] INT NOT NULL, 
    [dtmDate] DATETIME NULL, 
    [strPayee] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
    [strReferenceNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strRTN] NVARCHAR(12) COLLATE Latin1_General_CI_AS NULL, 
    [strBankAccountNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strBankDescription] nvarchar(255) COLLATE Latin1_General_CI_AS NULL,
    [dblAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDepositAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWithdrawalAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0,	
	[intImportStatus] INT NULL DEFAULT 0, 
    [intCreatedUserId] INT NULL DEFAULT 0, 
    [dtmCreated] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL, 
    [dtmLastModified] DATETIME NULL, 
    [intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblCMBankAccounttblCMBankStatementImport] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]), 
    CONSTRAINT [PK_tblCMBankStatementImport] PRIMARY KEY ([intBankStatementImportId]), 
)
