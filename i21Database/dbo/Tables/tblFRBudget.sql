﻿CREATE TABLE [dbo].[tblFRBudget] (
    [intBudgetId]       INT             IDENTITY (1, 1) NOT NULL,
    [intBudgetCode]     INT             NOT NULL,
    [strPeriod]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmStartDate]      DATETIME        NULL,
    [intFiscalYearId]   INT             NOT NULL,
    [intAccountId]      INT             NOT NULL,
    [intAccountGroupId] INT             NULL,
    [curActual]         NUMERIC (18, 6) NULL,
    [intSort]           INT             NULL,
    [dtmEndDate]        DATETIME        NULL,
    [curThisYear]       NUMERIC (18, 6) NULL,
    [dtmDate]           DATETIME        NOT NULL,
    [curLastYear]       NUMERIC (18, 6) NULL,
    [curBudget]         NUMERIC (18, 6) NULL,
    [curOperPlan]       NUMERIC (18, 6) NULL,
	[ysnSelect]         BIT             NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,    
    CONSTRAINT [PK_tblFRBudget] PRIMARY KEY CLUSTERED ([intBudgetId] ASC),
    CONSTRAINT [FK_tblFRBudget_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblFRBudget_tblFRBudgetCode] FOREIGN KEY ([intBudgetCode]) REFERENCES [dbo].[tblFRBudgetCode] ([intBudgetCode]),
    CONSTRAINT [FK_tblFRBudget_tblGLFiscalYear] FOREIGN KEY ([intFiscalYearId]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearId])
);

