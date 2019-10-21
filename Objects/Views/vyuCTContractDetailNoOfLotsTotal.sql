CREATE VIEW [dbo].[vyuCTContractDetailNoOfLotsTotal]
AS 
SELECT intContractDetailId, dblNoOfLots
FROM
(
	SELECT intContractDetailId, dblNoOfLots
	FROM tblCTContractDetail
	UNION ALL
	SELECT intSplitFromId, dblNoOfLots
	FROM tblCTContractDetail
) tbl
