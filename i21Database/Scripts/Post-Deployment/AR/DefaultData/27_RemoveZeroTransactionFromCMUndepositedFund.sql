print('/*******************  BEGIN Delete AR Transactions with dblAmount 0 and with Bank Deposit Id  *******************/')
GO

DELETE FROM tblCMBankTransactionDetail 
WHERE intUndepositedFundId IN 
(
	SELECT 
		intUndepositedFundId
	FROM 
		tblCMUndepositedFund 
	WHERE 
		ISNULL(dblAmount,0) = 0 
		AND strSourceSystem = 'AR' 
		AND intBankDepositId IS NOT NULL
)

DELETE FROM tblCMUndepositedFund
WHERE 
	ISNULL(dblAmount,0) = 0 
	AND strSourceSystem = 'AR' 
	AND intBankDepositId IS NOT NULL

print('/*******************  END Delete AR Transactions with dblAmount 0 and with Bank Deposit Id  *******************/')


print('/*******************  BEGIN Delete AR Transactions with dblAmount 0 and no Bank Deposit Id  *******************/')
--- 
DELETE FROM tblCMUndepositedFund 
WHERE ISNULL(dblAmount,0) = 0
	 AND strSourceSystem = 'AR'
	 AND intBankDepositId IS NULL

	
GO
print('/*******************  END Delete AR Transactions with dblAmount 0 and no Bank Deposit Id  *******************/')
