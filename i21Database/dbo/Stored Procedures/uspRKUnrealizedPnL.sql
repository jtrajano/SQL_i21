CREATE PROCEDURE [dbo].[uspRKUnrealizedPnL]
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intCommodityId INT = NULL
	, @ysnExpired BIT
	, @intFutureMarketId INT = NULL
	, @intEntityId INT = NULL
	, @intBrokerageAccountId INT = NULL
	, @intFutureMonthId INT = NULL
	, @strBuySell NVARCHAR(10) = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @intSelectedInstrumentTypeId INT = NULL

AS

BEGIN

	SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(@dtmToDate, GETDATE()), 110), 110)

	IF ISNULL(@intCommodityId, 0) = 0
	BEGIN
		SET @intCommodityId = NULL
	END
	IF ISNULL(@intFutureMarketId, 0) = 0
	BEGIN
		SET @intFutureMarketId = NULL
	END
	IF ISNULL(@intEntityId, 0) = 0
	BEGIN
		SET @intEntityId = NULL
	END
	IF ISNULL(@intBrokerageAccountId, 0) = 0
	BEGIN
		SET @intBrokerageAccountId = NULL
	END
	IF ISNULL(@intFutureMonthId, 0) = 0
	BEGIN
		SET @intFutureMonthId = NULL
	END
	IF ISNULL(@intBookId, 0) = 0
	BEGIN
		SET @intBookId = NULL
	END
	IF ISNULL(@intSubBookId, 0) = 0
	BEGIN
		SET @intSubBookId = NULL
	END
	IF ISNULL(@strBuySell, 0) = 0
	BEGIN
		SET @strBuySell = NULL
	END

	SELECT *
	INTO #TempSettlementPrice
	FROM (
		SELECT dblLastSettle
			, p.intFutureMarketId
			, pm.intFutureMonthId
			, dtmPriceDate
			, ROW_NUMBER() OVER (PARTITION BY p.intFutureMarketId, pm.intFutureMonthId ORDER BY dtmPriceDate DESC) intRowNum
		FROM tblRKFuturesSettlementPrice p
		INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
		WHERE CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmToDate, 111)
	) t WHERE intRowNum = 1

	SELECT CONVERT(INT, DENSE_RANK() OVER (ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth))) RowNum
		, strMonthOrder = strFutureMarket + ' - ' + strFutureMonth + ' - ' + strBroker
		, intFutOptTransactionId
		, GrossPnL dblGrossPnL
		, dblLong
		, dblShort
		, dblFutCommission = - ABS(dblFutCommission)
		, strFutureMarket
		, strFutureMonth
		, dtmTradeDate
		, strInternalTradeNo
		, strBroker
		, strBrokerAccount
		, strBook
		, strSubBook
		, strSalespersonId
		, strCommodityCode
		, strLocationName
		, Long1 dblLong1
		, Sell1 dblSell1
		, dblNet dblNet
		, dblActual
		, dblClosing
		, dblPrice
		, dblContractSize
		, dblFutCommission1 = - ABS(dblFutCommission1)
		, dblMatchLong = MatchLong
		, dblMatchShort = MatchShort
		, dblNetPnL = GrossPnL - ABS(dblFutCommission)
		, intFutureMarketId
		, intFutureMonthId
		, dblOriginalQty
		, intFutOptTransactionHeaderId
		, intCommodityId
		, ysnExpired
		, dblInitialMargin = 0.0
		, LongWaitedPrice = LongWaitedPrice / CASE WHEN ISNULL(dblLongTotalLotByMonth, 0) = 0 THEN 1 ELSE dblLongTotalLotByMonth END
		, ShortWaitedPrice = ShortWaitedPrice / CASE WHEN ISNULL(dblShortTotalLotByMonth, 0) = 0 THEN 1 ELSE dblShortTotalLotByMonth END
		, intSelectedInstrumentTypeId
	INTO #temp
	FROM (
		SELECT *
			, GrossPnL = GrossPnL1 * (dblClosing - dblPrice)
			, dblFutCommission = - dblFutCommission2
			, dblShortTotalLotByMonth = SUM(dblShort) OVER (PARTITION BY intFutureMonthId, strBroker)
			, dblLongTotalLotByMonth = SUM(dblLong) OVER (PARTITION BY intFutureMonthId, strBroker)
			, LongWaitedPrice = (dblLong * dblPrice)
			, ShortWaitedPrice = (dblShort * dblPrice)
		FROM (
			SELECT GrossPnL1 = (ISNULL(Long1, 0) - ISNULL(Sell1, 0)) * dblContractSize / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
				, dblLong = ISNULL(Long1, 0)
				, dblShort = ISNULL(Sell1, 0)
				, dblFutCommission2 = CASE WHEN dblFutCommission1 = 0 THEN 0 ELSE ((ISNULL(Long1, 0) - ISNULL(Sell1, 0)) * - dblFutCommission1) / CASE WHEN ComSubCurrency = 1 THEN ComCent ELSE 1 END END
				, dblNet = ISNULL(Long1, 0) - ISNULL(Sell1, 0)
				, *
			FROM (
				SELECT intFutOptTransactionId
					, ot.strFutureMarket
					, ot.strFutureMonth
					, ot.intFutureMonthId
					, ot.intCommodityId
					, ot.intFutureMarketId
					, dtmTradeDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110)
					, ot.strInternalTradeNo
					, ot.strBroker
					, ot.strBrokerAccount
					, ot.strBook
					, ot.strSubBook
					, ot.strSalespersonId
					, ot.strCommodityCode
					, ot.strLocationName
					, dblOriginalQty = ot.dblOpenContract
					, Long1 = ISNULL(CASE WHEN ot.strNewBuySell = 'Buy' THEN ISNULL(ot.dblOpenContract, 0) ELSE NULL END, 0)
					, Sell1 = ISNULL(CASE WHEN ot.strNewBuySell = 'Sell' THEN ABS(ISNULL(ot.dblOpenContract, 0)) ELSE NULL END, 0)
					, dblNet1 = ot.dblOpenContract
					, dblActual = ot.dblPrice
					, dblPrice = ISNULL(ot.dblPrice, 0)
					, ot.dblContractSize
					, intConcurrencyId = 0
					, dblFutCommission1 = ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 1 THEN 0 ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END)
												FROM tblRKBrokerageCommission bc
												LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
												WHERE bc.intFutureMarketId = ot.intFutureMarketId
													AND bc.intBrokerageAccountId = ot.intBrokerageAccountId AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE())), 0)
					--, MatchLong = ISNULL((SELECT SUM(dblMatchQty)
					--						FROM tblRKMatchFuturesPSDetail psd
					--						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
					--						WHERE psd.intLFutOptTransactionId = ot.intFutOptTransactionId
					--							AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
					--, MatchShort = ISNULL((SELECT SUM(dblMatchQty)
					--						FROM tblRKMatchFuturesPSDetail psd
					--						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
					--						WHERE psd.intSFutOptTransactionId = ot.intFutOptTransactionId
					--							AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
					, MatchLong = CASE WHEN strInstrumentType = 'Buy' THEN 0 ELSE dblMatchContract END
					, MatchShort = CASE WHEN strInstrumentType = 'Sell' THEN 0 ELSE dblMatchContract END
					, intCurrencyId = c.intCurrencyID
					, c.intCent
					, c.ysnSubCurrency
					, intFutOptTransactionHeaderId
					, ysnExpired
					, ComCent = c.intCent
					, ComSubCurrency = c.ysnSubCurrency
					, dblClosing = ISNULL(dblLastSettle, 0)
					, intSelectedInstrumentTypeId
				FROM fnRKGetOpenFutureByDate (@intCommodityId, @dtmFromDate, @dtmToDate, 1) ot
				--JOIN tblRKFuturesMonth om ON om.intFutureMonthId = ot.intFutureMonthId AND ot.intInstrumentTypeId = 1
				--JOIN tblRKBrokerageAccount acc ON acc.intBrokerageAccountId = ot.intBrokerageAccountId
				--JOIN tblICCommodity icc ON icc.intCommodityId = ot.intCommodityId
				--JOIN tblSMCompanyLocation sl ON sl.intCompanyLocationId = ot.intLocationId
				--JOIN tblEMEntity sp ON sp.intEntityId = ot.intTraderId
				--JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
				--JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId
				JOIN tblSMCurrency c ON c.intCurrencyID = ot.intCurrencyId
				LEFT JOIN #TempSettlementPrice t ON t.intFutureMarketId = ot.intFutureMarketId AND t.intFutureMonthId = ot.intFutureMonthId
				LEFT JOIN tblCTBook cb ON cb.intBookId = ot.intBookId
				LEFT JOIN tblCTSubBook csb ON csb.intSubBookId = ot.intSubBookId
				WHERE ot.intSelectedInstrumentTypeId = @intSelectedInstrumentTypeId
					AND ISNULL(ot.intCommodityId, 0) = ISNULL(@intCommodityId, ISNULL(ot.intCommodityId, 0))
					AND ISNULL(ot.intFutureMarketId, 0) = ISNULL(@intFutureMarketId, ISNULL(ot.intFutureMarketId, 0))
					AND ISNULL(ot.intBookId, 0) = ISNULL(@intBookId, ISNULL(ot.intBookId, 0))
					AND ISNULL(ot.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ot.intSubBookId, 0))
					AND ISNULL(ot.intEntityId, 0) = ISNULL(@intEntityId, ISNULL(ot.intEntityId, 0))
					AND ISNULL(ot.intBrokerageAccountId, 0) = ISNULL(@intBrokerageAccountId, ISNULL(ot.intBrokerageAccountId, 0))
					AND ISNULL(ot.intFutureMonthId, 0) = ISNULL(@intFutureMonthId, ISNULL(ot.intFutureMonthId, 0))
					AND ot.strNewBuySell = ISNULL(@strBuySell, ot.strNewBuySell)
					AND ot.intInstrumentTypeId = 1
			) t1
		) t1
	) t1
	WHERE (dblLong <> 0 OR dblShort <> 0)
	ORDER BY RowNum ASC

	SELECT RowNum
		, strMonthOrder = CASE WHEN ISNULL(RowNum, 0) <= 9 THEN '0' ELSE '' END + CONVERT(NVARCHAR, RowNum) + '-' + strMonthOrder
		, intFutOptTransactionId
		, dblGrossPnL
		, dblLong
		, dblShort
		, dblFutCommission
		, strFutureMarket
		, strFutureMonth
		, dtmTradeDate
		, strInternalTradeNo
		, strBroker
		, strBrokerAccount
		, strBook
		, strSubBook
		, strSalespersonId
		, strCommodityCode
		, strLocationName
		, dblLong1
		, dblSell1
		, dblNet
		, dblActual
		, dblClosing
		, dblPrice
		, dblContractSize
		, dblFutCommission1
		, dblMatchLong
		, dblMatchShort
		, dblNetPnL
		, intFutureMarketId
		, intFutureMonthId
		, dblOriginalQty
		, intFutOptTransactionHeaderId
		, intCommodityId
		, ysnExpired
		, dblVariationMargin = dblNet * (ISNULL(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize)
		, dblInitialMargin
		, LongWaitedPrice
		, ShortWaitedPrice
		, intSelectedInstrumentTypeId
	FROM #temp
	WHERE ysnExpired = CASE WHEN @ysnExpired = 1 THEN ysnExpired ELSE 0 END
END