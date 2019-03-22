CREATE TABLE [dbo].[tblGLSummary] (
    [intSummaryId]     INT             IDENTITY (1, 1) NOT NULL,
	[intMultiCompanyId]	   INT			   NULL,
    [intAccountId]     INT             NULL,
    [dtmDate]          DATETIME        NULL,
    [dblDebit]         NUMERIC (20, 6) NULL,
    [dblCredit]        NUMERIC (20, 6) NULL,
	[dblDebitForeign]        NUMERIC (20, 6) NULL,
	[dblCreditForeign]        NUMERIC (20, 6) NULL,
    [dblDebitUnit]     NUMERIC (20, 6) NULL,
    [dblCreditUnit]    NUMERIC (20, 6) NULL,
    [strCode]          NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLSummary] PRIMARY KEY CLUSTERED ([intSummaryId] ASC),
    CONSTRAINT [FK_tblGLSummary_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLSummary_intAccountId_dtmDate_strCode]
    ON [dbo].[tblGLSummary]([intAccountId] ASC, [dtmDate] ASC, [strCode] ASC)
    INCLUDE (dblDebit, dblCredit, dblDebitUnit, dblCreditUnit);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'intSummaryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Multi-Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'intMultiCompanyId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblDebitForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblCreditForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSummary', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO