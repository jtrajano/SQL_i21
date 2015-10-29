﻿create PROC uspRKM2MInquiryTransaction  
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
SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId
select @strLocationName=strLocationName from tblSMCompanyLocation where intCompanyLocationId=@intLocationId
SELECT * INTO #temp1 FROM (
SELECT *,isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) AS dblAdjustedContractPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblCashPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	 	 CASE WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) < 0
		      THEN ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) >= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) <= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) > 0
		      THEN -((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		   end dblResult,
		   
		   	  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) < 0
		   	  THEN (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 1 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) >= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) <= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) > 0
		      THEN -(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
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
				AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
				WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
				)t 
			) dblFutures ,
			
			CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
		
			isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId),0) dblCosts,
			
			isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
				WHERE temp.intM2MBasisId=@intM2MBasisId 
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
			),0) AS dblMarketBasis,											
		    dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice,					  
			convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

			(case when ISNULL((SELECT TOP 1 dblNewValue from tblCTSequenceUsageHistory uh 
				WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
				and convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
				ORDER BY dtmTransactionDate desc),0) =0  then cd.dblBalance else 
				(SELECT TOP 1 dblNewValue from tblCTSequenceUsageHistory uh 
				WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
				AND convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) 
				ORDER BY dtmTransactionDate desc) end ) as dblOpenQty,dblRate,
			cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId
			,null as intltemPrice
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
		AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
		AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId 
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
WHERE  intContractStatusId<>3 and convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10))t

UNION 

SELECT *,isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) AS dblAdjustedContractPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblCashPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	 	 	 CASE WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) < 0
		      THEN ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) >= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) <= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) > 0
		      THEN -((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		   end dblResult,
		   
		   	  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) < 0
		   	  THEN (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 1 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) >= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) <= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) > 0
		      THEN -(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
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
			isnull(cd.dblBasis,0) dblContractBasis,
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
			
				CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
		
			isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId),0) dblCosts,
			
			isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
				WHERE temp.intM2MBasisId=@intM2MBasisId 
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
			),0) AS dblMarketBasis,		
															
		    dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice,					  
			convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,
			--ri.dblOpenReceive as dblOpenQty,
			SUM(ri.dblOpenReceive) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty,dblRate,
			cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId
			,null as intltemPrice
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
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId  
WHERE  strReceiptType ='Purchase Contract' and intSourceType=2 and intContractStatusId<>3 
		AND convert(datetime,convert(varchar, ir.dtmReceiptDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t
		
UNION 

SELECT *,isnull(dblCosts,0)+(isnull(dblContractBasis,0) + ISNULL(dblFutures,0)) AS dblAdjustedContractPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblCashPrice,
		 isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	 	 	 CASE WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) < 0
		      THEN ((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 1 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) >= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) <= 0
		      THEN abs((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		      WHEN intContractTypeId = 2 and (((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))) > 0
		      THEN -((isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0))- (isnull(dblCosts,0)+isnull(dblContractBasis,0)+isnull(dblFutures,0)))*dblOpenQty
		   end dblResult,
		   
		   	  CASE WHEN intContractTypeId = 1 and ((isnull(dblMarketBasis,0)-(dblContractBasis+dblCosts))) < 0
		   	  THEN (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 1 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) >= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) <= 0
		      THEN abs(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
		      WHEN intContractTypeId = 2 and (isnull((dblContractBasis+dblCosts)-dblMarketBasis,0)) > 0
		      THEN -(isnull((dblContractBasis+dblCosts)-dblMarketBasis,0))*dblOpenQty
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
			isnull(cd.dblBasis,0) dblContractBasis,
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
				CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,		
			isnull((SELECT SUM(dblRate) FROM tblCTContractCost ct WHERE cd.intContractDetailId=ct.intContractDetailId),0) dblCosts,			
			isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
				WHERE temp.intM2MBasisId=@intM2MBasisId 
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
			),0) AS dblMarketBasis,		
															
		    dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice,					  
			convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,
			SUM(iv.dblStockQty) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty,dblRate,
			cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId
			,null as intltemPrice
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
		AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
		AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end		
JOIN vyuLGInventoryView iv on iv.intContractDetailId=cd.intContractDetailId AND strStatus='In-transit'
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=cd.intOriginId  
WHERE intContractStatusId<>3 AND convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t		

UNION 

SELECT *,null AS dblAdjustedContractPrice,
		 NUll AS dblCashPrice,
		null as dblMarketPrice,
	 	 	dblOpenQty * intltemPrice as   dblResult,		   
		    null as dblResultBasis,		     
			null as dblMarketFuturesResult,	
			null as dblResultCash
		   ,null as dblContractPrice 
FROM 
(SELECT		null intContractDetailId,
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
			0 intOriginId,
			'' as strPosition, 
			'' AS strPeriod,
			'' as strPriOrNotPriOrParPriced,
			null as intPricingTypeId,
			'' as strPricingType,
			null dblContractBasis,
			null dblFutures ,		
			null dblCash,	
			null dblCosts,
			null AS dblMarketBasis,		
			null as dblFuturesClosingPrice,					  
			null as intContractTypeId ,
			0 as intConcurrencyId ,
			SUM(isnull(iv.dblRunningQtyBalance,0)) OVER (PARTITION BY iv.intItemId) dblOpenQty,
			null dblRate,
			0 as intCommodityUnitMeasureId,
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
)t		
) f

IF (@strRateType='Exchange')
BEGIN
SELECT Convert(int,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,intContractDetailId,strContractOrInventoryType,
	strContractSeq,strEntityName,intEntityId,strFutMarketName,
	intFutureMarketId,intFutureMonthId,strFutureMonth,
	strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
	case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end  as dblOpenQty,
	intPricingTypeId,strPricingType, 
	dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractBasis) as dblContractBasis,
	dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblFutures) as dblFutures,	 
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCash) as dblCash, 
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCosts) as dblCosts,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketBasis) as dblMarketBasis, 
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblFuturesClosingPrice) as dblFuturesClosingPrice, 
    dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice) as dblContractPrice, 
	intContractTypeId,intConcurrencyId,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblAdjustedContractPrice) as dblAdjustedContractPrice,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCashPrice) as dblCashPrice, 
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketPrice) as dblMarketPrice,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResult) as dblResult ,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResultBasis) as dblResultBasis,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketFuturesResult) as dblMarketFuturesResult,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResultCash) as dblResultCash
FROM #temp1 ORDER BY intCommodityId
END
ELSE
BEGIN
	select Convert(int,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,intContractDetailId,strContractOrInventoryType,
		strContractSeq,strEntityName,intEntityId,strFutMarketName,
		intFutureMarketId,intFutureMonthId,strFutureMonth,
		strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
		case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end  as dblOpenQty,
		intPricingTypeId,strPricingType,
		case when isnull(dblRate,0)=0 then 
		dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractBasis)
		else
		case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractBasis)*dblRate 
		else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice) end 
		end
		as dblContractBasis, 
		case when isnull(dblRate,0)=0 then 
		dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblFutures)
		else
		case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblFutures)*dblRate 
		else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice) end 
		end
		as dblFutures, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCash) as dblCash, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCosts) as dblCosts,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketBasis) as dblMarketBasis, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblFuturesClosingPrice) as dblFuturesClosingPrice, 
		case when isnull(dblRate,0)=0 then 
		dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice)
		else
		case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice)*dblRate 
		else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblContractPrice) end 
		end
		as dblContractPrice, 		
		intContractTypeId,intConcurrencyId,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblAdjustedContractPrice) as dblAdjustedContractPrice,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblCashPrice) as dblCashPrice, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketPrice) as dblMarketPrice,
		case when isnull(intCommodityUnitMeasureId,0) = 0 then dblResult else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResult) end as dblResult ,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResultBasis) as dblResultBasis,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblMarketFuturesResult) as dblMarketFuturesResult,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblResultCash) as dblResultCash
	FROM #temp1 order by intCommodityId
END
