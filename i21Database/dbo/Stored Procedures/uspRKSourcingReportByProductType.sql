﻿CREATE PROC [dbo].[uspRKSourcingReportByProductType] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,
       @ysnVendorProducer bit = null,
	   	   @intBookId int = null,
	   @intSubBookId int = null,
	   @intAOPId int = null

AS

SELECT DISTINCT tcd.intContractDetailId,
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					(((SUM(detcd.dblFixationPrice*detcd.dblBalanceNoOfLots) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ tcd.dblNoOfLots)) dblParPricedAvgPrice,
					  dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,det.dblBasis) dblParPricedBasis,
			   dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					((((SUM(detcd.dblFixationPrice*detcd.dblBalanceNoOfLots) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ tcd.dblNoOfLots)
					 +det.dblBasis)
					 * 
					dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cuc.intCommodityUnitMeasureId, @intUnitMeasureId,tcd.dblQuantity)
					) dblParPriced
					INTO #tempPartiallyPriced	
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
			  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE detcd.strStatus in('Partially Priced')

IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN
select CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) as intRowNum,strEntityName strName,strOrigin,strProductType,sum(dblQty) dblQty,sum(dblTotPurchased) dblTotPurchased,0 as intConcurrencyId,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100  as dblCompanySpend,strLocationName

  from(
SELECT strName as strEntityName,		
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 		
       CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						0
				end
          WHEN (isnull(dblFullyPriced,0)) <> 0  then 
				case when isnull(dblRatio,0) <> 0 then
						(((isnull(dblFullyPricedFutures,0)) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblFullyPriced,0)) 
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblParPricedAvgPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblParPriced,0)) 
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblUnPricedSettlementPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblUnPriced,0))
				end
	 end AS dblTotPurchased
	 , strOrigin,strProductType,strLocationName
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,
             dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty  
			 ,cd.dblNoOfLots
			,(SELECT round(dblTotalCost,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6))  dblFullyPriced
			,(SELECT round(dblFutures,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
			,(SELECT round(dblBasis,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 

             ,((SELECT sum(
              dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, det.intUnitMeasureId, ic.intUnitMeasureId,det.dblQuantity)*
                ((det.dblBasis/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end)+
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))/
				case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) )
             FROM tblCTContractDetail det
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId 
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2))) dblUnPriced

			  ,(SELECT sum(det.dblBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
			    FROM tblCTContractDetail det
			    JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			    WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2)) dblUnPricedBasis
				
			,((SELECT sum(               
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,
							MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))
				--/case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) 
             FROM tblCTContractDetail det
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8))) dblUnPricedSettlementPrice

                      ,(SELECT sum(dblParPriced) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPriced,
             (SELECT sum(dblParPricedBasis) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPricedBasis,
			 (SELECT sum(dblParPricedAvgPrice) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPricedAvgPrice,


			(SELECT sum(dblReturnQty) from (
				SELECT  DISTINCT ri.*,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t) 
			  as dblReturn,
			  strOrigin,strProductType,
			   dblRatio,
			  dblBasis,
			  strLocationName
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
JOIN vyuRKSourcingContractDetail sc on sc.intContractDetailId=cd.intContractDetailId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intSubBookId,0) else @intBookId end

--and strName=@strEntityName
)t)t1 group by strEntityName,strOrigin,strProductType,strLocationName

END
ELSE

BEGIN

select CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) as intRowNum,strEntityName strName,strOrigin,strProductType,sum(dblQty) dblQty,sum(dblTotPurchased) dblTotPurchased,0 as intConcurrencyId,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100  as dblCompanySpend,strLocationName

  from(
SELECT strName as strEntityName,		
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 		
       CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						0
				end
          WHEN (isnull(dblFullyPriced,0)) <> 0  then 
				case when isnull(dblRatio,0) <> 0 then
						(((isnull(dblFullyPricedFutures,0)) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblFullyPriced,0)) 
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblParPricedAvgPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblParPriced,0)) 
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblUnPricedSettlementPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) * dblQty
					else
						(isnull(dblUnPriced,0))
				end
	 end AS dblTotPurchased  , strOrigin,strProductType,strLocationName
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,
             dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty  
			 ,cd.dblNoOfLots
			,(SELECT round(dblTotalCost,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6))  dblFullyPriced
			,(SELECT round(dblFutures,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
			,(SELECT round(dblBasis,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 

             ,((SELECT sum(
              dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, det.intUnitMeasureId, ic.intUnitMeasureId,det.dblQuantity)*
                ((det.dblBasis/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end)+
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))/
				case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) )
             FROM tblCTContractDetail det
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId 
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2))) dblUnPriced

			  ,(SELECT sum(det.dblBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
			    FROM tblCTContractDetail det
			    JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			    WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2)) dblUnPricedBasis
				
			,((SELECT sum(               
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,
							MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))
				--/case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) 
             FROM tblCTContractDetail det
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8))) dblUnPricedSettlementPrice

         
                      ,(SELECT sum(dblParPriced) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPriced,
             (SELECT sum(dblParPricedBasis) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPricedBasis,
			 (SELECT sum(dblParPricedAvgPrice) from #tempPartiallyPriced det WHERE det.intContractDetailId=cd.intContractDetailId) as dblParPricedAvgPrice,


			(SELECT sum(dblReturnQty) from (
				SELECT  DISTINCT ri.*,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t) 
			  as dblReturn,
			  strOrigin,strProductType,
			  dblRatio,
			  dblBasis,strLocationName
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
							case when isnull(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId end end
JOIN vyuRKSourcingContractDetail sc on sc.intContractDetailId=cd.intContractDetailId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intSubBookId,0) else @intBookId end
--and strName=@strEntityName
)t)t1 group by strEntityName,strOrigin,strProductType,strLocationName
END