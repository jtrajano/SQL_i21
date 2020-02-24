CREATE FUNCTION [dbo].[fnRKGetBucketContractBalance]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	 dtmCreateDate DATETIME
	, dtmTransactionDate DATETIME
	, strTransactionType  NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionReference   NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, strTransactionReferenceNo  NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractDetailId INT
	, intContractHeaderId INT
	, strContractNumber  NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, intContractTypeId INT
	, intEntityId INT
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, intLocationId INT
	, intPricingTypeId INT
	, strPricingType NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, intFutureMonthId INT
	, dtmStartDate DATETIME
	, dtmEndDate DATETIME
	, dblQty NUMERIC(24,10)
	, intQtyUOMId INT
	, dblFutures NUMERIC(24,10)
	, dblBasis NUMERIC(24,10)
	, intBasisUOMId INT
	, intBasisCurrencyId INT
	, intPriceUOMId INT
	, intContractStatusId INT
	, intBookId INT
	, intSubBookId INT
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	INSERT @returntable	
	SELECT
		 dtmTransactionDate
		, dtmCreatedDate 
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, strTransactionReferenceNo
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, intContractSeq
		, intContractTypeId
		, intEntityId
		, intCommodityId
		, strCommodityCode
		, intItemId
		, intLocationId 
		, intPricingTypeId
		, strPricingType
		, intFutureMarketId
		, intFutureMonthId
		, dtmStartDate
		, dtmEndDate
		, dblQty
		, intQtyUOMId
		, dblFutures
		, dblBasis
		, intBasisUOMId
		, intBasisCurrencyId
		, intPriceUOMId
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes
	FROM (
		SELECT 
			 dtmTransactionDate
			, dtmCreatedDate 
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, cb.intCommodityId
			, strCommodityCode
			, intItemId
			, intLocationId 
			, cb.intPricingTypeId
			, strPricingType
			, cb.intFutureMarketId
			, intFutureMonthId
			, dtmStartDate
			, dtmEndDate
			, dblQty
			, intQtyUOMId
			, dblFutures
			, dblBasis
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
		FROM tblCTContractBalanceLog cb
		INNER JOIN tblICCommodity c ON c.intCommodityId = cb.intCommodityId
		INNER JOIN tblCTPricingType pt ON pt.intPricingTypeId = cb.intPricingTypeId
		WHERE strTransactionType IN ('Contract Balance')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t


RETURN

END