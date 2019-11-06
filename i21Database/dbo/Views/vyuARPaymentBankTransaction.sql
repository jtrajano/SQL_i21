CREATE VIEW [dbo].[vyuARPaymentBankTransaction]
AS
SELECT DISTINCT intPaymentId	= PAYMENTS.intSourceTransactionId
	 , strRecordNumber			= PAYMENTS.strSourceTransactionId
	 , intUndepositedFundId		= UNDEPOSITED.intUndepositedFundId
	 , strTransactionId 		= STUFF(_BANKTRANSACTIONS.strTransactionIds,1,1,'') COLLATE Latin1_General_CI_AS
FROM tblCMUndepositedFund UNDEPOSITED
INNER JOIN (
	SELECT intSourceTransactionId	= P.intPaymentId
		 , strSourceTransactionId	= P.strRecordNumber
	FROM tblARPayment P
	WHERE P.ysnPosted = 1

	UNION ALL

	SELECT intSourceTransactionId	= I.intInvoiceId
		 , strSourceTransactionId	= I.strInvoiceNumber
	FROM tblARInvoice I WITH (NOLOCK) 
	WHERE I.ysnPosted = 1
	  AND I.strTransactionType = 'Cash'
) PAYMENTS ON UNDEPOSITED.intSourceTransactionId = PAYMENTS.intSourceTransactionId
		  AND UNDEPOSITED.strSourceTransactionId = PAYMENTS.strSourceTransactionId
INNER JOIN tblCMBankTransactionDetail BANKTRANSACTIONDETAIL ON BANKTRANSACTIONDETAIL.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
CROSS APPLY (
	SELECT strTransactionIds = (
		SELECT ',' + ISNULL(strTransactionId,'') 
		FROM tblCMBankTransaction CBT
		INNER JOIN tblCMBankTransactionDetail CBTD ON CBT.intTransactionId = CBTD.intTransactionId
		WHERE CBTD.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
		FOR XML PATH(''))
) AS _BANKTRANSACTIONS