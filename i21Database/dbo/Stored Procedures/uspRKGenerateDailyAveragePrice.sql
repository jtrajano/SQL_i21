CREATE PROCEDURE [dbo].[uspRKGenerateDailyAveragePrice]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @intDailyAveragePriceId INT
		, @strAverageNo NVARCHAR(50)
		, @dtmDate DATETIME = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
		, @intRowId INT
		, @bookId INT
		, @subBookId INT

	SELECT *
	INTO #tmpDerivatives
	FROM dbo.fnRKGetOpenFutureByDate(NULL, '1/1/1900', @dtmDate, 1)
	WHERE intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKDailyAveragePriceDetailTransaction)

	SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intBookId ORDER BY intBookId DESC)
		, *
	INTO #BookSubBook
	FROM (
		SELECT DISTINCT intBookId
			, intSubBookId		
		FROM #tmpDerivatives
	) tbl
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #BookSubBook)
	BEGIN
		SELECT TOP 1 @intRowId = intRowId, @bookId = intBookId, @subBookId = intSubBookId FROM #BookSubBook

		EXEC uspSMGetStartingNumber @intStartingNumberId = 143
			, @strID = @strAverageNo OUTPUT

		IF (ISNULL(@strAverageNo, '') = '')
		BEGIN
			RAISERROR ('Starting Number for Daily Average Price is not setup.', 16, 1)
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
			, intEntityId
		FROM #tmpDerivatives
		WHERE ISNULL(intBookId, 0) = ISNULL(@bookId, ISNULL(intBookId, 0))
			AND ISNULL(intSubBookId, 0) = ISNULL(@subBookId, ISNULL(intSubBookId, 0))
			AND ISNULL(intFutureMarketId, 0) <> 0

		INSERT INTO tblRKDailyAveragePriceDetailTransaction(intDailyAveragePriceDetailId
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
		JOIN #tmpDerivatives Derivative ON ISNULL(Derivative.intBookId, 0) = ISNULL(@bookId, ISNULL(Derivative.intBookId, 0))
			AND ISNULL(Derivative.intSubBookId, 0) = ISNULL(@subBookId, ISNULL(Derivative.intSubBookId, 0))
			AND Derivative.intFutureMarketId = Detail.intFutureMarketId
			AND Derivative.intCommodityId = Detail.intCommodityId
			AND Derivative.intFutureMonthId = Detail.intFutureMonthId
			AND Derivative.intEntityId = Detail.intBrokerId
		JOIN vyuRKFutOptTransaction Trans ON Trans.intFutOptTransactionId = Derivative.intFutOptTransactionId
		WHERE Detail.intDailyAveragePriceId = @intDailyAveragePriceId
			AND Trans.dblOpenContract <> 0

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