GO
    DECLARE @rowUpdated  NVARCHAR(20)
	DECLARE @btCount INT
	DECLARE @updateCount INT = 0
	SELECT @btCount = COUNT(1) FROM tblCMBankTransaction WHERE intFiscalPeriodId IS NULL


    WHILE @updateCount < @btCount
	  BEGIN
	  	SET @updateCount = @updateCount + 1000
		;WITH cte as(
		    SELECT intTransactionId ,
			ROW_NUMBER() over(order by intTransactionId) rowId
			from tblCMBankTransaction 
			WHERE intFiscalPeriodId IS NULL
		),
		cte1 as(

			SELECT intTransactionId from cte WHERE rowId <=@updateCount
		)

        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransaction T 
		JOIN cte1 C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransaction')
	END


	SELECT @btCount = COUNT(1) FROM tblCMBankTransfer WHERE intFiscalPeriodId IS NULL
	SET @updateCount = 0

    WHILE @updateCount < @btCount
	  BEGIN
	  	SET @updateCount = @updateCount + 1000

		;WITH cte as(
		    SELECT intTransactionId,
			ROW_NUMBER() over(order by intTransactionId) rowId
			from tblCMBankTransfer WHERE intFiscalPeriodId IS NULL
		),
		cte1 as(

			SELECT intTransactionId from cte WHERE rowId <=@updateCount
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransfer T 
		JOIN cte1 C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransfer')
	END
GO