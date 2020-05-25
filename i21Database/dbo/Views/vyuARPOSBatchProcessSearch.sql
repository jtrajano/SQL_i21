CREATE VIEW [dbo].[vyuARPOSBatchProcessSearch]
AS
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , intPOSEndOfDayId		= EOD.intPOSEndOfDayId
	 , intPOSId				= POS.intPOSId
	 , intInvoiceId			= POS.intInvoiceId
	 , intCreditMemoId		= POS.intCreditMemoId
	 , strEODNumber			= EOD.strEODNo
	 , strReceiptNumber		= POS.strReceiptNumber 
	 , strInvoiceNumber		= INVOICES.strInvoiceNumbers--ISNULL(I.strInvoiceNumber, CM.strInvoiceNumber)
	 , strCreditMemoNumber	= ''--CM.strInvoiceNumber
	 , strPaymentNumber		= PAYMENTS.strPaymentNumbers
	 , strDescription		= CASE WHEN (BP.intPOSBatchProcessLogId IS NULL AND POS.intInvoiceId IS NULL AND POS.intCreditMemoId IS NULL) THEN 'Pending' ELSE ISNULL(BP.strDescription, 'Successfully Processed.') END
	 , dtmPOSDate			= POS.dtmDate
	 , ysnProcessed			= CASE WHEN (POS.intInvoiceId IS NULL AND POS.intCreditMemoId IS NULL) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
FROM (
	SELECT intPOSId				= IPOS.intPOSId
		 , intPOSLogId			= IPOS.intPOSLogId
		 , intInvoiceId			= IPOS.intInvoiceId
		 , intCreditMemoId		= NULL
		 , intEntityCustomerId	= IPOS.intEntityCustomerId
		 , strReceiptNumber		= IPOS.strReceiptNumber
		 , dtmDate				= IPOS.dtmDate
	FROM tblARPOS IPOS
	WHERE IPOS.ysnHold = 0
	  AND ((IPOS.ysnReturn = 1 AND (IPOS.intInvoiceId IS NOT NULL OR IPOS.intCreditMemoId IS NULL)) OR (IPOS.ysnReturn = 0 AND IPOS.intCreditMemoId IS NULL))

	UNION ALL

	SELECT intPOSId				= CPOS.intPOSId
		 , intPOSLogId			= CPOS.intPOSLogId
		 , intInvoiceId			= NULL
		 , intCreditMemoId		= CPOS.intCreditMemoId
		 , intEntityCustomerId	= CPOS.intEntityCustomerId
		 , strReceiptNumber		= CPOS.strReceiptNumber
		 , dtmDate				= CPOS.dtmDate
	FROM tblARPOS CPOS
	WHERE CPOS.ysnHold = 0
	  AND CPOS.intCreditMemoId IS NOT NULL
	  AND CPOS.intInvoiceId IS NULL

	UNION ALL
	SELECT intPOSId				= ICPOS.intPOSId
		 , intPOSLogId			= ICPOS.intPOSLogId
		 , intInvoiceId			= ICPOS.intInvoiceId
		 , intCreditMemoId		= ICPOS.intCreditMemoId
		 , intEntityCustomerId	= ICPOS.intEntityCustomerId
		 , strReceiptNumber		= ICPOS.strReceiptNumber
		 , dtmDate				= ICPOS.dtmDate
	FROM tblARPOS ICPOS
	WHERE ICPOS.ysnHold = 0
	  AND ICPOS.intCreditMemoId IS NOT NULL
	  AND ICPOS.intInvoiceId IS NOT NULL
) POS
INNER JOIN tblARCustomer C ON POS.intEntityCustomerId = C.intEntityId
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
--LEFT JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1 AND I.strType = 'POS' AND I.strTransactionType = 'Invoice'
--LEFT JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND CM.ysnPosted = 1 AND CM.strType = 'POS' AND CM.strTransactionType = 'Credit Memo'
OUTER APPLY (
SELECT strInvoiceNumbers = LEFT(strInvoiceNumber, LEN(strInvoiceNumber) - 1)
	FROM (
		SELECT DISTINCT CAST(P.strInvoiceNumber AS VARCHAR(200))  + ', '
		FROM (
		 SELECT strInvoiceNumber = strInvoiceNumber from tblARInvoice
		 WHERE POS.intInvoiceId = intInvoiceId
		 UNION ALL 
		 SELECT strInvoiceNumber = strInvoiceNumber from tblARInvoice
		 WHERE POS.intCreditMemoId = intInvoiceId
		)P
		FOR XML PATH ('')
	) C (strInvoiceNumber)
)INVOICES

LEFT JOIN (
	SELECT intPOSBatchProcessLogId	= MIN(intPOSBatchProcessLogId)
		 , intPOSId					= intPOSId
		 , strDescription			= strDescription
	FROM tblARPOSBatchProcessLog
	GROUP BY intPOSId, strDescription
) BP ON POS.intPOSId = BP.intPOSId
OUTER APPLY (
	SELECT strPaymentNumbers = LEFT(strRecordNumber, LEN(strRecordNumber) - 1)
	FROM (
		SELECT DISTINCT CAST(P.strRecordNumber AS VARCHAR(200))  + ', '
		FROM (
		 SELECT strRecordNumber = strRecordNumber from tblARPayment PAY 
		 INNER JOIN tblARPaymentDetail PD ON PD.intPaymentId = PAY.intPaymentId
		 WHERE POS.intInvoiceId = PD.intInvoiceId
		 UNION ALL 
		 SELECT strRecordNumber = strRecordNumber from tblARPayment PAY 
		 INNER JOIN tblARPaymentDetail PD ON PD.intPaymentId = PAY.intPaymentId
		 WHERE POS.intCreditMemoId = PD.intInvoiceId
		)P
		FOR XML PATH ('')
	) C (strRecordNumber)
) PAYMENTS
WHERE EOD.ysnClosed = 0
GO


