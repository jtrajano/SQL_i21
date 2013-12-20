CREATE TABLE [dbo].[tblGLFiscalYearPeriod] (
    [intGLFiscalYearPeriodID] INT           IDENTITY (1, 1) NOT NULL,
    [intFiscalYearID]         INT           NOT NULL,
    [strPeriod]               NVARCHAR (30) COLLATE Latin1_General_CI_AS NULL,
    [dtmStartDate]            DATETIME      CONSTRAINT [DF__tblGLPeri__dtmSt__3F6663D5] DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/01/01',(0))) NOT NULL,
    [dtmEndDate]              DATETIME      CONSTRAINT [DF__tblGLPeri__dtmEn__405A880E] DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/12/31',(0))) NOT NULL,
    [ysnOpen]                 BIT           CONSTRAINT [DF__tblGLPeri__ysnOp__414EAC47] DEFAULT ((1)) NOT NULL,
    [intConcurrencyID]        INT           CONSTRAINT [DF__tblGLPeri__intCo__4242D080] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLPeriod] PRIMARY KEY CLUSTERED ([intGLFiscalYearPeriodID] ASC, [intFiscalYearID] ASC),
    CONSTRAINT [FK_tblGLPeriod_tblGLFiscalYearPeriod] FOREIGN KEY ([intFiscalYearID]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearID])
);

