﻿CREATE TABLE [dbo].[tblGLSummary] (
    [intSummaryId]     INT             IDENTITY (1, 1) NOT NULL,
	[intCompanyId]	   INT			   NULL,
    [intAccountId]     INT             NULL,
    [dtmDate]          DATETIME        NULL,
    [dblDebit]         NUMERIC (18, 6) NULL,
    [dblCredit]        NUMERIC (18, 6) NULL,
    [dblDebitUnit]     NUMERIC (18, 6) NULL,
    [dblCreditUnit]    NUMERIC (18, 6) NULL,
    [strCode]          NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLSummary] PRIMARY KEY CLUSTERED ([intSummaryId] ASC),
    CONSTRAINT [FK_tblGLSummary_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLSummary_intAccountId_dtmDate_strCode]
    ON [dbo].[tblGLSummary]([intAccountId] ASC, [dtmDate] ASC, [strCode] ASC)
    INCLUDE (dblDebit, dblCredit, dblDebitUnit, dblCreditUnit);
GO