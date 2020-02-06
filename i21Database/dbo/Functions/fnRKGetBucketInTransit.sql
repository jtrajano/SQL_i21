CREATE FUNCTION [dbo].[fnRKGetBucketInTransit]
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
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionRecordId INT
	, intOrigUOMId INT
)
AS
BEGIN

	INSERT @returntable	
	SELECT
		 dtmCreatedDate
		,dtmTransactionDate  
		,dblTotal
		,intEntityId
		,strEntityName
		,intLocationId
		,strLocationName
		,intItemId
		,strItemNo
		,intCommodityId
		,strCommodityCode
		,strTransactionNumber
		,strTransactionType
		,intTransactionRecordId
		,intOrigUOMId
	FROM (
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intTransactionRecordId ORDER BY c.intSummaryLogId DESC)
			,dtmCreatedDate
			,dtmTransactionDate
			,dblTotal = c.dblOrigQty
			,intEntityId
			,strEntityName
			,intLocationId
			,strLocationName
			,intItemId
			,strItemNo
			,intCommodityId
			,strCommodityCode
			,strTransactionNumber
			,strTransactionType
			,intTransactionRecordId
			,intOrigUOMId
		FROM vyuRKGetSummaryLog c
		WHERE strTransactionType IN ('Sales In-Transit', 'Purchase In-Transit') 
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t WHERE intRowNum = 1


RETURN

END