CREATE TABLE [dbo].[tblGLFiscalYear] (
    [intFiscalYearID]  INT           IDENTITY (1, 1) NOT NULL,
    [strFiscalYear]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intRetainAccount] INT           NULL,
    [dtmDateFrom]      DATETIME      NULL,
    [dtmDateTo]        DATETIME      NULL,
    [ysnStatus]        BIT           CONSTRAINT [DF__tblGLFisc__ysnSt__4BCC3ABA] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId] INT           CONSTRAINT [DF__tblGLFisc__intCo__4CC05EF3] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLFiscalYearPeriod_1] PRIMARY KEY CLUSTERED ([intFiscalYearID] ASC)
);

