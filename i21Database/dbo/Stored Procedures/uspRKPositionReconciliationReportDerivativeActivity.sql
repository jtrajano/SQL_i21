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
		,dtmFilledDate DATE
		,dblBuy  NUMERIC(18,6)
		,dblSell  NUMERIC(18,6)
		,strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intFutOptTransactionId INT
		,intFutOptTransactionHeaderId INT
		,ysnPreCrush BIT
		,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
	
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
			,dtmFilledDate
			,dblBuy
			,dblSell
			,strInternalTradeNo
			,intFutOptTransactionId
			,intFutOptTransactionHeaderId
			,ysnPreCrush
			,strCommodityCode
			,strAction)
		SELECT 
			dtmTransactionDate 
			,dtmFilledDate
			,dblBuy
			,dblSell
			,strInternalTradeNo
			,intFutOptTransactionId
			,intFutOptTransactionHeaderId
			,ysnPreCrush
			,@strCommodityCode
			,strAction
		FROM (
			select
				Row_Number() OVER (PARTITION BY H.dtmTransactionDate, H.intFutOptTransactionId, H.strAction, strNewBuySell ORDER BY  H.intFutOptTransactionHistoryId ASC, H.dtmTransactionDate ASC ) AS Row_Num 
				,H.dtmTransactionDate
				,H.dtmFilledDate
				,dblBuy = CASE WHEN strNewBuySell = 'Buy' THEN  dblLotBalance * dblContractSize ELSE 0 END
				,dblSell = CASE WHEN strNewBuySell = 'Sell' THEN dblLotBalance  * dblContractSize ELSE 0 END
				,H.strInternalTradeNo
				,H.intFutOptTransactionId
				,H.intFutOptTransactionHeaderId
				,H.strAction
				,ysnPreCrush = ISNULL(T.ysnPreCrush,0)
			from vyuRKGetFutOptTransactionHistory  H
				left join tblRKFutOptTransaction T on H.intFutOptTransactionId = T.intFutOptTransactionId
			where 
			H.intCommodityId = @intCommodityId
			and ISNULL(T.intCommodityId,@intCommodityId) = @intCommodityId --There are instance of history change for commodity, we need to do this
			and H.strInstrumentType = 'Futures'
			and dblLotBalance <> 0

			--Match Derivatives Buy
			UNION ALL
			SELECT
				1 AS Row_Num 
				, MD.dtmMatchDate
				, MD.dtmMatchDate
				, dblBuy = (ABS(SUM(MD.dblMatchQty)) * -1) * dblContractSize 
				, dblSell = 0
				, D.strInternalTradeNo
				, MD.intLFutOptTransactionId
				, D.intFutOptTransactionHeaderId
				, 'MATCH'
				,ysnPreCrush = ISNULL(D.ysnPreCrush,0)
			FROM tblRKMatchDerivativesHistory MD
			LEFT JOIN tblRKFutOptTransaction D ON D.intFutOptTransactionId = MD.intLFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = D.intFutureMarketId
			WHERE CAST(FLOOR(CAST(MD.dtmMatchDate AS FLOAT)) AS DATETIME) >= '01-01-1900'
				AND CAST(FLOOR(CAST(MD.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
				AND intCommodityId = @intCommodityId
			GROUP BY MD.intLFutOptTransactionId, intMatchFuturesPSDetailId, MD.dtmMatchDate, dblContractSize, strInternalTradeNo, intFutOptTransactionHeaderId,ysnPreCrush

			--Match Derivatives Sell
			UNION ALL
			SELECT
				1 AS Row_Num 
				, MD.dtmMatchDate
				, MD.dtmMatchDate
				, dblBuy = 0
				, dblSell = (ABS(SUM(MD.dblMatchQty))) * dblContractSize 
				, D.strInternalTradeNo
				, MD.intSFutOptTransactionId
				, D.intFutOptTransactionHeaderId
				, 'MATCH'
				,ysnPreCrush = ISNULL(D.ysnPreCrush,0)
			FROM tblRKMatchDerivativesHistory MD
			LEFT JOIN tblRKFutOptTransaction D ON D.intFutOptTransactionId = MD.intSFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = D.intFutureMarketId
			WHERE CAST(FLOOR(CAST(MD.dtmMatchDate AS FLOAT)) AS DATETIME) >= '01-01-1900'
				AND CAST(FLOOR(CAST(MD.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToTransactionDate
				AND intCommodityId = @intCommodityId
			GROUP BY MD.intSFutOptTransactionId, intMatchFuturesPSDetailId, MD.dtmMatchDate, dblContractSize, strInternalTradeNo, intFutOptTransactionHeaderId,ysnPreCrush

		) t
		WHERE Row_Num = 1
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
		,strTransactionId = strInternalTradeNo
		,intTransactionId = intFutOptTransactionId
		,intFutOptTransactionHeaderId
		,strCommodityCode
		,strAction
	INTO #tmpDerivativeActivity
	FROM @tblDerivativeHistory
	WHERE dtmTransactionDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate
	AND dtmFilledDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate

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
		,strTransactionId
		,intTransactionId
		,intFutOptTransactionHeaderId
		,strCommodityCode
		,dblFutBegBalForSummary
		,dblFutEndBalForSummary
		,dblCruBegBalForSummary
		,dblCruEndBalForSummary
		,strAction
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