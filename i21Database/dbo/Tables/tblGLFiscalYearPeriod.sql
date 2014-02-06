CREATE TABLE [dbo].[tblGLFiscalYearPeriod] (
    [intGLFiscalYearPeriodID] INT           IDENTITY (1, 1) NOT NULL,
    [intFiscalYearID]         INT           NOT NULL,
    [strPeriod]               NVARCHAR (30) COLLATE Latin1_General_CI_AS NULL,
    [dtmStartDate]            DATETIME      DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/01/01',(0))) NOT NULL,
    [dtmEndDate]              DATETIME      DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/12/31',(0))) NOT NULL,
    [ysnOpen]                 BIT           DEFAULT 1 NOT NULL,
    [intConcurrencyId]        INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLPeriod] PRIMARY KEY CLUSTERED ([intGLFiscalYearPeriodID] ASC, [intFiscalYearID] ASC),
    CONSTRAINT [FK_tblGLPeriod_tblGLFiscalYearPeriod] FOREIGN KEY ([intFiscalYearID]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearID])
);

