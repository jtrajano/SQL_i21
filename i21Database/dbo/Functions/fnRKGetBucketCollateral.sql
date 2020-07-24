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
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, dtmOpenDate DATETIME
	, dblOriginalQuantity NUMERIC(24, 10)
	, dblRemainingQuantity NUMERIC(24, 10)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityUnitMeasureId INT
	, intCompanyLocationId INT
	, intContractTypeId INT
	, intLocationId INT
	, intEntityId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmEndDate DATETIME
	, ysnIncludeInPriceRiskAndCompanyTitled BIT
	, dtmCreatedDate DATETIME
	, intUserId INT
	, strUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
			AND ISNULL(intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(intCommodityId, 0)) 
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
		, intContractDetailId
		, strContractNumber
		, intContractSeq
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
		, dtmCreatedDate
		, intUserId
		, strUserName
		, strAction
		, strTransactionType
		, strNotes
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId, c.strTransactionType ORDER BY c.intSummaryLogId DESC)
			, dblTotal = c.dblOrigQty
			, intCollateralId = c.intTransactionRecordId
			, c.strLocationName
			, c.intItemId
			, c.strItemNo
			, c.strCategoryCode
			, c.strEntityName
			, strReceiptNo = strTransactionNumber
			, c.intContractHeaderId
			, c.intContractDetailId
			, strContractNumber
			, intContractSeq
			, c.dtmTransactionDate
			, dblOriginalQuantity = ISNULL(c.dblOrigQty, 0)
			, dblRemainingQuantity = c.dblOrigQty
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
			, dtmCreatedDate
			, intUserId
			, strUserName
			, strAction
			, strTransactionType
			, strNotes
		FROM vyuRKGetSummaryLog c
		JOIN tblRKCollateral Col ON Col.intCollateralId = c.intTransactionRecordHeaderId
		LEFT JOIN Contracts Cnt ON Cnt.intContractHeaderId = c.intContractHeaderId
		WHERE strTransactionType IN ( 'Collateral', 'Collateral Adjustments')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND  c.dtmCreatedDate <= DATEADD(MI,(DATEDIFF(MI, SYSDATETIME(),SYSUTCDATETIME())), DATEADD(MI,1439,CONVERT(DATETIME, @dtmDate)))
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) a WHERE a.intRowNum = 1

	RETURN
END
