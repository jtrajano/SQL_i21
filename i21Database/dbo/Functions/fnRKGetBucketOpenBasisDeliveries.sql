CREATE FUNCTION [dbo].[fnRKGetBucketOpenBasisDeliveries]
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

DECLARE @tempBD TABLE
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

insert into @tempBD
select *
from  dbo.fnRKGetBucketBasisDeliveries(@dtmDate, @intCommodityId, @intVendorId) f



insert into @returntable(
	strCommodityCode
	, dblQty
	, intCommodityId
	, strLocationName
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategoryCode
	,  intQtyUOMId
	, intLocationId
	, strContractNumber 
	, intContractSeq
	, intContractHeaderId
	, intFutureMarketId
	, intFutureMonthId
	, strFutureMarket
	, strFutureMonth
	, dtmEndDate 
	, strContractType
	, strCurrency
	, strEntityName
	, intContractDetailId

)
select * from (
	select
		 strCommodityCode
		, dblQty = ROUND(sum(dblQty),2)
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategoryCode
		--, dtmTransactionDate
		,  intQtyUOMId
		, intLocationId
		, strContractNumber 
		, intContractSeq
		, intContractHeaderId
		--, intTransactionReferenceId
		--, intTransactionReferenceDetailId
		--, strTransactionReferenceNo
		--, strTransactionReference
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMarket
		, strFutureMonth
		, dtmEndDate 
		, strContractType
		, strCurrency
		, strEntityName
		, intContractDetailId
	from @tempBD
	group by strCommodityCode
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategoryCode
		--, dtmTransactionDate
		,  intQtyUOMId
		, intLocationId
		, strContractNumber 
		, intContractSeq
		, intContractHeaderId
		--, intTransactionReferenceId
		--, intTransactionReferenceDetailId
		--, strTransactionReferenceNo
		--, strTransactionReference
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMarket
		, strFutureMonth
		, dtmEndDate 
		, strContractType
		, strCurrency
		, strEntityName
		, intContractDetailId
	having ROUND(sum(dblQty),2) <> 0
) t
where dblQty <> 0


RETURN

END