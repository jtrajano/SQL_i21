﻿CREATE PROC [dbo].[uspRKSourcingReportDetail] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,
	   @strEntityName nvarchar(100) = null,
       @ysnVendorProducer bit = null,
	   @intBookId int = null,
	   @intSubBookId int = null,
	   @strYear nvarchar(10) = null,
	   @dtmAOPFromDate datetime = null,
	   @dtmAOPToDate datetime = null,	
	   @strLocationName nvarchar(250)= null,
	   @intCurrencyId int = null

AS

IF @strEntityName = '-1'
SET @strEntityName = NULL
IF @strLocationName = '-1'
SET @strLocationName = NULL


DECLARE @strCurrency nvarchar(100)
DECLARE @strUnitMeasure nvarchar(100)
SELECT @strCurrency=strCurrency from tblSMCurrency where intCurrencyID=@intCurrencyId

SELECT @strUnitMeasure=strUnitMeasure,@intUnitMeasureId=c.intUnitMeasureId from tblICCommodityUnitMeasure c
JOIN tblICUnitMeasure u on u.intUnitMeasureId=c.intUnitMeasureId where c.intCommodityUnitMeasureId=@intUnitMeasureId

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
		intCompanyLocationId int
		,dblFullyPriced  numeric(24,10)
		,dblUnPriced  numeric(24,10)
		,dblParPriced  numeric(24,10)
		,dblFullyPricedFutures numeric(24,10),dblParPricedBasis numeric(24,10),dblUnPricedBasis numeric(24,10)
		,dblParPricedAvgPrice numeric(24,10),dblFullyPricedBasis numeric(24,10)
		) 

BEGIN

insert into @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,intCompanyLocationId,dblFullyPriced,dblUnPriced,
							dblParPriced,dblFullyPricedFutures,dblParPricedBasis,dblUnPricedBasis,dblParPricedAvgPrice,dblFullyPricedBasis)
select CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) as intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,
							0.0 dblPrice, intCompanyLocationId,dblFullyPriced,dblUnPriced,dblParPriced
							,dblFullyPricedFutures,dblParPricedBasis,dblUnPricedBasis,dblParPricedAvgPrice,dblFullyPricedBasis
from(
SELECT intContractDetailId,
		strName as strEntityName,
		intContractHeaderId,
		strContractNumber as strContractSeq, 
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 
		CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty,
		CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty,
		CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots, 
		CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice,
		CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice,
		isnull(dblUnPricedBasis,dblBasis) AS dblBasis,
		dblRatio,         
	 intCompanyLocationId,dblFullyPriced,dblUnPriced,dblParPriced,dblFullyPricedFutures,dblParPricedBasis,dblUnPricedBasis,dblParPricedAvgPrice,dblFullyPricedBasis
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,intContractDetailId,
			 cd.dblQuantity  dblQty,
			 cd.dblQuantity dblOriginalQty			 
			 ,cd.dblNoOfLots
			,(SELECT dblCashPrice FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId AND intPricingTypeId in(1,6))  dblFullyPriced
			,(SELECT dblFutures FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
			,(SELECT dblConvertedBasis FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 

             ,((SELECT sum(
             det.dblQuantity*
                (det.dblConvertedBasis+
                (ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)))/
				case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end
				) 
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

			  ,(SELECT sum(det.dblBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
			    FROM tblCTContractDetail det
				join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
			    JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			    WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2)) dblUnPricedBasis
				
			,((SELECT 	
							ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0)
				/case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end					
             FROM tblCTContractDetail det
              join tblICItemUOM ic on det.intBasisUOMId=ic.intItemUOMId               
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8) 
			  )) dblUnPricedSettlementPrice

            ,(SELECT DISTINCT
               
					((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)
					 )/ cd.dblNoOfLots)
					 +tcd.dblConvertedBasis)
					 * 
					cd.dblQuantity
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


			  (SELECT DISTINCT tcd.dblConvertedBasis
              FROM vyuCTSearchPriceContract det
			  JOIN tblCTContractDetail tcd on det.intContractDetailId = tcd.intContractDetailId
			  JOIN tblCTContractHeader ch on det.intContractHeaderId= ch.intContractHeaderId
			  JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=ch.intCommodityUOMId               
              JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
              WHERE strStatus in('Partially Priced')
              AND det.intContractDetailId=cd.intContractDetailId
              ) as dblParPricedBasis,

			  (SELECT DISTINCT
               
					(((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,getdate()),0)))
					 )/ cd.dblNoOfLots)
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
				SELECT  DISTINCT ri.*,
				--dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, @intUnitMeasureId,ri.dblOpenReceive)
				ri.dblOpenReceive dblReturnQty			 
              from tblICInventoryReturned r
                     JOIN tblICInventoryReceipt ir on r.intTransactionId=ir.intInventoryReceiptId
                     JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId 
                     JOIN tblCTContractDetail cd1 on cd1.intContractDetailId=ri.intLineNo 
					 JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd1.intUnitMeasureId 
              WHERE strReceiptType='Inventory Return' and cd1.intContractDetailId=cd.intContractDetailId )t) 
			  as dblReturn,			
			  dblRatio
			 -- ,(SELECT sum(det.dblBasis)--/case when isnull(c.ysnSubCurrency,0) = 1 then 100 else 1 end				
			 --   FROM tblCTContractDetail det
				--join tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId 
			 --   JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
			 --   WHERE det.intContractDetailId=cd.intContractDetailId ) 
				,dblBasis,
			  cd.intCompanyLocationId
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=cd.intCompanyLocationId
JOIN tblEMEntity e on e.intEntityId=
						CASE WHEN ISNULL(@ysnVendorProducer,0)=0 then ch.intEntityId 
						ELSE
						CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
						CASE WHEN ISNULL(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId END END END
WHERE isnull(cd.dtmM2MDate,getdate()) BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
and strName=case when isnull(@strEntityName,'') = '' then strName else @strEntityName end
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(cd.intSubBookId,0) else @intSubBookId end
and isnull(cl.strLocationName,'')= case when isnull(@strLocationName,'')='' then isnull(cl.strLocationName,'') else @strLocationName end
--and strContractNumber='9'
)t
)t1 
END

declare @ysnSubCurrency int
select @ysnSubCurrency=ysnSubCurrency from tblSMCurrency where intCurrencyID=@intCurrencyId

select intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblBalanceQty*dblPrice dblTotPurchased, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,dblStandardValue,(dblStandardPrice-dblPrice)*dblBalanceQty dblPPV,
							(dblStandardPrice-dblNewPPVPrice)*dblBalanceQty dblPPVNew,strPricingType,strItemNo,strProductType
							,@strCurrency strCurrency ,@strUnitMeasure strUnitMeasure
FROM(
SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots, dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,	 							
									CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 
							case when isnull(dblRatio,0) <> 0 then
									((CONVERT(NUMERIC(16,6),dblSettlementPrice) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
								else
									dblSettlementPrice+dblBasis
							end
							WHEN (isnull(dblFullyPriced,0)) <> 0  then 
							case when isnull(dblRatio,0) <> 0 then
									(((isnull(dblFullyPricedFutures,0)) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
								else
									(isnull(dblFullyPriced,0)) 
							end
							WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then 
							case when isnull(dblRatio,0) <> 0 then
									((ISNULL(dblParPricedAvgPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))))
								else
									(isnull(dblParPriced,0)) / dblQty
							end
							WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then 
							case when isnull(dblRatio,0) <> 0 then
									((ISNULL(dblSettlementPrice,0) * dblRatio) + CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis))))) 
								else
									(isnull(dblUnPriced,0)) / dblQty
							end
							end AS dblPrice,
							 dblStandardRatio,dblBalanceQty*isnull(dblStandardRatio,1) dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,
							
							(isnull(dblFuturesPrice,dblSettlementPrice)*isnull(dblRatio,1))+isnull(dblRate,0) dblNewPPVPrice
							
							,strLocationName,(dblBalanceQty*isnull(dblStandardRatio,1))*isnull(dblStandardPrice,0) dblStandardValue,
							
							strPricingType,strItemNo,strProductType
FROM(
select intRowNum,
t.intContractDetailId,strEntityName,t.intContractHeaderId,strContractSeq,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblQty) dblQty,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblReturnQty) dblReturnQty,
						dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblBalanceQty) dblBalanceQty,
							t.dblNoOfLots,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,cd.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(dblFuturesPrice,0),null))	dblFuturesPrice,							
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(dblSettlementPrice,0),null))	dblSettlementPrice,

							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(t.dblBasis,0),null))	dblBasis,
							
							t.dblRatio,	cost.dblRate,
							
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,						
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(dblPrice,0),null))	dblPrice,
							t.intCompanyLocationId, ca.dblRatio dblStandardRatio, 
							ic.intItemId,
							
							
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,
							isnull((
							SELECT sum(dbo.[fnCTConvertQuantityToTargetItemUOM](b.intItemId,@intUnitMeasureId,ic1.intUnitMeasureId,dblCost)) from tblCTAOP a
							 join tblCTAOPDetail b on a.intAOPId=b.intAOPId 
							 JOIN tblICItemUOM ic1 on b.intPriceUOMId=ic1.intItemUOMId 
							 where a.dtmFromDate=@dtmAOPFromDate and dtmToDate=@dtmAOPToDate and strYear=@strYear
							and b.intItemId=cd.intItemId
							and a.intCommodityId=ic.intCommodityId
							and a.intCompanyLocationId=cd.intCompanyLocationId
							and isnull(a.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(a.intBookId,0) else @intBookId end
							and isnull(a.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(a.intSubBookId,0) else @intSubBookId end
							),0),null)  dblStandardPrice,

							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(cost.dblRate,t.dblBasis),null))	dblPPVBasis,
							strLocationName	,strPricingType,strItemNo,ca.strDescription strProductType,cd.intCurrencyId,ysnSubCurrency,cd.intUnitMeasureId,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,dblFullyPriced)		dblFullyPriced,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,dblUnPriced)		dblUnPriced,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,dblParPriced)		dblParPriced,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,dblFullyPricedFutures)		dblFullyPricedFutures,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,dblParPricedBasis) dblParPricedBasis,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,dblUnPricedBasis) dblUnPricedBasis,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,dblParPricedAvgPrice)	dblParPricedAvgPrice,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,dblFullyPricedBasis) dblFullyPricedBasis
 FROM @GetStandardQty t
JOIN tblCTContractDetail cd on t.intContractDetailId=cd.intContractDetailId
JOIN tblRKFutureMarket m on cd.intFutureMarketId=m.intFutureMarketId
join tblICItemUOM i on cd.intPriceItemUOMId=i.intItemUOMId
join tblICItemUOM j on cd.intBasisUOMId=j.intItemUOMId
--JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
join tblCTPricingType pt on cd.intPricingTypeId=pt.intPricingTypeId
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICItem ic ON ic.intItemId = cd.intItemId
join tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
LEFT JOIN(select intContractDetailId,SUM(dblRate) dblRate FROM tblCTContractCost where ysnBasis=1 and intItemId not in(
		 SELECT isnull(intItemId,0) from tblCTComponentMap where ysnExcludeFromPPV=1) Group by intContractDetailId) cost on cost.intContractDetailId=cd.intContractDetailId													
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId

)t)t1 