CREATE PROC uspRKSourcingReport 
	@dtmFromDate DATETIME,
	@dtmToDate DATETIME ,
	@intUnitMeasureId int

AS
SELECT CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,strName,convert(numeric(24,6),dblQty) as dblQty,convert(numeric(24,6),dblTotPurchased) dblTotPurchased, 
		convert(numeric(24,6),(isnull(dblQty,0)/case when isnull(dblTotPurchased,0) = 0 then 1 else dblTotPurchased end)*100) as dblCompanySpend ,0 as intConcurrencyId
	FROM(
SELECT strName, sum(isnull(dblQty,0)) as dblQty , sum(isnull(dblFullyPriced,0))+sum(isnull(dblUnPriced,0))+sum(isnull(dblParPriced,0)) as dblTotPurchased		
 FROM(
SELECT e.strName,
	   dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId,isnull(intNetWeightUOMId,@intUnitMeasureId),cd.dblQuantity) dblQty 
	   ,(SELECT dblTotalCost FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(1,6)) as dblFullyPriced

	   ,(SELECT (dblBasis  +
	    ISNULL(dbo.fnRKGetLatestClosingPrice(intFutureMarketId,intFutureMonthId,getdate()),0)) * isnull(dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId,isnull(intNetWeightUOMId,@intUnitMeasureId),cd.dblQuantity),0)
	    FROM tblCTContractDetail det WHERE det.intContractDetailId=cd.intContractDetailId and intPricingTypeId in(2)) as dblUnPriced

	   ,(
	   SELECT (((((isnull(dblLotsFixed,0)*isnull(dblFixationPrice,0)) + (isnull(dblBalanceNoOfLots,0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId,det.intFutureMonthId,getdate()),0))))
				/isnull(det.dblNoOfLots,1)) + isnull(det.dblBasis,0)) * isnull(dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId,isnull(intNetWeightUOMId,@intUnitMeasureId),det.dblQuantity),1)
		FROM vyuCTSearchPriceContract det
		join vyuCTSearchPriceContractDetail detcd on det.intPriceFixationId=detcd.intPriceFixationId WHERE strStatus in('Partially Priced')
		and det.intContractDetailId=cd.intContractDetailId
		) as dblParPriced
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
WHERE ch.dtmContractDate BETWEEN  @dtmFromDate AND @dtmToDate 
)t group by t.strName
)t2
