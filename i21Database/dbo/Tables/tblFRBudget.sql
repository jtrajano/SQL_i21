﻿CREATE TABLE [dbo].[tblFRBudget] (
    [intBudgetId]       INT             IDENTITY (1, 1) NOT NULL,
    [intBudgetCode]     INT             NOT NULL,
	[intAccountId]		INT             NOT NULL,
	[dblBudget1]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget2]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget3]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget4]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget5]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget6]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget7]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget8]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget9]        NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget10]       NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget11]       NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget12]       NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblBudget13]       NUMERIC (18, 6) DEFAULT 0 NULL,
	[intPeriod1]		INT             NULL,
	[intPeriod2]		INT             NULL,
	[intPeriod3]		INT             NULL,
	[intPeriod4]		INT             NULL,
	[intPeriod5]		INT             NULL,
	[intPeriod6]		INT             NULL,
	[intPeriod7]		INT             NULL,
	[intPeriod8]		INT             NULL,
	[intPeriod9]		INT             NULL,
	[intPeriod10]		INT             NULL,
	[intPeriod11]		INT             NULL,
	[intPeriod12]		INT             NULL,
	[intPeriod13]		INT             NULL,
	[dtmDate]           DATETIME        DEFAULT GETDATE() NULL,
	[intConcurrencyId]  INT             DEFAULT 1 NOT NULL,    

    CONSTRAINT [PK_tblFRBudget] PRIMARY KEY CLUSTERED ([intBudgetId] ASC),
    CONSTRAINT [FK_tblFRBudget_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblFRBudget_tblFRBudgetCode] FOREIGN KEY ([intBudgetCode]) REFERENCES [dbo].[tblFRBudgetCode] ([intBudgetCode]),
);

