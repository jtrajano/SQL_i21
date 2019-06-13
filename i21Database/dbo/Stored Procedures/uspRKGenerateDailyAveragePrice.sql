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
		, @bookId INT
		, @subBookId INT

	SELECT *
	INTO #tmpDerivatives
	FROM dbo.fnRKGetOpenFutureByDate(NULL, '1/1/1900', @dtmDate, 1)

	SELECT DISTINCT intBookId
		, intSubBookId
	INTO #BookSubBook
	FROM #tmpDerivatives

	WHILE EXISTS (SELECT TOP 1 1 FROM #BookSubBook)
	BEGIN
		SELECT TOP 1 @bookId = intBookId, @subBookId = intSubBookId FROM #BookSubBook

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
		WHERE intBookId = ISNULL(@bookId, intBookId)
			AND intSubBookId = ISNULL(@subBookId, intSubBookId)

		INSERT INTO tblRKDailyAveragePriceTransaction(intDailyAveragePriceDetailId
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
			, Trans.dtmTransactionDate
			, Trans.strEntity
			, Trans.dblCommission
			, Trans.strBrokerageCommission
			, Trans.strInstrumentType
			, Trans.strLocation
			, Trans.strTrader
			, Trans.strCurrency
			, Trans.strInternalTradeNo
			, Trans.strBrokerTradeNo
			, Trans.strBuySell
			, Trans.dblOpenContract
			, Trans.strOptionMonth
			, Trans.strOptionType
			, Trans.dblStrike
			, Trans.dblPrice
			, Trans.strReference
			, Trans.strStatus
			, Trans.dtmFilledDate
			, Trans.strReserveForFix
			, Trans.ysnOffset
			, Trans.strBank
			, Trans.strBankAccount
			, Trans.strContractNo
			, Trans.strContractSequenceNo
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
		JOIN #tmpDerivatives Derivative ON Derivative.intBookId = ISNULL(@bookId, Derivative.intBookId)
			AND Derivative.intSubBookId = ISNULL(@subBookId, Derivative.intSubBookId)
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
				, dblAvgLongPrice = dblPriceByLots / dblOpenContract
				, dblNoOfLots
			FROM (
				SELECT intDailyAveragePriceDetailId
					, dblPriceByLots = SUM((CASE WHEN strBuySell = 'Buy' THEN dblPrice ELSE 0 END) * dblNoOfContract)
					, dblOpenContract = SUM((CASE WHEN strBuySell = 'Buy' THEN dblNoOfContract ELSE 0 END))
					, dblNoOfLots = SUM(dblNoOfContract)				
				FROM tblRKDailyAveragePriceTransaction
				WHERE intDailyAveragePriceDetailId IN (SELECT intDailyAveragePriceDetailId FROM tblRKDailyAveragePriceDetail WHERE intDailyAveragePriceId = @intDailyAveragePriceId)
					AND strInstrumentType = 'Futures'
				GROUP BY intDailyAveragePriceDetailId
			) t
		) tblPatch
		WHERE tblPatch.intDailyAveragePriceDetailId = tblRKDailyAveragePriceDetail.intDailyAveragePriceDetailId

		DELETE FROM #BookSubBook WHERE intBookId = ISNULL(@bookId, intBookId) AND intSubBookId = ISNULL(@subBookId, intSubBookId)
	END

	DROP TABLE #BookSubBook
	DROP TABLE #tmpDerivatives
END