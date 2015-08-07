CREATE VIEW [dbo].[vyuGLJournalDetail]
AS

select 
A.intJournalId
,A.dtmReverseDate
,A.strJournalId
,A.strTransactionType
,A.dtmDate
,A.strReverseLink
,A.intCurrencyId
,A.dblExchangeRate
,A.dtmPosted
,A.strDescription as strHeaderDescription
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
,B.dtmDate as dtmDocDate
,B.dblDebit
,B.dblDebitRate
,B.dblCredit
,B.dblCreditRate
,B.dblDebitUnit
,B.dblCreditUnit
,B.strDescription as strTransactionDescription
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
,B.strOriginTable
,C.strAccountId
from tblGLJournal A
inner join tblGLJournalDetail B
on A.intJournalId = B.intJournalId

inner join tblGLAccount C
on C.intAccountId = B.intAccountId





