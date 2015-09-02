CREATE VIEW dbo.vyuARDepositAccount
AS
SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,AG.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
FROM
	tblGLAccount GL
INNER JOIN 
	tblGLAccountGroup AG
		ON GL.intAccountGroupId = AG.intAccountGroupId 											 
INNER JOIN
	tblCMBankAccount BA
		ON GL.intAccountId = BA.intGLAccountId 						
WHERE
	AG.strAccountGroup = 'Cash Accounts'
	AND BA.intGLAccountId IS NOT NULL
	AND BA.ysnActive = 1
		
UNION ALL

SELECT
	 GL.intAccountId
	,GL.strAccountId
	,GL.intAccountGroupId
	,AG.strAccountGroup 
	,GL.intAccountCategoryId 
	,GL.ysnActive
FROM
	tblGLAccount GL
INNER JOIN 
	tblGLAccountGroup AG
		ON GL.intAccountGroupId = AG.intAccountGroupId 											 						
WHERE
	AG.strAccountGroup = 'Undeposited Funds'