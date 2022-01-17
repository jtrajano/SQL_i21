CREATE VIEW [dbo].[vyuRKSearchDerivativeEntryHistory]

AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY intFutOptTransactionHistoryId) AS INT)
	, *
FROM (
	SELECT intFutOptTransactionHistoryId
		, intFutOptTransactionId
		, intFutOptTransactionHeaderId
		, dtmTransactionDate
		, strSelectedInstrumentType
		, strInstrumentType
		, intFutureMarketId
		, strFutureMarket
		, intCurrencyId
		, strCurrency
		, intCommodityId
		, strCommodity
		, intEntityId
		, intBrokerId
		, strBroker
		, strBrokerAccount
		, strTrader
		, strBrokerTradeNo
		, intFutureMonthId
		, strFutureMonth
		, intOptionMonthId
		, strOptionMonth
		, strOptionType
		, dblStrike
		, dblPrice
		, strStatus
		, dtmFilledDate
		, dblOldNoOfLots
		, dblLotBalance
		, dblContractBalance
		, dblNewNoOfLots
		, strScreenName
		, strOldBuySell
		, strNewBuySell	
		, strInternalTradeNo
		, intLocationId
		, strLocationName
		, dblContractSize
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, ysnMonthExpired
		, strUserName
		, strAction
		, strNotes
		, ysnPreCrush
		, strRollingMonth
		, intRollingMonthId
		, intTraderId
		, strSalespersonId
		, strBuyBankName 
		, strBuyBankAccountNo 
		, strBankTransferNo 
		, dtmBankTransferDate 
		, ysnBankTransferPosted 
	FROM vyuRKGetFutOptTransactionHistory

	UNION ALL SELECT *
	FROM (
		SELECT intFutOptTransactionHistoryId = NULL
			, MatchQty.intFutOptTransactionId
			, Derivative.intFutOptTransactionHeaderId
			, dtmTransactionDate = MatchQty.dtmMatchDate
			, Derivative.strSelectedInstrumentType
			, Derivative.strInstrumentType
			, Derivative.intFutureMarketId
			, strFutureMarket = Derivative.strFutMarketName
			, Derivative.intCurrencyId
			, strCurrency = NULL
			, Derivative.intCommodityId
			, strCommodity = Derivative.strCommodityCode
			, Derivative.intEntityId
			, intBrokerId = NULL
			, strBroker = NULL
			, strBrokerAccount = NULL
			, strTrader = NULL
			, Derivative.strBrokerTradeNo
			, Derivative.intFutureMonthId
			, Derivative.strFutureMonth
			, Derivative.intOptionMonthId
			, strOptionMonth = NULL
			, Derivative.strOptionType
			, Derivative.dblStrike
			, Derivative.dblPrice
			, Derivative.strStatus
			, Derivative.dtmFilledDate
			, dblOldNoOfLots = NULL
			, dblLotBalance = MatchQty.dblMatchQty
			, dblContractBalance = dbo.fnCTConvertQuantityToTargetCommodityUOM(Derivative.intCommodityUOMId, Derivative.intStockUOMId, (MatchQty.dblMatchQty * Derivative.dblContractSize))
			, dblNewNoOfLots = NULL
			, strScreenName = 'Match Derivatives'
			, strOldBuySell = NULL
			, strNewBuySell = NULL	
			, Derivative.strInternalTradeNo
			, Derivative.intLocationId
			, Derivative.strLocationName
			, Derivative.dblContractSize
			, Derivative.intBookId
			, Derivative.strBook
			, Derivative.intSubBookId
			, Derivative.strSubBook
			, ysnMonthExpired = NULL
			, strUserName = NULL
			, strAction = 'Match Qty'
			, Derivative.strNotes
			, Derivative.ysnPreCrush
			, Derivative.strRollingMonth
			, Derivative.intRollingMonthId
			, Derivative.intTraderId
			, Derivative.strSalespersonId
			, strBuyBankName = NULL
			, strBuyBankAccountNo  = NULL
			, strBankTransferNo  = NULL
			, dtmBankTransferDate  = NULL
			, ysnBankTransferPosted  = NULL
		FROM (
			SELECT DISTINCT intFutOptTransactionId = mf.intLFutOptTransactionId
				, strType = 'Options'
				, strBuySell = 'Buy'
				, dtmMatchDate = CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)
				, dblMatchQty = SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			GROUP BY mf.intLFutOptTransactionId
				, CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)

			UNION ALL SELECT DISTINCT intFutOptTransactionId = mf.intSFutOptTransactionId
				, 'Options'
				, 'Sell'
				, dtmMatchDate = CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)
				, - SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			GROUP BY mf.intSFutOptTransactionId
				, CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)

			UNION ALL SELECT DISTINCT intFutOptTransactionId = mf.intLFutOptTransactionId
				, 'Futures'
				, 'Buy'
				, dtmMatchDate = CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)
				, - SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			GROUP BY mf.intLFutOptTransactionId
				, CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)

			UNION ALL SELECT DISTINCT intFutOptTransactionId = mf.intSFutOptTransactionId
				, 'Futures'
				, 'Sell'
				, dtmMatchDate = CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)
				, SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			GROUP BY mf.intSFutOptTransactionId
				, CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME)
		) MatchQty
		CROSS APPLY (
			SELECT TOP 1 Trans.*
				, intCommodityUOMId = CommodityUOM.intCommodityUnitMeasureId
				, intStockUOMId = CommodityStock.intCommodityUnitMeasureId
			FROM vyuRKFutOptTransaction Trans
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = Trans.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure CommodityUOM ON CommodityUOM.intCommodityId = Trans.intCommodityId AND CommodityUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure CommodityStock ON CommodityStock.intCommodityId = Trans.intCommodityId AND CommodityStock.ysnStockUnit = 1
			WHERE intFutOptTransactionId = MatchQty.intFutOptTransactionId
		) Derivative
	) tbl
) tbl