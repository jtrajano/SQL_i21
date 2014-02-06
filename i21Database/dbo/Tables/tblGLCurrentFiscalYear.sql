CREATE TABLE [dbo].[tblGLCurrentFiscalYear] (
    [cntID]             INT             IDENTITY (1, 1) NOT NULL,
    [intFiscalYearID]   INT             NOT NULL,
    [dtmBeginDate]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [dtmEndDate]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [dblPeriods]        NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [ysnShowAllPeriods] BIT             DEFAULT ((0)) NOT NULL,
    [ysnDuplicates]     BIT             NOT NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLFiscalYear] PRIMARY KEY CLUSTERED ([cntID] ASC)
);

