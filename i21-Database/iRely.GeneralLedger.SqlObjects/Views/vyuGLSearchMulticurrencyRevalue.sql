
CREATE VIEW [dbo].[vyuGLSearchMulticurrencyRevalue]
AS
select 
strConsolidationNumber,
intConsolidationId,
B.strPeriod,
D.strCurrency,
strTransactionType,
C.strCurrencyExchangeRateType,
A.ysnPosted
from tblGLRevalue A
LEFT JOIN tblGLFiscalYearPeriod B
ON A.intGLFiscalYearPeriodId = B.intGLFiscalYearPeriodId
LEFT JOIN tblSMCurrencyExchangeRateType C 
ON  A.intRateTypeId= C.intCurrencyExchangeRateTypeId 
LEFT JOIN tblSMCurrency D 
ON A.intTransactionCurrencyId = D.intCurrencyID
GO


