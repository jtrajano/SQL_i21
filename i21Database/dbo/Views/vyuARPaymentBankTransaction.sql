CREATE VIEW [dbo].[vyuARPaymentBankTransaction]
AS
SELECT DISTINCT PAYMENTS.intPaymentId, PAYMENTS.strRecordNumber,UNDEPOSITED.intUndepositedFundId, STUFF(_BANKTRANSACTIONS.strTransactionIds,1,1,'') as strTransactionId FROM tblCMUndepositedFund UNDEPOSITED
INNER JOIN tblARPayment PAYMENTS
	ON UNDEPOSITED.intSourceTransactionId = PAYMENTS.intPaymentId
INNER JOIN tblCMBankTransactionDetail BANKTRANSACTIONDETAIL
	ON BANKTRANSACTIONDETAIL.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
CROSS APPLY (SELECT (SELECT ',' + ISNULL(strTransactionId,'') FROM tblCMBankTransaction CBT
			INNER JOIN tblCMBankTransactionDetail CBTD
				ON CBT.intTransactionId = CBTD.intTransactionId
			WHERE CBTD.intUndepositedFundId = UNDEPOSITED.intUndepositedFundId
			FOR XML PATH('')) as strTransactionIds) AS _BANKTRANSACTIONS