CREATE TABLE [dbo].[tblCMBankTransaction] (
    [cntID]                    INT              IDENTITY (1, 1) NOT NULL,
    [strTransactionID]         NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankTransactionTypeID] INT              NOT NULL,
    [intBankAccountID]         INT              NOT NULL,
    [intCurrencyID]            INT              NULL,
    [dblExchangeRate]          DECIMAL (38, 20) NOT NULL,
    [dtmDate]                  DATETIME         NOT NULL,
    [strPayee]                 NVARCHAR (300)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intPayeeID]               INT              NULL,
    [strAddress]               NVARCHAR (65)    COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]               NVARCHAR (42)    COLLATE Latin1_General_CI_AS NULL,
    [strCity]                  NVARCHAR (85)    COLLATE Latin1_General_CI_AS NULL,
    [strState]                 NVARCHAR (60)    COLLATE Latin1_General_CI_AS NULL,
    [strCountry]               NVARCHAR (75)    COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]                DECIMAL (18, 6)  NOT NULL,
    [strAmountInWords]         NVARCHAR (250)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strMemo]                  NVARCHAR (250)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strReferenceNo]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmCheckPrinted]          DATETIME              NULL DEFAULT NULL,
    [ysnCheckToBePrinted]      BIT              NOT NULL,
    [ysnCheckVoid]             BIT              NOT NULL,
    [ysnPosted]                BIT              NOT NULL,
    [strLink]                  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [ysnClr]                   BIT              NOT NULL,
    [dtmDateReconciled]        DATETIME         NULL,
    [intCreatedUserID]         INT              NULL,
    [dtmCreated]               DATETIME         NULL,
    [intLastModifiedUserID]    INT              NULL,
    [dtmLastModified]          DATETIME         NULL,
    [intConcurrencyID]         INT              NULL,
    CONSTRAINT [PK_tblCMBankTransaction] PRIMARY KEY CLUSTERED ([strTransactionID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransaction] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID]),
    CONSTRAINT [FK_tblCMBankTransactiontblSMCurrency] FOREIGN KEY ([intCurrencyID]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMBankTransaction]
    ON [dbo].[tblCMBankTransaction]([intBankAccountID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankTransactiontblSMCurrency]
    ON [dbo].[tblCMBankTransaction]([intCurrencyID] ASC);

