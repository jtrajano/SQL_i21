CREATE VIEW [dbo].[vyuCTContractDetailQuantityTotal]
AS 
SELECT intContractDetailId, dblQuantity
FROM
(
	SELECT intContractDetailId, dblQuantity
	FROM tblCTContractDetail
	UNION ALL
	SELECT intSplitFromId, dblQuantity
	FROM tblCTContractDetail
) tbl
