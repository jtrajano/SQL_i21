CREATE TABLE [dbo].[tblGLJournalDetail] (
    [intJournalDetailId] INT             IDENTITY (1, 1) NOT NULL,
	[intCompanyId]		 INT			 NULL,
    [intLineNo]          INT             NULL,
    [intJournalId]       INT             NOT NULL,
    [dtmDate]            DATETIME        NULL,
    [intAccountId]       INT             NULL,
    [dblDebit]           NUMERIC (18, 6) NULL,
    [dblDebitRate]       NUMERIC (18, 6) NULL,
    [dblCredit]          NUMERIC (18, 6) NULL,
    [dblCreditRate]      NUMERIC (18, 6) NULL,
    [dblDebitUnit]       NUMERIC (18, 6) NULL,
    [dblCreditUnit]      NUMERIC (18, 6) NULL,
    [strDescription]     NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]   INT             DEFAULT 1 NOT NULL,
    [dblUnitsInLBS]      NUMERIC (18, 6) NULL,
    [strDocument]        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strComments]        NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblDebitUnitsInLBS] NUMERIC (18, 6) NULL,
    [strCorrecting]      NVARCHAR (1)    COLLATE Latin1_General_CI_AS NULL,
    [strSourcePgm]       NVARCHAR (8)    COLLATE Latin1_General_CI_AS NULL,
    [strCheckBookNo]     NVARCHAR (2)    COLLATE Latin1_General_CI_AS NULL,
    [strWorkArea]        NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [strSourceKey]		 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblDebitForeign]	 NUMERIC(18, 9) NULL, 
    [dblDebitReport]	 NUMERIC(18, 9) NULL, 
	[dblCreditForeign]	 NUMERIC(18, 9) NULL, 
    [dblCreditReport]	 NUMERIC(18, 9) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
    CONSTRAINT [PK_tblGLJournalDetail] PRIMARY KEY CLUSTERED ([intJournalDetailId] ASC),
    CONSTRAINT [FK_tblGLJournalDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLJournalDetail_tblGLJournal] FOREIGN KEY ([intJournalId]) REFERENCES [dbo].[tblGLJournal] ([intJournalId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGLJournalDetail_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intJournalDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Line No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intLineNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebitRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblCreditRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Units In lbs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblUnitsInLBS' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strDocument' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strComments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Units In lbs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebitUnitsInLBS' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correcting' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strCorrecting' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Pgm' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strSourcePgm' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check Book No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strCheckBookNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Area' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strWorkArea' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'strSourceKey' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebitForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblDebitReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblCreditForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'dblCreditReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Exchange Rate Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalDetail', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateTypeId' 
GO
