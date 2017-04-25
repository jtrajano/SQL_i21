CREATE TABLE [dbo].[tblGLDetail] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
	[intCompanyId]				INT				 NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NULL,
    [dblDebit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebit]  DEFAULT ((0)),
    [dblCredit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCredit]  DEFAULT ((0)),
    [dblDebitUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebitUnit]  DEFAULT ((0)),
    [dblCreditUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCreditUnit]  DEFAULT ((0)),
    [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
    [strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]             INT              NULL,
    [dblExchangeRate]           NUMERIC (38, 20) NOT NULL,
    [dtmDateEntered]            DATETIME         NOT NULL,
    [dtmTransactionDate]        DATETIME         NULL,
    [strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
    [ysnIsUnposted]             BIT              NOT NULL,    
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
	[ysnExported] BIT NULL,
	[dtmExportedDate] DATETIME NULL,
    CONSTRAINT [PK_tblGL] PRIMARY KEY CLUSTERED ([intGLDetailId] ASC),
    CONSTRAINT [FK_tblGL_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);
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

