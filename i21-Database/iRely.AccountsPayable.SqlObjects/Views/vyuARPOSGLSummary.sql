CREATE VIEW [dbo].[vyuARPOSGLSummary]
AS 
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , dblDebit				= SUM(GL.dblDebit)
	 , dblCredit			= SUM(GL.dblCredit)	 
	 , strAccountId			= GLA.strAccountId
	 , strAccountCategory	= GLA.strAccountCategory
	 , strDescription		= GLA.strDescription
FROM dbo.tblARPOSLog POSLOG WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId
		 , intPOSLogId
		 , intPOSId
	FROM dbo.tblARPOS POS WITH (NOLOCK)
	WHERE intInvoiceId IS NOT NULL
) POS ON POSLOG.intPOSLogId = POS.intPOSLogId
CROSS APPLY (
	SELECT intTransactionId = intInvoiceId
		 , strTransactionId = strInvoiceNumber
		 , strTransaction   = 'Invoice'
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'POS'
	  AND ysnPosted = 1
	  AND POS.intInvoiceId = intInvoiceId

	UNION ALL

	SELECT intTransactionId = PD.intPaymentId
	     , strTransactionId = PD.strRecordNumber
		 , strTransaction   = 'Payment'
	FROM dbo.tblARPOSPayment POSP WITH (NOLOCK)	
	INNER JOIN (
		SELECT P.intPaymentId
			 , P.strRecordNumber
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
				 , strRecordNumber
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) P ON P.intPaymentId = PD.intPaymentId
	) PD ON POS.intInvoiceId = PD.intInvoiceId
	WHERE POSP.intPOSId = POS.intPOSId
	  AND POSP.strPaymentMethod <> 'On Account'
) TRANSACTIONS
INNER JOIN (
	SELECT intTransactionId
	     , strTransactionId
		 , dblDebit
		 , dblCredit
		 , intAccountId
	FROM dbo.tblGLDetail WITH (NOLOCK)
	WHERE ysnIsUnposted = 0
) GL ON TRANSACTIONS.intTransactionId = GL.intTransactionId
	AND TRANSACTIONS.strTransactionId = GL.strTransactionId
INNER JOIN (
	SELECT DISTINCT 
		   intAccountId
		 , strAccountId
		 , strAccountCategory
		 , strDescription
	FROM dbo.vyuGLAccountDetail WITH (NOLOCK)	
) GLA ON GL.intAccountId = GLA.intAccountId
     AND (GLA.strAccountCategory <> 'AR Account' OR (TRANSACTIONS.strTransaction = 'Invoice' AND TRANSACTIONS.intTransactionId NOT IN (SELECT intInvoiceId FROM dbo.tblARPaymentDetail)))
GROUP BY POSLOG.intPOSLogId
	   , GLA.strAccountId
	   , GLA.strAccountCategory
	   , GLA.strDescription