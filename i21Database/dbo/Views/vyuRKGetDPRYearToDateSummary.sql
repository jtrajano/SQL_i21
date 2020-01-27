CREATE VIEW [dbo].[vyuRKGetDPRYearToDateSummary]

AS

SELECT intRowId = ROW_NUMBER() OVER (ORDER BY intSeqId DESC)
	, intDPRHeaderId
	, strCommodityCode
	, strType
	, strFieldName
	, dblTotal
FROM (
	SELECT intSeqId = (SELECT TOP 1 intDPRYearToDateId FROM tblRKDPRYearToDate x
					WHERE x.intDPRHeaderId = t.intDPRHeaderId
						AND x.strCommodityCode = t.strCommodityCode
						AND x.strType = t.strType
						AND x.strFieldName = t.strFieldName)
		, *
	FROM (
		SELECT intDPRHeaderId
			, strCommodityCode
			, strType
			, strFieldName
			, dblTotal = ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00)
		FROM tblRKDPRYearToDate
		GROUP BY intDPRHeaderId
			, strCommodityCode
			, strType
			, strFieldName
	) t
) y