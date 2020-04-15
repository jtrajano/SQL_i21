-- clean FK in tblCMBankTransactionDetail WITH NO MATCHING RECORD IN tblCMUndepositedFund before applying foreign key
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE UPPER(TABLE_NAME)  = 'TBLCMBANKTRANSACTIONDETAIL')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE UPPER(TABLE_NAME)  =  'TBLCMUNDEPOSITEDFUND')
BEGIN
EXEC('
	BEGIN
		;WITH BT as(
			SELECT intUndepositedFundId, intTransactionDetailId FROM  tblCMBankTransactionDetail 
			WHERE intUndepositedFundId IS NOT NULL
		),
		idWithNoUndep as (
			SELECT A.intUndepositedFundId UndepId, B.intUndepositedFundId DetailId
			FROM tblCMUndepositedFund A RIGHT JOIN BT B
			ON A.intUndepositedFundId = B.intUndepositedFundId
			WHERE A.intUndepositedFundId IS NULL
		)
		UPDATE CM SET intUndepositedFundId = NULL 
		FROM tblCMBankTransactionDetail CM JOIN idWithNoUndep U ON U.DetailId = CM.intUndepositedFundId 
	END
')

END

