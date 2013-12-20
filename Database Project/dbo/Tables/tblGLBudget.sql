CREATE TABLE [dbo].[tblGLBudget] (
    [intBudgetID]       INT             IDENTITY (1, 1) NOT NULL,
    [intBudgetCode]     INT             NOT NULL,
    [strPeriod]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmStartDate]      DATETIME        NULL,
    [intFiscalYearID]   INT             NOT NULL,
    [intAccountID]      INT             NOT NULL,
    [intAccountGroupID] INT             NULL,
    [curActual]         NUMERIC (18, 6) NULL,
    [intSort]           INT             NULL,
    [dtmEndDate]        DATETIME        NULL,
    [curThisYear]       NUMERIC (18, 6) NULL,
    [dtmDate]           DATETIME        NOT NULL,
    [curLastYear]       NUMERIC (18, 6) NULL,
    [curBudget]         NUMERIC (18, 6) NULL,
    [curOperPlan]       NUMERIC (18, 6) NULL,
    [intConcurrencyID]  INT             NULL,
    [ysnSelect]         BIT             NULL,
    CONSTRAINT [PK_tblGLBudget] PRIMARY KEY CLUSTERED ([intBudgetID] ASC),
    CONSTRAINT [FK_tblGLBudget_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLBudget_tblGLBudgetCode] FOREIGN KEY ([intBudgetCode]) REFERENCES [dbo].[tblGLBudgetCode] ([intBudgetCode]),
    CONSTRAINT [FK_tblGLBudget_tblGLFiscalYear] FOREIGN KEY ([intFiscalYearID]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearID])
);

