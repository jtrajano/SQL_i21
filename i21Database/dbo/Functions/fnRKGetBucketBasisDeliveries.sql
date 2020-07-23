CREATE FUNCTION [dbo].[fnRKGetBucketBasisDeliveries]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	dtmTransactionDate DATETIME
	,dtmCreateDate DATETIME
	, strTransactionType  NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionReference   NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, intTransactionReferenceDetailId INT
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
	, intUserId INT
	, strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strAction  NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	DECLARE @OpenBasisContract TABLE
	(
		intContractHeaderId		INT,
		intContractDetailId		INT,
		intSequenceUnitMeasureId INT,
		strSequenceUnitMeasure nvarchar(100),
		intHeaderUnitMeasureId INT,
		strHeaderUnitMeasure NVARCHAR(100)
	)

	--INSERT INTO @OpenBasisContract	(intContractDetailId, intContractHeaderId,intSequenceUnitMeasureId,strSequenceUnitMeasure,intHeaderUnitMeasureId,strHeaderUnitMeasure)
	--SELECT CD.intContractDetailId,
	--	CH.intContractHeaderId,
	--	intSequenceUnitMeasureId = CDUM.intUnitMeasureId,
	--	strSequenceUnitMeasure = CDUM.strUnitMeasure,
	--	intHeaderUnitMeasureId = CHUM.intUnitMeasureId,
	--	strHeaderUnitMeasure = CHUM.strUnitMeasure
	--FROM tblCTContractHeader CH
	--INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	--LEFT JOIN tblICUnitMeasure CDUM ON CDUM.intUnitMeasureId = CD.intUnitMeasureId
	--LEFT JOIN tblICCommodityUnitMeasure CHCUM ON CHCUM.intCommodityId = CH.intCommodityId AND CHCUM.ysnStockUnit = 1
	--LEFT JOIN tblICUnitMeasure CHUM ON CHUM.intUnitMeasureId = CHCUM.intUnitMeasureId
	--LEFT JOIN 
	--(
	--	SELECT intRowId = ROW_NUMBER() OVER(PARTITION BY SH.intContractHeaderId, SH.intContractDetailId ORDER BY SH.dtmHistoryCreated DESC)
	--		, SH.intPricingTypeId
	--		, SH.intContractHeaderId
	--		, SH.intContractDetailId
	--		, dtmHistoryCreated
	--		, intContractStatusId
	--	FROM tblCTSequenceHistory SH
	--		INNER JOIN tblCTContractHeader ET
	--			ON SH.intContractHeaderId = ET.intContractHeaderId
	--	WHERE dtmHistoryCreated < DATEADD(DAY, 1, @dtmDate)
	--) tbl ON tbl.intContractDetailId = CD.intContractDetailId
	--	AND tbl.intContractHeaderId = CD.intContractHeaderId
	--	AND tbl.intRowId = 1
	--WHERE tbl.intPricingTypeId = 2
	--AND tbl.intContractStatusId = 1

	INSERT @returntable	
	SELECT
		 dtmTransactionDate
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
		, intUserId
		, strUserName
		, strAction
	FROM (
		SELECT 
			 dtmTransactionDate
			, dtmCreatedDate 
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, intTransactionReferenceDetailId
			, strTransactionReferenceNo
			, cb.intContractDetailId
			, cb.intContractHeaderId
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
			, cb.intUserId
			, strUserName = u.strName
			, cb.strAction
		FROM tblCTContractBalanceLog cb
		--INNER JOIN @OpenBasisContract obc ON cb.intContractDetailId = obc.intContractDetailId
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
		LEFT JOIN tblEMEntity u ON u.intEntityId = cb.intUserId
		WHERE strTransactionType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')
			AND cb.dtmCreatedDate <= DATEADD(MI,(DATEDIFF(MI, SYSDATETIME(),SYSUTCDATETIME())), DATEADD(MI,1439,CONVERT(DATETIME, @dtmDate)))
			-- AND CONVERT(DATETIME, CONVERT(VARCHAR(10), cb.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(cb.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(cb.intEntityId, 0))
	) t


RETURN

END