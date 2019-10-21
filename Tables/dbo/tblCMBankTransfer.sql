﻿CREATE TABLE [dbo].[tblCMBankTransfer] (
    [intTransactionId]         INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionId]         NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate]                  DATETIME        NOT NULL,
    [intBankTransactionTypeId] INT             NOT NULL,
    [dblAmount]                DECIMAL (18, 6) DEFAULT 0 NOT NULL,
	[dblAmountForeign]         DECIMAL (18, 6) DEFAULT 0 NULL,
    [strDescription]           NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [intBankAccountIdFrom]     INT             NOT NULL,
    [intGLAccountIdFrom]       INT             NOT NULL,
    [strReferenceFrom]         NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [intBankAccountIdTo]       INT             NOT NULL,
    [intGLAccountIdTo]         INT             NOT NULL,
    [strReferenceTo]           NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]                BIT             DEFAULT 0 NOT NULL,
	[intEntityId]			   INT			   NULL, 
    [intCreatedUserId]         INT             NULL,
    [dtmCreated]               DATETIME        NULL,
    [intLastModifiedUserId]    INT             NULL,
    [dtmLastModified]          DATETIME        NULL,
	[ysnRecurring]             BIT             DEFAULT 0 NOT NULL,
	[ysnDelete]				   BIT             NULL,
	[dtmDateDeleted]		   DATETIME		   NULL,
	[dblRate]                  DECIMAL (18, 6) DEFAULT 1 NULL,
	[intCurrencyExchangeRateTypeId] INT	NULL,
	[dblHistoricRate]          DECIMAL (18, 6) DEFAULT 1 NULL,
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankTransfer] PRIMARY KEY CLUSTERED ([intTransactionId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_From] FOREIGN KEY ([intBankAccountIdFrom]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_To] FOREIGN KEY ([intBankAccountIdTo]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
	CONSTRAINT [FK_tblGLAccounttblCMBankTransfer_From] FOREIGN KEY ([intGLAccountIdFrom]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblGLAccounttblCMBankTransfer_To] FOREIGN KEY ([intGLAccountIdTo]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    UNIQUE NONCLUSTERED ([strTransactionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intBankAccountIDFrom]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIdFrom] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intBankAccountIDTo]
    ON [dbo].[tblCMBankTransfer]([intBankAccountIdTo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intGLAccountIdFrom]
    ON [dbo].[tblCMBankTransfer]([intGLAccountIdFrom] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_intGLAccountIdTo]
    ON [dbo].[tblCMBankTransfer]([intGLAccountIdTo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransfer_strTransactionId]
    ON [dbo].[tblCMBankTransfer]([strTransactionId] ASC);

