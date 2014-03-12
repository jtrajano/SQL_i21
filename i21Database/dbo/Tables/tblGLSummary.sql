CREATE TABLE [dbo].[tblGLSummary] (
    [intSummaryId]     INT             IDENTITY (1, 1) NOT NULL,
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

