CREATE NONCLUSTERED INDEX [IX_tblGLJournalDetail_intJournalId] ON [dbo].[tblGLJournalDetail] 
(
	[intJournalId] ASC
)
INCLUDE ( [strComments]) WITH ( STATISTICS_NORECOMPUTE  = OFF,   IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO