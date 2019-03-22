CREATE VIEW [dbo].[vyuARPOSGLSummary]
AS
SELECT intPOSEndOfDayId		= GLSUMMARY.intPOSEndOfDayId
	 , dblDebit				= GLSUMMARY.dblDebit
	 , dblCredit			= GLSUMMARY.dblCredit
	 , strAccountId			= GLSUMMARY.strAccountId
	 , strAccountCategory	= GLSUMMARY.strAccountCategory
	 , strDescription		= GLSUMMARY.strDescription
FROM ( 
	SELECT intPOSEndOfDayId		= EOD.intPOSEndOfDayId
		 , dblOpeningBalance	= EOD.dblOpeningBalance
		 , dblEndingBalance		= EOD.dblFinalEndingBalance
		 , dblDebit				= CASE WHEN SUM(GL.dblDebit) - SUM(GL.dblCredit) <= 0.000000 THEN 0.000000 ELSE SUM(GL.dblDebit) - SUM(GL.dblCredit) END
		 , dblCredit			= CASE WHEN SUM(GL.dblDebit) - SUM(GL.dblCredit) >= 0.000000 THEN 0.000000 ELSE SUM(GL.dblCredit) - SUM(GL.dblDebit) END
		 , strAccountId			= GLA.strAccountId
		 , strAccountCategory	= GLA.strAccountCategory
		 , strDescription		= GLA.strDescription
	FROM dbo.tblARPOSEndOfDay EOD WITH (NOLOCK)
	INNER JOIN (
		SELECT
			intPOSLogId,
			intPOSEndOfDayId
		FROM tblARPOSLog
	) POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
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
		  AND EOD.ysnClosed = 1

		UNION ALL

		SELECT intTransactionId = PAYMENT.intPaymentId
			 , strTransactionId = PAYMENT.strRecordNumber
			 , strTransaction   = 'Payment'
		FROM dbo.tblARPOSPayment POSP WITH (NOLOCK)	
		INNER JOIN (
			SELECT intPaymentId
				 , strRecordNumber
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) PAYMENT ON POSP.intPaymentId = PAYMENT.intPaymentId
		WHERE POSP.intPOSId = POS.intPOSId
		  AND POSP.strPaymentMethod <> 'On Account'

		UNION ALL 

		SELECT	intTransactionId = EODT.intPOSEndOfDayId
				, strTransactionId = EODT.strEODNo
				, strTransaction = 'EOD'
		FROM dbo.tblARPOSEndOfDay EODT WITH (NOLOCK)
		WHERE EODT.ysnClosed = 1 AND EODT.intCashOverShortId IS NOT NULL
		AND EOD.intPOSEndOfDayId = EODT.intPOSEndOfDayId
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
	WHERE EOD.ysnClosed = 1
	GROUP BY EOD.intPOSEndOfDayId
		   , EOD.dblFinalEndingBalance
		   , EOD.dblOpeningBalance
		   , GLA.strAccountId
		   , GLA.strAccountCategory
		   , GLA.strDescription

	UNION ALL

	SELECT intPOSEndOfDayId		= EOD.intPOSEndOfDayId
		 , dblOpeningBalance	= EOD.dblOpeningBalance
		 , dblEndingBalance		= EOD.dblFinalEndingBalance
		 , dblDebit				= BTD.dblDebit
		 , dblCredit			= BTD.dblCredit
		 , strAccountId			= GLA.strAccountId
		 , strAccountCategory	= GLA.strAccountCategory
		 , strDescription		= GLA.strDescription
	FROM dbo.tblARPOSEndOfDay EOD WITH (NOLOCK)
	INNER JOIN (
		SELECT
			intPOSLogId
			,intPOSEndOfDayId
		FROM tblARPOSLog
	) POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
	INNER JOIN (
		SELECT intTransactionId
			 , intGLAccountId
			 , dblCredit
			 , dblDebit
		FROM dbo.tblCMBankTransactionDetail WITH (NOLOCK)		
	) BTD ON EOD.intBankDepositId = BTD.intTransactionId
	INNER JOIN (
		SELECT intTransactionId
			 , strTransactionId
		FROM dbo.tblCMBankTransaction WITH (NOLOCK)
		WHERE ysnPOS = 1
	) BT ON BTD.intTransactionId = BT.intTransactionId
	INNER JOIN (
		SELECT DISTINCT 
				  intAccountId
				, strAccountId
				, strAccountCategory
				, strDescription
		FROM dbo.vyuGLAccountDetail WITH (NOLOCK)
		WHERE strAccountCategory = 'Cash Account'	
	) GLA ON BTD.intGLAccountId = GLA.intAccountId
) GLSUMMARY