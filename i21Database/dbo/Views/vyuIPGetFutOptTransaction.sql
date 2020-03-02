CREATE VIEW vyuIPGetFutOptTransaction
AS
SELECT T.intFutOptTransactionId
	,T.intFutOptTransactionHeaderId
	,T.intConcurrencyId
	,T.dtmTransactionDate
	,T.intEntityId
	,T.intBrokerageAccountId
	,T.intFutureMarketId
	,T.dblCommission
	,T.intBrokerageCommissionId
	,T.intInstrumentTypeId
	,T.intCommodityId
	,T.intLocationId
	,T.intTraderId
	,T.intCurrencyId
	,T.strInternalTradeNo
	,T.strBrokerTradeNo
	,T.strBuySell
	,T.dblNoOfContract
	,T.intFutureMonthId
	,T.intOptionMonthId
	,T.strOptionType
	,T.dblStrike
	,T.dblPrice
	,T.strReference
	,T.strStatus
	,T.dtmFilledDate
	,T.strReserveForFix
	,T.intBookId
	,T.intSubBookId
	,T.ysnOffset
	,T.intBankId
	,T.intBankAccountId
	--,T.intContractDetailId
	--,T.intContractHeaderId
	,T.intSelectedInstrumentTypeId
	,T.intCurrencyExchangeRateTypeId
	,T.strFromCurrency
	,T.strToCurrency
	,T.dtmMaturityDate
	,T.dblContractAmount
	,T.dblExchangeRate
	,T.dblMatchAmount
	,T.dblAllocatedAmount
	,T.dblUnAllocatedAmount
	,T.dblSpotRate
	,T.ysnLiquidation
	,T.ysnSwap
	,T.strRefSwapTradeNo
	,T.intRefFutOptTransactionId
	,T.dtmCreateDateTime
	,T.ysnFreezed
	,T.intRollingMonthId
	,T.intFutOptTransactionRefId
	,T.ysnPreCrush
	,E.strName
	,BA.strAccountNumber
	,FM.strFutMarketName
	,C.strCommodityCode
	,CL.strLocationName
	,E1.strName AS strTrader
	,CUR.strCurrency
	,FUT.strFutureMonth
	,FUT1.strFutureMonth AS strRollingMonth
	,OM.strOptionMonth
	,B.strBook
	,SB.strSubBook
	,BANK.strBankName
	,BAA.strBankAccountNo
	,CE.strCurrencyExchangeRateType
FROM tblRKFutOptTransaction T WITH (NOLOCK)
LEFT JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = T.intEntityId
LEFT JOIN tblRKBrokerageAccount BA WITH (NOLOCK) ON BA.intBrokerageAccountId = T.intBrokerageAccountId
LEFT JOIN tblRKFutureMarket FM WITH (NOLOCK) ON FM.intFutureMarketId = T.intFutureMarketId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = T.intCommodityId
LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = T.intLocationId
LEFT JOIN tblEMEntity E1 WITH (NOLOCK) ON E1.intEntityId = T.intTraderId
LEFT JOIN tblSMCurrency CUR WITH (NOLOCK) ON CUR.intCurrencyID = T.intCurrencyId
LEFT JOIN tblRKFuturesMonth FUT WITH (NOLOCK) ON FUT.intFutureMonthId = T.intFutureMonthId
LEFT JOIN tblRKOptionsMonth OM WITH (NOLOCK) ON OM.intOptionMonthId = T.intOptionMonthId
LEFT JOIN tblCTBook B WITH (NOLOCK) ON B.intBookId = T.intBookId
LEFT JOIN tblCTSubBook SB WITH (NOLOCK) ON SB.intSubBookId = T.intSubBookId
LEFT JOIN tblCMBank BANK WITH (NOLOCK) ON BANK.intBankId = T.intBankId
LEFT JOIN tblCMBankAccount BAA WITH (NOLOCK) ON BAA.intBankAccountId = T.intBankAccountId
LEFT JOIN tblSMCurrencyExchangeRateType CE WITH (NOLOCK) ON CE.intCurrencyExchangeRateTypeId = T.intCurrencyExchangeRateTypeId
LEFT JOIN tblRKFuturesMonth FUT1 WITH (NOLOCK) ON FUT1.intFutureMonthId = T.intRollingMonthId
