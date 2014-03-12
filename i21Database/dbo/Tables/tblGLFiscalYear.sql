CREATE TABLE [dbo].[tblGLFiscalYear] (
    [intFiscalYearId]  INT           IDENTITY (1, 1) NOT NULL,
    [strFiscalYear]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intRetainAccount] INT           NULL,
    [dtmDateFrom]      DATETIME      NULL,
    [dtmDateTo]        DATETIME      NULL,
    [ysnStatus]        BIT           DEFAULT 1 NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLFiscalYearPeriod_1] PRIMARY KEY CLUSTERED ([intFiscalYearId] ASC)
);

