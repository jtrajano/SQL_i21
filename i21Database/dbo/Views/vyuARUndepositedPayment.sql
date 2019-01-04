CREATE VIEW [dbo].[vyuARUndepositedPayment]
AS
SELECT strSourceTransactionId	= TRANSACTIONS.strSourceTransactionId
	 , intSourceTransactionId	= TRANSACTIONS.intSourceTransactionId
	 , dtmDate					= TRANSACTIONS.dtmDate
	 , strName					= CUSTOMER.strName
	 , dblAmount				= TRANSACTIONS.dblAmount
	 , strSourceSystem			= 'AR' COLLATE Latin1_General_CI_AS
	 , intBankAccountId			= TRANSACTIONS.intBankAccountId
	 , intLocationId			= TRANSACTIONS.intCompanyLocationId
	 , strPaymentMethod			= TRANSACTIONS.strPaymentMethod
	 , intEntityEnteredById		= TRANSACTIONS.intEntityId
	 , strEntityEnteredBy		= ENTEREDBY.strName
FROM (
	SELECT strSourceTransactionId	= PAYMENT.strRecordNumber
		 , intSourceTransactionId	= PAYMENT.intPaymentId
		 , dtmDate					= PAYMENT.dtmDatePaid
		 , dblAmount				= CASE WHEN (ISNULL(PAYMENT.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('Prepay')) THEN PAYMENT.dblAmountPaid *-1 ELSE PAYMENT.dblAmountPaid END
		 , intBankAccountId			= PAYMENT.intBankAccountId
		 , intEntityCustomerId		= PAYMENT.intEntityCustomerId
		 , intCompanyLocationId		= PAYMENT.intLocationId
		 , intEntityId				= PAYMENT.intEntityId
		 , strPaymentMethod			= SMPM.strPaymentMethod
	FROM tblARPayment PAYMENT
	LEFT OUTER JOIN tblSMPaymentMethod SMPM ON PAYMENT.intPaymentMethodId = SMPM.intPaymentMethodID
	LEFT OUTER JOIN tblCMUndepositedFund CM ON PAYMENT.intPaymentId = CM.intSourceTransactionId 
										   AND PAYMENT.strRecordNumber = CM.strSourceTransactionId 
										   AND CM.strSourceSystem = 'AR'	
	WHERE PAYMENT.ysnPosted = 1
	  AND PAYMENT.intAccountId IS NOT NULL
	  AND (PAYMENT.ysnImportedFromOrigin <> 1 AND PAYMENT.ysnImportedAsPosted <> 1)
	  AND CM.intSourceTransactionId IS NULL
	  AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')
	  AND (ISNULL(PAYMENT.dblAmountPaid, 0) > 0 OR (ISNULL(PAYMENT.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('ACH','Prepay', 'Cash', 'Manual Credit Card', 'Debit Card')))

	UNION ALL	
	
	SELECT strSourceTransactionId	= INVOICE.strInvoiceNumber
		 , intSourceTransactionId	= INVOICE.intInvoiceId
		 , dtmDate					= INVOICE.dtmPostDate
		 , dblAmount				= INVOICE.dblInvoiceTotal
		 , intBankAccountId			= NULL
		 , intEntityCustomerId		= INVOICE.intEntityCustomerId
		 , intCompanyLocationId		= INVOICE.intCompanyLocationId
		 , intEntityId				= INVOICE.intEntityId		 		
		 , strPaymentMethod			= SMPM.strPaymentMethod				
	FROM tblARInvoice INVOICE
	LEFT OUTER JOIN tblSMPaymentMethod SMPM ON INVOICE.intPaymentMethodId = SMPM.intPaymentMethodID
	LEFT OUTER JOIN tblCMUndepositedFund CM ON INVOICE.intInvoiceId = CM.intSourceTransactionId 
										   AND INVOICE.strInvoiceNumber = CM.strSourceTransactionId
										   AND CM.strSourceSystem = 'AR'
	WHERE INVOICE.ysnPosted = 1
	  AND INVOICE.intAccountId IS NOT NULL
	  AND INVOICE.strTransactionType = 'Cash'
	  AND CM.intSourceTransactionId IS NULL
	  AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')
	  AND (ISNULL(INVOICE.ysnImportedFromOrigin,0) <> 1 AND ISNULL(INVOICE.ysnImportedAsPosted,0) <> 1)

	UNION ALL	
	
	SELECT strSourceTransactionId	= EOD.strEODNo
		 , intSourceTransactionId	= EOD.intPOSEndOfDayId 
		 , dtmDate					= EOD.dtmClose
		 , dblAmount				= EOD.dblFinalEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0)) - ABS(ISNULL(EOD.dblCashReturn,0)))
		 , intBankAccountId			= NULL
		 , intEntityCustomerId		= EOD.intEntityId
		 , intLocationId			= DRAWER.intCompanyLocationId	
		 , intEntityId				= EOD.intEntityId
		 , strPaymentMethod			= 'Cash' COLLATE Latin1_General_CI_AS
	FROM tblARPOSEndOfDay EOD
	INNER JOIN (
		SELECT intCompanyLocationId
			 , intCompanyLocationPOSDrawerId
		FROM tblSMCompanyLocationPOSDrawer
	) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
	WHERE EOD.ysnClosed = 1
	 AND (EOD.dblFinalEndingBalance - (EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0))) <> 0
) TRANSACTIONS
INNER JOIN tblEMEntity CUSTOMER ON TRANSACTIONS.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN tblEMEntity ENTEREDBY ON TRANSACTIONS.intEntityId = ENTEREDBY.intEntityId

GO