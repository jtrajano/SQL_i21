CREATE VIEW dbo.vyuARDepositAccount
AS
SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,GL.strDescription 
	,GL.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
	,BA.intBankAccountId 
	,BA.strBankAccountNo 
FROM
	vyuGLAccountDetail GL												 
INNER JOIN
	tblCMBankAccount BA
		ON GL.intAccountId = BA.intGLAccountId 						
WHERE
	GL.strAccountCategory = 'Cash Account'
	AND BA.intGLAccountId IS NOT NULL
	AND BA.ysnActive = 1
		
UNION ALL

SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,GL.strDescription 
	,GL.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
	,NULL AS intBankAccountId 
	,'' AS strBankAccountNo 
FROM
	vyuGLAccountDetail GL												 						
WHERE
	GL.strAccountCategory = 'Undeposited Funds'
