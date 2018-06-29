CREATE NONCLUSTERED INDEX IX_tblGLJournal_strSourceType
ON [dbo].[tblGLJournal] ([strSourceType])
INCLUDE ([intJournalId],[strJournalId])