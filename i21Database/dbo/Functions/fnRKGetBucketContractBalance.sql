CREATE FUNCTION [dbo].[fnRKGetBucketContractBalance]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	intContractBalanceLogId INT
	 , dtmTransactionDate DATETIME
	, dtmCreateDate DATETIME
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, strTransactionReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractDetailId INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, intContractTypeId INT
	, strContractType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intEntityId INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intPricingTypeId INT
	, strPricingType NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmStartDate DATETIME
	, dtmEndDate DATETIME
	, dblQty NUMERIC(24,10)
	, intQtyUOMId INT
	, dblFutures NUMERIC(24,10)
	, dblBasis NUMERIC(24,10)
	, intBasisUOMId INT
	, intPriceUOMId INT
	, intContractStatusId INT
	, intBookId INT
	, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intQtyCurrencyId INT
	, strQtyCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBasisCurrencyId INT
	, strBasisCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	INSERT @returntable	
	SELECT intContractBalanceLogId
		 , dtmTransactionDate
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
		, strCategory
		, intLocationId
		, strLocationName
		, intPricingTypeId
		, strPricingType
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, dtmStartDate
		, dtmEndDate
		, dblQty
		, intQtyUOMId
		, dblFutures
		, dblBasis
		, intBasisUOMId
		, intPriceUOMId
		, intContractStatusId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intQtyCurrencyId
		, strQtyCurrency
		, intBasisCurrencyId
		, strBasisCurrency
		, strNotes
	FROM (
		SELECT intContractBalanceLogId 
			, dtmTransactionDate
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
			, cb.intItemId
			, strItemNo
			, cat.intCategoryId
			, strCategory = cat.strCategoryCode
			, intLocationId
			, cl.strLocationName
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
			, intPriceUOMId
			, intContractStatusId
			, cb.intBookId
			, book.strBook
			, cb.intSubBookId
			, subBook.strSubBook
			, intQtyCurrencyId
			, strQtyCurrency = qCur.strCurrency
			, intBasisCurrencyId
			, strBasisCurrency = qCur.strCurrency
			, cb.strNotes
		FROM tblCTContractBalanceLog cb
		INNER JOIN tblICCommodity c ON c.intCommodityId = cb.intCommodityId
		INNER JOIN tblCTPricingType pt ON pt.intPricingTypeId = cb.intPricingTypeId
		INNER JOIN tblICItem Item ON Item.intItemId = cb.intItemId
		INNER JOIN tblICCategory cat ON cat.intCategoryId = Item.intCategoryId
		INNER JOIN tblCTContractType ct ON ct.intContractTypeId = cb.intContractTypeId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cb.intLocationId
		INNER JOIN tblSMCurrency qCur ON qCur.intCurrencyID = cb.intQtyCurrencyId
		INNER JOIN tblSMCurrency bCur ON bCur.intCurrencyID = cb.intBasisCurrencyId
		INNER JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = cb.intFutureMarketId
		INNER JOIN tblRKFuturesMonth fMon on fMon.intFutureMonthId = cb.intFutureMonthId
		INNER JOIN tblCTBook book ON book.intBookId = cb.intBookId
		INNER JOIN tblCTSubBook subBook ON subBook.intSubBookId = cb.intSubBookId
		INNER JOIN tblEMEntity em ON em.intEntityId = cb.intEntityId
		WHERE strTransactionType IN ('Contract Balance')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(cb.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(cb.intEntityId, 0))
	) t
RETURN

END