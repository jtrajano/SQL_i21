CREATE FUNCTION [dbo].[fnRKGetBucketDropshipInTransit]
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
	, strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOrigUOMId INT
	, intTicketId INT
	, strTicketNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strUserName NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, strAction NVARCHAR(250) COLLATE Latin1_General_CI_AS
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
		,strDistributionType
		,intOrigUOMId
		,intTicketId
		,strTicketNumber
		,intContractHeaderId
		,intContractDetailId
		,strContractNumber
		,strUserName
		,strAction 
	FROM (
		
		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intTransactionRecordId, intContractHeaderId, intContractDetailId ORDER BY intSummaryLogId DESC)
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
			,strDistributionType
			,intOrigUOMId
			,intTicketId
			,strTicketNumber
			,intContractHeaderId
			,intContractDetailId
			,strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR(10),intContractSeq)
			,strUserName
			,strAction
		FROM vyuRKGetSummaryLog c
		WHERE strBucketType = 'Dropship In-Transit'
		--AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmCreatedDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
		AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
		AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	) t WHERE intRowNum = 1 AND strAction IN( 'Distribute Direct In','Distribute Direct Out')


RETURN

END