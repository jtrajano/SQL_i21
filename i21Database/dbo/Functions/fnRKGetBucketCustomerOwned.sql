CREATE FUNCTION [dbo].[fnRKGetBucketCustomerOwned]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	  intSummaryLogId INT
	, dtmCreatedDate DATETIME
	, dtmTransactionDate DATETIME
	, strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strStorageTypeCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
	, dblTotal NUMERIC(18,6)
	, intEntityId INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT 
	, strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionRecordId INT
	, intTransactionRecordHeaderId INT
	, strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intOrigUOMId INT
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, ysnReceiptedStorage BIT
	, intTypeId INT
	, strStorageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intDeliverySheetId INT
	, strTicketStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strOwnedPhysicalStock NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strStorageTypeDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, ysnActive BIT
	, ysnExternal BIT
	, intTicketId INT
)
AS
BEGIN
	INSERT @returntable	
	SELECT intSummaryLogId 
		, dtmCreatedDate
		, dtmTransactionDate  
		, strDistributionType
		, strStorageTypeCode
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
		, strContractNumber
		, intContractHeaderId
		, intOrigUOMId
		, strNotes
		, ysnReceiptedStorage
		, intTypeId
		, strStorageType
		, intDeliverySheetId
		, strTicketStatus
		, strOwnedPhysicalStock
		, strStorageTypeDescription
		, ysnActive
		, ysnExternal
		, intTicketId
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY sl.intTransactionRecordId, sl.intTransactionRecordHeaderId, sl.intContractHeaderId, sl.strInOut, sl.ysnNegate, sl.strTransactionType, sl.strTransactionNumber ORDER BY sl.intSummaryLogId DESC)
			, sl.intSummaryLogId
			, dtmCreatedDate
			, dtmTransactionDate
			, strDistributionType
			, strStorageTypeCode
			, dblTotal = sl.dblOrigQty
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
			, strContractNumber
			, intContractHeaderId
			, intOrigUOMId
			, strNotes
			, ysnReceiptedStorage
			, intTypeId
			, strStorageType
			, intDeliverySheetId
			, strTicketStatus
			, strOwnedPhysicalStock
			, strStorageTypeDescription
			, ysnActive
			, ysnExternal = ISNULL(ysnExternal, 0)
			, intTicketId
		FROM vyuRKGetSummaryLog sl
		WHERE strBucketType = 'Customer Owned'
			--AND sl.dtmCreatedDate <= DATEADD(MI,(DATEDIFF(MI, SYSDATETIME(),SYSUTCDATETIME())), DATEADD(MI,1439,CONVERT(DATETIME, @dtmDate)))
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), sl.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
			AND ISNULL(sl.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(sl.intCommodityId, 0)) 
			AND ISNULL(sl.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(sl.intEntityId, 0))
	) t --WHERE intRowNum = 1
	
	RETURN
END