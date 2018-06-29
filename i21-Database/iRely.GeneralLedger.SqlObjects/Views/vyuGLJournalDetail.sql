CREATE VIEW [dbo].[vyuGLJournalDetail]
       AS

       SELECT
       A.intJournalId
       ,A.dtmReverseDate
       ,A.strJournalId
       ,A.strTransactionType
       ,A.dtmDate
       ,A.strReverseLink
       ,A.intCurrencyId
       ,A.dblExchangeRate
       ,A.dtmPosted
       ,A.strDescription AS strHeaderDescription
       ,A.ysnPosted
       ,A.intConcurrencyId
       ,A.dtmDateEntered
       ,A.intUserId
       ,A.intEntityId
       ,A.strSourceId
       ,A.strJournalType
       ,A.strRecurringStatus
       ,A.strSourceType
       ,A.intFiscalYearId
       ,A.intFiscalPeriodId
       ,A.intJournalIdToReverse
       ,A.ysnReversed
       ,B.intJournalDetailId
       ,B.dtmDate AS dtmDocDate
       ,B.dblDebit
       ,B.dblDebitRate
       ,B.dblCredit
       ,B.dblCreditRate
       ,B.dblDebitUnit
       ,B.dblCreditUnit
       ,B.strDescription AS strTransactionDescription
       ,B.dblUnitsInLBS
       ,B.strDocument
       ,B.strComments
       ,B.strReference
       ,B.dblDebitUnitsInLBS
       ,B.strCorrecting
       ,B.strSourcePgm
       ,B.strCheckBookNo
       ,B.strWorkArea
       ,B.strSourceKey
       ,B.dblDebitForeign
       ,B.dblDebitReport
       ,B.dblCreditForeign
       ,B.dblCreditReport
       ,C.strAccountId
       ,C.intAccountId
       ,C.strDescription AS strAccountDescription
       ,S.strCurrency

       FROM tblGLJournal A
       INNER JOIN tblGLJournalDetail B
       ON A.intJournalId = B.intJournalId

       INNER JOIN tblGLAccount C
       on C.intAccountId = B.intAccountId
       LEFT JOIN tblSMCurrency S
       ON C.intCurrencyID = S.intCurrencyID





