CREATE VIEW vyuRKGetContractBalanceLotForHeader
AS
SELECT *,
CASE WHEN ISNULL(dblAvailableLot,0)-dblSelectedLot <=0 then 0 else isnull(dblAvailableLot,0)-dblSelectedLot end dblBalanceLot
 FROM
(SELECT cd.intContractHeaderId, strContractNumber,
		cd.strEntityName, 
		cd.intFutureMarketId,cd.intFutureMonthId, cd.strContractType, cd.intContractTypeId,
		isnull(SUM(cd.dblNoOfLots),0) as dblAvailableLot,
		(SELECT convert(decimal, isnull(SUM(fot.dblAssignedLots),0.0)) 
		 FROM tblRKAssignFuturesToContractSummary fot WHERE fot.intContractHeaderId= cd.intContractHeaderId) as dblSelectedLot
		,cd.intContractStatusId		 
FROM vyuCTContractDetailView cd
WHERE cd.intFutureMarketId IS NOT NULL --AND cd.intFutureMonthId IS NOT NULL  
and intContractHeaderId not IN (select top 1 intContractHeaderId from tblCTContractDetail where intContractStatusId not in(2,3)) 
and isnull(ysnMultiplePriceFixation,0) = 0
GROUP BY strContractNumber,cd.intContractHeaderId,cd.intFutureMarketId,cd.intFutureMonthId,cd.strContractType,cd.intContractTypeId,cd.strEntityName, cd.intContractStatusId)t
WHERE intContractStatusId NOT IN (3,5,6)
