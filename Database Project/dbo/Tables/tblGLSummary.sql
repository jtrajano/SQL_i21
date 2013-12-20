CREATE TABLE [dbo].[tblGLSummary] (
    [intSummaryID]     INT             IDENTITY (1, 1) NOT NULL,
    [intAccountID]     INT             NULL,
    [dtmDate]          DATETIME        NULL,
    [dblDebit]         NUMERIC (18, 6) NULL,
    [dblCredit]        NUMERIC (18, 6) NULL,
    [dblDebitUnit]     NUMERIC (18, 6) NULL,
    [dblCreditUnit]    NUMERIC (18, 6) NULL,
    [strCode]          NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID] INT             NULL,
    CONSTRAINT [PK_tblGLSummary] PRIMARY KEY CLUSTERED ([intSummaryID] ASC),
    CONSTRAINT [FK_tblGLSummary_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID])
);

