CREATE FUNCTION fnGLGetAccountCurrencyReportExpRev(@intDefaultCurrencyId INT, @intAccountId INT)
RETURNS TABLE
AS

RETURN
(

WITH cteAccountCurrency AS(
SELECT 
C.intCurrencyID,
C.strCurrency,
A.intAccountId,
F.strFiscalYear
FROM tblGLAccount A ,
tblSMCurrency C,
tblGLFiscalYear F

),
GLQuery as(
select * from cteAccountCurrency C 
outer apply(
	select 
	intGLDetailId
	,A.dblDebit
	,A.dblCredit
	,A.dblCreditForeign
	,A.dblCreditReport
	,A.dtmDate
	,A.strBatchId
	,A.strAccountId
	,A.strAccountDescription
	,A.strAccountGroup
	,A.strAccountType
	,A.dblDebitUnit
	,A.dblCreditUnit
	,A.strDescription
	,A.strCode
	,A.strReference
	,A.dblExchangeRate
	,A.dtmDateEntered
	,A.dtmTransactionDate
	,A.strJournalLineDescription
	,A.strStatus
	,A.strUserName
	,A.strTransactionId
	,A.strTransactionType
	,A.strTransactionForm
	,A.strModuleName
	,A.dblDebitForeign
	,A.dblDebitReport
	,A.dblReportingRate
	,A.dblForeignRate
	,A.intJournalLineNo
	,A.strDocument
	,A.ysnIsUnposted
	,A.intTransactionId
	,A.intEntityId
	,A.strComments
	,A.strUOMCode
	,A.strLocationName
	,A.strSourceUOMId
	,A.strCommodityCode
	,A.dblSourceUnitDebit
	,A.dblSourceUnitCredit
	,A.strSourceEntity
	,A.strSourceDocumentId
	,A.strSourceEntityNo
	,A.intSourceEntityId
	,A.ysnPostAction
	,A.dtmDateEnteredMin
	,A.strPeriod
	,A.strCompanyLocation
	,A.strCurrencyExchangeRateType
	,A.strLocationSegmentDescription
	,A.strLOBSegmentDescription
	,(dblDebit - dblCredit) dblAmount 
    ,case when isnull(C.intCurrencyID,@intDefaultCurrencyId) <> @intDefaultCurrencyId 
        then (dblDebitForeign - dblCreditForeign) else 0 end dblAmountForeign
	from vyuGLDetail A where intAccountId = C.intAccountId and intCurrencyID = C.intCurrencyID
	and ysnIsUnposted = 0
)GL


where C.intAccountId = 53 and strFiscalYear = '2022'
--order by C.intAccountId, intCurrencyID, intGLDetailId
),
cteRunningBalance AS(
        select  sum(dblAmount) over (partition by intAccountId, strFiscalYear order by strFiscalYear,intCurrencyID,dtmDate,intTransactionId, intGLDetailId ) functionalRunningBalance,
		sum(dblAmountForeign) over (partition by intAccountId,strFiscalYear, intCurrencyID order by strFiscalYear, intCurrencyID,dtmDate,intTransactionId, intGLDetailId ) foreignRunningBalance,
		*
		from GLQuery
),
cteOpeningBalance AS(

	SELECT 
	strCurrency
	, strFiscalYear
	,strAccountId
	,functionalRunningBalance - dblAmount dblFunctionalOpeningBalance
	,dblAmount
	,functionalRunningBalance
	,dblDebit, dblCredit
	,foreignRunningBalance - dblAmountForeign dblForeignOpeningBalance
	,dblAmountForeign
	,foreignRunningBalance
	,dblDebitForeign
	,dblCreditForeign
	,intGLDetailId
	,dblCreditReport
	,dtmDate
	,strBatchId
	,strAccountDescription
	,strAccountGroup
	,strAccountType
	,dblDebitUnit
	,dblCreditUnit
	,strDescription
	,strCode
	,strReference
	,dblExchangeRate
	,dtmDateEntered
	,dtmTransactionDate
	,strJournalLineDescription
	,strStatus
	,strUserName
	,strTransactionId
	,strTransactionType
	,strTransactionForm
	,strModuleName
	,dblDebitReport
	,dblReportingRate
	,dblForeignRate
	,intJournalLineNo
	,strDocument
	,ysnIsUnposted
	,intTransactionId
	,intEntityId
	,strComments
	,strUOMCode
	,strLocationName
	,strSourceUOMId
	,strCommodityCode
	,dblSourceUnitDebit
	,dblSourceUnitCredit
	,strSourceEntity
	,strSourceDocumentId
	,strSourceEntityNo
	,intSourceEntityId
	,ysnPostAction
	,dtmDateEnteredMin
	,strPeriod
	,strCompanyLocation
	,strCurrencyExchangeRateType
	,strLocationSegmentDescription
	,strLOBSegmentDescription
	FROM cteRunningBalance
)

select * from cteOpeningBalance
)