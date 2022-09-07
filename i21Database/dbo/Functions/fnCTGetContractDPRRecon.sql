CREATE FUNCTION dbo.fnCTGetContractDPRRecon(
	@FromDate DATETIME
	, @ToDate DATETIME
	, @intCommodityId INT = NULL
)
RETURNS @Records TABLE (
	intRowId INT IDENTITY
	, strBucket NVARCHAR(100)
	, intCommodity INT
	, dtmDate DATETIME
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(50)
	, intContractTypeId INT
	, dblQuantity NUMERIC(18, 6)
)

AS

BEGIN
	
	WITH SequenceHistory AS (
		SELECT *
		FROM vyuCTSequenceHistoryForDPR sh
		WHERE sh.dtmDate >= @FromDate
			AND sh.dtmDate <= @ToDate
			AND sh.intCommodityId = ISNULL(@intCommodityId, sh.intCommodityId)
	)

	INSERT INTO @Records (strBucket
		, intCommodity
		, dtmDate
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intContractTypeId
		, dblQuantity)
	
	SELECT strBucket = 'New Priced Purchase Contract'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, sh.dblQuantity
	FROM SequenceHistory sh
	WHERE ysnNewPriced = 1
		AND intContractTypeId = 1

	UNION ALL
	SELECT strBucket = 'New HTA Purchase Contract'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, sh.dblQuantity
	FROM SequenceHistory sh
	WHERE ysnNewHTA = 1
		AND intContractTypeId = 1

	UNION ALL
	SELECT strBucket = 'Purchase Basis Pricing'		
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, dblQuantity = (sh.dblQtyPriced - sh.dblPrevQtyPriced)
	FROM SequenceHistory sh
	WHERE intContractTypeId = 1
		AND sh.intHeaderPricingTypeId = 2
		AND (sh.dblQtyPriced - sh.dblPrevQtyPriced) <> 0

	UNION ALL
	SELECT strBucket = 'Purchase Qty Adjustment'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, dblQuantity = sh.dblDifference
	FROM SequenceHistory sh
	WHERE ysnQtyChange = 1
		AND intContractTypeId = 1

	UNION ALL
	SELECT strBucket = 'Purchase Short Closed'
		, intCommodityId
		, dtmDate
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intContractTypeId
		, dblQuantity
	FROM (
		SELECT intRowNo = ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmDate DESC)
			, sh.intCommodityId
			, sh.dtmDate
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, strContractNumber = sh.strContractNoSeq
			, sh.intContractTypeId
			, sh.dblQuantity
		FROM SequenceHistory sh
		WHERE ysnShortClosed = 1
			AND intContractTypeId = 1
	) a WHERE a.intRowNo = 1

	UNION ALL
	SELECT strBucket = 'Purchase Cancelled'
		, intCommodityId
		, dtmDate
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intContractTypeId
		, dblQuantity
	FROM (
		SELECT intRowNo = ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmDate DESC)
			, sh.intCommodityId
			, sh.dtmDate
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, strContractNumber = sh.strContractNoSeq
			, sh.intContractTypeId
			, sh.dblQuantity
		FROM SequenceHistory sh
		WHERE ysnCancelled = 1
			AND intContractTypeId = 1
	) a WHERE a.intRowNo = 1

	UNION ALL
	SELECT strBucket = 'New Priced Sales Contract'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, sh.dblQuantity
	FROM SequenceHistory sh
	WHERE ysnNewPriced = 1
		AND intContractTypeId = 2

	UNION ALL
	SELECT strBucket = 'New HTA Sales Contract'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, sh.dblQuantity
	FROM SequenceHistory sh
	WHERE ysnNewHTA = 1
		AND intContractTypeId = 2

	UNION ALL
	SELECT strBucket = 'Sales Basis Pricing'		
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, dblQuantity = (sh.dblQtyPriced - sh.dblPrevQtyPriced)
	FROM SequenceHistory sh
	WHERE intContractTypeId = 2
		AND sh.intHeaderPricingTypeId = 2
		AND (sh.dblQtyPriced - sh.dblPrevQtyPriced) <> 0

	UNION ALL
	SELECT strBucket = 'Sales Qty Adjustment'
		, sh.intCommodityId
		, sh.dtmDate
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, strContractNumber = sh.strContractNoSeq
		, sh.intContractTypeId
		, dblQuantity = sh.dblDifference
	FROM SequenceHistory sh
	WHERE ysnQtyChange = 1
		AND intContractTypeId = 2

	UNION ALL
	SELECT strBucket = 'Sales Short Closed'
		, intCommodityId
		, dtmDate
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intContractTypeId
		, dblQuantity
	FROM (
		SELECT intRowNo = ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmDate DESC)
			, sh.intCommodityId
			, sh.dtmDate
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, strContractNumber = sh.strContractNoSeq
			, sh.intContractTypeId
			, sh.dblQuantity
		FROM SequenceHistory sh
		WHERE ysnShortClosed = 1
			AND intContractTypeId = 2
	) a WHERE a.intRowNo = 1

	UNION ALL
	SELECT strBucket = 'Sales Cancelled'
		, intCommodityId
		, dtmDate
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intContractTypeId
		, dblQuantity
	FROM (
		SELECT intRowNo = ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmDate DESC)
			, sh.intCommodityId
			, sh.dtmDate
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, strContractNumber = sh.strContractNoSeq
			, sh.intContractTypeId
			, sh.dblQuantity
		FROM SequenceHistory sh
		WHERE ysnCancelled = 1
			AND intContractTypeId = 2
	) a WHERE a.intRowNo = 1

RETURN

END