CREATE PROCEDURE uspRKPositionReconciliationReportCompanyTitled
	@strCommodityId NVARCHAR(100)  
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

BEGIN

	DECLARE @Commodity AS TABLE (
		 intCommodityId INT)
		
	
	INSERT INTO @Commodity(intCommodityId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strCommodityId, ',')

	DECLARE @ysnIncludeInTransitInCompanyTitled BIT
	SELECT TOP 1 
		@ysnIncludeInTransitInCompanyTitled = ysnIncludeInTransitInCompanyTitled
	FROM tblRKCompanyPreference



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
		,intCommodityId INT
		,strCommodityCode NVARCHAR(100)
		,ysnInTransit BIT DEFAULT (0)
	)
	
	
	DECLARE @intCommodityId INT
		,@strCommodities NVARCHAR(MAX)
		,@strCommodityCode NVARCHAR(100)

	SELECT DISTINCT com.intCommodityId, strCommodityCode
	INTO #tempCommodity
	FROM @Commodity com
	INNER JOIN tblICCommodity iccom on iccom.intCommodityId = com.intCommodityId
	WHERE ISNULL(com.intCommodityId, '') <> ''

	--Build concatenated commodities to be used if begin balance only (no record from given date range)
	SELECT @strCommodities =  COALESCE(@strCommodities + ', ' + strCommodityCode, strCommodityCode) FROM #tempCommodity

	WHILE EXISTS(SELECT TOP 1 1 FROM #tempCommodity)
	BEGIN

		SELECT TOP 1 
			@intCommodityId = intCommodityId
			,@strCommodityCode = strCommodityCode
		FROM #tempCommodity
		
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
			,intCommodityId
		)
		EXEC uspRKGetCompanyTitled @dtmFromTransactionDate = @dtmFromTransactionDate
			, @dtmToTransactionDate = @dtmToTransactionDate
			, @intCommodityId = @intCommodityId
			, @intItemId = null
			, @strPositionIncludes = null
			, @intLocationId = null

		
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
			,intCommodityId
			,ysnInTransit
		)
		SELECT 
			dtmDate
			,0
			,dblInTransitQty
			,0
			,0
			,strTransactionId
			,intTransactionId
			,''
			,0
			,@intCommodityId
			,1
		FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmToTransactionDate) InTran
		WHERE @ysnIncludeInTransitInCompanyTitled = 0

	
		UPDATE @CompanyTitle SET strCommodityCode = @strCommodityCode WHERE intCommodityId = @intCommodityId

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

	SELECT 
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
		,dtmTransactionDate = dtmDate
		,dblIn = CASE WHEN strDistribution IN('ADJ','IC','CM','DP', 'IT','IS', 'CLT', 'PRDC', 'CNSM','LG') AND  dblPaidBalance > 0 THEN dblPaidBalance ELSE dblUnpaidIncrease END
		,dblOut = CASE WHEN dblPaidBalance < 0 THEN ABS(dblPaidBalance) ELSE dblUnpaidDecrease END
		,strTransactionId
		,intTransactionId
		,strCommodityCode
		,ysnInTransit
	INTO #tmpCompanyTitled
	FROM @CompanyTitle
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
		AND intTransactionId IS NOT NULL
	ORDER BY dtmDate 

	SELECT	intRowNum, dtmTransactionDate 
	INTO #tempDateRange
	FROM #tmpCompanyTitled AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dtmDate DATE
		,dblCompTitledBegBalance  NUMERIC(18,6)
		,dblCompTitledEndBalance  NUMERIC(18,6)
		,dblCompTitledBegBalForSummary NUMERIC(18,6)
		,dblCompTitledEndBalForSummary NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dtmCurDate DATE
			,@dtmPrevDate DATE
			,@dblCTBalanceForward  NUMERIC(18,6)
			,@dblCompTitledBegBalForSummary NUMERIC(18,6)

	SELECT @dblCTBalanceForward =  SUM(ISNULL(dblCompanyTitled,0))
	FROM @CompanyTitle
	WHERE dtmDate IS NULL

	IF NOT EXISTS (SELECT TOP 1 * FROM #tempDateRange)
	BEGIN
		GOTO BeginBalanceOnly
	END

	While (Select Count(*) From #tempDateRange) > 0
	Begin

		Select Top 1 
			@intRowNum = intRowNum 
			,@dtmCurDate = dtmTransactionDate
		From #tempDateRange

		insert into @tblRunningBalance(
			intRowNum
			,dtmDate
			,dblCompTitledBegBalance
			,dblCompTitledEndBalance
		)
		select @intRowNum
			,dtmTransactionDate
			,ISNULL(@dblCTBalanceForward,0)
			,ISNULL(@dblCTBalanceForward,0) + ( dblIn - dblOut)  
		from #tmpCompanyTitled 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblCTBalanceForward = dblCompTitledEndBalance 
		from @tblRunningBalance where intRowNum = @intRowNum
		
		IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
		BEGIN
			SELECT @dblCompTitledBegBalForSummary =  dblCompTitledBegBalance
			FROM @tblRunningBalance
			WHERE dtmDate = @dtmCurDate
			
			UPDATE @tblRunningBalance 
			SET dblCompTitledBegBalForSummary = @dblCompTitledBegBalForSummary
				,dblCompTitledEndBalForSummary = @dblCTBalanceForward
			WHERE dtmDate = @dtmCurDate

		END

		IF @dtmCurDate = @dtmPrevDate
		BEGIN
			UPDATE @tblRunningBalance 
			SET dblCompTitledEndBalForSummary = @dblCTBalanceForward
			WHERE dtmDate = @dtmCurDate

			UPDATE @tblRunningBalance 
			SET dblCompTitledBegBalForSummary = @dblCompTitledBegBalForSummary
			WHERE dtmDate = @dtmCurDate
			AND dblCompTitledBegBalForSummary IS NULL
		END

		SET @dtmPrevDate = @dtmCurDate
		
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		CT.intRowNum
		,dtmTransactionDate
		,dblCompTitledBegBalance
		,dblIn
		,dblOut
		,dblCompTitledEndBalance
		,strTransactionId
		,intTransactionId
		,strCommodityCode
		,dblCompTitledBegBalForSummary
		,dblCompTitledEndBalForSummary
		,ysnInTransit
	FROM #tmpCompanyTitled CT
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = CT.intRowNum
	ORDER BY CT.dtmTransactionDate

	GOTO ExitRoutine

	BeginBalanceOnly:

	IF @dblCTBalanceForward IS NOT NULL
	BEGIN
		SELECT
			intRowNum =1
			,dtmTransactionDate = NULL
			,dblCompTitledBegBalance = @dblCTBalanceForward
			,dblIn = NULL
			,dblOut = NULL
			,dblCompTitledEndBalance = @dblCTBalanceForward
			,strTransactionId = 'Balance Forward'
			,intTransactionId = NULL
			,strCommodityCode = @strCommodities
			,dblCompTitledBegBalForSummary = @dblCTBalanceForward
			,dblCompTitledEndBalForSummary = @dblCTBalanceForward
			,ysnInTransit = 0
	END

	ExitRoutine:
	DROP TABLE #tmpCompanyTitled
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity
END