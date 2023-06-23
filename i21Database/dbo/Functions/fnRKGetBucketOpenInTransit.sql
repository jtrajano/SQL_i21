CREATE FUNCTION [dbo].[fnRKGetBucketOpenInTransit]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS  @returntable TABLE
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

DECLARE  @tmpOpenInTransit TABLE
(
	dblTotal NUMERIC(18,6)
	, intTransactionRecordHeaderId INT
	, intContractDetailId INT
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
)


;WITH OutTransit (
	  dblQty
	, intTransactionReferenceId
	, intContractDetailId
	, strTransactionType
) AS (

	SELECT 
		dblQty = ROUND(SUM(dblQty),2)
		, intTransactionReferenceId
		, intContractDetailId
		, strTransactionType = strTransactionType COLLATE Latin1_General_CI_AS
	FROM tblRKDPRInTransitHelperLog
	WHERE dtmDate < = @dtmDate
	AND intCommodityId = @intCommodityId
	GROUP BY intTransactionReferenceId, intContractDetailId, strTransactionType
)



insert into @tmpOpenInTransit
select dblTotal = (t.dblTotal + ISNULL(OT.dblQty, 0)), intTransactionRecordHeaderId, t.intContractDetailId, t.strTransactionType from (
	select 
		dblTotal = ROUND(SUM(SL.dblOrigQty),2)
		, intTransactionRecordHeaderId
		, intContractDetailId
		, strTransactionType
	from vyuRKGetSummaryLog SL
	WHERE strBucketType = 'Sales In-Transit'
		and strTransactionType IN('Inventory Shipment','Outbound Shipment')
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), SL.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
		AND ISNULL(SL.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(SL.intCommodityId, 0)) 
		AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	GROUP BY intTransactionRecordHeaderId, strTransactionNumber, intContractDetailId, strTransactionType
) t
LEFT JOIN OutTransit OT 
	ON OT.intTransactionReferenceId = t.intTransactionRecordHeaderId and OT.intContractDetailId = t.intContractDetailId AND OT.strTransactionType = t.strTransactionType
WHERE (t.dblTotal + ISNULL(OT.dblQty, 0)) <> 0



INSERT INTO @returntable
	SELECT  
		  c.strBucketType
		, dtmCreatedDate = MAX(c.dtmCreatedDate)
		, dtmTransactionDate = MAX(c.dtmTransactionDate)
		, dblTotal = SUM(o.dblTotal)
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
		, strDeliveryDate = dbo.fnRKFormatDate(MAX(c.dtmEndDate), 'MMM yyyy')
		, strType = CASE WHEN strBucketType = 'Sales In-Transit' THEN 'Sales' ELSE 'Purchase' END
		, intCurrencyId
		, strCurrency
	from vyuRKGetSummaryLog c
	inner join @tmpOpenInTransit o on o.intTransactionRecordHeaderId = c.intTransactionRecordHeaderId and  o.strTransactionType = c.strTransactionType and o.intContractDetailId = c.intContractDetailId
	where strBucketType = 'Sales In-Transit'
	AND c.strTransactionType IN('Inventory Shipment','Outbound Shipment')
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmDate)
	AND ISNULL(c.intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(c.intCommodityId, 0)) 
	AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
	group by  c.strBucketType
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
		, intCurrencyId
		, strCurrency


RETURN

END