
GO
    DECLARE @rowUpdated  NVARCHAR(20)
	DECLARE @updateCount INT = 0
	DECLARE @tCount INT
	DECLARE @interval INT = 1000
	SELECT @tCount = COUNT(1) FROM tblGLDetail WHERE intFiscalPeriodId IS NULL


    WHILE  @updateCount < @tCount
	  BEGIN
	  	SET @updateCount = @updateCount + @interval

		;WITH cte as(
		    SELECT intGLDetailId,
			ROW_NUMBER() OVER (ORDER BY intGLDetailId) rowId
			from tblGLDetail WHERE intFiscalPeriodId IS NULL
		),
		cte1 AS(
			SELECT intGLDetailId FROM cte WHERE rowId <= @interval
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblGLDetail T 
		JOIN cte1 C ON C.intGLDetailId = T.intGLDetailId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblGLDetail')

		
	 END
GO