CREATE FUNCTION [dbo].[fnRKGetBucketBasisDeliveries]
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
	, strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intEntityId INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intPricingTypeId INT
	, strPricingType NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, dblQty NUMERIC(24,10)
	, intQtyUOMId INT
	, intContractStatusId INT
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmEndDate DATETIME
	, intCurrencyId INT
	, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
		, strContractType
		, intEntityId
		, strEntityName
		, intCommodityId
		, strCommodityCode
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategoryCode
		, intLocationId 
		, strLocationName
		, intPricingTypeId
		, strPricingType
		, dblQty
		, intQtyUOMId
		, intContractStatusId
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, dtmEndDate
		, intCurrencyId
		, strCurrency
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
			, cb.intContractTypeId
			, strContractType
			, cb.intEntityId
			, strEntityName = em.strName
			, cb.intCommodityId
			, strCommodityCode
			, i.intItemId
			, strItemNo
			, i.intCategoryId
			, cat.strCategoryCode
			, intLocationId 
			, strLocationName
			, cb.intPricingTypeId
			, strPricingType
			, cb.intFutureMarketId
			, strFutureMarket = fMar.strFutMarketName
			, cb.intFutureMonthId
			, fMon.strFutureMonth
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
			, intCurrencyId = cb.intQtyCurrencyId
			, cur.strCurrency
			, intBookId
			, intSubBookId
			, cb.strNotes
		FROM tblCTContractBalanceLog cb
		INNER JOIN tblICCommodity c ON c.intCommodityId = cb.intCommodityId
		INNER JOIN tblICItem i ON i.intItemId = cb.intItemId
		INNER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
		INNER JOIN tblCTPricingType pt ON pt.intPricingTypeId = cb.intPricingTypeId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cb.intLocationId
		INNER JOIN tblCTContractType ct ON ct.intContractTypeId = cb.intContractTypeId
		LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = cb.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = cb.intFutureMonthId
		LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = cb.intQtyCurrencyId
		LEFT JOIN tblEMEntity em ON em.intEntityId = cb.intEntityId
		WHERE strTransactionType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(cb.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(cb.intEntityId, 0))
	) t


RETURN

END