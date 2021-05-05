CREATE VIEW [dbo].[vyuRKGetDPRInventorySummaryByLocation]
	AS

SELECT tbl.*, intLocationId = intCompanyLocationId FROM (
	SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY intSeqId DESC) AS INT)
		, intDPRHeaderId
		, strCommodityCode
		, intSeqId = CAST(intSeqId AS INT)
		, strSeqHeader
		, strLocationName
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
	FROM tblRKDPRInventory
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqId
		, strSeqHeader
		, strLocationName
) tbl
INNER JOIN tblSMCompanyLocation loc ON loc.strLocationName = tbl.strLocationName