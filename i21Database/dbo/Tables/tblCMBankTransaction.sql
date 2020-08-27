CREATE TABLE [dbo].[tblCMBankTransaction] (
    [intTransactionId]         INT              IDENTITY (1, 1) NOT NULL,
    [strTransactionId]         NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankTransactionTypeId] INT              NOT NULL,
    [intBankAccountId]         INT              NOT NULL,
	[intBankLoanId]			   INT              NULL,
	[intCurrencyId]            INT              NULL,
    [dblExchangeRate]          DECIMAL (38, 20) DEFAULT 1 NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,

    [dtmDate]                  DATETIME         NOT NULL,
    [strPayee]                 NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
    [intPayeeId]               INT              NULL,
    [strAddress]               NVARCHAR (65)    COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]               NVARCHAR (42)    COLLATE Latin1_General_CI_AS NULL,
    [strCity]                  NVARCHAR (85)    COLLATE Latin1_General_CI_AS NULL,
    [strState]                 NVARCHAR (60)    COLLATE Latin1_General_CI_AS NULL,
    [strCountry]               NVARCHAR (75)    COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]                DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
	[dblShortAmount]           DECIMAL (18, 6)  DEFAULT 0 NULL,
	[intShortGLAccountId]      INT				NULL,
    [strAmountInWords]         NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
    [strMemo]                  NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strReferenceNo]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [dtmCheckPrinted]          DATETIME         NULL,
    [ysnCheckToBePrinted]      BIT              DEFAULT 0 NOT NULL,
    [ysnCheckVoid]             BIT              DEFAULT 0 NOT NULL,
    [ysnPosted]                BIT              DEFAULT 0 NOT NULL,
    [strLink]                  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [ysnClr]                   BIT              DEFAULT 0 NOT NULL,
	[ysnEmailSent]			   BIT				NULL,
	[strEmailStatus]		   NVARCHAR (250)	COLLATE Latin1_General_CI_AS NULL,
    [dtmDateReconciled]        DATETIME         NULL,
	[intBankStatementImportId] INT              NULL,
	[intBankFileAuditId]	   INT				NULL, 
	[strSourceSystem]		   NVARCHAR (2)		COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]			   INT				NULL,
    [intCreatedUserId]         INT              NULL,
	[intCompanyLocationId]     INT              NULL,
    [dtmCreated]               DATETIME         NULL,
    [intLastModifiedUserId]    INT              NULL,
    [dtmLastModified]          DATETIME         NULL,
	[ysnRecurring]			   BIT              DEFAULT 0 NOT NULL,
	[ysnHold]				   BIT				DEFAULT 0 NOT NULL,
	[ysnPOS]				   BIT				DEFAULT 0 NULL,
	[strHoldReason]			   NVARCHAR (250)	COLLATE Latin1_General_CI_AS NULL,
	[ysnDelete]				   BIT              NULL,
	[dtmDateDeleted]		   DATETIME	        NULL,
	[dtmClr]				   DATETIME	        NULL,
    [ysnHasDetailOverflow]     BIT              NULL,
    [ysnHasBasisPrepayOverflow]BIT              NULL,
    [intPaymentId]             INT              NULL, 
    [intConcurrencyId]         INT              DEFAULT 1 NOT NULL
	CONSTRAINT [PK_tblCMBankTransaction] PRIMARY KEY CLUSTERED ([intTransactionId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMBankTransaction] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
    CONSTRAINT [FK_tblCMBankTransactiontblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblCMBankTransactiontblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] (intCompanyLocationId),
	CONSTRAINT [FK_tblCMBankTransactiontblGLAccount] FOREIGN KEY ([intShortGLAccountId]) REFERENCES [dbo].[tblGLAccount] (intAccountId),
	CONSTRAINT [FK_tblCMBankTransaction_tblCMBankLoan] FOREIGN KEY ([intBankLoanId]) REFERENCES [dbo].[tblCMBankLoan] (intBankLoanId),
    UNIQUE NONCLUSTERED ([strTransactionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_intBankAccountId]
    ON [dbo].[tblCMBankTransaction]([intBankAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_intCurrencyId]
    ON [dbo].[tblCMBankTransaction]([intCurrencyId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strLink]
    ON [dbo].[tblCMBankTransaction]([strLink] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strReferenceNo]
    ON [dbo].[tblCMBankTransaction]([strReferenceNo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_strTransactionId]
    ON [dbo].[tblCMBankTransaction]([strTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransaction_intBankStatementImportId]
    ON [dbo].[tblCMBankTransaction]([intBankStatementImportId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblCMBankTransaction]
(
	[strTransactionId] ASC
)
INCLUDE ( 	[intBankTransactionTypeId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
