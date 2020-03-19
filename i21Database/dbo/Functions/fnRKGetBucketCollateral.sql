﻿CREATE FUNCTION [dbo].[fnRKGetBucketCollateral]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	dblTotal NUMERIC(24, 10)
	, intCollateralId INT
	, strLocationName NVARCHAR(100)
	, intItemId INT
	, strItemNo NVARCHAR(100)
	, strCategory NVARCHAR(100)
	, strEntityName NVARCHAR(100)
	, strReceiptNo NVARCHAR(100)
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(100)
	, dtmOpenDate DATETIME
	, dblOriginalQuantity NUMERIC(24, 10)
	, dblRemainingQuantity NUMERIC(24, 10)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100)
	, intUnitMeasureId INT
	, intCompanyLocationId INT
	, intContractTypeId INT
	, intLocationId INT
	, intEntityId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strFutureMarket NVARCHAR(100)
	, strFutureMonth NVARCHAR(100)
	, dtmEndDate DATETIME
	, ysnIncludeInPriceRiskAndCompanyTitled BIT
)
AS
BEGIN

	; WITH Contracts (
		dtmEndDate
		, intContractHeaderId
	) AS (
		SELECT 
			dtmEndDate = MAX(dtmEndDate)
			, CH.intContractHeaderId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId  
		WHERE intContractStatusId <> 3
			AND intCommodityId = @intCommodityId
		GROUP BY CH.intContractHeaderId
	)

	INSERT @returntable
	SELECT dblTotal
		, intCollateralId
		, strLocationName
		, intItemId
		, strItemNo
		, strCategoryCode
		, strEntityName
		, strReceiptNo
		, intContractHeaderId
		, strContractNumber
		, dtmTransactionDate
		, dblOriginalQuantity
		, dblRemainingQuantity
		, intCommodityId
		, strCommodityCode
		, intCommodityUnitMeasureId
		, intCompanyLocationId
		, intContractTypeId
		, intLocationId
		, intEntityId
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMarket
		, strFutureMonth
		, dtmEndDate
		, ysnIncludeInPriceRiskAndCompanyTitled 
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId ORDER BY c.intSummaryLogId DESC)
			, dblTotal = c.dblOrigQty - ISNULL(ca.dblAdjustmentAmount, 0)
			, intCollateralId = c.intTransactionRecordId
			, c.strLocationName
			, c.intItemId
			, c.strItemNo
			, c.strCategoryCode
			, c.strEntityName
			, strReceiptNo = strTransactionNumber
			, c.intContractHeaderId
			, strContractNumber
			, c.dtmTransactionDate
			, dblOriginalQuantity = ISNULL(c.dblOrigQty, 0)
			, dblRemainingQuantity = c.dblOrigQty - ISNULL(ca.dblAdjustmentAmount, 0)
			, c.intCommodityId
			, c.strCommodityCode
			, intCommodityUnitMeasureId = c.intOrigUOMId
			, intCompanyLocationId = c.intLocationId
			, intContractTypeId = CASE WHEN c.strDistributionType = 'Purchase' THEN 1 ELSE 2 END
			, c.intLocationId
			, intEntityId
			, c.intFutureMarketId
			, c.intFutureMonthId
			, c.strFutureMarket
			, c.strFutureMonth
			, Cnt.dtmEndDate
			, Col.ysnIncludeInPriceRiskAndCompanyTitled
		FROM vyuRKGetSummaryLog c
		LEFT JOIN (
			SELECT intCollateralId
				, dblAdjustmentAmount = SUM(dblAdjustmentAmount)
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY Adj.intTransactionRecordId ORDER BY Adj.intSummaryLogId DESC)
					, intCollateralAdjustmentId = intTransactionRecordId
					, intCollateralId = intTransactionRecordHeaderId
					, dblAdjustmentAmount = dblOrigQty
				FROM vyuRKGetSummaryLog Adj
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
					AND strTransactionType = 'Collateral Adjustment'
			) t WHERE intRowNum = 1		
			GROUP BY intCollateralId
		) ca ON c.intTransactionRecordHeaderId = ca.intCollateralId
		JOIN tblRKCollateral Col ON Col.intCollateralId = c.intTransactionRecordId
		LEFT JOIN Contracts Cnt ON Cnt.intContractHeaderId = c.intContractHeaderId
		WHERE strTransactionType = 'Collateral'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND c.intCommodityId = @intCommodityId
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) a WHERE a.intRowNum = 1

	RETURN
END
