CREATE PROC [dbo].[uspRKSourcingReport] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL

AS

SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,convert(numeric(24,2),dblQty) as dblQty,
convert(numeric(24,2),dblTotPurchased) dblTotPurchased, 
               (dblTotPurchased/SUM(CASE WHEN isnull(dblTotPurchased,0)=0 then 1 else dblTotPurchased end) OVER ())*100  as dblCompanySpend ,0 as intConcurrencyId
       FROM(
SELECT strName, isnull(sum(dblQty),0) as dblQty,isnull(sum(dblTotPurchased),0) as dblTotPurchased from(
SELECT strName, (isnull(dblQty,0)- isnull(dblReturn,0)) as dblQty , 
       CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 0
              WHEN (isnull(dblFullyPriced,0)) <> 0  then (isnull(dblFullyPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then (isnull(dblParPriced,0))
              WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then (isnull(dblUnPriced,0)) end  as dblTotPurchased 
FROM(
SELECT e.strName,strContractNumber,
             dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty  

  ,(SELECT round(dblTotalCost,2) - isnull((select sum(dblLineTotal) from (
									SELECT distinct ri.* 
                                         FROM tblICInventoryReturned r
                                                JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                                                JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                                                JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
                                                WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=det.intContractDetailId)t ),0)
            FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6))  dblFullyPriced

             ,((SELECT sum(
              dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, det.intUnitMeasureId, ic.intUnitMeasureId,det.dblQuantity)*
                ((det.dblBasis/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end)+
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,MA.intUnitMeasureId, 
							ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))/
				case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) )
           FROM tblCTContractDetail det
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId 
              join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2))-
              isnull((
						select sum(dblLineTotal) from (
						SELECT distinct  ri.*
                            FROM tblICInventoryReturned r
                                    JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                                    JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
                                    JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo
                            WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t
							
							),0)) dblUnPriced

		  ,(SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					((((SUM(detcd.dblFixationPrice*detcd.dblBalanceNoOfLots) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots)
					 +det.dblBasis)
					 * 
					dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity)
					)
				/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
			  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE detcd.strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
              ) as dblParPriced,

			(select sum(dblReturnQty) from (
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
)t)t1 group by t1.strName
)t2