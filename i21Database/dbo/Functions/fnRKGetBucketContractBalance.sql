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
	, strTransactionType  NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionReference   NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, intTransactionReferenceDetailId INT
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
	, dblCashPrice NUMERIC(24,10)
	, dblAmount NUMERIC(24,10)
	, intBasisUOMId INT
	, intPriceUOMId INT
	, intContractStatusId INT
	, strContractStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intBookId INT
	, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intQtyCurrencyId INT
	, strQtyCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBasisCurrencyId INT
	, strBasisCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intUserId INT
	, strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strAction  NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	INSERT @returntable	
	SELECT
		 intContractBalanceLogId
		, dtmTransactionDate
		, dtmCreatedDate 
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
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
		, dblCashPrice
		, dblAmount
		, intBasisUOMId
		, intPriceUOMId
		, intContractStatusId
		, strContractStatus
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intQtyCurrencyId
		, strQtyCurrency
		, intBasisCurrencyId
		, strBasisCurrency
		, strNotes
		, intUserId
		, strUserName
		, strAction
	FROM (
		SELECT
			 intContractBalanceLogId 
			, dtmTransactionDate
			, dtmCreatedDate 
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, intTransactionReferenceDetailId
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
			, dblQty = ISNULL(dblQty, 0.000000)
			, intQtyUOMId
			, dblFutures = ISNULL(dblFutures, 0.000000)
			, dblBasis = ISNULL(dblBasis, 0.000000)
			, dblCashPrice = ISNULL(dblFutures, 0.000000) + ISNULL(dblBasis, 0.000000)
			, dblAmount = CASE WHEN cb.intPricingTypeId = 1 THEN ISNULL(dblQty, 0.000000) * (ISNULL(dblFutures, 0.000000) + ISNULL(dblBasis, 0.000000)) ELSE 0.000000 END
			, intBasisUOMId
			, intPriceUOMId
			, cb.intContractStatusId
			, cs.strContractStatus
			, cb.intBookId
			, book.strBook
			, cb.intSubBookId
			, subBook.strSubBook
			, intQtyCurrencyId
			, strQtyCurrency = qCur.strCurrency
			, intBasisCurrencyId
			, strBasisCurrency = qCur.strCurrency
			, cb.strNotes
			, cb.intUserId
			, strUserName = u.strName
			, cb.strAction		
		FROM tblCTContractBalanceLog cb
		INNER JOIN tblICCommodity c ON c.intCommodityId = cb.intCommodityId
		INNER JOIN tblCTPricingType pt ON pt.intPricingTypeId = cb.intPricingTypeId
		INNER JOIN tblICItem Item ON Item.intItemId = cb.intItemId
		INNER JOIN tblICCategory cat ON cat.intCategoryId = Item.intCategoryId
		INNER JOIN tblCTContractType ct ON ct.intContractTypeId = cb.intContractTypeId
		LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cb.intLocationId
		LEFT  JOIN tblSMCurrency qCur ON qCur.intCurrencyID = cb.intQtyCurrencyId
		LEFT  JOIN tblSMCurrency bCur ON bCur.intCurrencyID = cb.intBasisCurrencyId
		LEFT  JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = cb.intFutureMarketId
		LEFT  JOIN tblRKFuturesMonth fMon on fMon.intFutureMonthId = cb.intFutureMonthId
		LEFT  JOIN tblCTBook book ON book.intBookId = cb.intBookId
		LEFT  JOIN tblCTSubBook subBook ON subBook.intSubBookId = cb.intSubBookId
		LEFT JOIN tblEMEntity em ON em.intEntityId = cb.intEntityId
		LEFT JOIN tblEMEntity u ON u.intEntityId = cb.intUserId
		LEFT JOIN tblCTContractStatus cs ON cs.intContractStatusId = cb.intContractStatusId
		WHERE strTransactionType IN ('Contract Balance')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(cb.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(cb.intEntityId, 0))
	) t
RETURN

END
