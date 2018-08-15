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
	   @intAOPId nvarchar(100)= null

AS

if @strOrigin = '-1'
set @strOrigin = null
 if @strProductType = '-1'
set @strProductType = null

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


IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN

insert into @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType,cd.intCompanyLocationId)

SELECT  CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,intContractDetailId,
		strName as strEntityName,
		intContractHeaderId,
		strContractNumber as strContractSeq, 
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 
		CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty,
		CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty,
		CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots, 
		CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice,
		CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice,
		CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,dblUnPricedBasis))) AS dblBasis,
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
	 end AS dblTotPurchased, strOrigin,strProductType, intCompanyLocationId
FROM(
SELECT cd.intContractDetailId,e.strName ,ch.intContractHeaderId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,
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
			  as dblReturn,strOrigin,strProductType, cd.intCompanyLocationId,dblRatio, dblBasis
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
JOIN vyuRKSourcingContractDetail sc on sc.intContractDetailId=cd.intContractDetailId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
AND isnull(strName,'') = case when isnull(@strEntityName ,'')= '' then isnull(strName,'') else @strEntityName  end
AND isnull(strOrigin,'')= case when isnull(@strOrigin,'')= '' then isnull(strOrigin,'') else @strOrigin end
AND isnull(strProductType,'')=case when isnull(@strProductType,'')='' then isnull(strProductType,'') else @strProductType end
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intSubBookId,0) else @intBookId end

)t1 
END
ELSE

BEGIN

INSERT INTO @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType,cd.intCompanyLocationId)

SELECT  CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,intContractDetailId,
		strName as strEntityName,
		intContractHeaderId,
		strContractNumber as strContractSeq, 
		CONVERT(NUMERIC(16,6),isnull(dblQty,0)) as dblQty, 
		CONVERT(NUMERIC(16,6),isnull(dblReturn,0)) as dblReturnQty,
		CONVERT(NUMERIC(16,6),(isnull(dblQty,0) - isnull(dblReturn,0))) as dblBalanceQty,
		CONVERT(NUMERIC(16,6),dblNoOfLots) as dblNoOfLots, 
		CONVERT(NUMERIC(16,6),(case when isnull(dblFullyPricedFutures,0)=0 then dblParPricedAvgPrice else dblFullyPricedFutures end))  dblFuturesPrice,
		CONVERT(NUMERIC(16,6),dblUnPricedSettlementPrice) dblSettlementPrice,
		CONVERT(NUMERIC(16,6),isnull(dblFullyPricedBasis,isnull(dblParPricedBasis,dblUnPricedBasis))) AS dblBasis,
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
	 end AS dblTotPurchased , strOrigin,strProductType,intCompanyLocationId
FROM(
SELECT e.strName,ch.intContractHeaderId,cd.intContractDetailId,ch.strContractNumber +'-'+Convert(nvarchar,cd.intContractSeq) strContractNumber,
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
			  as dblReturn,
			  strOrigin,strProductType,cd.intCompanyLocationId,dblRatio, dblBasis
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intContractStatusId not in(2,3)
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICCommodityUnitMeasure cuc on cuc.intCommodityId=@intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId 
JOIN tblEMEntity e on e.intEntityId=CASE WHEN ISNULL(cd.intProducerId,0)=0 then ch.intEntityId else 
							case when isnull(cd.ysnClaimsToProducer,0)=1 then cd.intProducerId else ch.intEntityId end end
JOIN vyuRKSourcingContractDetail sc on sc.intContractDetailId=cd.intContractDetailId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate and ch.intCommodityId=@intCommodityId
AND isnull(strName,'') = case when isnull(@strEntityName ,'')= '' then isnull(strName,'') else @strEntityName  end
AND isnull(strOrigin,0)= case when isnull(@strOrigin,0)=0 then isnull(strOrigin,0) else @strOrigin end
AND isnull(strProductType,0)=case when isnull(@strProductType,0)=0 then isnull(strProductType,0) else @strProductType end
and isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
and isnull(cd.intSubBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intSubBookId,0) else @intBookId end
)t
END

select intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,dblStandardValue,dblPPV,dblPPVNew from(
SELECT intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,dblNewPPVPrice,strLocationName,(dblBalanceQty*isnull(t.dblRatio,1))*isnull(dblStandardPrice,0) dblStandardValue,(dblStandardPrice-dblPrice)*dblBalanceQty dblPPV,
(dblStandardPrice-dblNewPPVPrice)*dblBalanceQty dblPPVNew,strOrigin,strProductType
FROM(
select t.*, ca.dblRatio dblStandardRatio, dblBalanceQty*isnull(ca.dblRatio,1) dblStandardQty,ic.intItemId,
 (SELECT sum(dblCost) from tblCTAOP a
 join tblCTAOPDetail b on a.intAOPId=b.intAOPId and a.intAOPId=@intAOPId
							and b.intItemId=cd.intItemId
							and b.intCommodityId=ic.intCommodityId
							and isnull(a.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(a.intBookId,0)else @intBookId end
							and isnull(a.intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(a.intSubBookId,0) else @intSubBookId end 
							) dblStandardPrice
							,cost.dblRate dblPPVBasis, (isnull(dblFuturesPrice,dblSettlementPrice)*t.dblRatio)+isnull(cost.dblRate,0) as  dblNewPPVPrice,strLocationName
 from @GetStandardQty t
JOIN tblCTContractDetail cd on t.intContractDetailId=cd.intContractDetailId
join tblSMCompanyLocation l on cd.intCompanyLocationId=l.intCompanyLocationId
JOIN tblICItem ic ON ic.intItemId = cd.intItemId
LEFT JOIN(select intContractDetailId,SUM(dblRate) dblRate FROM tblCTContractCost where ysnBasis=1 and intItemId not in(
		 SELECT isnull(intItemId,0) from tblCTComponentMap where ysnExcludeFromPPV=1) Group by intContractDetailId) cost on cost.intContractDetailId=cd.intContractDetailId													
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId)t)t1
