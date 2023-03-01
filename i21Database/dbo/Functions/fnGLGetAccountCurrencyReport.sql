CREATE FUNCTION fnGLGetAccountCurrencyReport(@intDefaultCurrencyId INT)
RETURNS TABLE
AS

RETURN
(
    WITH cteAccountCurrency AS(
        SELECT 
        C.intCurrencyID,
        C.strCurrency,
        A.intAccountId,
        strAccountId
        FROM vyuGLAccountDetail A ,
        tblSMCurrency C
        where strAccountType NOT IN('Revenue','Expense')
    )
    ,
    GLQuery as(
    SELECT * FROM cteAccountCurrency C 
    CROSS APPLY(
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
        and ysnIsUnposted = 0
    )GL
    ),
    cteRunningBalance AS(
            select  sum(dblAmount) over (partition by intAccountId order by intCurrencyID,dtmDate, intGLDetailId ) functionalRunningBalance,
            sum(dblAmountForeign) over (partition by intAccountId, intCurrencyID order by intCurrencyID,dtmDate, intGLDetailId ) foreignRunningBalance,
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
