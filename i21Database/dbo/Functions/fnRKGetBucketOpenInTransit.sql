CREATE FUNCTION [dbo].[fnRKGetBucketOpenInTransit]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	  strBucketType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmCreateDate DATETIME
	, dtmTransactionDate DATETIME
	, dblTotal NUMERIC(18,6)
	, intEntityId INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionRecordId INT
	, intOrigUOMId INT
	, intContractDetailId INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strContractSeq NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTicketId INT
	, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intCurrencyId INT 
	, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
)
AS
BEGIN


;WITH OutTransit (
	  dblQty
	, intTransactionReferenceId
	--, intContractDetailId
	
) AS (

	SELECT 
		dblQty = SUM(dblQty)
		, intTransactionReferenceId
		--, intContractDetailId
	FROM tblRKDPRInTransitHelperLog
	WHERE dtmDate < = @dtmDate
	AND intCommodityId = @intCommodityId
	AND intInvoiceId IS NOT NULL
	GROUP BY intTransactionReferenceId
		--, intContractDetailId
)


INSERT INTO @returntable
SELECT    t.strBucketType
		, t.dtmCreatedDate
		, t.dtmTransactionDate
		, dblTotal = (t.dblTotal + ISNULL(OT.dblQty, 0))
		, t.intEntityId
		, t.strEntityName
		, t.intLocationId
		, t.strLocationName
		, t.intItemId
		, t.strItemNo
		, t.intCategoryId
		, t.strCategoryCode
		, t.intCommodityId
		, t.strCommodityCode
		, t.strTransactionNumber
		, t.strTransactionType
		, t.intTransactionRecordHeaderId
		, t.intOrigUOMId
		, t.intContractDetailId
		, t.intContractHeaderId
		, t.strContractNumber
		, t.strContractSeq
		, t.intTicketId
		, t.strTicketNumber
		, t.intFutureMarketId
		, t.strFutureMarket
		, t.intFutureMonthId
		, t.strFutureMonth
		, t.strDeliveryDate
		, t.strType
		, t.intCurrencyId
		, t.strCurrency
FROM (
	SELECT
		  c.strBucketType
		, dtmCreatedDate = MAX(c.dtmCreatedDate)
		, c.dtmTransactionDate
		, dblTotal = SUM(c.dblOrigQty)
		, c.intEntityId
		, c.strEntityName
		, c.intLocationId
		, c.strLocationName
		, c.intItemId
		, c.strItemNo
		, c.intCategoryId
		, c.strCategoryCode 
		, c.intCommodityId
		, c.strCommodityCode
		, c.strTransactionNumber
		, c.strTransactionType
		, c.intTransactionRecordHeaderId
		, intOrigUOMId = null
		, c.intContractDetailId --intContractDetailId = null
		, c.intContractHeaderId --intContractHeaderId = null
		, c.strContractNumber --strContractNumber = ''
		, c.strContractSeq --strContractSeq = ''
		, intTicketId = null
		, strTicketNumber = ''
		, intFutureMarketId = null
		, strFutureMarket = ''
		, intFutureMonthId = null
		, strFutureMonth = ''
		, strDeliveryDate = ''--dbo.fnRKFormatDate(c.dtmEndDate, 'MMM yyyy')
		, strType = CASE WHEN strBucketType = 'Sales In-Transit' THEN 'Sales' ELSE 'Purchase' END
		, intCurrencyId =null
		, strCurrency = ''
	from vyuRKGetSummaryLog c
	where strBucketType = 'Sales In-Transit'
	and strTransactionType = 'Inventory Shipment'
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
	AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
	AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	GROUP BY  c.strBucketType
		, c.dtmTransactionDate
		, c.intEntityId
		, c.strEntityName
		, c.intLocationId
		, c.strLocationName
		, c.intItemId
		, c.strItemNo
		, c.intCategoryId
		, c.strCategoryCode
		, c.intCommodityId
		, c.strCommodityCode
		, c.strTransactionNumber
		, c.strTransactionType
		, c.intTransactionRecordHeaderId
		--, c.intOrigUOMId
		, c.intContractDetailId
		, c.intContractHeaderId
		, c.strContractNumber
		, c.strContractSeq
		--, c.intTicketId
		--, c.strTicketNumber
		--, c.intFutureMarketId
		--, c.strFutureMarket
		--, c.intFutureMonthId
		--, c.strFutureMonth
		--, dtmEndDate 
		--, strBucketType 
		--, intCurrencyId
		--, strCurrency
) t
LEFT JOIN OutTransit OT 
	ON OT.intTransactionReferenceId = t.intTransactionRecordHeaderId 
	--AND ( t.intContractDetailId IS NULL AND OT.intContractDetailId IS NULL
	--		OR
	--	 (t.intContractDetailId IS NOT NULL AND OT.intContractDetailId IS NOT NULL
	--		AND OT.intContractDetailId = t.intContractDetailId)
	--	)
WHERE (t.dblTotal + ISNULL(OT.dblQty, 0)) <> 0

RETURN
END