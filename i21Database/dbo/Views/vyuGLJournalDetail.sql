CREATE VIEW [dbo].[vyuGLJournalDetail]
       AS

       SELECT
       A.intJournalId
       ,A.dtmReverseDate
       ,A.strJournalId COLLATE Latin1_General_CI_AS strJournalId
       ,A.strTransactionType COLLATE Latin1_General_CI_AS strTransactionType
       ,A.dtmDate
       ,A.strReverseLink COLLATE Latin1_General_CI_AS strReverseLink
       ,ISNULL(DC.intCurrencyID, ISNULL(S.intCurrencyID, A.intCurrencyId)) intCurrencyId
       ,A.dblExchangeRate
       ,A.dtmPosted
       ,A.strDescription COLLATE Latin1_General_CI_AS AS strHeaderDescription
       ,A.ysnPosted
       ,A.intConcurrencyId
       ,A.dtmDateEntered
       ,A.intUserId
       ,A.intEntityId
       ,A.strSourceId COLLATE Latin1_General_CI_AS strSourceId
       ,A.strJournalType COLLATE Latin1_General_CI_AS strJournalType
       ,A.strRecurringStatus COLLATE Latin1_General_CI_AS strRecurringStatus
       ,A.strSourceType COLLATE Latin1_General_CI_AS strSourceType
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
       ,B.strDescription COLLATE Latin1_General_CI_AS AS strTransactionDescription
       ,B.dblUnitsInLBS
       ,B.strDocument COLLATE Latin1_General_CI_AS strDocument
       ,B.strComments COLLATE Latin1_General_CI_AS strComments
       ,B.strReference COLLATE Latin1_General_CI_AS strReference
       ,B.dblDebitUnitsInLBS
       ,B.strCorrecting COLLATE Latin1_General_CI_AS strCorrecting
       ,B.strSourcePgm COLLATE Latin1_General_CI_AS strSourcePgm
       ,B.strCheckBookNo COLLATE Latin1_General_CI_AS strCheckBookNo
       ,B.strWorkArea COLLATE Latin1_General_CI_AS strWorkArea
       ,B.strSourceKey COLLATE Latin1_General_CI_AS strSourceKey
       ,B.dblDebitForeign
       ,B.dblDebitReport
       ,B.dblCreditForeign
       ,B.dblCreditReport
       ,C.strAccountId COLLATE Latin1_General_CI_AS strAccountId
       ,C.intAccountId
       ,C.strDescription COLLATE Latin1_General_CI_AS AS strAccountDescription
       ,ISNULL(DC.strCurrency, S.strCurrency) COLLATE Latin1_General_CI_AS strCurrency

       FROM tblGLJournal A
       INNER JOIN tblGLJournalDetail B
       ON A.intJournalId = B.intJournalId

       INNER JOIN tblGLAccount C
       on C.intAccountId = B.intAccountId
       LEFT JOIN tblSMCurrency S
       ON C.intCurrencyID = S.intCurrencyID
       LEFT JOIN tblSMCurrency DC
       ON DC.intCurrencyID = B.intCurrencyId