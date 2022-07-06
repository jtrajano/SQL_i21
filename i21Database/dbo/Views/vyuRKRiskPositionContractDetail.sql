CREATE VIEW vyuRKRiskPositionContractDetail

AS

SELECT DISTINCT CT.strContractType
	, CD.dblBalance
	, dblDetailQuantity = ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblInvoicedQty, 0)
	, CH.strContractNumber
	, CD.intContractSeq
	, dtmStartDate = ISNULL(CD.dtmM2MDate, GETDATE())
	, dtmEndDate = ISNULL(CD.dtmEndDate, GETDATE())
	, strEntityName = EY.strName
	, CD.dblNoOfLots
	, CH.intContractHeaderId
	, CD.intPricingTypeId
	, CH.intCommodityId
	, CD.intCompanyLocationId
	, CD.intFutureMarketId
	, CD.intFutureMonthId
	, CD.intItemUOMId
	, CD.intItemId
	, IU.intUnitMeasureId
	, CD.intContractStatusId
	, CD.intContractDetailId
	, dblHeaderNoOfLots = CH.dblNoOfLots
	, CH.ysnMultiplePriceFixation
	, dblDetailNoOfLots = CD.dblNoOfLots
	, CT.intContractTypeId
	, FM.strFutureMonth
	, CD.intBookId
	, book.strBook
	, CD.intSubBookId
	, subBook.strSubBook
	, dblRatioQty = ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblInvoicedQty, 0)
	, dtmTransactionDate = ISNULL(CD.dtmM2MDate, GETDATE())
	, intPricingTypeIdHeader = CH.intPricingTypeId
	, intLocationId = CD.intCompanyLocationId
	, Location.strLocationName
	, intCropYearId = CH.intCropYearId 
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId AND CD.intContractStatusId NOT IN (2, 3)
JOIN tblRKFuturesMonth FM on FM.intFutureMonthId = CD.intFutureMonthId
JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId 
JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = CD.intCompanyLocationId
LEFT JOIN tblCTBook book ON book.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = CD.intSubBookId
WHERE CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)