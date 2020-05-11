﻿CREATE VIEW [dbo].[vyuARUndepositedPayment]
AS
SELECT DISTINCT 
	   strSourceTransactionId	= TRANSACTIONS.strSourceTransactionId
	 , intSourceTransactionId	= TRANSACTIONS.intSourceTransactionId
	 , dtmDate					= TRANSACTIONS.dtmDate
	 , strName					= CUSTOMER.strName
	 , dblAmount				= TRANSACTIONS.dblAmount
	 , strSourceSystem			= 'AR' COLLATE Latin1_General_CI_AS
	 , intBankAccountId			= TRANSACTIONS.intBankAccountId
	 , intLocationId			= TRANSACTIONS.intCompanyLocationId
	 , strPaymentMethod			= TRANSACTIONS.strPaymentMethod
	 , intEntityEnteredById		= TRANSACTIONS.intEntityId
	 , intCurrencyId			= TRANSACTIONS.intCurrencyId
	 , strEntityEnteredBy		= ENTEREDBY.strName
	 , strPaymentSource			= TRANSACTIONS.strPaymentSource
	 , strEODNumber				= TRANSACTIONS.strEODNumber
	 , strDrawerName			= TRANSACTIONS.strDrawerName
	 , ysnCompleted				= TRANSACTIONS.ysnCompleted
FROM (
	SELECT strSourceTransactionId	= PAYMENT.strRecordNumber
		 , intSourceTransactionId	= PAYMENT.intPaymentId		 
		 , dtmDate					= PAYMENT.dtmDatePaid
		 , dblAmount				= CASE WHEN (ISNULL(PAYMENT.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('Prepay')) THEN PAYMENT.dblAmountPaid *-1 ELSE PAYMENT.dblAmountPaid END
		 , intBankAccountId			= PAYMENT.intBankAccountId
		 , intEntityCustomerId		= PAYMENT.intEntityCustomerId
		 , intCompanyLocationId		= PAYMENT.intLocationId
		 , intEntityId				= PAYMENT.intEntityId
		 , intCurrencyId			= PAYMENT.intCurrencyId
		 , strPaymentMethod			= SMPM.strPaymentMethod
		 , strPaymentSource			= CASE WHEN POSEOD.strEODNo IS NULL THEN 'Manual Entry' ELSE 'POS' END COLLATE Latin1_General_CI_AS
		 , strEODNumber				= POSEOD.strEODNo
		 , strDrawerName			= POSEOD.strPOSDrawerName
		 , ysnCompleted				= POSEOD.ysnClosed
	FROM tblARPayment PAYMENT
	LEFT OUTER JOIN tblSMPaymentMethod SMPM ON PAYMENT.intPaymentMethodId = SMPM.intPaymentMethodID
	LEFT OUTER JOIN tblCMUndepositedFund CM ON PAYMENT.intPaymentId = CM.intSourceTransactionId 
										   AND PAYMENT.strRecordNumber = CM.strSourceTransactionId 
										   AND CM.strSourceSystem = 'AR'
	OUTER APPLY (
		SELECT TOP 1 strEODNo = POSEOD.strEODNo
					, strPOSDrawerName = POSDRAWER.strPOSDrawerName
					, ysnClosed = POSEOD.ysnClosed
		FROM tblARPaymentDetail PD
		INNER JOIN tblARInvoice I ON I.intInvoiceId = PD.intInvoiceId AND I.strType = 'POS' AND I.ysnPosted = 1
		INNER JOIN tblARPOS POS ON I.intInvoiceId = POS.intInvoiceId  OR I.intInvoiceId =  POS.intCreditMemoId 
		INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
		INNER JOIN tblARPOSEndOfDay POSEOD ON POSLOG.intPOSEndOfDayId = POSEOD.intPOSEndOfDayId
		INNER JOIN tblSMCompanyLocationPOSDrawer POSDRAWER ON POSEOD.intCompanyLocationPOSDrawerId = POSDRAWER.intCompanyLocationPOSDrawerId
		WHERE PD.intPaymentId = PAYMENT.intPaymentId
	) POSEOD	
	WHERE PAYMENT.ysnPosted = 1
	  AND PAYMENT.ysnProcessedToNSF = 0
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
		 , intCurrencyId			= INVOICE.intCurrencyId
		 , strPaymentMethod			= SMPM.strPaymentMethod		
		 , strPaymentSource			= NULL
		 , strEODNumber				= NULL
		 , strDrawerName			= NULL
		 , ysnCompleted				= 0
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
		 , dblAmount				= EOD.dblFinalEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0) + ISNULL(EOD.dblCashPaymentReceived,0)) - ABS(ISNULL(EOD.dblCashReturn,0)))
		 , intBankAccountId			= NULL
		 , intEntityCustomerId		= EOD.intEntityId
		 , intLocationId			= DRAWER.intCompanyLocationId	
		 , intEntityId				= EOD.intEntityId
		 , intCurrencyId			= EOD.intCurrencyId
		 , strPaymentMethod			= 'Cash' COLLATE Latin1_General_CI_AS
		 , strPaymentSource			= 'POS' COLLATE Latin1_General_CI_AS
		 , strEODNumber				= EOD.strEODNo
		 , strDrawerName			= DRAWER.strPOSDrawerName
		 , ysnCompleted				= ysnClosed
	FROM tblARPOSEndOfDay EOD
	INNER JOIN (
		SELECT intCompanyLocationId
			 , intCompanyLocationPOSDrawerId
			 , strPOSDrawerName
		FROM tblSMCompanyLocationPOSDrawer
	) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
	WHERE EOD.ysnClosed = 1
	 AND intCashOverShortId IS NOT NULL
	 AND (EOD.dblFinalEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0) + ISNULL(EOD.dblCashPaymentReceived,0)) - ABS(ISNULL(EOD.dblCashReturn,0)))) <> 0.000000
) TRANSACTIONS
INNER JOIN tblEMEntity CUSTOMER ON TRANSACTIONS.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN tblEMEntity ENTEREDBY ON TRANSACTIONS.intEntityId = ENTEREDBY.intEntityId
GO
