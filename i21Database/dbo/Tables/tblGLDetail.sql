CREATE TABLE [dbo].[tblGLDetail] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
    [intCompanyId] [int] NULL,
    [intMultiCompanyId] [int]   NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NOT NULL,
    [dblDebit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebit]  DEFAULT ((0)),
    [dblCredit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCredit]  DEFAULT ((0)),
    [dblDebitUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebitUnit]  DEFAULT ((0)),
    [dblCreditUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCreditUnit]  DEFAULT ((0)),
    [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
    [strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]             INT              NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
    [dblExchangeRate]           NUMERIC (38, 20) NOT NULL,
    [dtmDateEntered]            DATETIME         NOT NULL,
    [dtmDateEnteredMin]         DATETIME         NULL,
    [dtmTransactionDate]        DATETIME         NULL,
    [strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
    [ysnIsUnposted]             BIT              NOT NULL,    
    [ysnPostAction]             BIT              NULL,    
    [intUserId]                 INT              NULL,
    [intEntityId]				INT              NULL,
    [strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intTransactionId]          INT              NULL,
    [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblDebitForeign]  DEFAULT ((0)),
    [dblDebitReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblDebitReport]  DEFAULT ((0)),
    [dblCreditForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblCreditForeign]  DEFAULT ((0)),
    [dblCreditReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblCreditReport]  DEFAULT ((0)),
    [dblReportingRate] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblReportingRate]  DEFAULT ((0)),
    [dblForeignRate] NUMERIC(18, 9) NULL, 
    [intReconciledId] INT NULL, 
    [dtmReconciled] DATETIME NULL, 
    [ysnReconciled] BIT NULL, 
	[ysnRevalued] BIT NULL,
    -- new columns GL-3550
    [strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    intSourceLocationId INT NULL,
    intSourceUOMId INT NULL,
    dblSourceUnitDebit NUMERIC(18,9) NULL,
	dblSourceUnitCredit NUMERIC(18,9) NULL,
    intCommodityId INT NULL,
    intSourceEntityId INT NULL,
	-- new columns GL-3550	
	[strDocument] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strComments] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGL] PRIMARY KEY CLUSTERED ([intGLDetailId] ASC),
    CONSTRAINT [FK_tblGL_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLDetail_tblSMMultiCompany] FOREIGN KEY([intMultiCompanyId]) REFERENCES [dbo].[tblSMMultiCompany] ([intMultiCompanyId])
);
GO
CREATE NONCLUSTERED INDEX [IX_tblGLDetail_Valuation]
	ON [dbo].[tblGLDetail]([strTransactionId], [strBatchId])
	INCLUDE (dtmDate, strTransactionType);
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblEMEntityCredential_9_1290448367__K2_3] ON [dbo].[tblEMEntityCredential]
(
	[intEntityId] ASC
)
INCLUDE ( 	[strUserName]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1702557399_9_5_1] ON [dbo].[tblGLAccount]([intAccountUnitId], [intAccountGroupId], [intAccountId])
GO
CREATE STATISTICS [_dta_stat_1702557399_5_1] ON [dbo].[tblGLAccount]([intAccountGroupId], [intAccountId])
GO
CREATE STATISTICS [_dta_stat_1702557399_1_9] ON [dbo].[tblGLAccount]([intAccountId], [intAccountUnitId])
GO
CREATE STATISTICS [_dta_stat_424544746_2_4_18_20_1] ON [dbo].[tblGLDetail]([dtmDate], [intAccountId], [ysnIsUnposted], [intEntityId], [intGLDetailId])
GO
CREATE STATISTICS [_dta_stat_424544746_2_20_4] ON [dbo].[tblGLDetail]([dtmDate], [intEntityId], [intAccountId])
GO
CREATE STATISTICS [_dta_stat_424544746_20_1_2_4] ON [dbo].[tblGLDetail]([intEntityId], [intGLDetailId], [dtmDate], [intAccountId])
GO
CREATE STATISTICS [_dta_stat_424544746_20_1_17_2_4] ON [dbo].[tblGLDetail]([intEntityId], [intGLDetailId], [intJournalLineNo], [dtmDate], [intAccountId])
GO
CREATE STATISTICS [_dta_stat_424544746_1_17_2_4] ON [dbo].[tblGLDetail]([intGLDetailId], [intJournalLineNo], [dtmDate], [intAccountId])
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblGLDetail_9_424544746__K4_K18_K2_K1_K17_K20_3_5_6_7_8_9_10_11_16_21_22_23_24_25_27_29] ON [dbo].[tblGLDetail]
(
	[intAccountId] ASC,
	[ysnIsUnposted] ASC,
	[dtmDate] ASC,
	[intGLDetailId] ASC,
	[intJournalLineNo] ASC,
	[intEntityId] ASC
)
INCLUDE ( 	[strBatchId],
	[dblDebit],
	[dblCredit],
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],
	[strReference],
	[strJournalLineDescription],
	[strTransactionId],
	[intTransactionId],
	[strTransactionType],
	[strTransactionForm],
	[strModuleName],
	[dblDebitForeign],
	[dblCreditForeign]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

GO
CREATE STATISTICS [_dta_stat_424544746_18_20_2] ON [dbo].[tblGLDetail]([ysnIsUnposted], [intEntityId], [dtmDate])
GO
CREATE STATISTICS [_dta_stat_424544746_17_4_18_2_1_20] ON [dbo].[tblGLDetail]([intJournalLineNo], [intAccountId], [ysnIsUnposted], [dtmDate], [intGLDetailId], [intEntityId])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intGLDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Multi-Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intMultiCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strBatchId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Exchange Rate Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateTypeId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Entered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dtmDateEntered' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dtmTransactionDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strJournalLineDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intJournalLineNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Unposted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'ysnIsUnposted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Form' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strTransactionForm' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strModuleName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblDebitForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblDebitReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblCreditForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblCreditReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reporting Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblReportingRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblForeignRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reconciled Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intReconciledId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Reconciled' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dtmReconciled' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Reconciled?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'ysnReconciled' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'ysnRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Give the entity that was used in the source transaction qucikly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intSourceEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Location of the transaction for ease of reporting' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intSourceLocationId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit of measure from the source transaction and will allow us to long term eliminate the conversions in GL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intSourceUOMId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debits in the source transaction uom' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblSourceUnitDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credits in the source transaction UOM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'dblSourceUnitCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Future use - to easily identify commodity in the GL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'intCommodityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This is the enities document number for example it is the vendor invoice number on a voucher - a customer po number on an invoice.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strSourceDocumentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strDocument' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetail', @level2type=N'COLUMN',@level2name=N'strComments' 
GO