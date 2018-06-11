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
[ysnIsUnposted]) WITH ( STATISTICS_NORECOMPUTE  = OFF,   IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
