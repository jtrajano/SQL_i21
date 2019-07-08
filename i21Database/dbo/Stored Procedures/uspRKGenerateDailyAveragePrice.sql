CREATE PROCEDURE [dbo].[uspRKGenerateDailyAveragePrice]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblRKDailyAveragePrice WHERE CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))
	BEGIN
		RAISERROR('Daily Average Price already exists for today.', 16, 1)
		RETURN
	END

	DECLARE @intDailyAveragePriceId INT
		, @strAverageNo NVARCHAR(50)
		, @dtmDate DATETIME = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
		, @intRowId INT
		, @bookId INT
		, @book NVARCHAR(50)
		, @subBookId INT
		, @subBook NVARCHAR(50)
		, @marketId INT
		, @market NVARCHAR(50)
		, @monthId INT
		, @month NVARCHAR(50)
		, @commodityId INT
		, @commodity NVARCHAR(50)

	DECLARE @DetailTable TABLE (intRowId INT IDENTITY
		, intBookId INT
		, strBook NVARCHAR(50)
		, intSubBookId INT
		, strSubBook NVARCHAR(50)
		, intFutureMarketId INT
		, strFutureMarket NVARCHAR(50)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(50)
		, intCommodityId INT
		, strCommodity NVARCHAR(50)
		, intBrokerId INT
		, strBrokerName NVARCHAR(100)
		, intTransactionId INT
		, strTransactionType NVARCHAR(50))

	DECLARE @Categories TABLE (intRowId INT
		, intBookId INT
		, strBook NVARCHAR(50)
		, intSubBookId INT
		, strSubBook NVARCHAR(50)
		, intFutureMarketId INT
		, strFutureMarket NVARCHAR(50)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(50))

	INSERT INTO @Categories (intRowId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth)
	SELECT DISTINCT intRowId = ROW_NUMBER() OVER (ORDER BY Book.intBookId, SubBook.intSubBookId, FM.intFutureMarketId, FM.intFutureMonthId DESC)
		, Book.intBookId
		, Book.strBook
		, SubBook.intSubBookId
		, SubBook.strSubBook
		, FM.intFutureMarketId
		, FM.strFutureMarket
		, FM.intFutureMonthId
		, FM.strFutureMonth
	FROM tblCTSubBook SubBook
	LEFT JOIN tblCTBook Book ON Book.intBookId = SubBook.intBookId
	CROSS APPLY (
		SELECT DISTINCT FMarket.intFutureMarketId
			, strFutureMarket = FMarket.strFutMarketName
			, FMonth.intFutureMonthId
			, FMonth.strFutureMonth
		FROM tblRKFuturesMonth FMonth
		LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = FMonth.intFutureMarketId
		WHERE FMonth.ysnExpired = 0
			AND FMarket.ysnActive = 1
	) FM
	WHERE Book.ysnActive = 1
		AND SubBook.ysnActive = 1
	ORDER BY Book.intBookId
		, Book.strBook
		, SubBook.intSubBookId
		, SubBook.strSubBook
		, FM.intFutureMarketId
		, FM.strFutureMarket
		, FM.intFutureMonthId
		, FM.strFutureMonth

	IF NOT EXISTS (SELECT TOP 1 1 FROM @Categories)
	BEGIN
		INSERT INTO @Categories(intRowId
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
			, intFutureMarketId
			, strFutureMarket
			, intFutureMonthId
			, strFutureMonth)
		SELECT 1
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
	END

	SELECT *
	INTO #tmpDerivatives
	FROM dbo.fnRKGetOpenFutureByDate(NULL, '1/1/1900', @dtmDate, 1)
	WHERE intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKDailyAveragePriceDetailTransaction)
		AND intFutureMonthId NOT IN (SELECT intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 1)

	WHILE EXISTS (SELECT TOP 1 1 FROM @Categories)
	BEGIN
		SELECT TOP 1 @intRowId = intRowId
			, @bookId = intBookId
			, @book = strBook
			, @subBookId  = intSubBookId
			, @subBook = strSubBook
			, @marketId = intFutureMarketId
			, @market = strFutureMarket
			, @monthId = intFutureMonthId
			, @month = strFutureMonth
		FROM @Categories
		
		INSERT INTO @DetailTable(intBookId
			, strBook
			, intSubBookId
			, strSubBook 
			, intFutureMarketId 
			, strFutureMarket 
			, intFutureMonthId
			, strFutureMonth
			, intCommodityId
			, strCommodity
			, intBrokerId
			, strBrokerName
			, intTransactionId
			, strTransactionType)
		SELECT DISTINCT intBookId
			, strBook
			, intSubBookId
			, strSubBook 
			, intFutureMarketId 
			, strFutureMarket 
			, intFutureMonthId
			, strFutureMonth
			, intCommodityId
			, strCommodityCode
			, intEntityId
			, strName
			, intFutOptTransactionId
			, 'FutOptTransaction'
		FROM #tmpDerivatives Derivative
		WHERE ISNULL(Derivative.intBookId, 0) = ISNULL(@bookId, ISNULL(Derivative.intBookId, 0))
			AND ISNULL(Derivative.intSubBookId, 0) = ISNULL(@subBookId, ISNULL(Derivative.intSubBookId, 0))
			AND Derivative.intFutureMarketId = ISNULL(@marketId, Derivative.intFutureMarketId)
			AND Derivative.intFutureMonthId = ISNULL(@monthId, Derivative.intFutureMonthId)
			AND dblOpenContract <> 0

		SET @intDailyAveragePriceId = NULL
		SELECT TOP 1 @intDailyAveragePriceId = intDailyAveragePriceId
		FROM tblRKDailyAveragePrice
		WHERE ISNULL(intBookId, 0) = ISNULL(@bookId, ISNULL(intBookId, 0))
			AND ISNULL(intSubBookId, 0) = ISNULL(@subBookId, ISNULL(intSubBookId, 0))
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) < @dtmDate
			AND ysnPosted = 1
		ORDER BY dtmDate DESC

		IF (ISNULL(@intDailyAveragePriceId, 0) = 0)
		BEGIN
			IF EXISTS (SELECT TOP 1 1
			FROM tblRKDailyAveragePrice
			WHERE ISNULL(intBookId, 0) = ISNULL(@bookId, ISNULL(intBookId, 0))
				AND ISNULL(intSubBookId, 0) = ISNULL(@subBookId, ISNULL(intSubBookId, 0))
				AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) < @dtmDate
				AND ysnPosted = 0
			ORDER BY dtmDate DESC)
			BEGIN
				DECLARE @ErrMsg NVARCHAR(200)
				SET @ErrMsg = 'An unposted previous daily average price'
								+ CASE WHEN ISNULL(@bookId, '') <> '' THEN ' Book: ' + @book ELSE ' ' END + ' '
								+ CASE WHEN ISNULL(@subBookId, '') <> '' THEN ' SubBook: ' + @subBook ELSE ' ' END + ' '
								+ CASE WHEN ISNULL(@marketId, '') <> '' THEN ' Future Market: ' + @market ELSE ' ' END + ' '
								+ CASE WHEN ISNULL(@monthId, '') <> '' THEN ' Future Month: ' + @month ELSE ' ' END + ' '
								+ 'was found. Please post all daily average prices before generating another.'
				RAISERROR(@ErrMsg, 16, 1)
				RETURN
			END
		END
		ELSE
		BEGIN
			INSERT INTO @DetailTable(intBookId
				, strBook
				, intSubBookId
				, strSubBook 
				, intFutureMarketId 
				, strFutureMarket 
				, intFutureMonthId
				, strFutureMonth
				, intCommodityId
				, strCommodity
				, intBrokerId
				, strBrokerName
				, intTransactionId
				, strTransactionType)
			SELECT Detail.intBookId
				, Detail.strBook
				, Detail.intSubBookId
				, Detail.strSubBook 
				, Detail.intFutureMarketId 
				, Detail.strFutureMarket 
				, Detail.intFutureMonthId
				, Detail.strFutureMonth
				, Detail.intCommodityId
				, Detail.strCommodity
				, Detail.intBrokerId
				, Detail.strBrokerName
				, Detail.intDailyAveragePriceDetailId
				, 'DailyAveragePrice'
			FROM vyuRKGetDailyAveragePriceDetail Detail
			LEFT JOIN tblRKFuturesMonth FM ON FM.intFutureMonthId = Detail.intFutureMonthId
			WHERE Detail.intDailyAveragePriceId = @intDailyAveragePriceId
				AND FM.ysnExpired <> 0			
		END

		DELETE FROM @Categories WHERE intRowId = @intRowId
	END

	SELECT intRowId = ROW_NUMBER() OVER (ORDER BY intBookId DESC)
		, *
	INTO #BookSubBook
	FROM (
		SELECT DISTINCT intBookId
			, intSubBookId
		FROM #tmpDerivatives
	) tbl

	IF NOT EXISTS (SELECT TOP 1 1 FROM #BookSubBook)
	BEGIN
		INSERT INTO #BookSubBook(intRowId, intBookId, intSubBookId)
		VALUES (1, NULL, NULL)
	END
	
	SELECT @intRowId = NULL
		, @bookId = NULL
		, @subBookId = NULL

	WHILE EXISTS (SELECT TOP 1 1 FROM #BookSubBook)
	BEGIN
		SELECT TOP 1 @intRowId = intRowId, @bookId = intBookId, @subBookId = intSubBookId FROM #BookSubBook

		EXEC uspSMGetStartingNumber @intStartingNumberId = 143
			, @strID = @strAverageNo OUTPUT

		IF (ISNULL(@strAverageNo, '') = '')
		BEGIN
			RAISERROR ('Starting Number for Daily Average Price is not setup.', 16, 1)
			RETURN
		END

		INSERT INTO tblRKDailyAveragePrice(strAverageNo
			, dtmDate
			, intBookId
			, intSubBookId)
		SELECT @strAverageNo
			, @dtmDate
			, @bookId
			, @subBookId

		SET @intDailyAveragePriceId = SCOPE_IDENTITY()

		INSERT INTO tblRKDailyAveragePriceDetail(intDailyAveragePriceId
			, intFutureMarketId
			, intCommodityId
			, intFutureMonthId
			, dblNoOfLots
			, dblAverageLongPrice
			, dblSwitchPL
			, dblOptionsPL
			, dblNetLongAvg
			, intBrokerId)
		SELECT DISTINCT @intDailyAveragePriceId
			, intFutureMarketId
			, intCommodityId
			, intFutureMonthId
			, dblNoOfLots = 0.00
			, dblAverageLongPrice = 0.00
			, dblSwitchPL = 0.00
			, dblOptionsPL = 0.00
			, dblNetLongAvg = 0.00
			, intBrokerId
		FROM @DetailTable
		WHERE ISNULL(intBookId, 0) = ISNULL(@bookId, ISNULL(intBookId, 0))
			AND ISNULL(intSubBookId, 0) = ISNULL(@subBookId, ISNULL(intSubBookId, 0))
			AND ISNULL(intFutureMarketId, 0) <> 0

		INSERT INTO tblRKDailyAveragePriceDetailTransaction(intDailyAveragePriceDetailId
			, intFutOptTransactionId
			, strTransactionType
			, dtmTransactionDate
			, strEntity
			, dblCommission
			, strBrokerageCommission
			, strInstrumentType
			, strLocation
			, strTrader
			, strCurrency
			, strInternalTradeNo
			, strBrokerTradeNo
			, strBuySell
			, dblNoOfContract
			, strOptionMonth
			, strOptionType
			, dblStrike
			, dblPrice
			, strReference
			, strStatus
			, dtmFilledDate
			, strReserveForFix
			, ysnOffset
			, strBank
			, strBankAccount
			, strContractNo
			, strContractSequenceNo
			, strSelectedInstrumentType
			, strFromCurrency
			, strToCurrency
			, dtmMaturityDate
			, dblContractAmount
			, dblExchangeRate
			, dblMatchAmount
			, dblAllocatedAmount
			, dblUnAllocatedAmount
			, dblSpotRate
			, ysnLiquidation
			, ysnSwap
			, strRefSwapTradeNo
			, dtmCreateDateTime
			, ysnFreezed
			, ysnPreCrush)
		SELECT Detail.intDailyAveragePriceDetailId
			, intFutOptTransactionId
			, 'FutOptTransaction'
			, Trans.dtmTransactionDate
			, strEntity = Trans.strName
			, 0
			, NULL
			, Trans.strInstrumentType
			, strLocation= Trans.strLocationName
			, strTrader = Trans.strBrokerageAccount
			, NULL
			, Trans.strInternalTradeNo
			, Trans.strBrokerTradeNo
			, Trans.strBuySell
			, Trans.dblOpenContract
			, Trans.strOptionMonthYear
			, Trans.strOptionType
			, Trans.dblStrike
			, Trans.dblPrice
			, NULL
			, Trans.strStatus
			, Trans.dtmFilledDate
			, NULL
			, NULL
			, Trans.strBankName
			, Trans.strBankAccountNo
			, Trans.strContractNumber
			, Trans.strSequenceNo
			, Trans.strSelectedInstrumentType
			, Trans.strFromCurrency
			, Trans.strToCurrency
			, Trans.dtmMaturityDate
			, Trans.dblContractAmount
			, Trans.dblExchangeRate
			, Trans.dblMatchAmount
			, Trans.dblAllocatedAmount
			, Trans.dblUnAllocatedAmount
			, Trans.dblSpotRate
			, Trans.ysnLiquidation
			, Trans.ysnSwap
			, Trans.strRefSwapTradeNo
			, Trans.dtmCreateDateTime
			, Trans.ysnFreezed
			, Trans.ysnPreCrush
		FROM vyuRKGetDailyAveragePriceDetail Detail
		JOIN @DetailTable Derivative ON ISNULL(Derivative.intBookId, 0) = ISNULL(@bookId, ISNULL(Derivative.intBookId, 0))
			AND ISNULL(Derivative.intSubBookId, 0) = ISNULL(@subBookId, ISNULL(Derivative.intSubBookId, 0))
			AND Derivative.intFutureMarketId = Detail.intFutureMarketId
			AND Derivative.intCommodityId = Detail.intCommodityId
			AND Derivative.intFutureMonthId = Detail.intFutureMonthId
		JOIN vyuRKFutOptTransaction Trans ON Trans.intFutOptTransactionId = Derivative.intTransactionId
		WHERE Detail.intDailyAveragePriceId = @intDailyAveragePriceId
			AND Derivative.strTransactionType = 'FutOptTransaction'

		INSERT INTO tblRKDailyAveragePriceDetailTransaction(intDailyAveragePriceDetailId
			, intRefDailyAveragePriceDetailId
			, strTransactionType
			, dtmTransactionDate
			, strEntity
			, dblNoOfContract
			, strInstrumentType
			, dblPrice)
		SELECT Detail.intDailyAveragePriceDetailId
			, Derivative.intTransactionId
			, 'DailyAveragePrice'
			, RefDetail.dtmDate
			, strEntity = RefDetail.strBrokerName
			, RefDetail.dblNoOfLots - (SELECT ISNULL(SUM(ISNULL(dblNoOfLots, 0)), 0) FROM tblCTPriceFixationDetail CT WHERE CT.intDailyAveragePriceDetailId = Detail.intDailyAveragePriceDetailId)
			, 'Futures'
			, RefDetail.dblNetLongAvg
		FROM vyuRKGetDailyAveragePriceDetail Detail
		JOIN @DetailTable Derivative ON ISNULL(Derivative.intBookId, 0) = ISNULL(@bookId, ISNULL(Derivative.intBookId, 0))
			AND ISNULL(Derivative.intSubBookId, 0) = ISNULL(@subBookId, ISNULL(Derivative.intSubBookId, 0))
			AND Derivative.intFutureMarketId = Detail.intFutureMarketId
			AND Derivative.intCommodityId = Detail.intCommodityId
			AND Derivative.intFutureMonthId = Detail.intFutureMonthId
		JOIN vyuRKGetDailyAveragePriceDetail RefDetail ON RefDetail.intDailyAveragePriceDetailId = Derivative.intTransactionId
		WHERE Detail.intDailyAveragePriceId = @intDailyAveragePriceId
			AND Derivative.strTransactionType = 'DailyAveragePrice'

		UPDATE tblRKDailyAveragePriceDetail
		SET dblAverageLongPrice = tblPatch.dblAvgLongPrice
			, dblNoOfLots = tblPatch.dblNoOfLots
		FROM (
			SELECT intDailyAveragePriceDetailId
				, dblAvgLongPrice = CASE WHEN ISNULL(dblOpenContract, 0) <> 0 THEN dblPriceByLots / dblOpenContract ELSE 0 END
				, dblNoOfLots
			FROM (
				SELECT intDailyAveragePriceDetailId
					, dblPriceByLots = SUM((CASE WHEN strBuySell = 'Buy' THEN dblPrice ELSE 0 END) * dblNoOfContract)
					, dblOpenContract = SUM((CASE WHEN strBuySell = 'Buy' THEN dblNoOfContract ELSE 0 END))
					, dblNoOfLots = SUM(dblNoOfContract)				
				FROM tblRKDailyAveragePriceDetailTransaction
				WHERE intDailyAveragePriceDetailId IN (SELECT intDailyAveragePriceDetailId FROM tblRKDailyAveragePriceDetail WHERE intDailyAveragePriceId = @intDailyAveragePriceId)
					AND strInstrumentType = 'Futures'
				GROUP BY intDailyAveragePriceDetailId
			) t
		) tblPatch
		WHERE tblPatch.intDailyAveragePriceDetailId = tblRKDailyAveragePriceDetail.intDailyAveragePriceDetailId

		DELETE FROM #BookSubBook WHERE intRowId = @intRowId
	END

	DROP TABLE #BookSubBook
	DROP TABLE #tmpDerivatives
END