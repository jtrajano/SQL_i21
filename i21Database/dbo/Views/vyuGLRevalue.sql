CREATE VIEW vyuGLRevalue
AS
SELECT 
A.*
,G.strCurrency strTransactionCurrency
,B.strPeriod
,C.strCurrency strFunctionalCurrency
,F.strFiscalYear
,B.dtmStartDate
,B.dtmEndDate
,B.ysnAPOpen
,B.ysnAROpen
,B.ysnINVOpen
,B.ysnCMOpen
,B.ysnPROpen
,B.ysnCTOpen
,B.ysnFAOpen
,B.ysnARRevalued
,B.ysnAPRevalued
,B.ysnINVRevalued 
,B.ysnCTRevalued
,B.ysnCMRevalued
FROM tblGLRevalue  A
LEFT JOIN tblGLFiscalYearPeriod B ON B.intGLFiscalYearPeriodId = A.intGLFiscalYearPeriodId
LEFT JOIN tblGLFiscalYear F on F.intFiscalYearId = B.intFiscalYearId
LEFT JOIN tblSMCurrency C on C.intCurrencyID = A.intFunctionalCurrencyId
LEFT JOIN tblSMCurrency G on G.intCurrencyID = A.intTransactionCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType D on D.intCurrencyExchangeRateTypeId = A.intRateTypeId