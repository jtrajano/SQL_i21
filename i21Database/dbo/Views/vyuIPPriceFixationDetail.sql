CREATE VIEW vyuIPPriceFixationDetail
AS
SELECT PFD.intPriceFixationDetailId
	,PFD.intPriceFixationId
	,PFD.intNumber
	,PFD.strTradeNo
	,PFD.strOrder
	,PFD.dtmFixationDate
	,PFD.dblQuantity
	,PFD.dblQuantityAppliedAndPriced
	,PFD.dblLoadAppliedAndPriced
	,PFD.dblLoadPriced
	,UM.strUnitMeasure AS strQtyItemUOM
	,PFD.dblNoOfLots
	,FM.strFutMarketName
	,FMon.strFutureMonth
	,FHMon.strFutureMonth AS strHedgeFutureMonth
	,PFD.dblFixationPrice
	,PFD.dblFutures
	,PFD.dblBasis
	,PFD.dblPolRefPrice
	,PFD.dblPolPremium
	,PFD.dblCashPrice
	,PFD.intPricingUOMId
	,PFD.ysnHedge
	,PFD.ysnAA
	,PFD.dblHedgePrice
	,PFD.intHedgeFutureMonthId
	,Broker.strName AS strBroker
	,BrokerageAccount.strAccountNumber
	--,intFutOptTransactionId
	,PFD.dblFinalPrice
	,PFD.strNotes
	,PFD.intPriceFixationDetailRefId
	--,intBillId
	--,intBillDetailId
	--,intInvoiceId
	--,intInvoiceDetailId
	--,intDailyAveragePriceDetailId
	,I.strItemNo
	,UM1.strUnitMeasure AS strPriceItemUOM
FROM tblCTPriceFixationDetail PFD
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = PFD.intQtyItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = IU.intItemId
LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = PFD.intPricingUOMId
LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = CUM.intUnitMeasureId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = PFD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMon ON FMon.intFutureMonthId = PFD.intFutureMonthId
LEFT JOIN tblRKFuturesMonth FHMon ON FHMon.intFutureMonthId = PFD.intHedgeFutureMonthId
LEFT JOIN tblEMEntity Broker ON Broker.intEntityId = PFD.intBrokerId
LEFT JOIN tblRKBrokerageAccount BrokerageAccount ON BrokerageAccount.intBrokerageAccountId = PFD.intBrokerageAccountId

