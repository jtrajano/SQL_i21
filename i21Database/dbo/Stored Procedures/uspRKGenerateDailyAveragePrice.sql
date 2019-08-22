﻿CREATE PROCEDURE [dbo].[uspRKGenerateDailyAveragePrice]

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
		, @ErrMsg NVARCHAR(200)

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

	SELECT DER.*
	INTO #tmpDerivatives
	FROM dbo.fnRKGetOpenFutureByDate(NULL, '1/1/1900', @dtmDate, 1) DER
	LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = DER.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = DER.intFutureMonthId
	LEFT JOIN tblCTBook Book ON Book.intBookId = DER.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = DER.intSubBookId
	WHERE intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKDailyAveragePriceDetailTransaction)
		AND DER.intFutureMonthId NOT IN (SELECT intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 1)
		AND dblOpenContract <> 0
		AND FMarket.ysnActive = 1
		AND FMonth.ysnExpired = 0
		AND ISNULL(Book.ysnActive, 1) = 1
		AND ISNULL(SubBook.ysnActive, 1) = 1

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

	INSERT INTO @Categories(intRowId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth)
	SELECT 0
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL

	SELECT DISTINCT intRowId
		, intBookId
		, intSubBookId
		, strBook
		, strSubBook
	INTO #tmpHeaderGroups		
	FROM @Categories

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpHeaderGroups)
	BEGIN
		SELECT TOP 1 @intRowId = intRowId
			, @bookId = intBookId
			, @book = strBook
			, @subBookId  = intSubBookId
			, @subBook = strSubBook
		FROM #tmpHeaderGroups
		
		IF (ISNULL(@intRowId, 0) = 0)
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
			WHERE (Derivative.intBookId IS NULL)
				AND (Derivative.intSubBookId IS NULL)
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
			WHERE ((Derivative.intBookId IS NULL AND @bookId IS NULL) OR (Derivative.intBookId = @bookId))
				AND ((Derivative.intSubBookId IS NULL AND @subBookId IS NULL) OR (Derivative.intSubBookId = @subBookId))
		END

		SET @intDailyAveragePriceId = NULL
		SELECT TOP 1 @intDailyAveragePriceId = intDailyAveragePriceId
		FROM tblRKDailyAveragePrice
		WHERE ((intBookId IS NULL AND @bookId IS NULL) OR (intBookId = @bookId))
			AND ((intSubBookId IS NULL AND @subBookId IS NULL) OR (intSubBookId = @subBookId))
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) < @dtmDate
			AND ysnPosted = 1
		ORDER BY dtmDate DESC

		IF (ISNULL(@intDailyAveragePriceId, 0) = 0)
		BEGIN
			IF EXISTS (SELECT TOP 1 1
			FROM tblRKDailyAveragePrice
			WHERE ((intBookId IS NULL AND @bookId IS NULL) OR (intBookId = @bookId))
				AND ((intSubBookId IS NULL AND @subBookId IS NULL) OR (intSubBookId = @subBookId))
				AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) < @dtmDate
				AND ysnPosted = 0
			ORDER BY dtmDate DESC)
			BEGIN
				SET @ErrMsg = 'An unposted previous daily average price was found. Please post all daily average prices before generating another.'
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
				AND FM.ysnExpired = 0
		END

		DELETE FROM #tmpHeaderGroups WHERE intRowId = @intRowId
	END

	DROP TABLE #tmpHeaderGroups

	SELECT intRowId = ROW_NUMBER() OVER (ORDER BY intBookId DESC)
		, *
	INTO #BookSubBook
	FROM (
		SELECT DISTINCT intBookId
			, intSubBookId
		FROM @DetailTable
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

		SELECT DISTINCT intFutureMarketId
			, intCommodityId
			, intFutureMonthId
			, dblNoOfLots = 0.00
			, dblAverageLongPrice = 0.00
			, dblSwitchPL = 0.00
			, dblOptionsPL = 0.00
			, dblNetLongAvg = 0.00
			, intBrokerId
		INTO #tmpDetailTable
		FROM @DetailTable
		WHERE ((intBookId IS NULL AND @bookId IS NULL) OR (intBookId = @bookId))
			AND ((intSubBookId IS NULL AND @subBookId IS NULL) OR (intSubBookId = @subBookId))

		IF EXISTS (SELECT TOP 1 1 FROM #tmpDetailTable)
		BEGIN
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
				, dblNoOfLots
				, dblAverageLongPrice
				, dblSwitchPL
				, dblOptionsPL
				, dblNetLongAvg
				, intBrokerId
			FROM #tmpDetailTable

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
			SELECT DISTINCT Detail.intDailyAveragePriceDetailId
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
			JOIN @DetailTable Derivative ON ((Derivative.intBookId IS NULL AND @bookId IS NULL) OR (Derivative.intBookId = @bookId))
				AND ((Derivative.intSubBookId IS NULL AND @subBookId IS NULL) OR (Derivative.intSubBookId = @subBookId))
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
				, dblPrice
				, strBuySell)
			SELECT DISTINCT Detail.intDailyAveragePriceDetailId
				, RefDetail.intDailyAveragePriceDetailId
				, 'DailyAveragePrice'
				, Detail.dtmDate
				, strEntity = Detail.strBrokerName
				, RefDetail.dblNoOfLots - (SELECT ISNULL(SUM(ISNULL(dblNoOfLots, 0)), 0) FROM tblCTPriceFixationDetail CT WHERE CT.intDailyAveragePriceDetailId = RefDetail.intDailyAveragePriceDetailId)
				, 'Futures'
				, dblNetLongAvg = ISNULL(RefDetail.dblAverageLongPrice, 0.00) + ISNULL(RefDetail.dblSwitchPL, 0.00) + ISNULL(RefDetail.dblOptionsPL, 0.00)
				, 'Buy'
			FROM @DetailTable Derivative
			JOIN vyuRKGetDailyAveragePriceDetail Detail ON ((Detail.intBookId IS NULL AND @bookId IS NULL) OR (Detail.intBookId = @bookId))
				AND ((Detail.intSubBookId IS NULL AND @subBookId IS NULL) OR (Detail.intSubBookId = @subBookId))
				AND Detail.intFutureMarketId = Derivative.intFutureMarketId
				AND Detail.intCommodityId = Derivative.intCommodityId
				AND Detail.intFutureMonthId = Derivative.intFutureMonthId
				AND Detail.intDailyAveragePriceId = @intDailyAveragePriceId
			JOIN vyuRKGetDailyAveragePriceDetail RefDetail ON ((RefDetail.intBookId IS NULL AND @bookId IS NULL) OR (RefDetail.intBookId = @bookId))
				AND ((RefDetail.intSubBookId IS NULL AND @subBookId IS NULL) OR (RefDetail.intSubBookId = @subBookId))
				AND RefDetail.intFutureMarketId = Derivative.intFutureMarketId
				AND RefDetail.intCommodityId = Derivative.intCommodityId
				AND RefDetail.intFutureMonthId = Derivative.intFutureMonthId
				AND RefDetail.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId FROM tblRKDailyAveragePrice
														WHERE dtmDate < GETDATE()
															AND ((intBookId IS NULL AND @bookId IS NULL) OR (intBookId = @bookId))
															AND ((intSubBookId IS NULL AND @subBookId IS NULL) OR (intSubBookId = @subBookId))
															AND ysnPosted = 1
														ORDER BY dtmDate DESC)
			WHERE ISNULL(RefDetail.dblNoOfLots, 0) <> 0


			UPDATE tblRKDailyAveragePriceDetail
			SET dblAverageLongPrice = tblPatch.dblAvgLongPrice
				, dblNoOfLots = tblPatch.dblNoOfLots
			FROM (
				SELECT intDailyAveragePriceDetailId
					, dblAvgLongPrice = CASE WHEN ISNULL(dblOpenContract, 0) <> 0 THEN dblPrice / dblOpenContract ELSE 0 END
					, dblNoOfLots = dblOpenContract
				FROM (
					SELECT intDailyAveragePriceDetailId
						, dblPrice = SUM(CASE WHEN strBuySell = 'Buy' THEN dblPrice * dblNewNoOfContract ELSE 0 END)
						, dblOpenContract = SUM((CASE WHEN strBuySell = 'Buy' THEN dblNewNoOfContract ELSE 0 END))
					FROM (
						SELECT *
							, dblNewNoOfContract = CASE WHEN strInstrumentType = 'Futures' THEN dblNoOfContract ELSE 0 END
						FROM tblRKDailyAveragePriceDetailTransaction
					) tblRKDailyAveragePriceDetailTransaction
					WHERE intDailyAveragePriceDetailId IN (SELECT intDailyAveragePriceDetailId FROM tblRKDailyAveragePriceDetail WHERE intDailyAveragePriceId = @intDailyAveragePriceId)
					GROUP BY intDailyAveragePriceDetailId
				) t
			) tblPatch
			WHERE tblPatch.intDailyAveragePriceDetailId = tblRKDailyAveragePriceDetail.intDailyAveragePriceDetailId
		END

		DROP TABLE #tmpDetailTable

		DELETE FROM #BookSubBook WHERE intRowId = @intRowId
	END

	DROP TABLE #BookSubBook
	DROP TABLE #tmpDerivatives
END