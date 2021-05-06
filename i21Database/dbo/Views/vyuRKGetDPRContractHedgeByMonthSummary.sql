CREATE VIEW [dbo].[vyuRKGetDPRContractHedgeByMonthSummary]

AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME, '01 ' + strContractEndMonth) END, intSeqNo, strType) AS INT)
	, intDPRHeaderId
	, strCommodityCode
	, intSeqNo = CAST(intSeqNo AS INT)
	, strContractEndMonth
	, strType
	, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
FROM tblRKDPRContractHedgeByMonth
GROUP BY intDPRHeaderId
	, strCommodityCode
	, intSeqNo
	, strContractEndMonth
	, strType