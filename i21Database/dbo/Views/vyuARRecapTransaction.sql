CREATE VIEW [dbo].[vyuARRecapTransaction]
WITH SCHEMABINDING
AS

SELECT
A.dblCredit
,A.dblCreditUnit
,A.dblDebit
,A.dblDebitUnit
,A.dblExchangeRate
,A.dtmDate
,A.dtmDateEntered
,A.dtmTransactionDate
,A.intAccountId
,A.intConcurrencyId
,A.intCurrencyId
,A.intEntityId
,A.intGLDetailId
,A.intJournalLineNo
,A.intTransactionId
,A.intUserId
,A.strBatchId
,A.strCode
,A.strDescription
,A.strJournalLineDescription
,A.strModuleName
,A.strReference
,A.strTransactionForm
,A.strTransactionId
,A.strTransactionType
,A.ysnIsUnposted
,B.strAccountId
,C.strAccountGroup
FROM dbo.tblGLDetailRecap A
INNER JOIN dbo.tblGLAccount B 
	ON A.intAccountId = B.intAccountId
INNER JOIN dbo.tblGLAccountGroup C
	ON B.intAccountGroupId = C.intAccountGroupId

