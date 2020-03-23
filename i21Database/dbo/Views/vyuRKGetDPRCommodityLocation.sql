CREATE VIEW [dbo].[vyuRKGetDPRCommodityLocation]

AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY PVT.intDPRHeaderId, strCommodityCode, strUnitMeasure, loc.intCompanyLocationId, PVT.strLocationName DESC) AS INT)
	, PVT.intDPRHeaderId
	, strCommodityCode
	, strUnitMeasure
	, intLocationId = loc.intCompanyLocationId
	, PVT.strLocationName
	, dblCompanyTitled = SUM(ISNULL([Company Titled Stock], 0))
	, dblInHouse = SUM(ISNULL([In-House], 0))
	, dblAvailForSale = SUM(ISNULL([Avail for Spot Sale], 0))
	, dblBasisExposure = SUM(ISNULL([Basis Risk], 0))
	, dblCaseExposure = SUM(ISNULL([Price Risk], 0))
	, imgReportId
FROM (
	SELECT intDPRHeaderId
		, strCommodityCode
		, intSeqId = CAST(intSeqId AS INT)
		, strSeqHeader
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
		, strUnitMeasure
		, strLocationName
	FROM tblRKDPRInventory
	WHERE strSeqHeader IN ('Company Titled Stock', 'In-House')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqId
		, strSeqHeader
		, strUnitMeasure
		, strLocationName

	UNION ALL SELECT intDPRHeaderId
		, strCommodityCode
		, intSeqNo = CAST(intSeqNo AS INT)
		, strType
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
		, strUnitMeasure
		, strLocationName
	FROM tblRKDPRContractHedge
	WHERE strType IN ('Avail for Spot Sale', 'Basis Risk', 'Price Risk')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqNo
		, strType
		, strUnitMeasure
		, strLocationName
) t
PIVOT (
	SUM(dblTotal)
	FOR strSeqHeader IN ([Company Titled Stock]
		, [In-House]
		, [Avail for Spot Sale]
		, [Basis Risk]
		, [Price Risk])
) AS PVT
LEFT JOIN tblSMCompanyLocation loc ON loc.strLocationName = PVT.strLocationName
LEFT JOIN tblRKDPRHeader h ON h.intDPRHeaderId = PVT.intDPRHeaderId
GROUP BY PVT.intDPRHeaderId
	, strCommodityCode
	, strUnitMeasure
	, loc.intCompanyLocationId
	, PVT.strLocationName
	, imgReportId