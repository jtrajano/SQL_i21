CREATE VIEW dbo.vyuARDepositAccount
AS
SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,GL.strDescription 
	,AG.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
	,BA.intBankAccountId 
	,BA.strBankAccountNo 
FROM
	tblGLAccount GL
INNER JOIN 
	tblGLAccountGroup AG
		ON GL.intAccountGroupId = AG.intAccountGroupId
INNER JOIN 
	tblGLAccountCategory AC
		ON GL.intAccountCategoryId = AC.intAccountCategoryId												 
INNER JOIN
	tblCMBankAccount BA
		ON GL.intAccountId = BA.intGLAccountId 						
WHERE
	AC.strAccountCategory = 'Cash Account'
	AND BA.intGLAccountId IS NOT NULL
	AND BA.ysnActive = 1
		
UNION ALL

SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,GL.strDescription 
	,AG.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
	,BA.intBankAccountId 
	,BA.strBankAccountNo 
FROM
	tblGLAccount GL
INNER JOIN 
	tblGLAccountGroup AG
		ON GL.intAccountGroupId = AG.intAccountGroupId
INNER JOIN 
	tblGLAccountCategory AC
		ON GL.intAccountCategoryId = AC.intAccountCategoryId			
INNER JOIN
	tblCMBankAccount BA
		ON GL.intAccountId = BA.intGLAccountId 											 						
WHERE
	AC.strAccountCategory = 'Undeposited Funds'
	AND BA.intGLAccountId IS NOT NULL
	AND BA.ysnActive = 1
