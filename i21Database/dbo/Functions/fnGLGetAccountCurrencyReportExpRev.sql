CREATE FUNCTION fnGLGetAccountCurrencyReportExpRev(@intDefaultCurrencyId INT)
RETURNS TABLE
AS

RETURN
(

WITH cteAccountCurrency AS(
SELECT 
C.intCurrencyID,
C.strCurrency,
A.intAccountId,
F.strFiscalYear,
A.strAccountId,
F.dtmDateFrom,
F.dtmDateTo
FROM vyuGLAccountDetail A ,
tblSMCurrency C,
tblGLFiscalYear F
where strAccountType IN('Revenue','Expense')

),
GLQuery as(
select * from cteAccountCurrency C 
cross apply(
	select 
	intGLDetailId
	,A.dblDebit
	,A.dblCredit
	,A.dblCreditForeign
	,A.dblCreditReport
	,A.dtmDate
	,A.strBatchId
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
	from vyuGLDetail A where intAccountId = C.intAccountId and A.intCurrencyId = C.intCurrencyID
    AND dtmDate between C.dtmDateFrom and C.dtmDateTo
	and ysnIsUnposted = 0
)GL
),
cteRunningBalance AS(
        select  sum(dblAmount) over (partition by intAccountId, strFiscalYear order by intCurrencyID, dtmDate, intGLDetailId ) functionalRunningBalance,
		sum(dblAmountForeign) over (partition by intAccountId,strFiscalYear, intCurrencyID order by intCurrencyID,dtmDate, intGLDetailId ) foreignRunningBalance,
		*
		from GLQuery
),
cteOpeningBalance AS(

	SELECT 
    intGLDetailId
	,strCurrency
	,strAccountId
	,functionalRunningBalance - dblAmount dblBeginningBalance
	,functionalRunningBalance dblEndingBalance
	,dblDebit, dblCredit
	,foreignRunningBalance - dblAmountForeign dblBeginningBalanceForeign
	,foreignRunningBalance dblEndingBalanceForeign
	,dblDebitForeign
	,dblCreditForeign
    ,intEntityId
    ,strBatchId
    ,intAccountId
    ,strTransactionId
    ,dtmDate
    ,dtmDateEntered
    ,dblDebitReport
	,dblCreditReport
    ,strUserName
    ,strDescription
    ,strCode
    ,strReference
	,strComments
	,strJournalLineDescription
	,strUOMCode
	,intTransactionId   
	,strTransactionType	    
	,strModuleName
	,strTransactionForm
	,strDocument
	,dblExchangeRate
	,dblSourceUnitDebit
	,dblSourceUnitCredit
	,dblDebitUnit
	,dblCreditUnit
	,strCommodityCode
	,strSourceDocumentId
	,strLocationName strLocation
	,strCompanyLocation
	,strSourceUOMId
	,strSourceEntity
    ,intCurrencyID
	,strSourceEntityNo
	,strLOBSegmentDescription
	FROM cteRunningBalance
)

select * from cteOpeningBalance
)