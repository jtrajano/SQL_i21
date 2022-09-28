
GO
    DECLARE @rowUpdated  NVARCHAR(20)	
    WHILE EXISTS(SELECT 1 FROM tblGLDetail WHERE intFiscalPeriodId IS NULL)
	  BEGIN
		;WITH cte as(
		    SELECT top 10000 intGLDetailId
			from tblGLDetail WHERE intFiscalPeriodId IS NULL
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblGLDetail T 
		JOIN cte C ON C.intGLDetailId = T.intGLDetailId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(50) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' + @rowUpdated +  ' records in tblGLDetail')
		
	 END
GO