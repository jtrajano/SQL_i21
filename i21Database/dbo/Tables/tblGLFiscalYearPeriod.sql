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