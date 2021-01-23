CREATE VIEW [dbo].[vyuRKGetDPRContractHedgeSummary]

AS

SELECT 
intRowId = CAST(ROW_NUMBER() OVER (ORDER BY intSeqNo DESC) AS INT)
,* 
FROM (

	SELECT  intDPRHeaderId
		, strCommodityCode
		, intSeqNo = CAST(intSeqNo AS INT)
		, strType
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
	FROM tblRKDPRContractHedge
	WHERE strType NOT IN ('Basis Risk','Price Risk')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqNo
		, strType
	HAVING CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10)) <> 0

	UNION ALL
	SELECT intDPRHeaderId
		, strCommodityCode
		, intSeqNo = CAST(intSeqNo AS INT)
		, strType
		, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
	FROM tblRKDPRContractHedge
	WHERE strType IN ('Basis Risk','Price Risk')
	GROUP BY intDPRHeaderId
		, strCommodityCode
		, intSeqNo
		, strType
) t 
