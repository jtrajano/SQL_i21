CREATE VIEW [dbo].[vyuRKGetDPRInventorySummary]
	AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY intSeqId DESC) AS INT)
	, intDPRHeaderId
	, strCommodityCode
	, intSeqId = CAST(intSeqId AS INT)
	, strSeqHeader
	, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
FROM tblRKDPRInventory
GROUP BY intDPRHeaderId
	, strCommodityCode
	, intSeqId
	, strSeqHeader