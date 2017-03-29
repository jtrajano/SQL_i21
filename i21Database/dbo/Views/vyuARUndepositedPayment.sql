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
		ON A.[intEntityCustomerId] = B.[intEntityId]
INNER JOIN
	vyuGLAccountDetail GL
		ON A.intAccountId = GL.intAccountId  
INNER JOIN
	tblEMEntity E
		ON B.[intEntityId] = E.intEntityId 
LEFT OUTER JOIN
	tblCMUndepositedFund CM
		ON 	A.intPaymentId = CM.intSourceTransactionId 
		AND A.strRecordNumber = CM.strSourceTransactionId 							 
		AND CM.strSourceSystem = 'AR'
LEFT OUTER JOIN
	tblSMPaymentMethod SMPM
		ON A.intPaymentMethodId = SMPM.intPaymentMethodID
WHERE
	A.ysnPosted = 1
	AND A.ysnImportedFromOrigin <> 1
	AND CM.intSourceTransactionId IS NULL
	AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')
	AND ISNULL(A.dblAmountPaid, 0) > 0
	
UNION ALL	
	
SELECT
	 [strSourceTransactionId]	= A.[strInvoiceNumber]
	,[intSourceTransactionId]	= A.[intInvoiceId] 
	,[dtmDate]					= A.[dtmPostDate]
	,[strName]					= E.[strName] 
	,[dblAmount]				= A.[dblInvoiceTotal] 
	,[strSourceSystem]			= 'AR'
	,[intBankAccountId]			= NULL
	,[intLocationId]			= A.[intCompanyLocationId] 					

FROM 
	tblARInvoice A
INNER JOIN tblARCustomer B
		ON A.[intEntityCustomerId] = B.[intEntityId]
INNER JOIN
	vyuGLAccountDetail GL
		ON A.intAccountId = GL.intAccountId  
INNER JOIN
	tblEMEntity E
		ON B.[intEntityId] = E.intEntityId 
LEFT OUTER JOIN
	tblCMUndepositedFund CM
		ON 	A.intInvoiceId = CM.intSourceTransactionId 
		AND A.strInvoiceNumber = CM.strSourceTransactionId 							 
		AND CM.strSourceSystem = 'AR'
LEFT OUTER JOIN
	tblSMPaymentMethod SMPM
		ON A.intPaymentMethodId = SMPM.intPaymentMethodID
WHERE
	A.ysnPosted = 1
	AND A.[strTransactionType] IN ('Cash', 'Cash Refund')
	AND CM.intSourceTransactionId IS NULL
	AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')