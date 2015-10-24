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
SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId

--IF @ysnIncludeBasisDifferentialsInResults =1
--BEGIN
SELECT * into #temp FROM tblRKM2MBasisDetail WHERE intM2MBasisId=@intM2MBasisId
--END

SELECT *,isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) AS dblAdjustedContractPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblCashPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	 	 CASE WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))) < 0
		      THEN ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))) >= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))) <= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))) > 0
		      THEN -((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		   end dblResult,
		   
		   	   	 CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) < 0
		      THEN (isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))*dblOpenQty
		      WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) >= 0
		      THEN abs(isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))*dblOpenQty
		      WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) <= 0
		      THEN abs(isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))*dblOpenQty
		      WHEN intContractTypeId = 2 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) > 0
		      THEN -(isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))*dblOpenQty
		     end dblResultBasis,
		     
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
		   end dblResultCash
		   ,isnull(dblContractBasis,0)+isnull(dblFutures,0) dblContractPrice
FROM 
(SELECT		cd.intContractDetailId,
			'Contract'+'('+LEFT(ch.strContractType,1)+')' as strContractOrInventoryType,
			cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
			cd.strEntityName strEntityName,
			cd.intEntityId,
			cd.strFutMarketName,
			cd.intFutureMarketId,
			cd.strFutureMonth,
			cd.intFutureMonthId,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,@intQuantityUOMId,cd.dblBalance) as dblOpenQty,
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
			isnull(cd.dblBasis,0) dblContractBasis,
			(SELECT avgLot/intTotLot FROM(
				SELECT
					sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
				FROM tblCTContractDetail  cdv
				LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
				LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
				and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
				AND dtmFixationDate<=@dtmTransactionDateUpTo 
				WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
				)t 
			) dblFutures ,
			
				CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
		
			isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId),0) dblCosts,
			
			isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM #temp temp 
						WHERE temp.intM2MBasisId=@intM2MBasisId and
						isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId  END
						AND RIGHT(CONVERT(VARCHAR(11),temp.strPeriodTo,106),8) = CASE WHEN isnull(temp.strPeriodTo,'')= '' THEN '' ELSE RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8)  END
						AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
						AND temp.intContractTypeId =ch.intContractTypeId),0) AS dblMarketBasis,											
		    dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice,					  
			convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId 
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
		AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
		AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId 
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
WHERE  intContractStatusId<>3 and ch.dtmContractDate <=@dtmTransactionDateUpTo)t