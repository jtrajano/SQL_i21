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
[strModuleName]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO