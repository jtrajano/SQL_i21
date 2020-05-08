CREATE PROCEDURE [dbo].[uspRKPositionReconciliationReportInventoryActivity]
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


	DECLARE @InHouse TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, dblTotal NUMERIC(24,10)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strTransactionType NVARCHAR(50)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(100)
		, strOwnership NVARCHAR(20)
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
		
		INSERT INTO @InHouse (dtmDate
			, dblTotal
			, strTransactionId
			, intTransactionId
			, strTransactionType
			, intCommodityId
			, strCommodityCode
			, strOwnership
		)
		SELECT
			dtmTransactionDate
			,dblTotal
			,strTransactionNumber
			,intTransactionRecordHeaderId
			,strTransactionType
			,intCommodityId
			,strCommodityCode
			,strOwnership = 'Company Owned'
		FROM dbo.fnRKGetBucketCompanyOwned(@dtmToTransactionDate, @intCommodityId, NULL)

		UNION ALL
		SELECT
			dtmTransactionDate
			,dblTotal
			,strTransactionNumber
			,intTransactionRecordHeaderId
			,strTransactionType
			,intCommodityId
			,strCommodityCode
			,strOwnership = 'Customer Owned'
		FROM dbo.fnRKGetBucketCustomerOwned(@dtmToTransactionDate, @intCommodityId, NULL)


		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

	SELECT  
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate, Id ASC))
		,dtmTransactionDate =  dtmDate
		,dblInvIn = CASE WHEN dblTotal > 0 THEN
							dblTotal
						ELSE 
							0
					END
		,dblInvOut = CASE WHEN dblTotal < 0 THEN
							dblTotal * -1
						ELSE 
							0
					END
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,strCommodityCode
		,strOwnership
	INTO #tmpInventoryActivity
	FROM @InHouse
	WHERE dtmDate between @dtmFromTransactionDate and @dtmToTransactionDate

	SELECT	intRowNum, dtmTransactionDate 
	INTO #tempDateRange
	FROM #tmpInventoryActivity AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dtmDate DATE
		,dblInvBegBalance  NUMERIC(18,6)
		,dblInvEndBalance  NUMERIC(18,6)
		,dblInvBegBalForSummary NUMERIC(18,6)
		,dblInvEndBalForSummary NUMERIC(18,6)
		,dblCompanyOwnedBegBalance  NUMERIC(18,6)
		,dblCompanyOwnedEndBalance  NUMERIC(18,6)
		,dblCompanyOwnedBegBalForSummary NUMERIC(18,6)
		,dblCompanyOwnedEndBalForSummary NUMERIC(18,6)
		,dblCustomerOwnedBegBalance  NUMERIC(18,6)
		,dblCustomerOwnedEndBalance  NUMERIC(18,6)
		,dblCustomerOwnedBegBalForSummary NUMERIC(18,6)
		,dblCustomerOwnedEndBalForSummary NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dtmCurDate DATE
			,@dtmPrevDate DATE
			,@dblInvBalanceForward  NUMERIC(18,6)
			,@dblInvBegBalForSummary NUMERIC(18,6)
			,@dblCompanyOwnedBalanceForward  NUMERIC(18,6)
			,@dblCompanyOwnedBegBalForSummary NUMERIC(18,6)
			,@dblCompanyOwnedBegBalance NUMERIC(18,6)
			,@dblCompanyOwnedEndBalance NUMERIC(18,6)
			,@dblCustomerOwnedBalanceForward  NUMERIC(18,6)
			,@dblCustomerOwnedBegBalForSummary NUMERIC(18,6)
			,@dblCustomerOwnedBegBalance NUMERIC(18,6)
			,@dblCustomerOwnedEndBalance NUMERIC(18,6)

	SELECT 
		@dblInvBalanceForward =  SUM(ISNULL(dblTotal,0))
	FROM @InHouse
	WHERE dtmDate < @dtmFromTransactionDate
	AND strOwnership IN('Company Owned', 'Customer Owned')

	SELECT 
		@dblCompanyOwnedBalanceForward = SUM(ISNULL(dblTotal,0))
	FROM @InHouse
	WHERE dtmDate < @dtmFromTransactionDate
	AND strOwnership IN('Company Owned')

	SELECT 
		@dblCustomerOwnedBalanceForward = SUM(ISNULL(dblTotal,0))
	FROM @InHouse
	WHERE dtmDate < @dtmFromTransactionDate
	AND strOwnership IN('Customer Owned')

	
		
	
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
			,dblInvBegBalance
			,dblInvEndBalance
			,dblCompanyOwnedBegBalance
			,dblCompanyOwnedEndBalance
			,dblCustomerOwnedBegBalance
			,dblCustomerOwnedEndBalance
		)
		select @intRowNum
			,dtmTransactionDate
			,ISNULL(@dblInvBalanceForward,0)
			,ISNULL(@dblInvBalanceForward,0) + ( dblInvIn - dblInvOut)  
			,ISNULL(@dblCompanyOwnedBalanceForward,0)
			,ISNULL(@dblCompanyOwnedBalanceForward,0) + (CASE WHEN strOwnership = 'Company Owned' THEN  ( dblInvIn - dblInvOut) ELSE 0 END)
			,ISNULL(@dblCustomerOwnedBalanceForward,0)
			,ISNULL(@dblCustomerOwnedBalanceForward,0) + (CASE WHEN strOwnership = 'Customer Owned' THEN  ( dblInvIn - dblInvOut) ELSE 0 END)
		from #tmpInventoryActivity 
		WHERE intRowNum = @intRowNum

		select 
			@dblInvBalanceForward = dblInvEndBalance 
			,@dblCompanyOwnedBalanceForward = dblCompanyOwnedEndBalance
			,@dblCustomerOwnedBalanceForward = dblCustomerOwnedEndBalance
		from @tblRunningBalance where intRowNum = @intRowNum

		IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
		BEGIN
			SELECT 
				@dblInvBegBalForSummary =  dblInvBegBalance
				,@dblCompanyOwnedBegBalForSummary = dblCompanyOwnedBegBalance
				,@dblCustomerOwnedBegBalForSummary = dblCustomerOwnedBegBalance
			FROM @tblRunningBalance
			WHERE dtmDate = @dtmCurDate
			
			UPDATE @tblRunningBalance 
			SET dblInvBegBalForSummary = @dblInvBegBalForSummary
				,dblInvEndBalForSummary = @dblInvBalanceForward
				,dblCompanyOwnedBegBalForSummary = @dblCompanyOwnedBegBalForSummary
				,dblCompanyOwnedEndBalForSummary = @dblCompanyOwnedBalanceForward
				,dblCustomerOwnedBegBalForSummary = @dblCustomerOwnedBegBalForSummary
				,dblCustomerOwnedEndBalForSummary = @dblCustomerOwnedBalanceForward
			WHERE dtmDate = @dtmCurDate

		END

		IF @dtmCurDate = @dtmPrevDate
		BEGIN
			UPDATE @tblRunningBalance 
			SET dblInvEndBalForSummary = @dblInvBalanceForward
				,dblCompanyOwnedEndBalForSummary = @dblCompanyOwnedBalanceForward
				,dblCustomerOwnedEndBalForSummary = @dblCustomerOwnedBalanceForward
			WHERE dtmDate = @dtmCurDate

			UPDATE @tblRunningBalance 
			SET dblInvBegBalForSummary = @dblInvBegBalForSummary
				,dblCompanyOwnedBegBalForSummary = @dblCompanyOwnedBegBalForSummary
				,dblCustomerOwnedBegBalForSummary = @dblCustomerOwnedBegBalForSummary
			WHERE dtmDate = @dtmCurDate
			AND dblInvBegBalForSummary IS NULL
		END

		SET @dtmPrevDate = @dtmCurDate
						
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		IA.intRowNum
		,dtmTransactionDate
		,dblCompanyOwnedBegBalance
		,dblCompanyOwnedIn = (CASE WHEN strOwnership = 'Company Owned' THEN dblInvIn ELSE 0 END)
		,dblCompanyOwnedOut = (CASE WHEN strOwnership = 'Company Owned' THEN dblInvOut ELSE 0 END)
		,dblCompanyOwnedEndBalance
		,dblCustomerOwnedBegBalance
		,dblCustomerOwnedIn = (CASE WHEN strOwnership = 'Customer Owned' THEN dblInvIn ELSE 0 END)
		,dblCustomerOwnedOut = (CASE WHEN strOwnership = 'Customer Owned' THEN dblInvOut ELSE 0 END)
		,dblCustomerOwnedEndBalance
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,strCommodityCode
		,dblInvBegBalance
		,dblInvIn
		,dblInvOut
		,dblInvEndBalance
		,dblCompanyOwnedBegBalForSummary
		,dblCompanyOwnedEndBalForSummary
		,dblCustomerOwnedBegBalForSummary
		,dblCustomerOwnedEndBalForSummary
		,dblInvBegBalForSummary
		,dblInvEndBalForSummary
		,strOwnership
	FROM #tmpInventoryActivity IA
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = IA.intRowNum
	ORDER BY IA.dtmTransactionDate

	GOTO ExitRoutine

	BeginBalanceOnly:

	IF @dblInvBalanceForward IS NOT NULL
	BEGIN
		SELECT
			 intRowNum = 1
			,dtmTransactionDate = NULL
			,dblCompanyOwnedBegBalance = @dblCompanyOwnedBalanceForward
			,dblCompanyOwnedIn = NULL
			,dblCompanyOwnedOut = NULL
			,dblCompanyOwnedEndBalance = @dblCompanyOwnedBalanceForward
			,dblCustomerOwnedBegBalance = @dblCustomerOwnedBalanceForward
			,dblCustomerOwnedIn = NULL
			,dblCustomerOwnedOut = NULL
			,dblCustomerOwnedEndBalance = @dblCustomerOwnedBalanceForward
			,strTransactionType = 'Balance Forward'
			,strTransactionId = 'Balance Forward'
			,intTransactionId = NULL
			,strCommodityCode = @strCommodities
			,dblInvBegBalance = @dblInvBalanceForward
			,dblInvIn = NULL
			,dblInvOut = NULL
			,dblInvEndBalance = @dblInvBalanceForward
			,dblCompanyOwnedBegBalForSummary = @dblCompanyOwnedBalanceForward
			,dblCompanyOwnedEndBalForSummary = @dblCompanyOwnedBalanceForward
			,dblCustomerOwnedBegBalForSummary = @dblCustomerOwnedBalanceForward
			,dblCustomerOwnedEndBalForSummary = @dblCustomerOwnedBalanceForward
			,dblInvBegBalForSummary = @dblInvBalanceForward
			,dblInvEndBalForSummary = @dblInvBalanceForward
			,strOwnership = ''
	END

	ExitRoutine:
	DROP TABLE #tmpInventoryActivity
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity

END