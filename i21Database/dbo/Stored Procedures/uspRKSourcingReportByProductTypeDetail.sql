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
	   @strYear nvarchar(10) = null,
	   @dtmAOPFromDate datetime = null,
	   @dtmAOPToDate datetime = null,	
	   @strLocationName nvarchar(250)= null,
	   @intCurrencyId int = null

AS
if @dtmAOPToDate='1900-01-01'
set  @dtmAOPToDate= getdate()
if @strOrigin = '-1'
set @strOrigin = null
if @strProductType = '-1'
set @strProductType = null


declare @strCurrency nvarchar(100)
declare @strUnitMeasure nvarchar(100)
select @strCurrency=strCurrency from tblSMCurrency where intCurrencyID=@intCurrencyId

select @strUnitMeasure=strUnitMeasure,@intUnitMeasureId=c.intUnitMeasureId from tblICCommodityUnitMeasure c
join tblICUnitMeasure u on u.intUnitMeasureId=c.intUnitMeasureId where c.intCommodityUnitMeasureId=@intUnitMeasureId


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
		)
		
BEGIN

INSERT INTO @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,strOrigin,strProductType,cd.intCompanyLocationId)
select CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT) as intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,0.0 dblPrice, strOrigin,strProductType,intCompanyLocationId
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
		CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,isnull(dblUnPricedBasis,dblBasis)))) AS dblBasis,
		dblRatio, strOrigin,strProductType,         
	 intCompanyLocationId,dblFullyPriced,dblUnPriced,dblParPriced,dblFullyPricedFutures,dblParPricedBasis,dblUnPricedBasis,dblParPricedAvgPrice,dblFullyPricedBasis
	 
	  
FROM(
SELECT e.strName,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,cd.intContractDetailId,
             cd.dblQuantity  dblQty,
			 cd.dblQuantity dblOriginalQty			 
			 ,cd.dblNoOfLots
			,(SELECT dblCashPrice FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId AND intPricingTypeId in(1,6))  dblFullyPriced
			,(SELECT dblFutures FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedFutures 
			,(SELECT dblConvertedBasis FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) dblFullyPricedBasis 

             ,((SELECT sum(
             det.dblQuantity*
                (det.dblConvertedBasis+
                (ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,@dtmToDate),0)))/
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
							ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,@dtmToDate),0)
				/case when isnull(mc.ysnSubCurrency,0) = 1 then 100 else 1 end					
             FROM tblCTContractDetail det
              join tblICItemUOM ic on det.intBasisUOMId=ic.intItemUOMId               
			  JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
			  join tblSMCurrency mc on MA.intCurrencyId=mc.intCurrencyID
              WHERE det.intContractDetailId=cd.intContractDetailId and det.intPricingTypeId in(2,8) 
			  )) dblUnPricedSettlementPrice

            ,(SELECT DISTINCT
               
					((SUM(detcd.dblFixationPrice*detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId )  
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,@dtmToDate),0)
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
					 + (isnull(detcd.dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,tcd.intFutureMonthId,@dtmToDate),0)))
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
			 strOrigin,strProductType,
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

declare @ysnSubCurrency int
select @ysnSubCurrency=ysnSubCurrency from tblSMCurrency where intCurrencyID=@intCurrencyId

SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblBalanceQty*dblPrice  dblTotPurchased,strOrigin,strProductType, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,(dblBalanceQty*isnull(dblStandardPrice,0)) dblStandardValue,(dblStandardPrice-dblPrice)*dblBalanceQty dblPPV,
							(dblStandardPrice-dblNewPPVPrice)*dblBalanceQty dblPPVNew,strPricingType,strItemNo,@strCurrency strCurrency,@strUnitMeasure strUnitMeasure
FROM(
SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots, dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,
							 (case when isnull(dblFuturesPrice,0)=0 then dblSettlementPrice else dblFuturesPrice end *isnull(dblRatio,1))+isnull(dblBasis,0)  dblPrice,
							 dblStandardRatio,dblBalanceQty*isnull(dblStandardRatio,1) dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,
							((case when isnull(dblFuturesPrice,0)=0 then dblSettlementPrice else dblFuturesPrice end 
								*isnull(dblRatio,1))+isnull(dblBasis,0)) - isnull(dblRate,0) dblNewPPVPrice
							,strLocationName,
							strOrigin,strProductType,strPricingType,strItemNo
FROM(
SELECT intRowNum,t.intContractDetailId,strEntityName,t.intContractHeaderId,strContractSeq,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblQty) dblQty,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblReturnQty) dblReturnQty,
						dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblBalanceQty) dblBalanceQty,
							t.dblNoOfLots,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,i.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(dblFuturesPrice,0),null,null,null))	dblFuturesPrice,	
													
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,cd.intCurrencyId,isnull(dblSettlementPrice,0),null,null,m.intCurrencyId)
							,null,null,null)
							)/case when isnull(c.ysnSubCurrency,0)=1 then c.intCent else 1 end	dblSettlementPrice,

							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(t.dblBasis,0),null,intBasisCurrencyId,null))	dblBasis,
							
							t.dblRatio,	dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,cost.dblRate,null,null,null) dblRate,
							
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,m.intUnitMeasureId,						
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(dblPrice,0),null,null,null))	dblPrice,
							t.intCompanyLocationId, ca.dblRatio dblStandardRatio, 
							ic.intItemId,						
							
							(SELECT sum(dblQty) FROM
							(SELECT 
								dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,ic1.intUnitMeasureId,
								dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(ac.dblCost,0),b.intCurrencyId,null,null)) dblQty
							FROM tblCTAOP a
							 JOIN tblCTAOPDetail b on a.intAOPId=b.intAOPId 
							 JOIN tblICItemUOM ic1 on b.intPriceUOMId=ic1.intItemUOMId 
							 join tblCTAOPComponent ac on ac.intAOPDetailId=b.intAOPDetailId
							 WHERE a.dtmFromDate=@dtmAOPFromDate and dtmToDate=@dtmAOPToDate and strYear=@strYear
							and b.intItemId=cd.intItemId
							and a.intCommodityId=ic.intCommodityId
							and a.intCompanyLocationId=cd.intCompanyLocationId
							and isnull(a.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(a.intBookId,0) else @intBookId end
							and isnull(a.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(a.intSubBookId,0) else @intSubBookId end
							and isnull(b.intStorageLocationId,0) = case when isnull(cd.intSubLocationId,0)=0 then isnull(b.intStorageLocationId,0) else cd.intSubLocationId end
							)t)  dblStandardPrice,

							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,j.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,
											isnull(cost.dblRate,t.dblBasis),null,null,null))	dblPPVBasis,
							strLocationName,strPricingType,strItemNo,strOrigin,strProductType,cd.intCurrencyId,ysnSubCurrency,cd.intUnitMeasureId
 FROM @GetStandardQty t
JOIN tblCTContractDetail cd on t.intContractDetailId=cd.intContractDetailId
JOIN tblRKFutureMarket m on cd.intFutureMarketId=m.intFutureMarketId
JOIN tblICItemUOM i on cd.intPriceItemUOMId=i.intItemUOMId
JOIN tblICItemUOM j on cd.intBasisUOMId=j.intItemUOMId
JOIN tblCTPricingType pt on cd.intPricingTypeId=pt.intPricingTypeId
JOIN tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICItem ic ON ic.intItemId = cd.intItemId
JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
LEFT JOIN(select intContractDetailId,sum(dbo.[fnCTConvertQuantityToTargetItemUOM](c1.intItemId,@intUnitMeasureId,i.intUnitMeasureId,isnull(dblRate,0))) dblRate 
			FROM tblCTContractCost c1
			JOIN tblICItemUOM i on c1.intItemUOMId=i.intItemUOMId  where ysnBasis=1 and c1.intItemId not in(
		 SELECT isnull(intItemId,0) from tblCTComponentMap where ysnExcludeFromPPV=1) Group by intContractDetailId) cost on cost.intContractDetailId=cd.intContractDetailId													
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId where cd.intPricingTypeId<>6
)t)t1

UNION ALL 

select intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							null dblNoOfLots,null dblFuturesPrice,null dblSettlementPrice,null dblBasis,null dblRatio,dblPrice,dblBalanceQty*dblPrice dblTotPurchased, strOrigin,strProductType,
							null dblStandardRatio, null dblStandardQty,intItemId,
							dblStandardPrice,null dblPPVBasis,strLocationName,null dblNewPPVPrice,(dblBalanceQty*isnull(dblStandardPrice,0)) dblStandardValue,
							(dblStandardPrice-dblPrice)*dblBalanceQty dblPPV,
							null dblPPVNew,strPricingType,strItemNo,@strCurrency strCurrency ,@strUnitMeasure strUnitMeasure
FROM(
SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							  dblPrice, 
							 intItemId,
							dblStandardPrice,							
							strLocationName,							
							strPricingType,strItemNo,strOrigin,strProductType
FROM(
select intRowNum,
t.intContractDetailId,strEntityName,t.intContractHeaderId,strContractSeq,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblQty) dblQty,
					dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblReturnQty) dblReturnQty,
						dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,cd.intUnitMeasureId,@intUnitMeasureId, dblBalanceQty) dblBalanceQty,
							dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,i.intUnitMeasureId,
							dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(cd.dblCashPrice,0),null,null,null))	dblPrice,	
							t.intCompanyLocationId, 
							ic.intItemId,							
							(SELECT sum(dblQty) FROM
							(SELECT 
								dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,@intUnitMeasureId,ic1.intUnitMeasureId,
								dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId,@intCurrencyId,isnull(ac.dblCost,0),b.intCurrencyId,null,null)) dblQty

							FROM tblCTAOP a
							 JOIN tblCTAOPDetail b on a.intAOPId=b.intAOPId 
							 JOIN tblICItemUOM ic1 on b.intPriceUOMId=ic1.intItemUOMId 
							 join tblCTAOPComponent ac on ac.intAOPDetailId=b.intAOPDetailId
							 WHERE a.dtmFromDate=@dtmAOPFromDate and dtmToDate=@dtmAOPToDate and strYear=@strYear
							and b.intItemId=cd.intItemId
							and a.intCommodityId=ic.intCommodityId
							and a.intCompanyLocationId=cd.intCompanyLocationId
							and isnull(a.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(a.intBookId,0) else @intBookId end
							and isnull(a.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(a.intSubBookId,0) else @intSubBookId end
							and isnull(b.intStorageLocationId,0) = case when isnull(cd.intSubLocationId,0)=0 then isnull(b.intStorageLocationId,0) else cd.intSubLocationId end
							)t)  dblStandardPrice,
							strLocationName	,strPricingType,strItemNo,strOrigin,strProductType,cd.intCurrencyId,ysnSubCurrency,cd.intUnitMeasureId
 FROM @GetStandardQty t
JOIN tblCTContractDetail cd on t.intContractDetailId=cd.intContractDetailId
LEFT JOIN tblRKFutureMarket m on cd.intFutureMarketId=m.intFutureMarketId
LEFT JOIN tblICItemUOM i on cd.intPriceItemUOMId=i.intItemUOMId
--LEFT JOIN tblICItemUOM j on cd.int=j.intItemUOMId
LEFT JOIN tblCTPricingType pt on cd.intPricingTypeId=pt.intPricingTypeId
LEFT JOIN tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
LEFT JOIN tblICItem ic ON ic.intItemId = cd.intItemId
LEFT JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
LEFT JOIN(select intContractDetailId,sum(dbo.[fnCTConvertQuantityToTargetItemUOM](c1.intItemId,@intUnitMeasureId,i.intUnitMeasureId,isnull(dblRate,0))) dblRate 
			FROM tblCTContractCost c1
			JOIN tblICItemUOM i on c1.intItemUOMId=i.intItemUOMId  where ysnBasis=1 and c1.intItemId not in(
		 SELECT isnull(intItemId,0) from tblCTComponentMap where ysnExcludeFromPPV=1) Group by intContractDetailId) cost on cost.intContractDetailId=cd.intContractDetailId													
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
where cd.intPricingTypeId=6

)t)t1