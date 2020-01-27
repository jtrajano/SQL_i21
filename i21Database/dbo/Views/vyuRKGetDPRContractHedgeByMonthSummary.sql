CREATE VIEW [dbo].[vyuRKGetDPRContractHedgeByMonthSummary]

AS

SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY strCommodityCode, strType ORDER BY intSeqNo DESC)
	, intDPRHeaderId
	, strCommodityCode
	, intSeqNo
	, strType
	, dblTotal = ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00)
FROM tblRKDPRContractHedgeByMonth
GROUP BY intDPRHeaderId
	, strCommodityCode
	, intSeqNo
	, strType