CREATE NONCLUSTERED INDEX [IX_tblGLDetail_strBatchId] ON [dbo].[tblGLDetail] ([strBatchId])
INCLUDE ([dtmDateEntered])
GO