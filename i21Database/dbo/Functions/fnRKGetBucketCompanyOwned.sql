CREATE FUNCTION [dbo].[fnRKGetBucketCompanyOwned]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	 dtmCreateDate DATETIME
	, dtmTransactionDate DATETIME
	, dblTotal NUMERIC(18,6)
	, intEntityId INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionRecordId INT
	, intTransactionRecordHeaderId INT
	, intOrigUOMId INT
	, intTicketId INT
	, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmEndDate DATETIME
	, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intCurrencyId INT
	, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	INSERT @returntable	
	SELECT dtmCreatedDate
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
		, intTransactionRecordHeaderId
		, intOrigUOMId
		, intTicketId
		, strTicketNumber
		, strDistributionType
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, dtmEndDate
		, strFutureMonth
		, intCurrencyId
		, strCurrency
	FROM (
		SELECT --intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId, c.intTransactionRecordHeaderId, c.intContractHeaderId, c.strInOut, c.ysnNegate, c.strTransactionType, c.strTransactionNumber ORDER BY c.intSummaryLogId DESC)
			 dtmCreatedDate
			, dtmTransactionDate
			, dblTotal = c.dblOrigQty
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
			, intTransactionRecordHeaderId
			, intOrigUOMId
			, intTicketId
			, strTicketNumber
			, strDistributionType
			, intContractHeaderId
			, intContractDetailId
			, strContractNumber
			, dtmEndDate
			, strFutureMonth
			, intCurrencyId
			, strCurrency
		FROM vyuRKGetSummaryLog c
		WHERE strBucketType = 'Company Owned'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t --WHERE intRowNum = 1


RETURN

END