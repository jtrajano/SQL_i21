﻿CREATE TABLE [dbo].[tblCMUndepositedFund] (    
	[intUndepositedFundId]		INT IDENTITY (1, 1) NOT NULL,
	[intBankAccountId]			INT NOT NULL,
    [strSourceTransactionId]	NVARCHAR (40) COLLATE Latin1_General_CI_AS NOT NULL,	    
    [intSourceTransactionId]	INT NULL,
	[intLocationId]				INT NULL,	
	[dtmDate]					DATETIME NULL,
	[strName]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblAmount]					DECIMAL (18, 6) DEFAULT 0 NOT NULL,
	[strSourceSystem]			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intBankDepositId]			INT NULL,
    [intCreatedUserId]			INT NULL,
    [dtmCreated]				DATETIME NULL,
	[ysnToProcess]				BIT NOT NULL DEFAULT ((0)),
	[ysnGenerated]				BIT NULL,
	[ysnNotified]				BIT NULL,
	[strNotificationStatus]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnCommitted]				BIT NULL,
	[intBankFileAuditId]		INT NULL,
    [intLastModifiedUserId]		INT NULL,
    [dtmLastModified]			DATETIME NULL,
    [intConcurrencyId]			INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundId] ASC)
);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankAccountId]
    ON [dbo].[tblCMUndepositedFund]([intBankAccountId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([intSourceTransactionId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strSourceTransactionId] ASC);	
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankDepositId]
    ON [dbo].[tblCMUndepositedFund]([intBankDepositId] ASC);
GO