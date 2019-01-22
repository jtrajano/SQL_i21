-- clean FK in tblCMBankTransactionDetail WITH NO MATCHING RECORD IN tblCMUndepositedFund before applying foreign key
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE UPPER(TABLE_NAME) = 'TBLCMBANKTRANSACTIONDETAIL')
BEGIN
EXEC('
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMDataFixLog WHERE strDescription =''Fix tblCMBankTransactionDetail orphan intUndepositedId on tblCMUndepositedFund'')
	BEGIN
		WITH BT as(
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
		INSERT INTO tblCMDataFixLog VALUES (GETDATE(), ''Fix tblCMBankTransactionDetail orphan intUndepositedId on tblCMUndepositedFund'' , @@ROWCOUNT)
	END
')

END

