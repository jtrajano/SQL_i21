CREATE PROC [dbo].[uspRKUnrealizedPnL]
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

	SELECT *
	INTO #TempSettlementPrice
	FROM (
		SELECT dblLastSettle
			, p.intFutureMarketId
			, pm.intFutureMonthId
			, dtmPriceDate
			, ROW_NUMBER() OVER (PARTITION BY p.intFutureMarketId, pm.intFutureMonthId ORDER BY CONVERT(NVARCHAR, dtmPriceDate, 111) DESC) intRowNum
		FROM tblRKFuturesSettlementPrice p
		INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
		WHERE CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmToDate, 111)
	) t WHERE intRowNum = 1

	SELECT CONVERT(INT, DENSE_RANK() OVER (ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth))) RowNum
		, strFutMarketName + ' - ' + strFutureMonth + ' - ' + strName strMonthOrder
		, intFutOptTransactionId
		, GrossPnL dblGrossPnL
		, dblLong
		, dblShort
		, - abs(dblFutCommission) dblFutCommission
		, strFutMarketName
		, strFutureMonth
		, dtmTradeDate
		, strInternalTradeNo
		, strName
		, strAccountNumber
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
		, - abs(dblFutCommission1) dblFutCommission1
		, MatchLong dblMatchLong
		, MatchShort dblMatchShort
		, GrossPnL - abs(dblFutCommission) dblNetPnL
		, intFutureMarketId
		, intFutureMonthId
		, dblOriginalQty dblOriginalQty
		, intFutOptTransactionHeaderId
		, intCommodityId
		, ysnExpired
		, 0.0 dblInitialMargin
		, LongWaitedPrice / CASE WHEN ISNULL(dblLongTotalLotByMonth, 0) = 0 THEN 1 ELSE dblLongTotalLotByMonth END LongWaitedPrice
		, ShortWaitedPrice / CASE WHEN ISNULL(dblShortTotalLotByMonth, 0) = 0 THEN 1 ELSE dblShortTotalLotByMonth END ShortWaitedPrice
		, intSelectedInstrumentTypeId
	INTO #temp
	FROM (
		SELECT *
			, GrossPnL1 * (dblClosing - dblPrice) GrossPnL
			, - dblFutCommission2 dblFutCommission
			, SUM(dblShort) OVER (PARTITION BY intFutureMonthId, strName) dblShortTotalLotByMonth
			, SUM(dblLong) OVER (PARTITION BY intFutureMonthId, strName) dblLongTotalLotByMonth
			, (dblLong * dblPrice) LongWaitedPrice
			, (dblShort * dblPrice) ShortWaitedPrice
		FROM (
			SELECT (ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0)) * dblContractSize / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END GrossPnL1
				, ISNULL((Long1 - MatchLong), 0) AS dblLong
				, ISNULL(Sell1 - MatchShort, 0) AS dblShort
				, CONVERT(INT, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0)) * - dblFutCommission1 / CASE WHEN ComSubCurrency = 1 THEN ComCent ELSE 1 END AS dblFutCommission2
				, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0) AS dblNet
				, *
			FROM (
				SELECT intFutOptTransactionId
					, fm.strFutMarketName
					, om.strFutureMonth
					, ot.intFutureMonthId
					, ot.intCommodityId
					, ot.intFutureMarketId
					, CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110) AS dtmTradeDate
					, ot.strInternalTradeNo
					, e.strName
					, acc.strAccountNumber
					, cb.strBook
					, csb.strSubBook
					, sp.strName strSalespersonId
					, icc.strCommodityCode
					, sl.strLocationName
					, ot.dblNoOfContract AS dblOriginalQty
					, ISNULL(CASE WHEN ot.strBuySell = 'Buy' THEN ISNULL(ot.dblNoOfContract, 0) ELSE NULL END, 0) Long1
					, ISNULL(CASE WHEN ot.strBuySell = 'Sell' THEN ISNULL(ot.dblNoOfContract, 0) ELSE NULL END, 0) Sell1
					, ot.dblNoOfContract AS dblNet1
					, ot.dblPrice AS dblActual
					, ISNULL(ot.dblPrice, 0) dblPrice
					, fm.dblContractSize dblContractSize
					, 0 AS intConcurrencyId
					, dblFutCommission1 = ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 1 THEN 0 ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END)
												FROM tblRKBrokerageCommission bc
												LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
												WHERE bc.intFutureMarketId = ot.intFutureMarketId
													AND bc.intBrokerageAccountId = ot.intBrokerageAccountId AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, getdate())), 0)
					, ISNULL((SELECT SUM(dblMatchQty)
							FROM tblRKMatchFuturesPSDetail psd
							JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
							WHERE psd.intLFutOptTransactionId = ot.intFutOptTransactionId
								AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchLong
					, ISNULL((SELECT SUM(dblMatchQty)
							FROM tblRKMatchFuturesPSDetail psd
							JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
							WHERE psd.intSFutOptTransactionId = ot.intFutOptTransactionId
								AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchShort
					, c.intCurrencyID AS intCurrencyId
					, c.intCent
					, c.ysnSubCurrency
					, intFutOptTransactionHeaderId
					, ysnExpired
					, c.intCent ComCent
					, c.ysnSubCurrency ComSubCurrency
					, ISNULL(dblLastSettle, 0) dblClosing
					, intSelectedInstrumentTypeId
				FROM tblRKFutOptTransaction ot
				JOIN tblRKFuturesMonth om ON om.intFutureMonthId = ot.intFutureMonthId AND ot.strStatus = 'Filled' AND ot.intInstrumentTypeId = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
				JOIN tblRKBrokerageAccount acc ON acc.intBrokerageAccountId = ot.intBrokerageAccountId
				JOIN tblICCommodity icc ON icc.intCommodityId = ot.intCommodityId
				JOIN tblSMCompanyLocation sl ON sl.intCompanyLocationId = ot.intLocationId
				JOIN tblEMEntity sp ON sp.intEntityId = ot.intTraderId
				JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
				JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId
				JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
				LEFT JOIN #TempSettlementPrice t ON t.intFutureMarketId = ot.intFutureMarketId AND t.intFutureMonthId = ot.intFutureMonthId
				LEFT JOIN tblCTBook cb ON cb.intBookId = ot.intBookId
				LEFT JOIN tblCTSubBook csb ON csb.intSubBookId = ot.intSubBookId
				WHERE ot.intSelectedInstrumentTypeId = @intSelectedInstrumentTypeId AND ISNULL(ot.intCommodityId, 0) = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN ISNULL(ot.intCommodityId, 0) ELSE @intCommodityId END AND ISNULL(ot.intFutureMarketId, 0) = CASE WHEN ISNULL(@intFutureMarketId, 0) = 0 THEN ISNULL(ot.intFutureMarketId, 0) ELSE @intFutureMarketId END AND ISNULL(ot.intBookId, 0) = CASE WHEN ISNULL(@intBookId, 0) = 0 THEN ISNULL(ot.intBookId, 0) ELSE @intBookId END AND ISNULL(ot.intSubBookId, 0) = CASE WHEN ISNULL(@intSubBookId, 0) = 0 THEN ISNULL(ot.intSubBookId, 0) ELSE @intSubBookId END AND ISNULL(ot.intEntityId, 0) = CASE WHEN ISNULL(@intEntityId, 0) = 0 THEN ot.intEntityId ELSE @intEntityId END AND ISNULL(ot.intBrokerageAccountId, 0) = CASE WHEN ISNULL(@intBrokerageAccountId, 0) = 0 THEN ot.intBrokerageAccountId ELSE @intBrokerageAccountId END AND ISNULL(ot.intFutureMonthId, 0) = CASE WHEN ISNULL(@intFutureMonthId, 0) = 0 THEN ot.intFutureMonthId ELSE @intFutureMonthId END AND ot.strBuySell = CASE WHEN ISNULL(@strBuySell, '0') = '0' THEN ot.strBuySell ELSE @strBuySell END
			) t1
		) t1
	) t1
	WHERE (dblLong <> 0 OR dblShort <> 0)
	ORDER BY RowNum ASC

	IF (@ysnExpired = 1)
	BEGIN
		SELECT RowNum
			, CASE WHEN ISNULL(RowNum, 0) <= 9 THEN '0' ELSE '' END + CONVERT(NVARCHAR, RowNum) + '-' + strMonthOrder strMonthOrder
			, intFutOptTransactionId
			, dblGrossPnL
			, dblLong
			, dblShort
			, dblFutCommission
			, strFutMarketName
			, strFutureMonth
			, dtmTradeDate
			, strInternalTradeNo
			, strName
			, strAccountNumber
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
			, dblNet * (ISNULL(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize) dblVariationMargin
			, dblInitialMargin
			, LongWaitedPrice
			, ShortWaitedPrice
			, intSelectedInstrumentTypeId
		FROM #temp
	END
	ELSE
	BEGIN
		SELECT RowNum
			, CASE WHEN ISNULL(RowNum, 0) <= 9 THEN '0' ELSE '' END + CONVERT(NVARCHAR, RowNum) + '-' + strMonthOrder strMonthOrder
			, intFutOptTransactionId
			, dblGrossPnL
			, dblLong
			, dblShort
			, dblFutCommission
			, strFutMarketName
			, strFutureMonth
			, dtmTradeDate
			, strInternalTradeNo
			, strName
			, strAccountNumber
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
			, dblNet * (ISNULL(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize) dblVariationMargin
			, dblInitialMargin
			, LongWaitedPrice
			, ShortWaitedPrice
			, intSelectedInstrumentTypeId
		FROM #temp
		WHERE ysnExpired = 0
	END
END