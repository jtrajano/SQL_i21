CREATE  PROC [dbo].[uspRKSourcingReportDetail] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,
	   @strEntityName nvarchar(100) = null,
       @ysnVendorProducer bit = null

AS

IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN
SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,intContractDetailId,
		strName as strEntityName,
		intContractHeaderId,
		strContractNumber as strContractSeq, 
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 
		CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty,
		CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty,
		CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots, 
		CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice,
		CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice,
		CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))) AS dblBasis,
		dblRatio,
      CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
					else
						0
				end
          WHEN (isnull(dblFullyPriced,0)) <> 0  then 
				case when isnull(dblRatio,0) <> 0 then
						(((isnull(dblFullyPricedFutures,0)) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
					else
						(isnull(dblFullyPriced,0)) / dblQty
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblParPricedAvgPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
					else
						(isnull(dblParPriced,0)) / dblQty
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblUnPricedSettlementPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
					else
						(isnull(dblUnPriced,0)) / dblQty
				end
	 end AS dblPrice, 
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
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,intContractDetailId,
             dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty  
			 ,cd.dblNoOfLots
			,(SELECT round(dblTotalCost,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6))  dblFullyPriced
			,(SELECT round(dblFutures,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
			,(SELECT round(dblConvertedBasis,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 

             ,((SELECT sum(
              dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, det.intUnitMeasureId, ic.intUnitMeasureId,det.dblQuantity)*
                (det.dblConvertedBasis+
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
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2)
			  and intContractDetailId NOT IN(SELECT intContractDetailId FROM vyuCTSearchPriceContract)
			  )) dblUnPriced

			  ,(SELECT sum(det.dblConvertedBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
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
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8) 
			  )) dblUnPricedSettlementPrice

            ,(SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					((((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots)
					 +tcd.dblConvertedBasis)
					 * 
					dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,tcd.intUnitMeasureId,cuc.intUnitMeasureId,cd.dblQuantity)
					)
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
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


			  (SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,tcd.dblConvertedBasis)
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
              ) as dblParPricedBasis,

			  (SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					(((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots))
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
			  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE detcd.strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
              ) as dblParPricedAvgPrice,


			(SELECT sum(dblReturnQty) from (
				SELECT  DISTINCT ri.*,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t) 
			  as dblReturn,
			  dblRatio,
			  dblBasis

FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
and strName=@strEntityName
)t
END
ELSE
BEGIN
SELECT 
	CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum
	,intContractDetailId
	,strName as strEntityName
	,intContractHeaderId
	,strContractNumber as strContractSeq
	,CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty
	,CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty
	,CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty
	,CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots
	,CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice
	,CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice
	,CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))) AS dblBasis
	,dblRatio
	,CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
					else
						0
				end
          WHEN (isnull(dblFullyPriced,0)) <> 0  then 
				case when isnull(dblRatio,0) <> 0 then
						(((isnull(dblFullyPricedFutures,0)) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
					else
						(isnull(dblFullyPriced,0)) / dblQty
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblParPricedAvgPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
					else
						(isnull(dblParPriced,0)) / dblQty
				end
          WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then 
				case when isnull(dblRatio,0) <> 0 then
						((ISNULL(dblUnPricedSettlementPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
					else
						(isnull(dblUnPriced,0)) / dblQty
				end
	 end AS dblPrice 
	 ,CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
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
FROM(
	SELECT 
		e.strName
		,ch.intContractHeaderId
		,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber
		,intContractDetailId
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty  
		,cd.dblNoOfLots
		,(SELECT round(dblTotalCost,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6))  dblFullyPriced
		,(SELECT round(dblFutures,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
		,(SELECT round(dblConvertedBasis,2) FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 
		,((SELECT 
			sum(
              dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, det.intUnitMeasureId, ic.intUnitMeasureId,det.dblQuantity)
			  *
              ((det.dblConvertedBasis)+(dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))
			   /
			   case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
			  )
			)
            FROM tblCTContractDetail det
				JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
				JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId 
				join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
				join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
				JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
				join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
			WHERE det.intContractDetailId=cd.intContractDetailId 
				and det.intPricingTypeId in(2,8)
				AND intContractDetailId NOT IN(SELECT intContractDetailId FROM vyuCTSearchPriceContract)
		 )) dblUnPriced
		,(SELECT 
			sum(det.dblConvertedBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
			FROM tblCTContractDetail det
				JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2)
		 ) dblUnPricedBasis
		,((SELECT 
			sum(               
                (dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,ic.intUnitMeasureId,MA.intUnitMeasureId, ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))
				--/case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
			) 
			FROM tblCTContractDetail det
				join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
				join tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
				JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
				join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
			WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8)
		 )) dblUnPricedSettlementPrice
		,(SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					((((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots)
					 +tcd.dblConvertedBasis)
					 * 
					dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,tcd.intUnitMeasureId,cuc.intUnitMeasureId,cd.dblQuantity)
					)
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
			  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE detcd.strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
		 ) as dblParPriced
		 ,(SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,tcd.dblConvertedBasis)
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
		 ) as dblParPricedBasis
		,(SELECT DISTINCT
               dbo.fnCTConvertQtyToTargetCommodityUOM
			   (@intCommodityId,tcd.intUnitMeasureId, cuc.intUnitMeasureId,
					(((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots))
				--/ case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end
              FROM vyuCTSearchPriceContract det
              JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId 
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
			  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE detcd.strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
         ) as dblParPricedAvgPrice
		,(SELECT sum(dblReturnQty) from (
				SELECT  DISTINCT ri.*,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive) dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )
		 t) as dblReturn
		 ,dblRatio
		 ,dblBasis
FROM tblCTContractHeader ch
	JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
	JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
	JOIN tblEMEntity e on e.intEntityId=CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
							case when isnull(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId end end
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
and strName=@strEntityName
)t
END