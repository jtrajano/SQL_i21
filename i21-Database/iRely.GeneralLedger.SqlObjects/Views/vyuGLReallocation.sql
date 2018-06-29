CREATE VIEW [dbo].[vyuGLReallocation]
AS
SELECT AAD.intAccountReallocationDetailId,
AAD.intConcurrencyId,
A.intAccountId,
RA.intCurrencyId,
RA.intAccountReallocationId, 
RA.strName, RA.strDescription AS strDescription, 
A.strAccountId, A.strDescription as strAccountIdDescription, ISNULL(dblPercentage, 0) AS dblPercentage,
A.intCurrencyExchangeRateTypeId,
R.strCurrencyExchangeRateType
FROM tblGLAccountReallocationDetail AAD
LEFT JOIN tblGLAccount A ON AAD.intAccountId = A.intAccountId
LEFT JOIN tblGLAccountReallocation RA ON AAD.intAccountReallocationId = RA.intAccountReallocationId
LEFT JOIN tblGLAccountGroup G on G.intAccountGroupId = A.intAccountGroupId
LEFT JOIN tblSMCurrencyExchangeRateType R ON R.intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId