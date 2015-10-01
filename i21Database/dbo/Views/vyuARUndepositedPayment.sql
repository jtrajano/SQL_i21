CREATE VIEW [dbo].[vyuARUndepositedPayment]
AS
SELECT
	 [strSourceTransactionId]	= A.[strRecordNumber]
	,[intSourceTransactionId]	= A.[intPaymentId] 
	,[dtmDate]					= A.[dtmDatePaid]
	,[strName]					= E.[strName] 
	,[dblAmount]				= A.[dblAmountPaid]
	,[strSourceSystem]			= 'AR'						

FROM 
	tblARPayment A
INNER JOIN tblARCustomer B
		ON A.[intEntityCustomerId] = B.[intEntityCustomerId]
INNER JOIN
	tblGLAccount GL
		ON A.intAccountId = GL.intAccountId 
INNER JOIN 
	tblGLAccountGroup AG
		ON GL.intAccountGroupId = AG.intAccountGroupId 		
INNER JOIN 
	tblGLAccountCategory AC
		ON GL.intAccountCategoryId = AC.intAccountCategoryId 
INNER JOIN
	tblEntity E
		ON B.intEntityCustomerId = E.intEntityId 
LEFT OUTER JOIN
	tblCMUndepositedFund CM
		ON 	A.intPaymentId = CM.intSourceTransactionId 
		AND A.strRecordNumber = CM.strSourceTransactionId 							 
		AND CM.strSourceSystem = 'AR'
WHERE
	A.ysnPosted = 1
	AND CM.intSourceTransactionId IS NULL