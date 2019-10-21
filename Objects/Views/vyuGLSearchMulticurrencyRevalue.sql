
CREATE VIEW [dbo].[vyuGLSearchMulticurrencyRevalue]
AS
select 
strConsolidationNumber COLLATE Latin1_General_CI_AS strConsolidationNumber,
intConsolidationId,
B.strPeriod COLLATE Latin1_General_CI_AS strPeriod,
D.strCurrency COLLATE Latin1_General_CI_AS strCurrency,
strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,
C.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS strCurrencyExchangeRateType,
A.ysnPosted
from tblGLRevalue A
LEFT JOIN tblGLFiscalYearPeriod B
ON A.intGLFiscalYearPeriodId = B.intGLFiscalYearPeriodId
LEFT JOIN tblSMCurrencyExchangeRateType C 
ON  A.intRateTypeId= C.intCurrencyExchangeRateTypeId 
LEFT JOIN tblSMCurrency D 
ON A.intTransactionCurrencyId = D.intCurrencyID
GO


