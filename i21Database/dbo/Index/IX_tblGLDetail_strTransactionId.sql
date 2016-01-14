CREATE NONCLUSTERED INDEX IX_tblGLDetail_strTransactionId
ON [dbo].[tblGLDetail] ([strTransactionId])
INCLUDE ([dtmDate],[strBatchId],[intAccountId],[dblDebit],[dblCredit],[intJournalLineNo],[ysnIsUnposted])
GO