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


	DECLARE @tblGetOpenFutureByDate TABLE (Id INT identity(1,1)
		, intFutOptTransactionId INT
		, dtmTransactionDate DATE
		, dblOpenContract NUMERIC(18,6)
		, dblMatchContract NUMERIC(18,6)
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblContractSize NUMERIC(24,10)
		, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblStrike NUMERIC(24,10)
		, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId int
		, ysnPreCrush BIT
		, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
	
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
		
		INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId
				, dtmTransactionDate
				, dblOpenContract
				, dblMatchContract
				, strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, dblContractSize
				, strFutureMarket
				, strFutureMonth
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, strNewBuySell
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strNotes
				, strBrokerTradeNo)
			SELECT intFutOptTransactionId
				, dtmTransactionDate
				, dblOpenContract
				, dblMatchContract
				, strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, dblContractSize
				, strFutureMarket
				, strFutureMonth
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, strNewBuySell
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strNotes
				, strBrokerTradeNo
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '01/01/1900', @dtmToTransactionDate, @CrushReport)
			WHERE intCommodityId = @intCommodityId

		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
	END 

	SELECT  
		intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate, Id ASC))
		,dtmTransactionDate =  dtmTransactionDate
		,dblFuturesBuy = CASE 
						WHEN strNewBuySell = 'Buy' AND ISNULL(ysnPreCrush,0) = 0 THEN 
							dblOpenContract * dblContractSize 
							--CASE WHEN dblOpenContract <> 0 THEN
							--		dblOpenContract * dblContractSize 
							--	ELSE
							--		dblMatchContract * dblContractSize 
							--END
						ELSE 
							0
					END
		,dblFuturesSell = CASE 
						WHEN strNewBuySell = 'Sell' AND ISNULL(ysnPreCrush,0) = 0 THEN 
							dblOpenContract * dblContractSize 
							--CASE WHEN dblOpenContract <> 0 THEN
							--		dblOpenContract * dblContractSize 
							--	ELSE
							--		dblMatchContract * dblContractSize 
							--END
						ELSE 
							0
					END
		,dblCrushBuy = CASE 
						WHEN strNewBuySell = 'Buy' AND ISNULL(ysnPreCrush,0) = 1 THEN 
							dblOpenContract * dblContractSize 
							--CASE WHEN dblOpenContract <> 0 THEN
							--		dblOpenContract * dblContractSize 
							--	ELSE
							--		dblMatchContract * dblContractSize 
							--END
						ELSE 
							0
					END
		,dblCrushSell = CASE 
						WHEN strNewBuySell = 'Sell' AND ISNULL(ysnPreCrush,0) =1 THEN 
							dblOpenContract * dblContractSize 
							--CASE WHEN dblOpenContract <> 0 THEN
							--		dblOpenContract * dblContractSize 
							--	ELSE
							--		dblMatchContract * dblContractSize 
							--END
						ELSE 
							0
					END
		,strTransactionId = strInternalTradeNo
		,intTransactionId = intFutOptTransactionId
		,intFutOptTransactionHeaderId
		,strCommodityCode
	INTO #tmpDerivativeActivity
	FROM @tblGetOpenFutureByDate
	WHERE dtmTransactionDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate
	

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
		@dblFutBalanceForward =  SUM(CASE WHEN ISNULL(ysnPreCrush,0) = 0 THEN dblOpenContract * dblContractSize END)
		,@dblCruBalanceForward =  SUM(CASE WHEN ISNULL(ysnPreCrush,0) = 1 THEN dblOpenContract * dblContractSize END)
	FROM @tblGetOpenFutureByDate
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
			,@dblFutBalanceForward
			,@dblFutBalanceForward + ( dblFuturesBuy + dblFuturesSell)  
			,@dblCruBalanceForward
			,@dblCruBalanceForward + ( dblCrushBuy + dblCrushSell)  
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
			,dblCurEndBalance = ISNULL(@dblCruBalanceForward,0)
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