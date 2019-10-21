CREATE VIEW [dbo].[vyuGLReallocation]
AS
SELECT 
	AAD.intAccountReallocationDetailId
	,AAD.intConcurrencyId
	,A.intAccountId
	,RA.intCurrencyId
	,RA.intAccountReallocationId
	,RA.strName COLLATE Latin1_General_CI_AS strName
	,RA.strDescription COLLATE Latin1_General_CI_AS AS strDescription
	,A.strAccountId COLLATE Latin1_General_CI_AS strAccountId
	,A.strDescription COLLATE Latin1_General_CI_AS as strAccountIdDescription
	,ISNULL(dblPercentage, 0) AS dblPercentage
	,A.intCurrencyExchangeRateTypeId
	,R.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS strCurrencyExchangeRateType
FROM tblGLAccountReallocationDetail AAD
LEFT JOIN tblGLAccount A ON AAD.intAccountId = A.intAccountId
LEFT JOIN tblGLAccountReallocation RA ON AAD.intAccountReallocationId = RA.intAccountReallocationId
LEFT JOIN tblGLAccountGroup G on G.intAccountGroupId = A.intAccountGroupId
LEFT JOIN tblSMCurrencyExchangeRateType R ON R.intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId