CREATE PROC uspRKSourcingReport 
	@dtmFromDate DATETIME = NULL,
	@dtmToDate DATETIME = NULL,
	@intCommodityId int = NULL,
	@intUnitMeasureId int = NULL

AS

SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,convert(numeric(24,6),dblQty) as dblQty, convert(numeric(24,6),dblTotPurchased) dblTotPurchased, 
		 (dblTotPurchased/SUM(CASE WHEN isnull(dblTotPurchased,0)=0 then 1 else dblTotPurchased end) OVER ())*100  as dblCompanySpend ,0 as intConcurrencyId
	FROM(
SELECT strName, isnull(sum(dblQty),0) as dblQty,isnull(sum(dblTotPurchased),0) as dblTotPurchased from(
SELECT strName, (isnull(dblQty,0)) as dblQty , 
	CASE WHEN (isnull(dblFullyPriced,0)) =0 and (isnull(dblUnPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0 then 0
		 WHEN (isnull(dblFullyPriced,0)) <> 0  then (isnull(dblFullyPriced,0))
		 WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) <> 0 then (isnull(dblParPriced,0))
		 WHEN (isnull(dblFullyPriced,0)) = 0 and (isnull(dblParPriced,0)) = 0  then (isnull(dblUnPriced,0)) end as dblTotPurchased		
 FROM(
 SELECT e.strName,
	   dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity) dblQty 
	   ,(SELECT dblTotalCost FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) as dblFullyPriced

	   ,(SELECT (dblBasis  +
	    ISNULL(dbo.fnRKGetLatestClosingPrice(intFutureMarketId,intFutureMonthId,getdate()),0)) * dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity)
	    FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(2)) as dblUnPriced

	    ,(SELECT ((sum(isnull(detcd.dblNoOfLots,0)*isnull(dblFixationPrice,0))  + isnull(max(dblBalanceNoOfLots),0) 
	    *MAX(ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0))) 
						/ (cd.dblNoOfLots)) * dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,cd.intUnitMeasureId, @intUnitMeasureId,cd.dblQuantity)				
		FROM vyuCTSearchPriceContract det
		JOIN vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId WHERE strStatus in('Partially Priced')
		AND det.intContractDetailId=cd.intContractDetailId
		) as dblParPriced
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
WHERE ch.dtmContractDate BETWEEN @dtmFromDate AND @dtmToDate 
)t)t1 group by t1.strName)t2