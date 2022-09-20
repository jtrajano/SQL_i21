﻿CREATE VIEW [dbo].[vyuRKGetFutOptTransactionHistory]

AS

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
	, dblLotBalance = (ISNULL(dblNewNoOfLots, 0.00) - ISNULL(dblOldNoOfLots, 0.00))
	, dblContractBalance = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUOMId, intStockUOMId, (ISNULL(dblNewNoOfLots, 0.00) - ISNULL(dblOldNoOfLots, 0.00)) * dblContractSize)
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
	, intContractDetailId
	, intContractHeaderId
	, intUserId
FROM (
	SELECT History.intFutOptTransactionHistoryId
		, History.intFutOptTransactionId
		, History.intFutOptTransactionHeaderId
		, History.dtmTransactionDate
		, History.strSelectedInstrumentType
		, History.strInstrumentType
		, FutMarket.intFutureMarketId
		, History.strFutureMarket
		, intCurrencyId = Currency.intCurrencyID
		, History.strCurrency
		, Commodity.intCommodityId
		, History.strCommodity
		, intEntityId = BrokerAccount.intEntityId
		, intBrokerId = BrokerAccount.intBrokerageAccountId
		, History.strBroker
		, History.strBrokerAccount
		, History.strTrader
		, History.strBrokerTradeNo
		, FutMonth.intFutureMonthId
		, History.strFutureMonth
		, OptMonth.intOptionMonthId
		, History.strOptionMonth
		, History.strOptionType
		, History.dblStrike
		, History.dblPrice
		, History.strStatus
		, History.dtmFilledDate
		, dblOldNoOfLots = (SELECT TOP 1 CASE WHEN strNewBuySell = 'Buy' THEN ISNULL(dblNewNoOfContract, 0.00) ELSE - ISNULL(dblNewNoOfContract, 0.00) END
								FROM tblRKFutOptTransactionHistory PrevRec
								WHERE PrevRec.intFutOptTransactionId = History.intFutOptTransactionId
									AND PrevRec.intFutOptTransactionHistoryId != History.intFutOptTransactionHistoryId
									AND PrevRec.strCommodity = History.strCommodity
									AND PrevRec.dtmTransactionDate < History.dtmTransactionDate
								ORDER BY PrevRec.dtmTransactionDate DESC)
		, dblNewNoOfLots = CASE WHEN ISNULL(HistoryDelete.intFutOptTransactionHistoryId, 0) <> 0 
							THEN 0
							ELSE CASE WHEN History.strNewBuySell = 'Buy' THEN History.dblNewNoOfContract ELSE - History.dblNewNoOfContract END
							END
		, History.strScreenName
		, History.strOldBuySell
		, History.strNewBuySell	
		, History.strInternalTradeNo
		, intLocationId = ISNULL(companyLoc.intCompanyLocationId, companyLoc2.intCompanyLocationId)
		, strLocationName = CASE WHEN companyLoc.intCompanyLocationId IS NOT NULL 
							THEN companyLoc.strLocationName
							ELSE companyLoc2.intCompanyLocationId
							END
		, History.dblContractSize
		, History.intBookId
		, Book.strBook
		, History.intSubBookId
		, SubBook.strSubBook
		, History.ysnMonthExpired
		, History.strUserName
		, History.strAction
		, History.strNotes
		, ysnPreCrush = CAST(History.ysnPreCrush AS BIT)
		, strRollingMonth = RollMonth.strFutureMonth
		, intRollingMonthId
		, Trader.intEntityId intTraderId
		, History.strTrader strSalespersonId
		, FutMarket.intUnitMeasureId
		, intCommodityUOMId = CommodityUOM.intCommodityUnitMeasureId
		, intStockUOMId = CommodityStock.intCommodityUnitMeasureId
		, Trans.intContractDetailId
		, Trans.intContractHeaderId
		, intUserId = secUser.intEntityId
	FROM tblRKFutOptTransactionHistory History
	LEFT JOIN tblRKFutOptTransaction Trans ON Trans.intFutOptTransactionId = History.intFutOptTransactionId
	LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.strFutMarketName = History.strFutureMarket
	LEFT JOIN tblRKFuturesMonth FutMonth ON FutMonth.strFutureMonth = History.strFutureMonth AND FutMonth.intFutureMarketId = FutMarket.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth RollMonth ON RollMonth.intFutureMarketId = Trans.intRollingMonthId
	LEFT JOIN tblICCommodity Commodity ON Commodity.strCommodityCode = History.strCommodity
	LEFT JOIN tblRKOptionsMonth OptMonth ON OptMonth.strOptionMonth = History.strOptionMonth AND OptMonth.intFutureMarketId = FutMarket.intFutureMarketId
	LEFT JOIN tblSMCompanyLocation companyLoc ON companyLoc.strLocationName = History.strLocationName
	LEFT JOIN tblSMCompanyLocation companyLoc2 ON companyLoc2.intCompanyLocationId = History.intLocationId
	LEFT JOIN tblCTBook Book ON Book.intBookId = History.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = History.intSubBookId
	LEFT JOIN tblSMCurrency Currency ON Currency.strCurrency = History.strCurrency
	LEFT JOIN (
		tblRKBrokerageAccount BrokerAccount
		LEFT JOIN tblEMEntity em ON em.intEntityId = BrokerAccount.intEntityId
	) ON BrokerAccount.strAccountNumber = History.strBrokerAccount AND em.strName = History.strBroker
	LEFT JOIN (
		SELECT DISTINCT E.strName, E.intEntityId
		FROM tblEMEntity E
		JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
		WHERE strType = 'Salesperson'
	) Trader ON Trader.strName = History.strTrader 
	LEFT JOIN (
		tblEMEntity secUser
		JOIN tblEMEntityType et ON et.intEntityId = secUser.intEntityId AND et.strType = 'User'
		JOIN tblSMUserSecurity sec on sec.intEntityId = secUser.intEntityId AND ysnDisabled = 0
	) ON secUser.strName = History.strUserName
	LEFT JOIN tblICCommodityUnitMeasure CommodityUOM ON CommodityUOM.intCommodityId = Commodity.intCommodityId AND CommodityUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure CommodityStock ON CommodityStock.intCommodityId = Commodity.intCommodityId AND CommodityStock.ysnStockUnit = 1
	LEFT JOIN (
		SELECT histDel.intFutOptTransactionHistoryId
			, intFutOptTransactionId
			, dtmTransactionDate
		FROM tblRKFutOptTransactionHistory histDel
		WHERE histDel.strAction = 'DELETE'
	) HistoryDelete
		ON HistoryDelete.intFutOptTransactionId = History.intFutOptTransactionId
		AND History.strAction = 'ADD'
		AND History.dtmTransactionDate > HistoryDelete.dtmTransactionDate
	WHERE ISNULL(History.strAction, '') <> ''
		AND History.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
		AND History.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		AND History.strStatus = 'Filled'
) t