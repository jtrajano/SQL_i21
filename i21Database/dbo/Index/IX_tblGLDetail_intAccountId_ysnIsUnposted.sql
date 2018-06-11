CREATE NONCLUSTERED INDEX [IX_tblGLDetail_intAccountId_ysnIsUnposted] ON [dbo].[tblGLDetail] 
(
	[intAccountId] ASC,
	[ysnIsUnposted] ASC
)
INCLUDE ( [intGLDetailId],
[dtmDate],
[strBatchId],
[dblDebit],
[dblCredit],
[dblDebitUnit],
[dblCreditUnit],
[strDescription],
[strCode],
[strReference],
[intJournalLineNo],
[strTransactionId],
[intTransactionId],
[strTransactionType],
[strTransactionForm],
[strModuleName]) WITH ( STATISTICS_NORECOMPUTE  = OFF,   IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO