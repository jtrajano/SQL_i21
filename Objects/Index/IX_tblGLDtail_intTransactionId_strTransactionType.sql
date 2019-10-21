CREATE NONCLUSTERED INDEX IX_tblGLDtail_intTransactionId_strTransactionType
ON [dbo].[tblGLDetail] ([intTransactionId],[strTransactionType])
INCLUDE ([strBatchId])
GO