CREATE PROC uspRKDPRContractDetail 
	@intCommodityId int =null,
	@dtmToDate datetime= null
AS
	set @dtmToDate=convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

SELECT * FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblQuantity - isnull(dblQuantity-dblBalance,0)  dblBalance,
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,strContractType+' Priced' AS strType	
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId		
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId 
    WHERE intPricingTypeId=1 and dtmHistoryCreated <= @dtmToDate and h.intCommodityId=@intCommodityId
		  and intContractStatusId  not in(2,3,6) 
	) a where a.intRowNum =1 

    UNION ALL

   select * from (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblQtyUnpriced dblBalance,  -- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,strContractType+' Basis' AS strType
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId
    WHERE  dblQuantity >= (dblQuantity-dblBalance) and dtmHistoryCreated <= @dtmToDate and h.intCommodityId=@intCommodityId
	and intContractStatusId  not in(2,3,6)
	) a where a.intRowNum =1 

 UNION ALL
	  SELECT * FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblQtyPriced-(dblQuantity-dblBalance)  dblBalance,  -- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,strContractType+' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId
    WHERE  dblQuantity > (dblQuantity-dblBalance) and dtmHistoryCreated <= @dtmToDate and h.intCommodityId=@intCommodityId
	and intContractStatusId  not in(2,3,6)
	) a where a.intRowNum =1 

 UNION ALL
	  SELECT * FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblBalance dblBalance,  -- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,strContractType+' Basis' AS strType
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId
    WHERE  dblQuantity < (dblQuantity-dblBalance) and dtmHistoryCreated <= @dtmToDate and h.intCommodityId=@intCommodityId
	and intContractStatusId  not in(2,3,6)
	) a where a.intRowNum =1 

 UNION ALL
	  SELECT * FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblBalance  dblBalance,  
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,case when intPricingTypeId=1 then strContractType+' Priced'  else  strContractType+' Basis' end AS strType
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId
        WHERE   intContractDetailId NOT IN (SELECT intContractDetailId FROM tblCTPriceFixation) and dtmHistoryCreated <= @dtmToDate and h.intCommodityId=@intCommodityId
		and intContractStatusId  not in(2,3,6)
	) a where a.intRowNum =1 

	UNION ALL
  SELECT * FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC) intRowNum, 
		strCommodity strCommodityCode,
		h.intCommodityId intCommodityId,
		intContractHeaderId,
	     strContractNumber +'-' +Convert(nvarchar,intContractSeq)  strContractNumber
		,strLocation strLocationName,
		dtmEndDate,
		dblBalance  dblBalance,  
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' ' + strPricingType AS strType
		,i.intItemId intItemId
		,strItemNo,getdate() dtmContractDate,e.strName strEntityName,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
	FROM    tblCTSequenceHistory h
	JOIN tblICItem i on h.intItemId=i.intItemId
	JOIN tblEMEntity e on e.intEntityId=h.intEntityId
        WHERE intPricingTypeId Not In(1,2) and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110)<=convert(datetime,@dtmToDate) and h.intCommodityId=@intCommodityId
		and intContractStatusId  not in(2,3,6) 
	) a WHERE a.intRowNum =1 