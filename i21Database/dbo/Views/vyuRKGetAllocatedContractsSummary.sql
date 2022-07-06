CREATE VIEW [dbo].[vyuRKGetAllocatedContractsSummary]

AS

SELECT s.intAllocatedContractsSummaryId
    , s.intAllocatedContractsGainOrLossHeaderId
	, s.strSummary
    , s.intCommodityId
	, c.strCommodityCode
    , s.dblPurchaseAllocatedQty
	, s.dblSalesAllocatedQty
    , s.dblTotal
    , s.dblFutures
    , s.dblBasis
    , s.dblCash
    , s.intConcurrencyId
FROM tblRKAllocatedContractsSummary s
LEFT JOIN tblICCommodity c ON c.intCommodityId = s.intCommodityId