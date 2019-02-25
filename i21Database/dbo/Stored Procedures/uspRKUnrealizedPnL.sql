CREATE PROC [dbo].[uspRKUnrealizedPnL]
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intCommodityId INT = NULL
	, @ysnExpired BIT
	, @intFutureMarketId INT = NULL
	, @intEntityId int = null
	, @intBrokerageAccountId INT = NULL
	, @intFutureMonthId INT = NULL
	, @strBuySell nvarchar(10)=NULL
	, @intBookId int=NULL
	, @intSubBookId int=NULL

AS

SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(@dtmToDate, GETDATE()), 110), 110)

SELECT CONVERT(INT, DENSE_RANK() OVER (ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth))) RowNum
	, strMonthOrder = (strFutMarketName + ' - ' + strFutureMonth + ' - ' + strName)
	, intFutOptTransactionId
	, GrossPnL dblGrossPnL
	, dblLong
	, dblShort
	, dblFutCommission = - ABS(dblFutCommission)
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
	, intNet dblNet
	, dblActual
	, dblClosing
	, dblPrice
	, dblContractSize
	, dblFutCommission1 = - ABS(dblFutCommission1)
	, MatchLong dblMatchLong
	, MatchShort dblMatchShort
	, NetPnL dblNetPnL
	, intFutureMarketId
	, intFutureMonthId
	, dblOriginalQty dblOriginalQty
	, intFutOptTransactionHeaderId
	, intCommodityId
	, ysnExpired
	, dblVariationMargin = intNet * VM.dblVariationMargin1
	, 0.0 dblInitialMargin
	, LongWaitedPrice = LongWaitedPrice / CASE WHEN ISNULL(dblLongTotalLotByMonth,0)=0 THEN 1 ELSE dblLongTotalLotByMonth END
	, ShortWaitedPrice = ShortWaitedPrice / CASE WHEN ISNULL(dblShortTotalLotByMonth,0)=0 THEN 1 ELSE dblShortTotalLotByMonth END
FROM (
	SELECT *
		, NetPnL = (GrossPnL1 * (dblClosing - dblPrice) - dblFutCommission2)
		, GrossPnL = GrossPnL1 * (dblClosing - dblPrice)
		, dblFutCommission = - dblFutCommission2
		, dblShortTotalLotByMonth = SUM(dblShort) OVER (PARTITION BY intFutureMonthId,strName)
		, dblLongTotalLotByMonth = SUM(dblLong) OVER (PARTITION BY intFutureMonthId,strName)
		, LongWaitedPrice = (dblLong*dblPrice)
		, ShortWaitedPrice = (dblShort*dblPrice)
	FROM (
		SELECT GrossPnL1 = (CONVERT(INT, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0))) * dblContractSize / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
			, dblLong = ISNULL((Long1 - MatchLong), 0)
			, dblShort = ISNULL(Sell1 - MatchShort, 0)
			, dblFutCommission2 = CONVERT(INT, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0)) * - dblFutCommission1 / CASE WHEN ComSubCurrency = 1 THEN ComCent ELSE 1 END
			, intNet = CONVERT(INT, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0))
			, dblClosing = dblLastSettle
			, *
		FROM (
			SELECT intFutOptTransactionId
				, fm.strFutMarketName
				, om.strFutureMonth
				, ot.intFutureMonthId
				, ot.intCommodityId
				, ot.intFutureMarketId
				, dtmTradeDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110)
				, ot.strInternalTradeNo
				, e.strName
				, acc.strAccountNumber
				, cb.strBook
				, csb.strSubBook
				, sp.strSalespersonId
				, icc.strCommodityCode
				, sl.strLocationName
				, ot.dblNoOfContract AS dblOriginalQty
				, Long1 = ISNULL(CASE WHEN ot.strBuySell = 'Buy' THEN ISNULL(ot.dblNoOfContract, 0) ELSE NULL END, 0)
				, Sell1 = ISNULL(CASE WHEN ot.strBuySell = 'Sell' THEN ISNULL(ot.dblNoOfContract, 0) ELSE NULL END, 0)
				, dblNet1 = ot.dblNoOfContract
				, dblActual = ot.dblPrice
				, dblPrice = ISNULL(ot.dblPrice, 0)
				, fm.dblContractSize
				, intConcurrencyId = 0
				, dblFutCommission1 = ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 1 THEN 0 ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END)
											FROM tblRKBrokerageCommission bc
											LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
											WHERE bc.intFutureMarketId = ot.intFutureMarketId
												AND bc.intBrokerageAccountId = ot.intBrokerageAccountId
												AND ot.dtmTransactionDate BETWEEN bc.dtmEffectiveDate
												AND ISNULL(bc.dtmEndDate,getdate())), 0)
				, MatchLong = ISNULL((SELECT SUM(dblMatchQty)
									FROM tblRKMatchFuturesPSDetail psd
									JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
									WHERE psd.intLFutOptTransactionId = ot.intFutOptTransactionId
										AND h.strType = 'Realize'
										AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
				, MatchShort = ISNULL((SELECT SUM(dblMatchQty)
									FROM tblRKMatchFuturesPSDetail psd
									JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
									WHERE psd.intSFutOptTransactionId = ot.intFutOptTransactionId
										AND h.strType = 'Realize'
										AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
				, intCurrencyId = c.intCurrencyID
				, c.intCent
				, c.ysnSubCurrency
				, intFutOptTransactionHeaderId
				, ysnExpired
				, ComCent = c.intCent
				, ComSubCurrency = c.ysnSubCurrency
				, LS.dblLastSettle
				, ot.dtmFilledDate
			FROM tblRKFutOptTransaction ot
			JOIN tblRKFuturesMonth om ON om.intFutureMonthId = ot.intFutureMonthId AND ot.strStatus = 'Filled'
			JOIN tblRKBrokerageAccount acc ON acc.intBrokerageAccountId = ot.intBrokerageAccountId
			JOIN tblICCommodity icc ON icc.intCommodityId = ot.intCommodityId
			JOIN tblSMCompanyLocation sl ON sl.intCompanyLocationId = ot.intLocationId
			JOIN tblARSalesperson sp ON sp.intEntityId = ot.intTraderId
			JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
			JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId
			JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblCTBook cb ON cb.intBookId = ot.intBookId
			LEFT JOIN tblCTSubBook csb ON csb.intSubBookId = ot.intSubBookId
			OUTER APPLY (
				SELECT TOP 1 dblLastSettle, intFutureMarketId, intFutureMonthId
				FROM tblRKFuturesSettlementPrice p
				INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
				WHERE p.intFutureMarketId = ot.intFutureMarketId
					AND pm.intFutureMonthId = ot.intFutureMonthId
					AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmToDate, 111)
				ORDER BY dtmPriceDate DESC
			) LS
			WHERE ISNULL(ot.intCommodityId, 0) = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN ISNULL(ot.intCommodityId, 0) ELSE @intCommodityId END
				AND ISNULL(ot.intFutureMarketId, 0) = CASE WHEN ISNULL(@intFutureMarketId, 0) = 0 THEN ISNULL(ot.intFutureMarketId, 0) ELSE @intFutureMarketId END
				AND ISNULL(ot.intBookId, 0) = CASE WHEN ISNULL(@intBookId, 0) = 0 THEN ISNULL(ot.intBookId, 0) ELSE @intBookId END
				AND ISNULL(ot.intSubBookId, 0) = CASE WHEN ISNULL(@intSubBookId, 0) = 0 THEN ISNULL(ot.intSubBookId, 0) ELSE @intSubBookId END
				AND ISNULL(ot.intEntityId, 0) = CASE WHEN ISNULL(@intEntityId, 0) = 0 THEN ot.intEntityId ELSE @intEntityId END
				AND ISNULL(ot.intBrokerageAccountId, 0) = CASE WHEN ISNULL(@intBrokerageAccountId, 0) = 0 THEN ot.intBrokerageAccountId ELSE @intBrokerageAccountId END
				AND ISNULL(ot.intFutureMonthId, 0) = CASE WHEN ISNULL(@intFutureMonthId, 0) = 0 THEN ot.intFutureMonthId ELSE @intFutureMonthId END
				AND ot.strBuySell = CASE WHEN ISNULL(@strBuySell, '0') = '0' THEN ot.strBuySell ELSE @strBuySell END
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) <= @dtmToDate
				AND ISNULL(ysnExpired, 0) = CASE WHEN ISNULL(@ysnExpired, 0) = 1 THEN ISNULL(ysnExpired, 0) ELSE @ysnExpired END
				AND ot.intInstrumentTypeId = 1
			) t1
		) t1
	) t1
OUTER APPLY(
	SELECT dblVariationMargin1 = ISNULL(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmFilledDate), 0.0) * dblContractSize
) VM
WHERE (
		dblLong <> 0
		OR dblShort <> 0
		)
ORDER BY RowNum ASC
