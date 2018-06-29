CREATE NONCLUSTERED INDEX [IX_tblGLDetail_dtmDate] ON [dbo].[tblGLDetail] 
(
	[dtmDate] ASC
)
INCLUDE ( [intGLDetailId],
[strBatchId],
[intAccountId],
[dblDebit],
[dblCredit],
[dblDebitUnit],
[dblCreditUnit],
[strDescription],
[strCode],
[strReference],
[intCurrencyId],
[dblExchangeRate],
[dtmDateEntered],
[dtmTransactionDate],
[strJournalLineDescription],
[intJournalLineNo],
[ysnIsUnposted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
