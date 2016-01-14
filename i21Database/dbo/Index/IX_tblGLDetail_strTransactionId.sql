CREATE NONCLUSTERED INDEX [IX_tblGLDetail_strTransactionId] ON [dbo].[tblGLDetail]
(
	[strTransactionId] ASC
)
INCLUDE ( 	[dtmDate],
	[strBatchId],
	[intAccountId],
	[dblDebit],
	[dblCredit],
	[intJournalLineNo],
	[ysnIsUnposted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO