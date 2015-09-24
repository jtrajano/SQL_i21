CREATE VIEW vyuRKGetContractBalanceLot
AS
SELECT *,isnull(dblAvailableLot,0)-dblSelectedLot as dblBalanceLot FROM
(SELECT cd.intContractDetailId, strContractNumber, intContractSeq as intContractSeq,
		strContractNumber + ' - ' + CONVERT(varchar,intContractSeq) as strContractSeq,
		cd.intFutureMarketId,cd.intFutureMonthId, cd.strContractType,
		isnull(SUM(cd.dblNoOfLots),0) as dblAvailableLot,
		(SELECT convert(decimal, isnull(SUM(fot.intNoOfContract),0.0)) 
		 FROM tblRKFutOptTransaction fot WHERE fot.intContractDetailId= cd.intContractDetailId) as dblSelectedLot		 
FROM vyuCTContractDetailView cd
WHERE ysnAllowedToShow=1 AND cd.intFutureMarketId IS NOT NULL AND cd.intFutureMonthId IS NOT NULL
GROUP BY strContractNumber,cd.intContractDetailId,intContractSeq,cd.intFutureMarketId,cd.intFutureMonthId,cd.strContractType)t  


