CREATE FUNCTION fnGLGetAccountCurrencyReport(@intDefaultCurrencyId INT, @intAccountId INT)
RETURNS TABLE
AS

RETURN
(

WITH cteAccountCurrency AS(
    SELECT 
    C.intCurrencyID,
    C.strCurrency,
    A.intAccountId
    FROM tblGLAccount A ,
    tblSMCurrency C
),
GLQuery as(
SELECT * FROM cteAccountCurrency C 
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
where C.intAccountId = @intAccountId
),
cteRunningBalance AS(
        select  sum(dblAmount) over (partition by intAccountId order by intCurrencyID,intGLDetailId ) functionalRunningBalance,
		sum(dblAmountForeign) over (partition by intAccountId, intCurrencyID order by intCurrencyID, intGLDetailId ) foreignRunningBalance,
		*
		from GLQuery
),
cteOpeningBalance AS(
	SELECT 
	strCurrency
	,strAccountId
	,functionalRunningBalance - dblAmount dblBeginningBalance
	,functionalRunningBalance dblEndingBalance
	,dblDebit, dblCredit
	,foreignRunningBalance - dblAmountForeign dblBeginningBalanceForeign
	,dblAmountForeign
	,foreignRunningBalance dblEndingBalanceForeign
	,dblDebitForeign
	,dblCreditForeign
	,dblCreditReport
	,dtmDate
	,strBatchId
	,dblDebitUnit
	,dblCreditUnit
	,strDescription
	,strCode
	,strReference
	,dblExchangeRate
	,dtmDateEntered
	,strJournalLineDescription
	,strUserName
	,strTransactionId
	,strTransactionType
	,strTransactionForm
	,strModuleName
	,dblDebitReport
	,strDocument
	--,ysnIsUnposted
	,intTransactionId
	--,intEntityId
	,strComments
	,strUOMCode
	,strLocationName
	,strSourceUOMId
	,strCommodityCode
	,dblSourceUnitDebit
	,dblSourceUnitCredit
	,strSourceEntity
	,strSourceDocumentId
	--,strSourceEntityNo
	--,intSourceEntityId
	--,ysnPostAction
	--,dtmDateEnteredMin
	--,strPeriod
	,strCompanyLocation
	--,strCurrencyExchangeRateType
	--,strLocationSegmentDescription
	--,strLOBSegmentDescription
    ,intCurrencyID
	FROM cteRunningBalance
)
select * from cteOpeningBalance
)
