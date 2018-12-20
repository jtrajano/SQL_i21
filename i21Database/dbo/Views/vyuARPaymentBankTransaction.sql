CREATE VIEW [dbo].[vyuARPaymentBankTransaction]
AS
SELECT DISTINCT intPaymentId	= PAYMENTS.intPaymentId
	 , strRecordNumber			= PAYMENTS.strRecordNumber
	 , intUndepositedFundId		= UNDEPOSITED.intUndepositedFundId
	 , strTransactionId 		= STUFF(_BANKTRANSACTIONS.strTransactionIds,1,1,'') COLLATE Latin1_General_CI_AS
FROM tblCMUndepositedFund UNDEPOSITED
INNER JOIN tblARPayment PAYMENTS ON UNDEPOSITED.intSourceTransactionId = PAYMENTS.intPaymentId
							    AND UNDEPOSITED.strSourceTransactionId = PAYMENTS.strRecordNumber
								AND PAYMENTS.ysnPosted = 1
INNER JOIN tblCMBankTransactionDetail BANKTRANSACTIONDETAIL ON BANKTRANSACTIONDETAIL.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
CROSS APPLY (
	SELECT strTransactionIds = (
		SELECT ',' + ISNULL(strTransactionId,'') 
		FROM tblCMBankTransaction CBT
		INNER JOIN tblCMBankTransactionDetail CBTD ON CBT.intTransactionId = CBTD.intTransactionId
		WHERE CBTD.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
		FOR XML PATH(''))
) AS _BANKTRANSACTIONS