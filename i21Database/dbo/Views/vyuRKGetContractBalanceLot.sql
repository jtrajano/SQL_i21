CREATE VIEW vyuRKGetContractBalanceLot
AS
SELECT *,
CASE WHEN ISNULL(dblAvailableLot,0)-dblSelectedLot <=0 then 0 else isnull(dblAvailableLot,0)-dblSelectedLot end dblBalanceLot
 FROM
(SELECT cd.intContractDetailId, strContractNumber, intContractSeq as intContractSeq,
		strContractNumber + ' - ' + CONVERT(varchar,intContractSeq) as strContractSeq,
		cd.strEntityName, 
		cd.intFutureMarketId,cd.intFutureMonthId, cd.strContractType,
		isnull(SUM(cd.dblNoOfLots),0) as dblAvailableLot,
		(SELECT convert(decimal, isnull(SUM(fot.dblAssignedLots),0.0)) 
		 FROM tblRKAssignFuturesToContractSummary fot WHERE fot.intContractDetailId= cd.intContractDetailId) as dblSelectedLot		 
FROM vyuCTContractDetailView cd
WHERE cd.intFutureMarketId IS NOT NULL AND cd.intFutureMonthId IS NOT NULL and cd.intContractStatusId <> 3
GROUP BY strContractNumber,cd.intContractDetailId,intContractSeq,cd.intFutureMarketId,cd.intFutureMonthId,cd.strContractType,cd.strEntityName)t  