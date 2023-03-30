CREATE VIEW [dbo].[vyuGLAuditorTransaction]
AS
SELECT 
	A.intAuditorTransactionId
	,A.intType
	,A.intGeneratedBy
	,A.dtmDateGenerated
	,A.intEntityId
	,A.strGroupTitle
	,A.strTotalTitle
	,A.intAccountId
	,A.intTransactionId
	,A.strTransactionId
	,A.dtmDate
	,A.dblDebit
	,A.dblCredit
	,A.dblDebitForeign
	,A.dblCreditForeign
	,A.dblBeginningBalance
	,A.dblEndingBalance
	,A.dblBeginningBalanceForeign
	,A.dblEndingBalanceForeign
	,A.dblExchangeRate
	,A.intCurrencyId
	,A.strBatchId
	,A.dtmDateEntered
	,A.intCreatedBy
	,A.strCode
	,A.strTransactionType
	,A.strTransactionForm
	,A.strModuleName
	,A.strReference
	,A.strDocument
	,A.strComments
	,A.strPeriod
	,A.strDescription
	,A.dblSourceUnitDebit
	,A.dblSourceUnitCredit
	,A.dblDebitUnit
	,A.dblCreditUnit
	,A.dblDebitReport
	,A.dblCreditReport
	,A.strCommodityCode
	,A.strSourceDocumentId
	,A.strLocation
	,A.strCompanyLocation
	,A.strSourceUOMId
	,A.strJournalLineDescription
	,A.strUOMCode
	,A.intJournalId
	,A.strStatus
	,A.intSourceEntityId
	,A.strSourceEntity
	,A.strSourceEntityNo
	,A.dblTotal
	,A.dblTotalForeign
	,A.intConcurrencyId
	,A.strCurrency
	,A.strAccountId
	,A.strLOBSegmentDescription
	,A.strAccountDescription
	,AG.strAccountGroup
	,A.ysnGroupHeader
	,A.ysnGroupFooter
	,A.ysnSummary
	,A.ysnSummaryFooter
	,A.ysnSpace
	,CASE WHEN (A.strTotalTitle = 'Total') THEN '' ELSE A.strUserName END COLLATE Latin1_General_CI_AS strUserName
FROM tblGLAuditorTransaction A
LEFT JOIN tblGLAccount ACC ON ACC.intAccountId = A.intAccountId
LEFT JOIN tblGLAccountGroup AG ON AG.intAccountGroupId = ACC.intAccountGroupId


