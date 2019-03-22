CREATE PROC uspRKRiskPositionContractDetail 
	 @intCommodityId INT
	,@intFutureMarketId INT
	,@dtmToDate DATETIME = NULL
 
AS
--declare @intCommodityId INT = 21
--	,@dtmToDate DATETIME = getdate()
--,@intFutureMarketId int = 13


SELECT intRowNum	,
strCommodityCode	,
intCommodityId	,
intContractHeaderId	,
strContractNumber,
strLocationName,
dtmEndDate,
dblBalance,
intUnitMeasureId,
intPricingTypeId,
intContractTypeId,
intCompanyLocationId,
strContractType,
strPricingType,
intCommodityUnitMeasureId	,
intContractDetailId	,
intContractStatusId	,
intEntityId	,
intCurrencyId	,
strType	,
intItemId	,
strItemNo	,
dtmContractDate	,
strEntityName	,
strCustomerContract	,
intFutureMarketId	,
intFutureMonthId,intItemUOMId,intBookId as intBookId,intSubBookId as intSubBookId,dblQuantity,isnull(dblBalance,0)*isnull(dblRatio ,0) dblRatioQty,dblNoOfLot,dtmHistoryCreated,intHeaderPricingTypeId
FROM
(
select * 
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum,dtmHistoryCreated
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,h.intContractHeaderId
		,h.strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		, dblBalance
		,intDtlQtyUnitMeasureId intUnitMeasureId
		,h.intPricingTypeId
		,h.intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,h.intFutureMarketId
		,h.intFutureMonthId,strPricingStatus,h.intItemUOMId,h.intBookId as intBookId,h.intSubBookId as intSubBookId,h.dblQuantity,dblLotsPriced dblNoOfLot,
		ch.intPricingTypeId as intHeaderPricingTypeId,dblRatio dblRatio
	FROM tblCTSequenceHistory h
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=h.intContractHeaderId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
	) a
WHERE a.intRowNum = 1  AND strPricingStatus IN ('Fully Priced') AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId  in (1,2,8)

UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum,dtmHistoryCreated
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,h.intContractHeaderId
		,h.strContractNumber + '-' + Convert(NVARCHAR, h.intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		--,isnull(dblQtyUnpriced,dblQuantity) + ISNULL(dblQtyPriced - (dblQuantity - dblBalance),0) dblBalance
		,case when strPricingStatus='Parially Priced' then h.dblQuantity - ISNULL(h.dblQtyPriced + (h.dblQuantity - h.dblBalance),0) 
				else isnull(h.dblQtyUnpriced,h.dblQuantity) end dblBalance 		
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,2 intPricingTypeId
		,h.intContractTypeId
		,h.intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Basis' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,h.intFutureMarketId
		,h.intFutureMonthId
		,strPricingStatus,h.intItemUOMId,h.intBookId as intBookId,h.intSubBookId as intSubBookId,h.dblQuantity,
		dblLotsUnpriced dblNoOfLot,
		ch.intPricingTypeId as intHeaderPricingTypeId,dblRatio dblRatio
	FROM tblCTSequenceHistory h
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=h.intContractHeaderId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
	
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId in(2,8) and strPricingStatus in( 'Parially Priced','Unpriced') 

UNION

SELECT intRowNum,	dtmHistoryCreated	,strCommodityCode,	intCommodityId,	intContractHeaderId,	strContractNumber,
	strLocationName,	dtmEndDate,	dblBalance,	intUnitMeasureId,	1 as intPricingTypeId,	intContractTypeId,	intCompanyLocationId,	strContractType,	strPricingType,
		intCommodityUnitMeasureId,	intContractDetailId,	intContractStatusId,	intEntityId,	intCurrencyId,	strType	,
		intItemId,	strItemNo,	dtmContractDate	,strEntityName,	strCustomerContract,	intFutureMarketId,	intFutureMonthId,	strPricingStatus,	intItemUOMId,	intBookId,
			intSubBookId,	dblQuantity,	dblNoOfLot,	intHeaderPricingTypeId,	dblRatio

FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum,dtmHistoryCreated
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,h.intContractHeaderId
		,h.strContractNumber + '-' + Convert(NVARCHAR, h.intContractSeq) strContractNumber
		,strLocation strLocationName
		,h.dtmEndDate
		,CASE WHEN h.dblQtyPriced - (h.dblQuantity - h.dblBalance) < 0 THEN 0 ELSE h.dblQtyPriced - (h.dblQuantity - h.dblBalance) END dblBalance
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,2 intPricingTypeId
		,h.intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,h.intContractDetailId
		,h.intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,h.intFutureMarketId
		,h.intFutureMonthId 
		,strPricingStatus,intItemUOMId,h.intBookId as intBookId,h.intSubBookId as intSubBookId,h.dblQuantity
		,dblLotsPriced dblNoOfLot
		,ch.intPricingTypeId as intHeaderPricingTypeId,dblRatio dblRatio
	FROM tblCTSequenceHistory h
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=h.intContractHeaderId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 

	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and strPricingStatus = 'Parially Priced'  and intPricingTypeId in(2,8)

)t
