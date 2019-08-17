CREATE VIEW [dbo].[vyuCTContractFutures]
AS 
SELECT CF.intContractFuturesId
,CF.intContractDetailId
,CF.intFutOptTransactionId
,dblFuturesPrice = CD.dblFutures
,CF.intFutureMarketId
,CF.dblNoOfLots
,CF.dblQuantity
,CF.dblHedgeNoOfLots
,CF.ysnAA
,CF.dblHedgePrice
,strHedgeCurrency = CY.strCurrency
,strHedgeUOM = UM.strUnitMeasure
,CF.intHedgeFutureMonthId
,strHedgeMonth = REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ')
,CF.intBrokerId
,strBroker = EY.strName
,CF.intBrokerageAccountId
,strBrokerAccount = BA.strAccountNumber
,strInternalTradeNo = FT.strInternalTradeNo
,CF.intConcurrencyId
FROM tblCTContractFutures CF
INNER JOIN tblCTContractDetail CD ON CF.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblRKFutOptTransaction FT ON CF.intFutOptTransactionId = FT.intFutOptTransactionId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CF.intHedgeFutureMonthId
LEFT JOIN tblEMEntity EY ON EY.intEntityId = CF.intBrokerId
LEFT JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = CF.intBrokerageAccountId
LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CD.intUnitMeasureId