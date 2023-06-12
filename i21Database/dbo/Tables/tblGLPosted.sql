CREATE TABLE [dbo].[tblGLPosted]
(
	[intPostedId]			INT             IDENTITY (1, 1) NOT NULL,
	[intAccountId]			INT             NOT NULL,
	[dtmDate]				DATETIME		NOT NULL,
	[dblDebit]				NUMERIC(20, 6)	NULL,
	[dblCredit]				NUMERIC(20, 6)	NULL,
	[dblDebitForeign]		NUMERIC(20, 6)	NULL,
	[dblCreditForeign]		NUMERIC(20, 6)	NULL,
	[dblDebitUnit]			NUMERIC(20, 6)	NULL,
	[dblCreditUnit]			NUMERIC(20, 6)	NULL,
	[strCode]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId]			INT             NOT NULL DEFAULT 0,
	[intConcurrencyId]		INT             NOT NULL,
	[intLedgerId]			INT             NOT NULL DEFAULT 0,
	[intSubledgerId]		INT             NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblGLPosted] PRIMARY KEY CLUSTERED ([intAccountId] ASC,[dtmDate] ASC,[intCurrencyId] ASC,[strCode] ASC,[intLedgerId] ASC,[intSubledgerId] ASC),
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGLPosted_intAccountId_strCode_intCurrencyId_dtmDate]
    ON [dbo].[tblGLPosted]([intAccountId] ASC, [strCode] ASC, [intCurrencyId] ASC, [dtmDate] ASC)
    INCLUDE (dblDebit, dblCredit, dblDebitUnit, dblCreditUnit, dblDebitForeign, dblCreditForeign);
GO