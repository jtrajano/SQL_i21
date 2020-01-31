﻿CREATE VIEW [dbo].[vyuRKGetDPRContractHedgeSummary]

AS

SELECT intRowId = CAST(ROW_NUMBER() OVER (ORDER BY intSeqNo DESC) AS INT)
	, intDPRHeaderId
	, strCommodityCode
	, intSeqNo = CAST(intSeqNo AS INT)
	, strType
	, dblTotal = CAST(ISNULL(SUM(ISNULL(dblTotal, 0.00)), 0.00) AS DECIMAL(24, 10))
FROM tblRKDPRContractHedge
GROUP BY intDPRHeaderId
	, strCommodityCode
	, intSeqNo
	, strType