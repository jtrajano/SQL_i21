CREATE VIEW [dbo].[vyuRKGetDPRInventorySummary]
	AS

SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY strCommodityCode, strSeqHeader ORDER BY intSeqId DESC)
	, intDPRHeaderId
	, strCommodityCode
	, intSeqId
	, strSeqHeader
	, dblTotal = ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00)
FROM tblRKDPRInventory
GROUP BY intDPRHeaderId
	, strCommodityCode
	, intSeqId
	, strSeqHeader