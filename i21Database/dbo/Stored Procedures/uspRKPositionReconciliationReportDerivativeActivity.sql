CREATE PROCEDURE uspRKPositionReconciliationReportDerivativeActivity
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


	DECLARE @tblDerivativeHistory TABLE (Id INT identity(1,1)
		,dtmTransactionDate DATE
		,dblBuy  NUMERIC(18,6)
		,dblSell  NUMERIC(18,6)
		,strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intFutOptTransactionId INT
		,intFutOptTransactionHeaderId INT
		,ysnPreCrush BIT
		,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
	
	DECLARE @intCommodityId INT
		,@strCommodityCode NVARCHAR(100)
		,@strCommodities NVARCHAR(MAX)
		,@CrushReport BIT = 1

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
		
		INSERT INTO @tblDerivativeHistory (dtmTransactionDate 
			,dblBuy
			,dblSell
			,strInternalTradeNo
			,intFutOptTransactionId
			,intFutOptTransactionHeaderId
			,ysnPreCrush
			,strCommodityCode
			,strTransactionType)
		SELECT 
			dtmTransactionDate 
			,dblBuy
			,dblSell
			,strInternalTradeNo
			,intFutOptTransactionId = intTransactionRecordId
			,intFutOptTransactionHeaderId = intTransactionRecordHeaderId
			,ysnPreCrush
			,@strCommodityCode
			,strTransactionType
		FROM (
				SELECT * FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY sl.intTransactionRecordId ORDER BY sl.intSummaryLogId DESC)
						,dtmTransactionDate
						,dblBuy = CASE WHEN strDistributionType = 'Buy' THEN  dblOrigNoOfLots * dblContractSize ELSE 0 END
						,dblSell = CASE WHEN strDistributionType = 'Sell' THEN  dblOrigNoOfLots * dblContractSize ELSE 0 END
						,strInternalTradeNo = strTransactionNumber
						,intTransactionRecordId
						,intTransactionRecordHeaderId
						,ysnPreCrush
						,strCommodityCode
						,strTransactionType = sl.strTransactionType
						FROM vyuRKGetSummaryLog sl
						WHERE strTransactionType IN ('Derivative Entry')
							AND CONVERT(DATETIME, CONVERT(VARCHAR(10), sl.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
							AND CONVERT(DATETIME, CONVERT(VARCHAR(10), sl.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
							AND ISNULL(sl.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(sl.intCommodityId, 0)) 

					) t WHERE intRowNum = 1

					UNION ALL
					SELECT * FROM (
						SELECT  intRowNum = ROW_NUMBER() OVER (PARTITION BY sl.strDistributionType, sl.dtmTransactionDate ORDER BY sl.intSummaryLogId DESC)
						,dtmTransactionDate
						,dblBuy = CASE WHEN strDistributionType = 'Buy' THEN  (dblOrigNoOfLots * -1) * dblContractSize ELSE 0 END
						,dblSell = CASE WHEN strDistributionType = 'Sell' THEN  (dblOrigNoOfLots * -1) * dblContractSize ELSE 0 END
						,strInternalTradeNo = strTransactionNumber
						,intTransactionRecordId
						,intTransactionRecordHeaderId
						,ysnPreCrush
						,strCommodityCode
						,strTransactionType = sl.strTransactionType
						FROM vyuRKGetSummaryLog sl
						WHERE strTransactionType = 'Match Derivatives'
							AND CAST(FLOOR(CAST(dtmCreatedDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
							AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
							AND ISNULL(sl.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(sl.intCommodityId, 0)) 

					) t WHERE intRowNum = 1


					UNION ALL
					SELECT * FROM (
						SELECT  intRowNum = ROW_NUMBER() OVER (PARTITION BY sl.strDistributionType, sl.dtmTransactionDate ORDER BY sl.intSummaryLogId DESC)
						,dtmTransactionDate
						,dblBuy = CASE WHEN strDistributionType = 'Buy' THEN  (dblOrigNoOfLots * -1) * dblContractSize ELSE 0 END
						,dblSell = CASE WHEN strDistributionType = 'Sell' THEN  (dblOrigNoOfLots * -1) * dblContractSize ELSE 0 END
						,strInternalTradeNo = strTransactionNumber
						,intTransactionRecordId
						,intTransactionRecordHeaderId
						,ysnPreCrush
						,strCommodityCode
						,strTransactionType = sl.strTransactionType
						FROM vyuRKGetSummaryLog sl
						WHERE strTransactionType = 'Options Lifecycle'
							AND CAST(FLOOR(CAST(dtmCreatedDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
							AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
							AND ISNULL(sl.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(sl.intCommodityId, 0)) 

					) t WHERE intRowNum = 1
		) t
		ORDER BY  dtmTransactionDate, intFutOptTransactionId

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 


	SELECT  
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate, Id ASC))
		,dtmTransactionDate =  dtmTransactionDate
		,dblFuturesBuy = CASE WHEN ysnPreCrush = 0 THEN dblBuy ELSE 0 END
		,dblFuturesSell =  CASE WHEN ysnPreCrush = 0 THEN dblSell ELSE 0 END
		,dblCrushBuy = CASE WHEN ysnPreCrush = 1 THEN dblBuy ELSE 0 END
		,dblCrushSell =  CASE WHEN ysnPreCrush = 1 THEN dblSell ELSE 0 END
		,strTransactionType
		,strTransactionId = strInternalTradeNo
		,intTransactionId = intFutOptTransactionId
		,intFutOptTransactionHeaderId
		,strCommodityCode
	INTO #tmpDerivativeActivity
	FROM @tblDerivativeHistory
	WHERE dtmTransactionDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate
	--AND dtmFilledDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate

	SELECT	intRowNum, dtmTransactionDate 
	INTO #tempDateRange
	FROM #tmpDerivativeActivity AS d

	declare @tblRunningBalance as table (
		intRowNum  INT  NULL
		,dtmDate DATE
		,dblFutBegBalance  NUMERIC(18,6)
		,dblFutEndBalance  NUMERIC(18,6)
		,dblFutBegBalForSummary NUMERIC(18,6)
		,dblFutEndBalForSummary NUMERIC(18,6)
		,dblCruBegBalance  NUMERIC(18,6)
		,dblCruEndBalance  NUMERIC(18,6)
		,dblCruBegBalForSummary NUMERIC(18,6)
		,dblCruEndBalForSummary NUMERIC(18,6)
	)

	Declare @intRowNum int
			,@dtmCurDate DATE
			,@dtmPrevDate DATE
			,@dblFutBalanceForward  NUMERIC(18,6)
			,@dblFutBegBalForSummary NUMERIC(18,6)
			,@dblCruBalanceForward  NUMERIC(18,6)
			,@dblCruBegBalForSummary NUMERIC(18,6)

	SELECT 
		@dblFutBalanceForward =  SUM(ISNULL(CASE WHEN ysnPreCrush = 0 THEN dblBuy + dblSell END,0))
		,@dblCruBalanceForward =  SUM(ISNULL(CASE WHEN ysnPreCrush = 1 THEN dblBuy + dblSell END,0))
	FROM @tblDerivativeHistory
	WHERE dtmTransactionDate < @dtmFromTransactionDate



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
			,dblFutBegBalance
			,dblFutEndBalance
			,dblCruBegBalance
			,dblCruEndBalance
		)
		select @intRowNum
			,dtmTransactionDate
			,ISNULL(@dblFutBalanceForward,0)
			,ISNULL(@dblFutBalanceForward,0) + ( dblFuturesBuy + dblFuturesSell)  
			,ISNULL(@dblCruBalanceForward,0)
			,ISNULL(@dblCruBalanceForward,0) + ( dblCrushBuy + dblCrushSell)  
		from #tmpDerivativeActivity 
		WHERE intRowNum = @intRowNum
	
		select 
			@dblFutBalanceForward = dblFutEndBalance 
			,@dblCruBalanceForward = dblCruEndBalance
		from @tblRunningBalance where intRowNum = @intRowNum

		IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
		BEGIN
			SELECT @dblFutBegBalForSummary =  dblFutBegBalance
				 ,@dblCruBegBalForSummary =  dblCruBegBalance
			FROM @tblRunningBalance
			WHERE dtmDate = @dtmCurDate
			
			UPDATE @tblRunningBalance 
			SET dblFutBegBalForSummary = @dblFutBegBalForSummary
				,dblFutEndBalForSummary = @dblFutBalanceForward
				,dblCruBegBalForSummary = @dblCruBegBalForSummary
				,dblCruEndBalForSummary = @dblCruBalanceForward
			WHERE dtmDate = @dtmCurDate

		END

		IF @dtmCurDate = @dtmPrevDate
		BEGIN
			UPDATE @tblRunningBalance 
			SET dblFutEndBalForSummary = @dblFutBalanceForward
				,dblCruEndBalForSummary = @dblCruBalanceForward
			WHERE dtmDate = @dtmCurDate

			UPDATE @tblRunningBalance 
			SET dblFutBegBalForSummary = @dblFutBegBalForSummary
				,dblCruBegBalForSummary = @dblCruBegBalForSummary
			WHERE dtmDate = @dtmCurDate
			AND dblFutBegBalForSummary IS NULL
		END

		SET @dtmPrevDate = @dtmCurDate
						
		Delete #tempDateRange Where intRowNum = @intRowNum

	End

	SELECT
		IA.intRowNum
		,dtmTransactionDate
		,dblFutBegBalance
		,dblFuturesBuy
		,dblFuturesSell
		,dblFutEndBalance
		,dblCruBegBalance
		,dblCrushBuy
		,dblCrushSell
		,dblCruEndBalance
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,intFutOptTransactionHeaderId
		,strCommodityCode
		,dblFutBegBalForSummary
		,dblFutEndBalForSummary
		,dblCruBegBalForSummary
		,dblCruEndBalForSummary
	FROM #tmpDerivativeActivity IA
	FULL JOIN @tblRunningBalance RB on RB.intRowNum = IA.intRowNum
	ORDER BY IA.dtmTransactionDate

	GOTO ExitRoutine

	BeginBalanceOnly:

	IF @dblFutBalanceForward IS NOT NULL OR @dblCruBalanceForward IS NOT NULL
	BEGIN
		SELECT
			 intRowNum = 1
			,dtmTransactionDate = NULL
			,dblFutBegBalance = ISNULL(@dblFutBalanceForward,0)
			,dblFuturesBuy = NULL
			,dblFuturesSell = NULL
			,dblFutEndBalance = ISNULL(@dblFutBalanceForward,0)
			,dblCruBegBalance = ISNULL(@dblCruBalanceForward,0)
			,dblCrushBuy = NULL
			,dblCrushSell = NULL
			,dblCruEndBalance = ISNULL(@dblCruBalanceForward,0)
			,strTransactionId = 'Balance Forward'
			,strTransactionType = ''
			,intTransactionId = NULL
			,intFutOptTransactionHeaderId = NULL
			,strCommodityCode = @strCommodities
			,dblFutBegBalForSummary = ISNULL(@dblFutBalanceForward,0)
			,dblFutEndBalForSummary = ISNULL(@dblFutBalanceForward,0)
			,dblCruBegBalForSummary = ISNULL(@dblCruBalanceForward,0)
			,dblCruEndBalForSummary = ISNULL(@dblCruBalanceForward,0)
	END

	ExitRoutine:
	DROP TABLE #tmpDerivativeActivity
	DROP TABLE #tempDateRange
	DROP TABLE #tempCommodity
END