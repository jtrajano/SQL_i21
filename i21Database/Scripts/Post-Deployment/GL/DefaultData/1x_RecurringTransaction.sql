GO

DELETE A FROM tblSMRecurringTransaction A LEFT JOIN 
tblGLJournal B ON A.intTransactionId = B.intJournalId
WHERE A.strTransactionType = 'General Journal' 
AND B.intJournalId IS NULL

GO