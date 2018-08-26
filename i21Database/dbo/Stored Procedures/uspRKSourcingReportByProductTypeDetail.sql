CREATE PROC [dbo].[uspRKSourcingReportByProductTypeDetail] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,  
	   @strEntityName nvarchar(100) = null,
	   @ysnVendorProducer bit = null,
	   @strProductType nvarchar(100) = null,
	   @strOrigin nvarchar(100) = null,
	   @intBookId int = null,
	   @intSubBookId int = null,
	   @intAOPId nvarchar(100)= null,
	   @strLocationName nvarchar(250)= null

AS

if @strOrigin = '-1'
set @strOrigin = null
 if @strProductType = '-1'
set @strProductType = null

DECLARE @GetStandardQty AS TABLE(
		intRowNum int,
		intContractDetailId int,
		strEntityName nvarchar(max),
		intContractHeaderId int,
		strContractSeq nvarchar(100),
		dblQty numeric(24,10),
		dblReturnQty numeric(24,10),
		dblBalanceQty numeric(24,10),
		dblNoOfLots numeric(24,10),
		dblFuturesPrice numeric(24,10),
		dblSettlementPrice numeric(24,10),
		dblBasis numeric(24,10),
		dblRatio numeric(24,10),
		dblPrice numeric(24,10),
		dblTotPurchased numeric(24,10),
	    strOrigin nvarchar(100),
		strProductType nvarchar(100),
		intCompanyLocationId int
		,dblOriginalBalanceQty  numeric(24,10)
		)
		
BEGIN

INSERT INTO @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType,cd.intCompanyLocationId,dblOriginalBalanceQty)
select CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) as intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblOriginalBalanceQty*dblPrice dblTotPurchased, strOrigin,strProductType,intCompanyLocationId,dblOriginalBalanceQty
from(
SELECT intContractDetailId,
		strName as strEntityName,
		intContractHeaderId,
		strContractNumber as strContractSeq, 
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 
		CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty,
		CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty,
		CONVERT(NUMERIC(16,6),(isnull(dblOriginalQty,0) - isnull(dblOriginalReturn,0))) as dblOriginalBalanceQty,
		CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots, 
		CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice,
		CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice,
		CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))) AS dblBasis,
		dblRatio,
        CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
				case when isnull(dblRatio,0) <> 0 then
						((CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
					else
						dblUnPricedSettlementPrice+dblBasis
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
	 end AS dblPrice, strOrigin,strProductType, intCompanyLocationId
	 
	  
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,cd.intContractDetailId,
             dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty,
			 cd.dblQuantity dblOriginalQty			 
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
			  			(SELECT sum(dblReturnQty) from (
				SELECT  DISTINCT ri.*,ri.dblOpenReceive dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t) 
			  as dblOriginalReturn,strOrigin,strProductType,
			  dblRatio,
			  dblBasis,
			  cd.intCompanyLocationId
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=CASE WHEN ISNULL(@ysnVendorProducer,0)=0 then ch.intEntityId 
						ELSE
						CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
						CASE WHEN ISNULL(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId END END END
JOIN vyuRKSourcingContractDetail sc on sc.intContractDetailId=cd.intContractDetailId
WHERE isnull(cd.dtmM2MDate,getdate()) BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
AND isnull(strName,'') = case when isnull(@strEntityName ,'')= '' then isnull(strName,'') else @strEntityName  end
AND isnull(strOrigin,'')= case when isnull(@strOrigin,'')= '' then isnull(strOrigin,'') else @strOrigin end
AND isnull(strProductType,'')=case when isnull(@strProductType,'')='' then isnull(strProductType,'') else @strProductType end
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(cd.intSubBookId,0) else @intSubBookId end
and isnull(l.strLocationName,'')= case when isnull(@strLocationName,'')='' then isnull(l.strLocationName,'') else @strLocationName end
)t)t1
END

SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,dblStandardValue,dblPPV,dblPPVNew,strPricingType,strItemNo from(
SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,dblNewPPVPrice,strLocationName,(dblBalanceQty*isnull(t.dblRatio,1))*isnull(dblStandardPrice,0) dblStandardValue,
							(dblStandardPrice-dblPrice)*dblOriginalBalanceQty dblPPV,
(dblStandardPrice-dblNewPPVPrice)*dblOriginalBalanceQty dblPPVNew,strOrigin,strProductType,strPricingType,strItemNo
FROM(
SELECT t.*, ca.dblRatio dblStandardRatio, dblBalanceQty*isnull(ca.dblRatio,1) dblStandardQty,ic.intItemId,
 (SELECT sum(dblCost) from tblCTAOP a
 join tblCTAOPDetail b on a.intAOPId=b.intAOPId and a.intAOPId=@intAOPId
							and b.intItemId=cd.intItemId
							and b.intCommodityId=ic.intCommodityId
							and isnull(a.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(a.intBookId,0) else @intBookId end
							and isnull(a.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(a.intSubBookId,0) else @intSubBookId end
							) dblStandardPrice
							,isnull(cost.dblRate,t.dblBasis) dblPPVBasis, (isnull(dblFuturesPrice,dblSettlementPrice)* isnull(t.dblRatio,1))+isnull(cost.dblRate,0) as  dblNewPPVPrice,strLocationName
						,strPricingType,strItemNo
 from @GetStandardQty t
JOIN tblCTContractDetail cd on t.intContractDetailId=cd.intContractDetailId
join tblCTPricingType pt on cd.intPricingTypeId=pt.intPricingTypeId
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICItem ic ON ic.intItemId = cd.intItemId
LEFT JOIN(select intContractDetailId,SUM(dblRate) dblRate FROM tblCTContractCost where ysnBasis=1 and intItemId not in(
		 SELECT isnull(intItemId,0) from tblCTComponentMap where ysnExcludeFromPPV=1) Group by intContractDetailId) cost on cost.intContractDetailId=cd.intContractDetailId													
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId)t)t1