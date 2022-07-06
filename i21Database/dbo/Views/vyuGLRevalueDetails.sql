CREATE VIEW vyuGLRevalueDetails
AS
SELECT 
A.*,
B.strCurrency
FROM tblGLRevalueDetails A 
LEFT JOIN tblSMCurrency B on  A.intCurrencyId = B.intCurrencyID
LEFT JOIN tblSMCurrencyExchangeRateType C ON C.intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
