CREATE PROC [dbo].[uspRKM2MInquiryTransaction]  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(50)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null
AS

DECLARE @ysnIncludeBasisDifferentialsInResults bit
DECLARE @dtmPriceDate DATETIME    
DECLARE @dtmSettlemntPriceDate DATETIME  
DECLARE @strLocationName nvarchar(50)
DECLARE @ysnIncludeInventoryM2M bit
DECLARE @ysnEnterForwardCurveForMarketBasisDifferential bit

SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @ysnEnterForwardCurveForMarketBasisDifferential=ysnEnterForwardCurveForMarketBasisDifferential FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId
SELECT @strLocationName=strLocationName from tblSMCompanyLocation where intCompanyLocationId=@intLocationId
SELECT @ysnIncludeInventoryM2M= ysnIncludeInventoryM2M from tblRKCompanyPreference
DECLARE @tblFinalDetail TABLE (
       intContractHeaderId int,   
       intContractDetailId int
       ,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strEntityName NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intEntityId int
       ,strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intFutureMarketId int
       ,strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intFutureMonthId int
       ,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intCommodityId int
       ,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intItemId int
       ,strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intOriginId int
       ,strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intPricingTypeId int
       ,strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,dblFutures NUMERIC(24, 10)      
       ,dblCash NUMERIC(24, 10)
       ,dblCosts NUMERIC(24, 10)
       ,dblMarketBasis1 NUMERIC(24, 10)
       ,dblMarketBasisUOM  NUMERIC(24, 10)
       ,dblContractBasis NUMERIC(24, 10)
       ,dblFuturePrice1 NUMERIC(24, 10)
       ,dblFuturesClosingPrice1 NUMERIC(24, 10)
       ,intContractTypeId int
       ,intConcurrencyId int
       ,dblOpenQty NUMERIC(24, 10)
       ,dblRate NUMERIC(24, 10)
       ,intCommodityUnitMeasureId int
       ,intQuantityUOMId INT
       ,intPriceUOMId INT
       ,intCurrencyId INT
       ,PriceSourceUOMId INT
       ,intltemPrice INT
       ,dblMarketBasis NUMERIC(24, 10)
       ,dblCashPrice NUMERIC(24, 10)
       ,dblAdjustedContractPrice NUMERIC(24, 10)
       ,dblFuturesClosingPrice NUMERIC(24, 10)
       ,dblFuturePrice NUMERIC(24, 10)
       ,dblMarketPrice NUMERIC(24, 10)
       ,dblResult NUMERIC(24, 10)
       ,dblResultBasis1 NUMERIC(24, 10)
       ,dblMarketFuturesResult NUMERIC(24, 10)
       ,dblResultCash1 NUMERIC(24, 10)
       ,dblContractPrice NUMERIC(24, 10)
       ,dblResultCash NUMERIC(24, 10)
       ,dblResultBasis NUMERIC(24, 10)
       ,dblShipQty numeric(24,10)
       ,ysnSubCurrency bit
       ,intMainCurrencyId int
       ,intCent int
	   ,dtmPlannedAvailabilityDate datetime
       )

INSERT INTO @tblFinalDetail (intContractHeaderId,
    intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 

SELECT distinct   intContractHeaderId,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,0 as intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice,dblFuturePrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
      dblResultBasis,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate FROM(
SELECT *,   
       isnull(dblFuturePrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
       ,0 dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
CASE when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,

CASE WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
ELSE 
CONVERT(DECIMAL(24,6),
CASE WHEN ISNULL(dblRate,0)=0 THEN 
               dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
ELSE
CASE WHEN case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*isnull(dblRate,0) 
ELSE                                            dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
END) 
+ 
convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblFutures,0))
else
case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*isnull(dblRate,0) 
else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
end) + 
isnull(dblCosts,0)
END AS dblAdjustedContractPrice,

dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturePrice,    
    
convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblContractOriginalQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblContractOriginalQty) end )
    -isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then InTransQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,InTransQty)end),0)
    as dblOpenQty
  FROM
(SELECT cd.intContractHeaderId, cd.intContractDetailId,
					'Contract'+'('+LEFT(cd.strContractType,1)+')' as strContractOrInventoryType,
                  cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
                  cd.strEntityName strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId as intItemId,
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  cd.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
					dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,(CASE WHEN ffm.ysnExpired= 0 THEN cd.intFutureMonthId  ELSE (SELECT TOP 1  intFutureMonthId FROM tblRKFuturesMonth FuMo WHERE dtmFutureMonthsDate > (
                                        SELECT dtmFutureMonthsDate from tblRKFuturesMonth mo 
                                        WHERE mo.intFutureMonthId = cd.intFutureMonthId ) AND FuMo.ysnExpired = 0 
                                        AND FuMo.intFutureMarketId = cd.intFutureMarketId 
                                        ORDER BY intFutureMarketId,dtmFutureMonthsDate asc)
					 end) ,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,
                  isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN isnull(dblFutures,0)
                  --(SELECT     (isnull(dblFutures,0)) 
                  --      FROM tblCTContractDetail  cdv                         
                  --      WHERE intPricingTypeId=1 and cdv.intContractStatusId not in(2,3,6) AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(pfd.[dblNoOfLots],0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(pfd.[dblNoOfLots],0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId                        
						where cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId and cdv.intContractStatusId not in(2,3,6))t) end
                  ) as dblFutures ,                
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
                            
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,                            
                         isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,                                                                          
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,                         
                  CONVERT(int,cd.intContractTypeId) intContractTypeId ,
                  cd.dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId,
        (select sum(dblCosts) FROM    
            (SELECT case when strAdjustmentType = 'Add' then abs(sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0)))) 
                                  WHEN strAdjustmentType = 'Reduce' then -sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
                                  ELSE 0 END dblCosts,strAdjustmentType
            FROM vyuRKM2MContractCost dc 
			    JOIN tblRKM2MConfiguration M2M on dc.intItemId= M2M.intItemId and cd.intContractBasisId=M2M.intContractBasisId
                JOIN tblICCommodityUnitMeasure cu1 on cd.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
                JOIN tblICCommodityUnitMeasure cu on cd.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=@intPriceUOMId                           
                WHERE  dc.intContractDetailId=cd.intContractDetailId
                group by cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,strAdjustmentType)t ) dblCosts,   
         cd.dblBalance  as dblContractOriginalQty,
		 SUM(iv.dblPurchaseContractShippedQty) over (Partition BY cd.intContractDetailId) as InTransQty,
		 cur.ysnSubCurrency,cur.intMainCurrencyId,cur.intCent,cd.dtmPlannedAvailabilityDate
		 ,cd.intCompanyLocationId,cd.intMarketZoneId,cd.intContractStatusId,dtmContractDate,
		 ffm.ysnExpired
FROM vyuRKM2MGetContractDetailView  cd
JOIN tblICItem i on cd.intItemId= i.intItemId 
JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId 
	and convert(datetime,convert(varchar, cd.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
	and cd.intContractStatusId not in(2,3,6) and cd.intCommodityId= @intCommodityId and intContractStatusId not in(2,3,6) 
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and  cuc2.intUnitMeasureId  = @intPriceUOMId
LEFT JOIN vyuRKPurchaseIntransitView iv on iv.intContractDetailId=cd.intContractDetailId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId 
WHERE  cd.intCommodityId= @intCommodityId
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
            AND intContractStatusId not in(2,3,6) and convert(datetime,convert(varchar, cd.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
			)t 
)t where  isnull(dblOpenQty,0) >0 )t1 

if isnull(@ysnIncludeInventoryM2M,0) = 1
BEGIN

INSERT INTO @tblFinalDetail (intContractHeaderId,
    intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 
SELECT DISTINCT     intContractHeaderId,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis,0 as dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate FROM(
SELECT *,
   isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty1,0))) dblResultCash1
       ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+isnull(dblFutures,0) dblContractPrice
FROM 
 (SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
                     end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice,         
       isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty1)end),0)       
          -isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQtyShipped else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQtyShipped)end),0)            
                -isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblInvoiceQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblInvoiceQty)end),0)
              as dblOpenQty
  FROM
(SELECT   distinct  cd.intContractHeaderId, cd.intContractDetailId,
                  'Inventory (P)' as strContractOrInventoryType,
                  cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
                  cd.strEntityName strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId as intItemId,
				  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  cd.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN isnull(dblFutures,0)
                  --(SELECT     (isnull(dblFutures,0)) 
                  --      FROM tblCTContractDetail  cdv                         
                  --      WHERE intPricingTypeId=1 and cdv.intContractStatusId not in(2,3,6) AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(pfd.[dblNoOfLots],0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(pfd.[dblNoOfLots],0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId                        
						where cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId and cdv.intContractStatusId not in(2,3,6))t) end
                  ) as dblFutures ,             
                 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
                            
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,          
                  
                         isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,
                                                                          
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  CONVERT(int,cd.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,
                   (SELECT top 1 (OpenQty) from vyuRKGetInventoryAdjustQty aq where cd.intContractDetailId=aq.intContractDetailId)
                               as  dblOpenQty1,                  
                  cd.dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId,

        (select sum(dblCosts) FROM    
            (SELECT case when strAdjustmentType = 'Add' then abs(sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0)))) 
                                  WHEN strAdjustmentType = 'Reduce' then -sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
                                  ELSE 0 END dblCosts,strAdjustmentType
            FROM vyuRKM2MContractCost dc 
				JOIN tblRKM2MConfiguration M2M on dc.intItemId= M2M.intItemId and cd.intContractBasisId=M2M.intContractBasisId
                JOIN tblICCommodityUnitMeasure cu1 on cd.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
                JOIN tblICCommodityUnitMeasure cu on cd.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=@intPriceUOMId                           
                WHERE  dc.intContractDetailId=cd.intContractDetailId
                group by cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,strAdjustmentType)t ) dblCosts,   

                     -- (SELECT SUM(ISNULL(dblUnitReserved,0)) FROM vyuRKGetSalesIntransit iv WHERE iv.intContractDetailId=cd.intContractDetailId)  dblSalesIntransit,
                     (SELECT sum(cd1.dblQty) from vyuRKGetSalesIntransit  cd1 where cd1.intContractDetailId= cd.intContractDetailId)  dblOpenQtyShipped,                              
                                   (SELECT sum(cd1.dblInvoiceQty) from vyuRKGetInventoryAdjustQty  cd1 where cd1.intContractDetailId= cd.intContractDetailId)  dblInvoiceQty
                                  ,cur.ysnSubCurrency,cur.intMainCurrencyId,cur.intCent,cd.dtmPlannedAvailabilityDate

FROM tblICInventoryReceiptItem ri
JOIN tblICItem i on ri.intItemId= i.intItemId and i.strLotTracking<>'No'
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ri.intInventoryReceiptId
join vyuRKM2MGetContractDetailView  cd on ri.intLineNo=cd.intContractDetailId and cd.intContractHeaderId = ri.intOrderId  AND cd.intCommodityId= @intCommodityId
JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId and cd.intContractStatusId not in(2,3,6) AND intContractTypeId =1 and intSourceType=2  
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
WHERE  cd.intCommodityId= @intCommodityId
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
            AND intContractStatusId not in(2,3,6) and convert(datetime,convert(varchar, cd.dtmContractDate, 101),101) 
			<= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
			)t 
)t1)t2 WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory (P)' else '' end 

END

INSERT INTO @tblFinalDetail (intContractHeaderId,
    intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 
SELECT DISTINCT    intContractHeaderId, intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturePrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis,0 as dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate FROM(
SELECT *,   
       isnull(dblFuturePrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
       ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+isnull(dblFutures,0) dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturePrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
              end dblAdjustedContractPrice,
         dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice, 

        (convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblOpenQty1,0))end))
         -(isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblContractPQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblContractPQty,0))end),0))
         as dblOpenQty,
		 dblFuturePrice1 dblFuturesClosingPrice1
  FROM
(SELECT  distinct  cd.intContractHeaderId,  cd.intContractDetailId,
                  'In-transit'+'(P)' as strContractOrInventoryType,
                  cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
                  cd.strEntityName strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId as intItemId,
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  ch.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END,0) dblContractBasis,
                 (CASE WHEN cd.intPricingTypeId=1 THEN isnull(dblFutures,0)
                  --(SELECT     (isnull(dblFutures,0)) 
                  --      FROM tblCTContractDetail  cdv                         
                  --      WHERE intPricingTypeId=1 and cdv.intContractStatusId not in(2,3,6) AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(pfd.[dblNoOfLots],0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(pfd.[dblNoOfLots],0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId                        
						where cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId and cdv.intContractStatusId not in(2,3,6))t) end
                  ) as dblFutures  ,
                               
                  
                  CASE WHEN cd.intPricingTypeId=6 then cd.dblCashPrice else null end dblCash,            
       
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,    
                  isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,                                                              
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,
				     convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,                           
                  SUM(sri.dblOpenReceive) over (partition by cd.intContractDetailId) dblContractPQty,   

                  (select sum(cc.dblPurchaseContractShippedQty) from vyuRKPurchaseIntransitView cc where cc.intContractDetailId=cd.intContractDetailId)  dblOpenQty1,
                             cd.dblRate,
                      cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId ,

                     (SELECT sum(dblCosts) FROM    
                     (SELECT case when strAdjustmentType = 'Add' then abs(sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0)))) 
                           WHEN strAdjustmentType = 'Reduce' then -sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
                           ELSE 0 END dblCosts,strAdjustmentType
                     FROM vyuCTContractCostView dc 
					 JOIN tblRKM2MConfiguration M2M on dc.intItemId= M2M.intItemId and cd.intContractBasisId=M2M.intContractBasisId
                     JOIN tblICCommodityUnitMeasure cu1 on cd.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
                     JOIN tblICCommodityUnitMeasure cu on cd.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=@intPriceUOMId                   
                     WHERE  dc.intContractDetailId=cd.intContractDetailId
                     GROUP BY cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,strAdjustmentType)t ) dblCosts,   
                     0 dblSalesIntransit
                     ,dblDetailQuantity as dblContractOriginalQty,cur.ysnSubCurrency,cur.intMainCurrencyId,cur.intCent,cd.dtmPlannedAvailabilityDate
FROM vyuRKM2MGetContractDetailView cd
JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId and cd.intContractStatusId not in(2,3,6) AND cd.intCommodityId= @intCommodityId     
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId        
           AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end       
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId 
JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICInventoryReceiptItem sri  on cd.intContractDetailId=sri.intLineNo
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=cd.intOriginId  
WHERE 
 cd.intCommodityId= @intCommodityId
           AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end    and
intContractStatusId not in(2,3,6) AND convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t       
)t)t2

INSERT INTO @tblFinalDetail (intContractHeaderId,
              intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 
SELECT DISTINCT intContractHeaderId, intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis,0 as dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate  FROM(
SELECT *,   
       isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
       ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+isnull(dblFutures,0) dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
              end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice,
        (isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblOpenQty1,0))end),0))
         as dblOpenQty
  FROM
(
SELECT  distinct  cd.intContractHeaderId,cd.intContractDetailId,
                  'In-transit'+'(S)' as strContractOrInventoryType,
                  cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
                  cd.strEntityName strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId as intItemId,
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  cd.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END,0) dblContractBasis,
                 (CASE WHEN cd.intPricingTypeId=1 THEN isnull(dblFutures,0)
                  --(SELECT     (isnull(dblFutures,0)) 
                  --      FROM tblCTContractDetail  cdv                         
                  --      WHERE intPricingTypeId=1 and cdv.intContractStatusId not in(2,3,6) AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(pfd.[dblNoOfLots],0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(pfd.[dblNoOfLots],0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId                        
						where cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId and cdv.intContractStatusId not in(2,3,6))t) end
                  ) as dblFutures ,
                                   
                  CASE WHEN cd.intPricingTypeId=6 then cd.dblCashPrice else null end dblCash,
                       isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,    
                  isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,                                                              
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  convert(int,cd.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

                          (SELECT sum(cd1.dblQty) from vyuRKGetSalesIntransit  cd1 where cd1.intContractDetailId= cd.intContractDetailId)  dblOpenQty1,
                             cd.dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId ,

        (select sum(dblCosts) FROM    
            (SELECT case when strAdjustmentType = 'Add' then abs(sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0)))) 
                                  WHEN strAdjustmentType = 'Reduce' then -sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
                                  ELSE 0 END dblCosts,strAdjustmentType
            FROM vyuCTContractCostView dc 
				JOIN tblRKM2MConfiguration M2M on dc.intItemId= M2M.intItemId and cd.intContractBasisId=M2M.intContractBasisId
                JOIN tblICCommodityUnitMeasure cu1 on cd.intCommodityId=cu1.intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
                JOIN tblICCommodityUnitMeasure cu on cd.intCommodityId=cu.intCommodityId and cu.intUnitMeasureId=@intPriceUOMId                           
                WHERE  dc.intContractDetailId=cd.intContractDetailId
                group by cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,strAdjustmentType)t ) dblCosts
                     ,cur.ysnSubCurrency,cur.intMainCurrencyId,cur.intCent,cd.dtmPlannedAvailabilityDate
FROM vyuRKGetSalesIntransit si
JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intContractDetailId and cd.intContractStatusId not in(2,3,6)
            AND cd.intCommodityId= @intCommodityId
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end 
JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId                    
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=cd.intOriginId  
WHERE intContractStatusId not in(2,3,6) AND convert(datetime,convert(varchar, cd.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)  )t       
)t)t2

---------------- Lot Not Controlled
if isnull(@ysnIncludeInventoryM2M,0) = 1
BEGIN
DECLARE @RunningQtyBalance AS TABLE 
              (
              RowNum int  , 
              intItemId  INT,
              dblRunningQtyBalance numeric(24,10)
              )
INSERT INTO @RunningQtyBalance (RowNum,intItemId,dblRunningQtyBalance)
SELECT RowNum,intItemId,dblRunningQtyBalance from
          (
          SELECT iv.intItemId,dblRunningQtyBalance,iv.dtmDate,ROW_NUMBER()
          over(Partition by iv.intItemId ORDER BY iv.dtmDate desc)RowNum FROM
          vyuICGetInventoryValuation iv 
JOIN tblICInventoryTransaction it on iv.intInventoryTransactionId=it.intInventoryTransactionId
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No'
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId and c.intCommodityId=@intCommodityId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=it.intTransactionId and intTransactionTypeId=4 AND ir.strReceiptType = 'Purchase Contract' 
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
JOIN tblCTContractDetail cd on cd.intContractDetailId=intLineNo AND intPricingTypeId in(2,5) and cd.intContractStatusId not in(2,3,6)
JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE  convert(datetime,convert(varchar,iv.dtmDate, 101),101) <= left(convert(varchar, getdate(), 101),10) )sr WHERE RowNum=1

INSERT INTO @tblFinalDetail (
    strContractOrInventoryType 
       ,strCommodityCode 
       ,intCommodityId 
       ,strItemNo 
       ,intItemId 
       ,intConcurrencyId 
       ,dblOpenQty 
       ,PriceSourceUOMId 
       ,intltemPrice 
       ,dblResult )

SELECT strContractOrInventoryType 
       ,strCommodityCode 
       ,intCommodityId 
       ,strItemNo 
       ,intItemId 
       ,intConcurrencyId 
       ,dblOpenQty 
       ,PriceSourceUOMId 
       ,intltemPrice 
       ,dblResult 
FROM(SELECT *,0 as intConcurrencyId, isnull(dblOpenQty,0) * isnull(intltemPrice,0) as dblResult,0 as PriceSourceUOMId
FROM 
(SELECT DISTINCT  'Inventory' as strContractOrInventoryType,                  
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  i.intItemId as intItemId,                 
                           isnull((select sum (isnull(giv.dblRunningQtyBalance,0)) from  @RunningQtyBalance giv where giv.intItemId=iv.intItemId),0) dblOpenQty,                 
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No' and i.intCommodityId= @intCommodityId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE i.intCommodityId= @intCommodityId
AND strLocationName= case when isnull(@strLocationName,'')='' then strLocationName else @strLocationName end

UNION

SELECT strContractOrInventoryType,strCommodityCode,intCommodityId,strItemNo,intItemId,sum(dblOpenQty) dblOpenQty,intltemPrice from(
              SELECT DISTINCT      'Inventory - '+ strPricingType as strContractOrInventoryType,                  
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  iv.intItemId as intItemId,                 
                          isnull(ri.dblReceived, 0) dblOpenQty,strPricingType ,                
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No' and i.intCommodityId= @intCommodityId
JOIN tblICInventoryTransaction it on iv.intInventoryTransactionId=it.intInventoryTransactionId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=it.intTransactionId and intTransactionTypeId=4 AND ir.strReceiptType = 'Purchase Contract' 
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
JOIN tblCTContractDetail cd on cd.intContractDetailId=intLineNo AND intPricingTypeId in(2,5)  and cd.intContractStatusId not in(2,3,6)
JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE i.intCommodityId= @intCommodityId
AND strLocationName= case when isnull(@strLocationName,'')='' then strLocationName else @strLocationName end)t1
group by  strContractOrInventoryType,strCommodityCode,intCommodityId, strItemNo, intItemId,strPricingType,intltemPrice

)t WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then strContractOrInventoryType else '' end )t2

END

IF (@strRateType='Configuration')
BEGIN
SELECT intContractHeaderId,
    convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFuturePrice)) as dblFuturePrice,
      intContractDetailId,strContractOrInventoryType,
      strContractSeq,strEntityName,intEntityId,strFutMarketName,
      intFutureMarketId,intFutureMonthId,strFutureMonth,
      strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
    case when convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblShipQty)end) < 0  THEN 0 else
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblShipQty)end)
            end as dblOpenQty,
      intPricingTypeId,strPricingType, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))) as dblContractBasis,
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)) as dblFutures,    
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash, 
         dblCosts,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketBasis)) as dblMarketBasis, 
      convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblContractPrice)) as dblContractPrice, 
      CONVERT(int,intContractTypeId) as intContractTypeId,
      CONVERT(int,0) as intConcurrencyId,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblAdjustedContractPrice)) as dblAdjustedContractPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCashPrice)) as dblCashPrice, 
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketPrice)) as dblMarketPrice,
              dblCashPrice as dblCashPrice,
              dblResult as dblResult1,
              dblResultBasis as dblResultBasis1,
              dblMarketFuturesResult as dblMarketFuturesResult1,
                       intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate   
FROM @tblFinalDetail ORDER BY intCommodityId
END
ELSE
BEGIN
SELECT *,isnull(dblContractBasis,0) + isnull(dblFutures,0) as dblContractPrice,
              convert(decimal(24,6),(isnull(dblAdjustedContractPrice,0)-isnull(dblMarketPrice,0))*isnull(dblResult1,0)) dblResult,
              convert(decimal(24,6),((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))*isnull(dblResultBasis1,0)) dblResultBasis,
              convert(decimal(24,6),((isnull(dblFutures,0)- isnull(dblFuturePrice,0))*isnull(dblMarketFuturesResult1,0))) dblMarketFuturesResult,
              case when strPricingType='Cash' THEN convert(decimal(24,6),(isnull(dblAdjustedContractPrice,0)-isnull(dblMarketPrice,0))*isnull(dblResult1,0))
              else null end as dblResultCash into #Temp   
 FROM(
      SELECT intContractHeaderId,
                     intContractDetailId,strContractOrInventoryType,
            strContractSeq,strEntityName,intEntityId,strFutMarketName,
            intFutureMarketId,intFutureMonthId,strFutureMonth,
            strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
                     case when intContractTypeId =1 then  dblOpenQty else -dblOpenQty end dblOpenQty ,                    
            intPricingTypeId,strPricingType,
            convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end end)
            as dblContractBasis,
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
            end)
            as dblFutures,             
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash, 
                     dblCosts,
                     dbo.fnRKGetCurrencyConvertion(CASE WHEN ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* 
                                                                     dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketBasis)
                     AS dblMarketBasis,
                     dbo.fnRKGetCurrencyConvertion(CASE WHEN ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* 
                                                                     dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFuturePrice)
                     
                     as dblFuturePrice,

            convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice,              
            CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId,            
             dblAdjustedContractPrice, 
                      dbo.fnRKGetCurrencyConvertion(CASE WHEN ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)*           
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketPrice)) as dblMarketPrice,                       
           
                     dblCashPrice as dblCashPrice, 
                     case when  ysnSubCurrency=1 then (convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)))/isnull(intCent,0) else convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)) end as dblResultCash1,
                     case when  ysnSubCurrency=1 then dblResult/isnull(intCent,0) else dblResult end as dblResult1,
                     case when  ysnSubCurrency=1 then dblResultBasis/isnull(intCent,0) else dblResultBasis end as dblResultBasis1,
                     case when  ysnSubCurrency=1 then dblMarketFuturesResult/isnull(intCent,0) else dblMarketFuturesResult end  as dblMarketFuturesResult1            
                                   ,intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate
      FROM @tblFinalDetail )t 
      ORDER BY intCommodityId,strContractSeq desc    
END

------------- Calculation of Results ----------------------
   UPDATE #Temp set dblResult=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice <= dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice >= dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblResult)
               END ,
              dblResultCash=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice <= dblMarketPrice) 
                  THEN abs(dblResultCash)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblResultCash)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice >= dblMarketPrice) 
                  THEN abs(dblResultCash)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblResultCash)
               END ,
               dblResultBasis=
             CASE WHEN intContractTypeId = 1 and (isnull(dblContractBasis,0) <= dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 1 and (isnull(dblContractBasis,0) > dblMarketBasis) 
                  THEN -abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (isnull(dblContractBasis,0) >= dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (isnull(dblContractBasis,0) < dblMarketBasis) 
                  THEN -abs(dblResultBasis)
               END ,
               dblMarketFuturesResult=
             CASE WHEN intContractTypeId = 1 and (isnull(dblFutures,0) <= isnull(dblFuturesClosingPrice,0)) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 1 and (isnull(dblFutures,0) > isnull(dblFuturesClosingPrice,0)) 
                  THEN -abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (isnull(dblFutures,0) >= isnull(dblFuturesClosingPrice,0)) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (isnull(dblFutures,0) < isnull(dblFuturesClosingPrice,0)) 
                  THEN -abs(dblMarketFuturesResult)
               END 
              
--------------END ---------------

SELECT DISTINCT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,0 as intConcurrencyId,intContractHeaderId,intContractDetailId,
strContractOrInventoryType,strContractSeq,strEntityName,intEntityId,intFutureMarketId,strFutMarketName,intFutureMonthId,
strFutureMonth,dblOpenQty dblOpenQty,strCommodityCode,intCommodityId,intItemId,strItemNo,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,intPricingTypeId,strPricingType,
dblContractBasis dblContractBasis,dblFutures dblFutures, dblCash dblCash ,abs(dblCosts) dblCosts,
dblMarketBasis dblMarketBasis,dblFuturePrice dblFuturePrice,intContractTypeId,dblAdjustedContractPrice dblAdjustedContractPrice ,
dblCashPrice dblCashPrice,dblMarketPrice dblMarketPrice,dblResult dblResult,dblResultBasis dblResultBasis,
dblMarketFuturesResult dblMarketFuturesResult,dblResultCash dblResultCash,
dblContractBasis + dblFutures + dblCash dblContractPrice,intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate from #Temp 
where dblOpenQty <> 0 
order by intContractHeaderId desc