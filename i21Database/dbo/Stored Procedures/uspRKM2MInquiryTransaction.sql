CREATE PROC uspRKM2MInquiryTransaction  
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

SELECT * INTO #temp1 FROM (
SELECT *,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash FROM(
SELECT *,
              
             isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
             CASE WHEN intContractTypeId = 1 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) < 0
                  THEN (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice)*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 1 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) >= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) <= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)-dblAdjustedContractPrice)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) > 0
                  THEN -(isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)- dblAdjustedContractPrice)*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
               end dblResult,
            case WHEN intPricingTypeId = 6  then 0 else 
            CASE WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end * dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                 end end dblResultBasis,
                 
             CASE WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) ) < 0)
                  THEN (dblFuturesClosingPrice - dblFutures) *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) ) >= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) ) <= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) ) > 0)
                  THEN -(dblFuturesClosingPrice - dblFutures) *dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
               end dblMarketFuturesResult,      
                   
                  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) < 0
                  THEN (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) >= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) <= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) > 0
                  THEN -(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty)
                end dblResultCash1
               ,isnull(dblContractBasis,0)+isnull(dblFutures,0) dblContractPrice 
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) end AS dblAdjustedContractPrice,
            dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice    
  FROM
(SELECT           cd.intContractDetailId,
                  'Contract'+'('+LEFT(ch.strContractType,1)+')' as strContractOrInventoryType,
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
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN
                  (SELECT     (isnull(dblFutures,0)) 
                        FROM tblCTContractDetail  cdv                         
                        WHERE intPricingTypeId=1 AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                  )t) end
                  ) dblFutures ,
                
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
            
                  isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct 
						  WHERE cd.intContractDetailId=ct.intContractDetailId and ysnMTM = 1),0) dblCosts,
                  
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
                                                                                   
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,                                
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

                  (case when ISNULL((SELECT TOP 1 dblNewValue from tblCTSequenceUsageHistory uh 
                        WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
                        and convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        ORDER BY dtmTransactionDate desc),0) =0  then cd.dblBalance else 
                        (SELECT TOP 1 dblNewValue from tblCTSequenceUsageHistory uh 
                        WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
                        AND convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) 
                        ORDER BY dtmTransactionDate desc) end ) as dblOpenQty,dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId      ,null as intltemPrice
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId 
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
WHERE  intContractStatusId<>3 and convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10))t
)t)t1
UNION 

SELECT *,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash FROM(
SELECT *,
            isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
             CASE WHEN intContractTypeId = 1 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice) < 0
                  THEN (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice)*dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) >= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice) <= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)-dblAdjustedContractPrice) > 0
                  THEN -(isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)- dblAdjustedContractPrice)*dblOpenQty
               end dblResult,
            case WHEN intPricingTypeId = 6  then 0 else 
            CASE WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                 end end dblResultBasis,
                 
             CASE WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) < 0)
                  THEN (dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) >= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) <= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) > 0)
                  THEN -(dblFuturesClosingPrice - dblFutures) *dblOpenQty
               end dblMarketFuturesResult,      
                   
                  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) < 0
                  THEN (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) >= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) <= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) > 0
                  THEN -(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                end dblResultCash1
               ,isnull(dblContractBasis,0)+isnull(dblFutures,0) dblContractPrice 
            FROM (select *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(dblMarketBasis1,0) ELSE 0 END dblMarketBasis,
            case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
            case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
            else isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) end AS dblAdjustedContractPrice,
            dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice  
  FROM
(SELECT           cd.intContractDetailId,
                  'Inventory'+'(P)' as strContractOrInventoryType,
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
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (SELECT avgLot/intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) dblFutures ,
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
            
                  isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId and ysnMTM = 1),0) dblCosts,
                  
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
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,
                  SUM(ri.dblOpenReceive) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty,dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId,null as intltemPrice
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId 
JOIN tblICInventoryReceiptItem ri ON ch.intContractHeaderId = ri.intOrderId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ri.intInventoryReceiptId
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId  
WHERE  strReceiptType ='Purchase Contract' and intSourceType=2 and intContractStatusId<>3 
            AND convert(datetime,convert(varchar, ir.dtmReceiptDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t
)t)t2 WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory(P)' else '' end 

UNION
SELECT *,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash FROM(
SELECT *,
      
            isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
                   CASE WHEN intContractTypeId = 1 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice) < 0
                  THEN (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice)*dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) >= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) - dblAdjustedContractPrice) <= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and (isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)-dblAdjustedContractPrice) > 0
                  THEN -(isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0)- dblAdjustedContractPrice)*dblOpenQty
               end dblResult,
            case WHEN intPricingTypeId = 6  then 0 else 
            CASE WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) < 0
                    THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else -((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) >= 0
                  THEN case when @ysnIncludeBasisDifferentialsInResults = 1 then abs((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) else ((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0)) end *dblOpenQty
                 end end dblResultBasis,
                 
             CASE WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) < 0)
                  THEN (dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 1 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) >= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) <= 0)
                  THEN abs(dblFuturesClosingPrice - dblFutures) *dblOpenQty
                  WHEN intContractTypeId = 2 and (((dblFuturesClosingPrice - dblFutures) *dblOpenQty) > 0)
                  THEN -(dblFuturesClosingPrice - dblFutures) *dblOpenQty
               end dblMarketFuturesResult,      
                 CASE WHEN intPricingTypeId = 6  THEN
               CASE WHEN intContractTypeId = 1 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) < 0
                  THEN ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) >= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) <= 0
                  THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice)) > 0
                  THEN -((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (dblAdjustedContractPrice))*dblOpenQty
               end
               else                
                  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) < 0
                  THEN (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) >= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) <= 0
                  THEN abs(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
                  WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-isnull(dblCash,0))) > 0
                  THEN -(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dblOpenQty
               end  end dblResultCash1
               ,isnull(dblContractBasis,0)+isnull(dblFutures,0) dblContractPrice
FROM (SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(dblMarketBasis1,0) ELSE 0 END dblMarketBasis
,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
            case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
            else isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) end AS dblAdjustedContractPrice,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice  
  from
(SELECT           cd.intContractDetailId,
                  'In-transit' as strContractOrInventoryType,
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
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (SELECT avgLot/intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) dblFutures ,
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
            
                  isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId and ysnMTM = 1),0) dblCosts,
                  
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
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

                  SUM(iv.dblStockQty) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty,dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId
                  ,null as intltemPrice
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end       
JOIN vyuLGInventoryView iv on iv.intContractDetailId=cd.intContractDetailId AND strStatus='In-transit'
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=cd.intOriginId  
WHERE intContractStatusId<>3 AND convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t       
)t)t2

UNION 

SELECT *,null AS dblAdjustedContractPrice,0 AS dblMarketBasisUOM,
            NUll AS dblCashPrice,
            null as dblMarketPrice,
           dblOpenQty * intltemPrice as   dblResult,          
          null as dblResultBasis,              
            null as dblMarketFuturesResult,     
            null as dblResultCash
         ,null as dblContractPrice 
         ,null as dblMarketBasis,null as dblResultCash1, 0 as PriceSourceUOMId
FROM 
(SELECT           null intContractDetailId,
                  'Inventory' as strContractOrInventoryType,
                  '' as strContractSeq,
                  '' as strEntityName,
                  null as intEntityId,
                  '' as strFutMarketName,
                  null as intFutureMarketId,
                  '' as strFutureMonth,
                  null as intFutureMonthId,
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  i.intItemId as intItemId,
                  '' as strOrgin,
                  null as intOriginId,
                  '' as strPosition, 
                  '' AS strPeriod,
                  '' as strPriOrNotPriOrParPriced,
                  null as intPricingTypeId,
                  '' as strPricingType,
                  null dblContractBasis,
                  null dblFutures ,       
                  null dblCash,     
                  null dblCosts,
                  null AS avgLot,
                  null AS intTotLot,
                  null AS dblMarketBasis1 ,
                  null AS dblFuturePrice,
                  null as dblFuturesClosingPrice, 
                  null AS dblFuturePrice1,
                  null as dblFuturesClosingPrice1,                               
                  null as intContractTypeId ,
                  0 as intConcurrencyId ,
                  SUM(isnull(iv.dblRunningQtyBalance,0)) OVER (PARTITION BY iv.intItemId) dblOpenQty,
                  null dblRate,
                  null as intCommodityUnitMeasureId,
                  null as  intQuantityUOMId,
                  null  intPriceUOMId,
                  null intCurrencyId,
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
WHERE i.intCommodityId= case when isnull(@intCommodityId,0)=0 then i.intCommodityId else @intCommodityId end
AND strLocationName= case when isnull(@strLocationName,0)=0 then strLocationName else @strLocationName end
)t WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1    then 'Inventory' else '' end 

) f

IF (@strRateType='Exchange')
BEGIN
SELECT Convert(int,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,
    convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFuturePrice)) as dblFuturePrice,
intContractDetailId,strContractOrInventoryType,
      strContractSeq,strEntityName,intEntityId,strFutMarketName,
      intFutureMarketId,intFutureMonthId,strFutureMonth,
      strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
      convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end)  as dblOpenQty,
      intPricingTypeId,strPricingType, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)) as dblContractBasis,
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)) as dblFutures,    
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCash)) as dblCash, 
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCosts)) as dblCosts,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketBasis)) as dblMarketBasis, 
      convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractPrice)) as dblContractPrice, 
      CONVERT(int,intContractTypeId) as intContractTypeId,
      CONVERT(int,0) as intConcurrencyId,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblAdjustedContractPrice)) as dblAdjustedContractPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCashPrice)) as dblCashPrice, 
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketPrice)) as dblMarketPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResult)) as dblResult ,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultBasis)) as dblResultBasis,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketFuturesResult)) as dblMarketFuturesResult,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultCash)) as dblResultCash
FROM #temp1 ORDER BY intCommodityId
END
ELSE
BEGIN
      select Convert(int,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFuturePrice)) as dblFuturePrice
			,intContractDetailId,strContractOrInventoryType,
            strContractSeq,strEntityName,intEntityId,strFutMarketName,
            intFutureMarketId,intFutureMonthId,strFutureMonth,
            strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end)  as dblOpenQty,
            intPricingTypeId,strPricingType,
            convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis) end 
            end)
            as dblContractBasis,
            --dblMarketBasisUOM,intQuantityUOMId,intPriceUOMId,PriceSourceUOMId,
            convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures) end 
            end)
            as dblFutures,             
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCash)) as dblCash, 
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCosts)) as dblCosts,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketBasis)) as dblMarketBasis, 
            convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice,              
            convert(decimal(24,6),case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractPrice)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractPrice)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractPrice) end 
            end)
            as dblContractPrice,          
            CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblAdjustedContractPrice)) as dblAdjustedContractPrice,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCashPrice)) as dblCashPrice, 
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketPrice)) as dblMarketPrice,
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblResult else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResult) end) as dblResult ,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultBasis)) as dblResultBasis,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketFuturesResult)) as dblMarketFuturesResult,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultCash)) as dblResultCash
      FROM #temp1 
      ORDER BY intCommodityId 
END