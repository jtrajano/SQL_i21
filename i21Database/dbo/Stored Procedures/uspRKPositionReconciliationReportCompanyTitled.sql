CREATE PROCEDURE uspRKPositionReconciliationReportCompanyTitled
	@intCommodityId INT 
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS


--declare
--	 @dtmFromTransactionDate date = '06/01/2019'
--	, @dtmToTransactionDate date = '07/31/2019'
--	, @intCommodityId  int= 2

BEGIN

	DECLARE @CompanyTitle AS TABLE (
		dtmDate  DATE  NULL
		,dblUnpaidIncrease  NUMERIC(18,6)
		,dblUnpaidDecrease  NUMERIC(18,6)
		,dblUnpaidBalance  NUMERIC(18,6)
		,dblPaidBalance  NUMERIC(18,6)
		,strTransactionId NVARCHAR(50)
		,intTransactionId INT
		,strDistribution NVARCHAR(10)
		,dblCompanyTitled NUMERIC(18,6)
	)
		
	INSERT INTO @CompanyTitle(
		dtmDate
		,dblUnpaidIncrease 
		,dblUnpaidDecrease 
		,dblUnpaidBalance  
		,dblPaidBalance  
		,strTransactionId
		,intTransactionId 
		,strDistribution
		,dblCompanyTitled
	)
	EXEC uspRKGetCompanyTitled @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = null
		, @strPositionIncludes = null
		, @intLocationId = null


	SELECT 
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
		,dtmTransactionDate = dtmDate
		,dblIn = CASE WHEN strDistribution IN('ADJ','IC','CM','DP', 'IT','IS', 'CLT', 'PRDC') AND  dblPaidBalance > 0 THEN dblPaidBalance ELSE dblUnpaidIncrease END
		,dblOut = CASE WHEN dblPaidBalance < 0 THEN ABS(dblPaidBalance) ELSE dblUnpaidDecrease END
		,strTransactionId
		,intTransactionId
	INTO #tmpCompanyTitled
	FROM @CompanyTitle
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
		AND intTransactionId IS NOT NULL
	ORDER BY dtmDate 

	SELECT	intRowNum 
	INTO #tempDateRange
	FROM #tmpCompanyTitled AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dblCompanyTitled  NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dblCTBeginBalance  NUMERIC(18,6)

	SELECT @dblCTBeginBalance =  dblCompanyTitled
	FROM @CompanyTitle
	WHERE dtmDate IS NULL

	insert into @tblRunningBalance(
		intRowNum
		,dblCompanyTitled
	)
	values(null,@dblCTBeginBalance)
	

	While (Select Count(*) From #tempDateRange) > 0
	Begin

		Select Top 1 @intRowNum = intRowNum From #tempDateRange

		insert into @tblRunningBalance(
			intRowNum
			,dblCompanyTitled
		)
		select @intRowNum
			,@dblCTBeginBalance + ( dblIn - dblOut)  
		from #tmpCompanyTitled 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblCTBeginBalance = dblCompanyTitled 
		from @tblRunningBalance where intRowNum = @intRowNum
						
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		CT.intRowNum
		,dtmTransactionDate
		,dblIn
		,dblOut
		,dblCompanyTitled
		,strTransactionId
		,intTransactionId
	FROM #tmpCompanyTitled CT
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = CT.intRowNum
	ORDER BY CT.dtmTransactionDate


	DROP TABLE #tmpCompanyTitled
	DROP TABLE #tempDateRange
END