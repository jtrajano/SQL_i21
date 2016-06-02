CREATE NONCLUSTERED INDEX IX_tblGLJournal_strJournalId_strTransactionType
ON [dbo].[tblGLJournal] ([strJournalId],[strTransactionType])
INCLUDE ([intJournalId],[dtmReverseDate],[intCurrencyId],[dtmPosted],[strDescription],[ysnPosted],[dtmDateEntered],[intEntityId],[strJournalType],[strSourceType])
GO
