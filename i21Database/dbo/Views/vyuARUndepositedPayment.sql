CREATE VIEW [dbo].[vyuARUndepositedPayment]
AS
SELECT
	 [strSourceTransactionId]	= A.[strRecordNumber]
	,[intSourceTransactionId]	= A.[intPaymentId] 
	,[dtmDate]					= A.[dtmDatePaid]
	,[strName]					= E.[strName] 
	,[dblAmount]				= A.[dblAmountPaid]
	,[strSourceSystem]			= 'AR'
	,[intBankAccountId]			= A.[intBankAccountId]
	,[intLocationId]			= A.[intLocationId] 					

FROM 
	tblARPayment A
INNER JOIN tblARCustomer B
		ON A.[intEntityCustomerId] = B.[intEntityCustomerId]
INNER JOIN
	vyuGLAccountDetail GL
		ON A.intAccountId = GL.intAccountId  
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