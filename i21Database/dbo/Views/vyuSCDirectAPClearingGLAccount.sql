CREATE VIEW [dbo].[vyuSCDirectAPClearingGLAccount]
	AS 


SELECT

	DETAIL.strTransactionId,
	DETAIL.strTransactionForm,
	DETAIL.strTransactionType, 
	DETAIL.dblDebit,
	DETAIL.dblCredit,
	DETAIL.dblDebitUnit,
	DETAIL.dblCreditUnit,
	DETAIL.strCode,
	ACCOUNT_DETAIL.intAccountCategoryId,
	DETAIL.strReference,
	ACCOUNT_DETAIL.strAccountId,
	ACCOUNT_DETAIL.strAccountId1,
	ACCOUNT_DETAIL.strAccountCategory,
	DETAIL.ysnIsUnposted


FROM tblGLDetail DETAIL 
	JOIN vyuGLAccountDetail ACCOUNT_DETAIL
		ON DETAIL.intAccountId = ACCOUNT_DETAIL.intAccountId

WHERE DETAIL.strCode = 'SCTKT' 
