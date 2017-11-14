CREATE VIEW vyuRKRiskPositionContractDetail
AS
SELECT * FROM (
SELECT DISTINCT CT.strContractType
	,CD.dblBalance
	,isnull(CD.dblQuantity,0) - 
	(case when CH.intContractTypeId=1 then 
			isnull((select sum(a.dblPurchaseInvoiceQty)  from vyuRKGetInvoicedQty a where a.intPContractDetailId=CD.intContractDetailId),0) 
			ELSE 
			isnull((select sum(b.dblSalesInvoiceQty) from vyuRKGetInvoicedQty b where b.intSContractDetailId=CD.intContractDetailId),0)  end) AS dblDetailQuantity
	,CH.strContractNumber
	,CD.intContractSeq
	,CD.dtmStartDate
	,EY.strName strEntityName
	,CD.dblNoOfLots
	,CH.intContractHeaderId
	,CD.intPricingTypeId
	,CH.intCommodityId
	,CD.intCompanyLocationId
	,CD.intFutureMarketId
	,CD.intFutureMonthId
	,CD.intItemUOMId
	,CD.intItemId
	,IU.intUnitMeasureId
	,CD.intContractStatusId
	,CD.intContractDetailId
	,CH.dblNoOfLots dblHeaderNoOfLots
	,CH.ysnMultiplePriceFixation
	,CD.dblNoOfLots dblDetailNoOfLots
	,CT.intContractTypeId,FM.strFutureMonth
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId AND CD.intContractStatusId not in(2,3)
JOIN tblRKFuturesMonth FM on FM.intFutureMonthId=CD.intFutureMonthId
JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId 
)t WHERE  dblDetailQuantity >0

