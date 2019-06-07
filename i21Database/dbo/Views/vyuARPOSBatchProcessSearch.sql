CREATE VIEW [dbo].[vyuARPOSBatchProcessSearch]
AS
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , intPOSEndOfDayId		= EOD.intPOSEndOfDayId
	 , intPOSId				= POS.intPOSId
	 , intInvoiceId			= ISNULL(POS.intInvoiceId, POS.intCreditMemoId)
	 , intCreditMemoId		= POS.intCreditMemoId
	 , strEODNumber			= EOD.strEODNo
	 , strReceiptNumber		= POS.strReceiptNumber 
	 , strInvoiceNumber		= ISNULL(I.strInvoiceNumber, CM.strInvoiceNumber)
	 , strCreditMemoNumber	= CM.strInvoiceNumber
	 , strPaymentNumber		= PAYMENTS.strPaymentNumbers
	 , strDescription		= CASE WHEN BP.intPOSBatchProcessLogId IS NULL AND POS.intInvoiceId IS NULL AND POS.intCreditMemoId IS NULL THEN 'Pending' ELSE ISNULL(BP.strDescription, 'Successfully Processed.') END
	 , dtmPOSDate			= POS.dtmDate
	 , ysnProcessed			= CASE WHEN (POS.intInvoiceId IS NULL AND POS.intCreditMemoId IS NULL) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
LEFT JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1 AND I.strType = 'POS' AND I.strTransactionType = 'Invoice'
LEFT JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND I.ysnPosted = 1 AND I.strType = 'POS' AND I.strTransactionType = 'Credit Memo'
LEFT JOIN tblARPOSBatchProcessLog BP ON POS.intPOSId = BP.intPOSId
OUTER APPLY (
	SELECT strPaymentNumbers = LEFT(strRecordNumber, LEN(strRecordNumber) - 1)
	FROM (
		SELECT DISTINCT CAST(P.strRecordNumber AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD
		INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
		WHERE PD.intInvoiceId = I.intInvoiceId
		  OR PD.intInvoiceId = CM.intInvoiceId
		FOR XML PATH ('')
	) C (strRecordNumber)
) PAYMENTS
WHERE EOD.ysnClosed = 0
  AND POS.ysnHold = 0