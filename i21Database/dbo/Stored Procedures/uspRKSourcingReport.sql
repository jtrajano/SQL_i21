CREATE PROC [dbo].[uspRKSourcingReport] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL

AS


SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,convert(numeric(24,6),dblQty) as dblQty,
convert(numeric(24,6),dblTotPurchased) dblTotPurchased, 
               (dblTotPurchased/SUM(CASE WHEN isnull(dblTotPurchased,0)=0 then 1 else dblTotPurchased end) OVER ())*100  as dblCompanySpend ,0 as intConcurrencyId
       FROM(
SELECT strName, isnull(sum(dblQty),0) as dblQty,isnull(sum(dblTotPurchased),0) as dblTotPurchased from(
SELECT strName, (isnull(dblQty,0)- isnull(dblReturn,0)) as dblQty , 
         CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 0
              WHEN (isnull(dblFullyPriced,0)) <> 0 then (isnull(dblFullyPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then (isnull(dblParPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then (isnull(dblUnPriced,0)) end  as dblTotPurchased 
FROM(
SELECT e.strName,strContractNumber,
          dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty 

  ,(SELECT round(dblTotalCost,2) -isnull((SELECT dblLineTotal 
                                         FROM tblICInventoryReturned r
                                                JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                                                JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                                                JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
                                                WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=det.intContractDetailId ),0)
            FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) as dblFullyPriced

 ,((SELECT dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity)*
                dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, @intUnitMeasureId,ic.intUnitMeasureId,det.dblBasis+
                ISNULL(dbo.fnRKGetLatestClosingPrice(intFutureMarketId,intFutureMonthId,getdate()),0)) /
                case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
           FROM tblCTContractDetail det
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(2))-
              -isnull((SELECT dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) 
                                FROM tblICInventoryReturned r
                                        JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                                        JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                                        JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
                                WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId ),0))
              as dblUnPriced

 ,(SELECT 
               dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, @intUnitMeasureId,ic.intUnitMeasureId,
              (((SUM(dblFixationPrice) OVER (PARTITION BY det.intContractDetailId )  * SUM(dblFixationPrice) OVER (PARTITION BY det.intContractDetailId )  +
                     (isnull(dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))
                     /cd.dblNoOfLots)+det.dblBasis)*
                     dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) 
					 - isnull((SELECT dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) 
                                        FROM tblICInventoryReturned r
                                                JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                                                JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                                                JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
                                        WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId ),0))/
                     case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
              JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId) as dblParPriced,

(SELECT dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId ) dblReturn
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate 
)t)t1 group by t1.strName
)t2