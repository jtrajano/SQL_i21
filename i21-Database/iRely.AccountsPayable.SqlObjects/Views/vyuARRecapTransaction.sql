CREATE VIEW [dbo].[vyuARRecapTransaction]
WITH SCHEMABINDING
AS 

SELECT
	 ISNULL(A.dblCredit,0.00)			AS 'dblCredit'
	,ISNULL(A.dblCreditUnit,0.00)		AS 'dblCreditUnit'
	,ISNULL(A.dblDebit,0.00)			AS 'dblDebit'
	,ISNULL(A.dblDebitUnit,0.00)		AS 'dblDebitUnit'
	,ISNULL(A.dblExchangeRate,0.00)		AS 'dblExchangeRate'
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
	,B.strDescription
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
