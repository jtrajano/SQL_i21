CREATE VIEW [dbo].[vyuGLAuditorTransactionsByAccountId]
AS
SELECT 
	A.*
	,ACC.strAccountId
	,ACC.strDescription strAccountDescription
	,AG.strAccountGroup
	,Currency.strCurrency
	,CASE WHEN (A.strTotalTitle = 'Total') THEN '' ELSE EM.strName END COLLATE Latin1_General_CI_AS strUserName
FROM tblGLAuditorTransactionsByAccountId A
LEFT JOIN tblGLAccount ACC ON ACC.intAccountId = A.intAccountId
LEFT JOIN tblGLAccountGroup AG ON AG.intAccountGroupId = ACC.intAccountGroupId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = A.intCurrencyId
LEFT JOIN tblEMEntity EM ON EM.intEntityId = A.intEntityId

