CREATE FUNCTION [dbo].[fnRKGetBucketCollateral]
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
	, strFutMarketName NVARCHAR(100)
	, strFutureMonth NVARCHAR(100)
	, ysnIncludeInPriceRiskAndCompanyTitled BIT
)
AS
BEGIN
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
			, intContractTypeId = CASE WHEN c.strNotes = 'Purchase Collateral' THEN 1 ELSE 2 END
			, c.intLocationId
			, intEntityId
			, c.intFutureMarketId
			, c.intFutureMonthId
			, c.strFutureMarket
			, c.strFutureMonth
			, Col.ysnIncludeInPriceRiskAndCompanyTitled
		FROM vyuRKGetSummaryLog c
		LEFT JOIN (
			SELECT intCollateralId
				, dblAdjustmentAmount = SUM(dblAdjustmentAmount)
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY Adj.intContractDetailId ORDER BY Adj.intSummaryLogId DESC)
					, intCollateralAdjustmentId = intContractDetailId
					, intCollateralId = intTransactionRecordId
					, dblAdjustmentAmount = dblOrigQty
				FROM vyuRKGetSummaryLog Adj
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
					AND strTransactionType = 'Collateral Adjustment'
			) t WHERE intRowNum = 1		
			GROUP BY intCollateralId
		) ca ON c.intTransactionRecordId = ca.intCollateralId
		JOIN tblRKCollateral Col ON Col.intCollateralId = c.intTransactionRecordId
		WHERE strTransactionType = 'Collateral'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND c.intCommodityId = @intCommodityId
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) a WHERE a.intRowNum = 1

	RETURN
END
