CREATE VIEW [dbo].[vyuAPUnknownPayables]
AS 

SELECT 
	A.intGLDetailId,
	A.strTransactionId,
	A.dtmDate,
	A.dtmDateEntered,
	A.dblDebit,
	A.dblCredit,
	strUserId = C.strUserName
FROM tblGLDetail A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
LEFT JOIN tblEMEntityCredential C ON A.intEntityId = C.intEntityId
WHERE 
	B.intAccountCategoryId IN (1, 53)
AND A.ysnIsUnposted = 0
AND A.strModuleName NOT IN ('Accounts Payable', 'Accounts Receivable')
