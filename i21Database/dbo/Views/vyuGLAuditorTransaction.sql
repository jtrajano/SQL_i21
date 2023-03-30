CREATE VIEW [dbo].[vyuGLAuditorTransaction]
AS
SELECT 
	A.*
	,ACC.strAccountId
	,ACC.strDescription strAccountDescription
	,AG.strAccountGroup
	,A.ysnGroupHeader
	,A.ysnGroupFooter
	,A.ysnSummary
	,A.ysnSummaryFooter
	,A.ysnSpace
	,CASE WHEN (A.strTotalTitle = 'Total') THEN '' ELSE A.strUserName END COLLATE Latin1_General_CI_AS strUserName
FROM tblGLAuditorTransaction A
LEFT JOIN tblGLAccount ACC ON ACC.intAccountId = A.intAccountId
LEFT JOIN tblGLAccountGroup AG ON AG.intAccountGroupId = ACC.intAccountGroupId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = A.intCurrencyId
LEFT JOIN tblEMEntity EM ON EM.intEntityId = A.intEntityId

