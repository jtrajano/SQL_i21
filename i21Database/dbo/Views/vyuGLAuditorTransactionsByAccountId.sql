CREATE VIEW [dbo].[vyuGLAuditorTransactionsByAccountId]
AS
	SELECT 
		A.*
		,ACC.strAccountId
		,Currency.strCurrency
	FROM tblGLAuditorTransactionsByAccountId A
	LEFT JOIN tblGLAccount ACC ON ACC.intAccountId = A.intAccountId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = A.intCurrencyId

