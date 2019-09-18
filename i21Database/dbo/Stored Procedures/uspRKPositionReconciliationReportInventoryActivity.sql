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
		, dblInvIn NUMERIC(24,10)
		, dblInvOut NUMERIC(24,10)
		, dblAdjustments NUMERIC(24,10)
		, dblInventoryCount NUMERIC(24,10)
		, dblBalanceInv NUMERIC(24,10)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(10)
		, dblSalesInTransit NUMERIC(24,10)
		, strTransactionType NVARCHAR(50)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(100)
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
			, dblInvIn
			, dblInvOut
			, dblAdjustments
			, dblInventoryCount
			, strTransactionId
			, intTransactionId
			, strDistribution
			, dblBalanceInv
			, dblSalesInTransit
			, strTransactionType
			, intCommodityId
		)
		EXEC uspRKGetInHouse
			 @dtmFromTransactionDate  = @dtmFromTransactionDate
			, @dtmToTransactionDate  = @dtmToTransactionDate
			, @intCommodityId  = @intCommodityId
			, @intItemId  = null
			, @strPositionIncludes  = NULL
			, @intLocationId  = NULL

		UPDATE @InHouse SET strCommodityCode = @strCommodityCode WHERE intCommodityId = @intCommodityId

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

	SELECT  
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate, Id ASC))
		,dtmTransactionDate =  dtmDate
		,dblInvIn = CASE 
						WHEN dblAdjustments IS NOT NULL AND dblAdjustments > 0 THEN 
							dblAdjustments 
						WHEN dblInventoryCount IS NOT NULL AND dblInventoryCount > 0 THEN 
							dblInventoryCount 
						ELSE 
							ISNULL(dblInvIn,0) 
					END
		,dblInvOut = CASE 
						WHEN dblAdjustments IS NOT NULL AND dblAdjustments < 0 THEN 
							ABS(dblAdjustments)
						WHEN dblInventoryCount IS NOT NULL AND dblInventoryCount < 0 THEN 
							ABS(dblInventoryCount)
						ELSE
							ISNULL(dblInvOut,0)
					END
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,strCommodityCode
	INTO #tmpInventoryActivity
	FROM @InHouse
	WHERE (dtmDate IS NOT NULL
		AND dblInvIn IS NOT NULL
		OR dblInvOut IS NOT NULL
		OR dblAdjustments IS NOT NULL
		OR dblInventoryCount IS NOT NULL
		OR strTransactionId IS NOT NULL
		OR intTransactionId IS NOT NULL
		OR strDistribution IS NOT NULL)


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
	)

	Declare @intRowNum int
			,@dtmCurDate DATE
			,@dtmPrevDate DATE
			,@dblInvBalanceForward  NUMERIC(18,6)
			,@dblInvBegBalForSummary NUMERIC(18,6)

	SELECT @dblInvBalanceForward =  SUM(dblBalanceInv)
	FROM @InHouse
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
			,dblInvBegBalance
			,dblInvEndBalance
		)
		select @intRowNum
			,dtmTransactionDate
			,@dblInvBalanceForward
			,@dblInvBalanceForward + ( dblInvIn - dblInvOut)  
		from #tmpInventoryActivity 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblInvBalanceForward = dblInvEndBalance 
		from @tblRunningBalance where intRowNum = @intRowNum

		IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
		BEGIN
			SELECT @dblInvBegBalForSummary =  dblInvBegBalance
			FROM @tblRunningBalance
			WHERE dtmDate = @dtmCurDate
			
			UPDATE @tblRunningBalance 
			SET dblInvBegBalForSummary = @dblInvBegBalForSummary
				,dblInvEndBalForSummary = @dblInvBalanceForward
			WHERE dtmDate = @dtmCurDate

		END

		IF @dtmCurDate = @dtmPrevDate
		BEGIN
			UPDATE @tblRunningBalance 
			SET dblInvEndBalForSummary = @dblInvBalanceForward
			WHERE dtmDate = @dtmCurDate

			UPDATE @tblRunningBalance 
			SET dblInvBegBalForSummary = @dblInvBegBalForSummary
			WHERE dtmDate = @dtmCurDate
			AND dblInvBegBalForSummary IS NULL
		END

		SET @dtmPrevDate = @dtmCurDate
						
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		IA.intRowNum
		,dtmTransactionDate
		,dblInvBegBalance
		,dblInvIn
		,dblInvOut
		,dblInvEndBalance
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,strCommodityCode
		,dblInvBegBalForSummary
		,dblInvEndBalForSummary
	FROM #tmpInventoryActivity IA
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = IA.intRowNum
	ORDER BY IA.dtmTransactionDate

	GOTO ExitRoutine

	BeginBalanceOnly:

	SELECT
		 intRowNum = 1
		,dtmTransactionDate = NULL
		,dblInvBegBalance = @dblInvBalanceForward
		,dblInvIn = NULL
		,dblInvOut = NULL
		,dblInvEndBalance = @dblInvBalanceForward
		,strTransactionType = 'Balance Forward'
		,strTransactionId = 'Balance Forward'
		,intTransactionId = NULL
		,strCommodityCode = @strCommodities
		,dblInvBegBalForSummary = @dblInvBalanceForward
		,dblInvEndBalForSummary = @dblInvBalanceForward


	ExitRoutine:
	DROP TABLE #tmpInventoryActivity
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity

END