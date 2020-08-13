CREATE VIEW [dbo].[vyuRKGetDPRCommodityVisualization]

AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY t.intDPRHeaderId, strCommodityCode, strUnitMeasure DESC) AS INT)
	, t.intDPRHeaderId
	, strCommodityCode
	, strUnitMeasure
	, strTransactionType = strSeqHeader
	, dblTransactionQuantity = dblTotal
	, imgReportId
FROM (
	SELECT intDPRHeaderId
		, strCommodityCode
		, intSeqId = CAST(intSeqId AS INT)
		, strSeqHeader  = CASE WHEN strSeqHeader = 'Company Titled Stock' THEN 'Company Titled' ELSE strSeqHeader END
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
		, strUnitMeasure
	FROM tblRKDPRInventory
	WHERE strSeqHeader IN ('Company Titled Stock', 'In-House')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqId
		, strSeqHeader
		, strUnitMeasure

	UNION ALL SELECT intDPRHeaderId
		, strCommodityCode
		, intSeqNo = CAST(intSeqNo AS INT)
		, strType
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
		, strUnitMeasure
	FROM tblRKDPRContractHedge
	WHERE strType IN ('Avail for Spot Sale', 'Basis Risk', 'Price Risk')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqNo
		, strType
		, strUnitMeasure
) t
LEFT JOIN tblRKDPRHeader h ON h.intDPRHeaderId = t.intDPRHeaderId
