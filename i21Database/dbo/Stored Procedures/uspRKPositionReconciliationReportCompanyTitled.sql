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
			,@dblInTransitBegBalance NUMERIC(18,6) = 0
	SELECT TOP 1 
		@ysnIncludeInTransitInCompanyTitled = ysnIncludeInTransitInCompanyTitled
	FROM tblRKCompanyPreference



	DECLARE @CompanyTitle AS TABLE (
		 dtmCreateDate DATETIME
		, dtmTransactionDate DATETIME
		, dblTotal NUMERIC(18,6)
		, intEntityId INT
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intLocationId INT
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTransactionRecordId INT
		, intOrigUOMId INT
		, ysnInTransit BIT DEFAULT (0)
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
			 dtmCreateDate
			, dtmTransactionDate
			, dblTotal
			, intEntityId
			, strEntityName
			, intLocationId
			, strLocationName
			, intItemId 
			, strItemNo 
			, intCommodityId 
			, strCommodityCode
			, strTransactionNumber 
			, strTransactionType 
			, intTransactionRecordId
			, intOrigUOMId 
		)
		SELECT
			 dtmCreateDate
			, dtmTransactionDate
			, dblTotal
			, intEntityId
			, strEntityName
			, intLocationId
			, strLocationName
			, intItemId 
			, strItemNo 
			, intCommodityId 
			, strCommodityCode
			, strTransactionNumber 
			, strTransactionType 
			, intTransactionRecordHeaderId
			, intOrigUOMId 
		FROM dbo.fnRKGetBucketCompanyOwned (@dtmToTransactionDate,@intCommodityId,NULL)


		INSERT INTO @CompanyTitle(
			dtmCreateDate
			,dtmTransactionDate
			,dblTotal
			,strTransactionNumber 
			,strTransactionType 
			,intTransactionRecordId
			,intCommodityId
			,ysnInTransit
		)
		SELECT 
			dtmCreateDate
			,dtmTransactionDate
			,dblTotal
			,strTransactionNumber
			,'Sales In-Transit'
			,intTransactionRecordId
			,@intCommodityId
			,1
		FROM dbo.fnRKGetBucketInTransit(@dtmToTransactionDate,@intCommodityId,NULL) InTran
		WHERE strBucketType = 'Sales In-Transit'
			AND @ysnIncludeInTransitInCompanyTitled = 1

			
		--SELECT 
		--	@dblInTransitBegBalance = @dblInTransitBegBalance + SUM(dblInTransitQty)
		--FROM dbo.fnICOutstandingInTransitAsOf(NULL, 1, DATEADD(day, -1, convert(date, @dtmFromTransactionDate))) InTran
		--WHERE @ysnIncludeInTransitInCompanyTitled = 1

	
		UPDATE @CompanyTitle SET strCommodityCode = @strCommodityCode WHERE intCommodityId = @intCommodityId

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

		
	SELECT 
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmCreateDate ASC))
		,dtmTransactionDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreateDate, 110), 110)
		,dblIn = CASE WHEN dblTotal > 0 THEN dblTotal ELSE 0 END
		,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dblTotal) ELSE 0 END
		,strTransactionId = strTransactionNumber
		,intTransactionId = intTransactionRecordId
		,strTransactionType
		,strCommodityCode
		,ysnInTransit = ISNULL(ysnInTransit,0)
	INTO #tmpCompanyTitled
	FROM @CompanyTitle
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreateDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
		--AND intTransactionId IS NOT NULL
	ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreateDate, 110), 110) 

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

	SELECT @dblCTBalanceForward =  SUM(ISNULL(dblTotal,0)) --+ ISNULL(@dblInTransitBegBalance,0)
	FROM @CompanyTitle
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreateDate, 110), 110) < CONVERT(DATETIME, @dtmFromTransactionDate)

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
		,strTransactionType
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
			,strTransactionType = ''
			,strCommodityCode = @strCommodities
			,dblCompTitledBegBalForSummary = @dblCTBalanceForward
			,dblCompTitledEndBalForSummary = @dblCTBalanceForward
	END

	ExitRoutine:
	DROP TABLE #tmpCompanyTitled
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity
END