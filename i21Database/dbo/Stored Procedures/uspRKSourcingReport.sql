﻿CREATE PROC [dbo].[uspRKSourcingReport] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,           
       @ysnVendorProducer bit = null

AS 

SELECT DISTINCT tcd.intContractDetailId,
               dbo.fnCTConvertQtyToTargetCommodityUOM
                        (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
                                  (((SUM(detcd.dblFixationPrice*detcd.dblBalanceNoOfLots) OVER (PARTITION BY det.intContractDetailId )  
                                   + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
                                  ))) dblParPricedAvgPrice,
					dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,det.dblBasis) dblParPricedBasis,
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
SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,sum(dblQty) dblQty,sum(dblTotPurchased) dblTotPurchased, 0 as intConcurrencyId,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100  dblCompanySpend
from (
SELECT 
              strName as strName,        
              CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty,            
        CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 0
              WHEN (isnull(dblFullyPriced,0)) <> 0  then (isnull(dblFullyPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then (isnull(dblParPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then (isnull(dblUnPriced,0)) end AS dblTotPurchased                   
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) COLLATE Latin1_General_CI_AS strContractNumber,intContractDetailId,
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
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2))) dblUnPricedSettlementPrice
			  
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
                       as dblReturn

FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId

)t )t1 group by strName
END
ELSE
BEGIN

select CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,sum(dblQty) dblQty,sum(dblTotPurchased) dblTotPurchased, 0 as intConcurrencyId,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100  dblCompanySpend
from (
SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName as strName,       
              CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty,            
        CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 0
              WHEN (isnull(dblFullyPriced,0)) <> 0  then (isnull(dblFullyPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then (isnull(dblParPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then (isnull(dblUnPriced,0)) end AS dblTotPurchased, 0 as intCuncorrencyId
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) COLLATE Latin1_General_CI_AS strContractNumber,intContractDetailId,
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
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2))) dblUnPricedSettlementPrice

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
                       as dblReturn

FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
                                                case when isnull(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId end end
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId

)t )t1 group by strName
END