CREATE TABLE [dbo].[tblGLFiscalYearPeriod] (
    [intGLFiscalYearPeriodId]	INT				IDENTITY (1, 1) NOT NULL,
    [intFiscalYearId]			INT				NOT NULL,
    [strPeriod]					NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL,
    [dtmStartDate]				DATETIME		DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/01/01',(0))) NULL,
    [dtmEndDate]				DATETIME		DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/12/31',(0))) NULL,
    [ysnOpen]					BIT				DEFAULT 1 NULL,
	[ysnAPOpen]					BIT				DEFAULT 1 NULL,
	[ysnAROpen]					BIT				DEFAULT 1 NULL,
	[ysnINVOpen]				BIT				DEFAULT 1 NULL,
	[ysnCMOpen]					BIT				DEFAULT 1 NULL,
	[ysnCTOpen]					BIT				DEFAULT 1 NULL,
	[ysnFAOpen]					BIT				DEFAULT 1 NULL, 
	[ysnPROpen]					BIT				DEFAULT 1 NULL,
	[ysnAPRevalued]				BIT				DEFAULT 0 NULL,
	[ysnARRevalued]				BIT				DEFAULT 0 NULL,
	[ysnINVRevalued]			BIT				DEFAULT 0 NULL,
	[ysnCTRevalued]				BIT				DEFAULT 0 NULL,
    [ysnCMRevalued]				BIT				DEFAULT 0 NULL,
	[ysnConsolidated]			BIT				DEFAULT 0 NULL,
    [intConcurrencyId]			INT				DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLPeriod] PRIMARY KEY CLUSTERED ([intGLFiscalYearPeriodId] ASC, [intFiscalYearId] ASC),
    CONSTRAINT [FK_tblGLPeriod_tblGLFiscalYearPeriod] FOREIGN KEY ([intFiscalYearId]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearId]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLFiscalYearPeriod_intFiscalYearId]
    ON [dbo].[tblGLFiscalYearPeriod](intFiscalYearId ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblGLFiscalYearPeriod_ysnOpen]
    ON [dbo].[tblGLFiscalYearPeriod]([ysnOpen] ASC)
	INCLUDE ([dtmStartDate], [dtmEndDate])
GO

CREATE NONCLUSTERED INDEX [IX_tblGLFiscalYearPeriod_dtmStartDate]
    ON [dbo].[tblGLFiscalYearPeriod]([dtmStartDate] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblGLFiscalYearPeriod_dtmEndDate]
    ON [dbo].[tblGLFiscalYearPeriod]([dtmEndDate] ASC)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'intGLFiscalYearPeriodId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'strPeriod' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Start Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'dtmStartDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'dtmEndDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Accounts Payable Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnAPOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Accounts Receivable Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnAROpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Inventory Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnINVOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Cash Management Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnCMOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Contract Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnCTOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Fixed Assets Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnFAOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Payroll Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnPROpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Accounts Payable Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnAPRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Accounts Receivable Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnARRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Inventory Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnINVRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Contract Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnCTRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Consolidated?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'ysnConsolidated' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYearPeriod', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO