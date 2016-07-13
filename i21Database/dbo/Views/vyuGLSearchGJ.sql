CREATE VIEW [dbo].[vyuGLSearchGJ]
AS
WITH total AS
  (SELECT  j.strJournalId,
          sum(d.dblCredit) dblCredit,
          sum(d.dblDebit) dblDebit
   FROM tblGLJournal j
   JOIN tblGLJournalDetail d ON j.intJournalId = d.intJournalId
   GROUP BY j.strJournalId)
     
   SELECT strJournalType,
           strTransactionType,
           strSourceType,
           j.strJournalId,
           j.strDescription,
           j.intJournalId,
           ysnPosted,
           dtmDate,
           dtmReverseDate,
           dtmDateEntered,
           e.strName strUserName,
           t.dblCredit,
           t.dblDebit,
		   strCurrency
   FROM tblGLJournal j
   JOIN total t ON j.strJournalId = t.strJournalId
   LEFT JOIN tblEMEntity e ON e.intEntityId = j.intEntityId
   LEFT JOIN tblSMCurrency C ON C.intCurrencyID = j.intCurrencyId
