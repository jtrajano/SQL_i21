CREATE VIEW [dbo].[vyuRKGetDailyAveragePriceDetailTransaction]

AS

SELECT Trans.intDailyAveragePriceDetailTransactionId
	, Detail.intDailyAveragePriceDetailId
	, Detail.intDailyAveragePriceId
	, Detail.strAverageNo
	, Detail.dtmDate
	, Detail.intBookId
	, Detail.strBook
	, Detail.intSubBookId
	, Detail.strSubBook
	, Detail.ysnPosted
    , Detail.intFutureMarketId
	, Detail.strFutureMarket
    , Detail.intCommodityId
	, Detail.strCommodity
    , Detail.intFutureMonthId
	, Detail.strFutureMonth
    , Detail.dblNoOfLots
    , Detail.dblAverageLongPrice
    , Detail.dblSwitchPL
    , Detail.dblOptionsPL
    , Detail.dblNetLongAvg
    , Detail.intBrokerId
	, Detail.strBrokerName
	, dblRefNoOfLots = NULL
	, dblRefNetLongAvg = NULL
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
    , Trans.dblNoOfContract
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
    , Trans.intConcurrencyId
FROM tblRKDailyAveragePriceDetailTransaction Trans
LEFT JOIN vyuRKGetDailyAveragePriceDetail Detail ON Detail.intDailyAveragePriceDetailId = Trans.intDailyAveragePriceDetailId
WHERE strTransactionType = 'FutOptTransaction'

UNION ALL SELECT Trans.intDailyAveragePriceDetailTransactionId
	, Detail.intDailyAveragePriceDetailId
	, Detail.intDailyAveragePriceId
	, Detail.strAverageNo
	, Detail.dtmDate
	, Detail.intBookId
	, Detail.strBook
	, Detail.intSubBookId
	, Detail.strSubBook
	, Detail.ysnPosted
    , Detail.intFutureMarketId
	, Detail.strFutureMarket
    , Detail.intCommodityId
	, Detail.strCommodity
    , Detail.intFutureMonthId
	, Detail.strFutureMonth
    , Detail.dblNoOfLots
    , Detail.dblAverageLongPrice
    , Detail.dblSwitchPL
    , Detail.dblOptionsPL
    , Detail.dblNetLongAvg
    , Detail.intBrokerId
	, Detail.strBrokerName
	, dblRefNoOfLots = RefDetail.dblNoOfLots
	, dblRefNetLongAvg = RefDetail.dblNetLongAvg
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
    , Trans.dblNoOfContract
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
    , Trans.intConcurrencyId
FROM tblRKDailyAveragePriceDetailTransaction Trans
LEFT JOIN vyuRKGetDailyAveragePriceDetail Detail ON Detail.intDailyAveragePriceDetailId = Trans.intDailyAveragePriceDetailId
JOIN vyuRKGetDailyAveragePriceDetail RefDetail ON RefDetail.intDailyAveragePriceDetailId = Trans.intRefDailyAveragePriceDetailId
WHERE strTransactionType = 'DailyAveragePriceDetail'