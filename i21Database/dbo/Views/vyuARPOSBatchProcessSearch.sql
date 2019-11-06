CREATE VIEW [dbo].[vyuARPOSBatchProcessSearch]
AS
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , intPOSEndOfDayId		= EOD.intPOSEndOfDayId
	 , intPOSId				= POS.intPOSId
	 , intInvoiceId			= POS.intInvoiceId
	 , intCreditMemoId		= POS.intCreditMemoId
	 , strEODNumber			= EOD.strEODNo
	 , strReceiptNumber		= POS.strReceiptNumber 
	 , strInvoiceNumber		= ISNULL(I.strInvoiceNumber, CM.strInvoiceNumber)
	 , strCreditMemoNumber	= CM.strInvoiceNumber
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
) POS
INNER JOIN tblARCustomer C ON POS.intEntityCustomerId = C.intEntityId
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
LEFT JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1 AND I.strType = 'POS' AND I.strTransactionType = 'Invoice'
LEFT JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND CM.ysnPosted = 1 AND CM.strType = 'POS' AND CM.strTransactionType = 'Credit Memo'
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
		FROM tblARPaymentDetail PD
		INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
		WHERE PD.intInvoiceId = POS.intInvoiceId
		  OR PD.intInvoiceId = CM.intInvoiceId
		FOR XML PATH ('')
	) C (strRecordNumber)
) PAYMENTS
WHERE EOD.ysnClosed = 0