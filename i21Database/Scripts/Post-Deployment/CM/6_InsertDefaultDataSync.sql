GO
    DECLARE @rowUpdated  NVARCHAR(20)
    WHILE EXISTS(SELECT TOP 1 1 FROM tblCMBankTransaction WHERE intFiscalPeriodId IS NULL)
	  BEGIN
		;WITH cte as(
		    SELECT TOP 1000 intTransactionId from tblCMBankTransaction WHERE intFiscalPeriodId IS NULL
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransaction T 
		JOIN cte C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransaction')
	END
    WHILE EXISTS(SELECT TOP 1 1 FROM tblCMBankTransfer WHERE intFiscalPeriodId IS NULL)
	  BEGIN
		;WITH cte as(
		    SELECT TOP 1000 intTransactionId from tblCMBankTransfer WHERE intFiscalPeriodId IS NULL
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransfer T 
		JOIN cte C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransfer')
	END
GO