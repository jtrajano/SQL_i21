CREATE VIEW [dbo].[vyuARUndepositedPayment]
AS
SELECT
	 [strSourceTransactionId]	= A.[strRecordNumber]
	,[intSourceTransactionId]	= A.[intPaymentId] 
	,[dtmDate]					= A.[dtmDatePaid]
	,[strName]					= E.[strName] 
	,[dblAmount]				= CASE WHEN (ISNULL(A.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('Prepay')) THEN A.[dblAmountPaid]*-1 ELSE A.[dblAmountPaid] END
	,[strSourceSystem]			= 'AR' COLLATE Latin1_General_CI_AS
	,[intBankAccountId]			= A.[intBankAccountId]
	,[intLocationId]			= A.[intLocationId] 
	,[strPaymentMethod]			= SMPM.[strPaymentMethod]

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
	AND (A.ysnImportedFromOrigin <> 1 AND A.ysnImportedAsPosted <> 1)
	AND CM.intSourceTransactionId IS NULL
	AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')
	AND (ISNULL(A.dblAmountPaid, 0) > 0 OR (ISNULL(A.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('ACH','Prepay', 'Cash', 'Manual Credit Card', 'Debit Card'))) OR SMPM.strPaymentMethod = 'Refund'
	
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
	,[strPaymentMethod]			= SMPM.[strPaymentMethod]								

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
	AND A.[strTransactionType] IN ('Cash') --, 'Cash Refund')
	AND CM.intSourceTransactionId IS NULL
	AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')
	AND (ISNULL(A.ysnImportedFromOrigin,0) <> 1 AND ISNULL(A.ysnImportedAsPosted,0) <> 1)

UNION ALL	
	
SELECT
	 [strSourceTransactionId]	= EOD.strEODNo
	,[intSourceTransactionId]	= EOD.intPOSEndOfDayId 
	,[dtmDate]					= EOD.dtmClose
	,[strName]					= ENTITY.strName
	,[dblAmount]				= EOD.dblFinalEndingBalance - (EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0))
	,[strSourceSystem]			= 'AR'
	,[intBankAccountId]			= NULL
	,[intLocationId]			= DRAWER.intCompanyLocationId	
	,[strPaymentMethod]			= 'Cash'								
FROM tblARPOSEndOfDay EOD
INNER JOIN (
	SELECT
		 intEntityId
		,strName
	FROM tblEMEntity
)ENTITY ON EOD.intEntityId = ENTITY.intEntityId
INNER JOIN(
	SELECT 
		intCompanyLocationId,
		intCompanyLocationPOSDrawerId
	FROM tblSMCompanyLocationPOSDrawer
)DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
WHERE EOD.ysnClosed = 1
AND (EOD.dblFinalEndingBalance - (EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0))) <> 0
GO

