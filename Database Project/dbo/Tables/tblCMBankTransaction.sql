CREATE TABLE [dbo].[tblCMBankTransaction] (
    [intTransactionId]                    INT              IDENTITY (1, 1) NOT NULL,
    [strTransactionId]         NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [intBankTransactionTypeId] INT              NOT NULL ,
    [intBankAccountId]         INT              NOT NULL,
    [intCurrencyId]            INT              NULL,
    [dblExchangeRate]          DECIMAL (38, 20) NOT NULL DEFAULT 1,
    [dtmDate]                  DATETIME         NOT NULL ,
    [strPayee]                 NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
    [intPayeeId]               INT              NULL,
    [strAddress]               NVARCHAR (65)    COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]               NVARCHAR (42)    COLLATE Latin1_General_CI_AS NULL,
    [strCity]                  NVARCHAR (85)    COLLATE Latin1_General_CI_AS NULL,
    [strState]                 NVARCHAR (60)    COLLATE Latin1_General_CI_AS NULL,
    [strCountry]               NVARCHAR (75)    COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]                DECIMAL (18, 6)  NOT NULL DEFAULT 0,
    [strAmountInWords]         NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
    [strMemo]                  NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNo]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [dtmCheckPrinted]          DATETIME              NULL ,
    [ysnCheckToBePrinted]      BIT              NOT NULL DEFAULT 0,
    [ysnCheckVoid]             BIT              NOT NULL DEFAULT 0,
    [ysnPosted]                BIT              NOT NULL DEFAULT 0,
    [strLink]                  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [ysnClr]                   BIT              NOT NULL DEFAULT 0,
    [dtmDateReconciled]        DATETIME         NULL,
    [intCreatedUserId]         INT              NULL,
    [dtmCreated]               DATETIME         NULL,
    [intLastModifiedUserId]    INT              NULL,
    [dtmLastModified]          DATETIME         NULL,
    [intConcurrencyId]         INT              NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankTransaction] PRIMARY KEY CLUSTERED ([intTransactionId]),
	CONSTRAINT [FK_tblCMBankAccounttblCMBankTransaction] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
    CONSTRAINT [FK_tblCMBankTransactiontblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strTransactionId]
    ON [dbo].[tblCMBankTransaction]([strTransactionId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_intBankAccountId]
    ON [dbo].[tblCMBankTransaction]([intBankAccountId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strReferenceNo]
    ON [dbo].[tblCMBankTransaction]([strReferenceNo] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strLink]
    ON [dbo].[tblCMBankTransaction]([strLink] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_intCurrencyId]
    ON [dbo].[tblCMBankTransaction]([intCurrencyId] ASC);

GO

