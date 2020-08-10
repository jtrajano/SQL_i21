CREATE FUNCTION [dbo].[fnRKGetBucketInTransit]
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

	INSERT @returntable	
	SELECT strBucketType
		, dtmCreatedDate
		, dtmTransactionDate  
		, dblTotal
		, intEntityId
		, strEntityName
		, intLocationId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategoryCode
		, intCommodityId
		, strCommodityCode
		, strTransactionNumber
		, strTransactionType
		, intTransactionRecordId
		, intOrigUOMId
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, strContractSeq
		, intTicketId
		, strTicketNumber
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, strDeliveryDate
		, strType
		, intCurrencyId
		, strCurrency
	FROM (
		SELECT --intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId, c.strBucketType, c.strTransactionType, c.strTransactionNumber, c.strInOut ORDER BY c.intSummaryLogId DESC)
			 c.strBucketType
			, c.dtmCreatedDate
			, c.dtmTransactionDate
			, dblTotal = c.dblOrigQty
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
			, c.intTransactionRecordId
			, c.intOrigUOMId
			, c.intContractDetailId
			, c.intContractHeaderId
			, c.strContractNumber
			, c.strContractSeq
			, c.intTicketId
			, c.strTicketNumber
			, c.intFutureMarketId
			, c.strFutureMarket
			, c.intFutureMonthId
			, c.strFutureMonth
			, strDeliveryDate = dbo.fnRKFormatDate(c.dtmEndDate, 'MMM yyyy')
			, strType = CASE WHEN strBucketType = 'Sales In-Transit' THEN 'Sales' ELSE 'Purchase' END
			, intCurrencyId
			, strCurrency
		FROM vyuRKGetSummaryLog c
		WHERE strBucketType IN ('Sales In-Transit', 'Purchase In-Transit') 
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t --WHERE intRowNum = 1

RETURN

END