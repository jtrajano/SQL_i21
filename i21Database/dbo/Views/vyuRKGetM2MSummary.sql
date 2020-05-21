CREATE VIEW [dbo].[vyuRKGetM2MSummary]

AS

SELECT s.intM2MSummaryId
    , s.intM2MHeaderId
	, s.strSummary
    , s.intCommodityId
	, c.strCommodityCode
    , s.strContractOrInventoryType
    , s.dblQty
    , s.dblTotal
    , s.dblFutures
    , s.dblBasis
    , s.dblCash
    , s.intConcurrencyId
FROM tblRKM2MSummary s
LEFT JOIN tblICCommodity c ON c.intCommodityId = s.intCommodityId