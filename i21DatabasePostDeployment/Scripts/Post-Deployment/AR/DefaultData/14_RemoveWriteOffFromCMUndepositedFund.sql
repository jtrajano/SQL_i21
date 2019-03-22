print('/*******************  BEGIN - Write Off Payments clean up  *******************/')
GO

DELETE FROM tblCMUndepositedFund
WHERE
	intUndepositedFundId IN 
	(
	SELECT 
		B.intUndepositedFundId
	FROM
		tblARPayment A
	INNER JOIN
		tblCMUndepositedFund B 
			ON A.intPaymentId = B.intSourceTransactionId 
			AND A.strRecordNumber = B.strSourceTransactionId
	LEFT OUTER JOIN
		tblCMBankTransactionDetail TD
			ON B.intUndepositedFundId = TD.intUndepositedFundId
	LEFT OUTER JOIN
		tblSMPaymentMethod SMPM
			ON A.intPaymentMethodId = SMPM.intPaymentMethodID			
	WHERE 
		B.strSourceSystem = 'AR'
		AND TD.intUndepositedFundId IS NULL
		AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) = UPPER('Write Off')
	)

	
GO
print('/*******************  END - Write Off Payments clean up  *******************/')
