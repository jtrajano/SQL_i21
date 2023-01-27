CREATE FUNCTION [dbo].[fnRKGetBucketOpenCollateral]
(
	@dtmDate DATETIME,
	@intCommodityId INT,
	@intVendorId INT
)
RETURNS @returntable TABLE
(
	dblTotal NUMERIC(24, 10)
	, intCollateralId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, dtmOpenDate DATETIME
	, dblOriginalQuantity NUMERIC(24, 10)
	, dblRemainingQuantity NUMERIC(24, 10)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityUnitMeasureId INT
	, intCompanyLocationId INT
	, intContractTypeId INT
	, intLocationId INT
	, intEntityId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmEndDate DATETIME
	, ysnIncludeInPriceRiskAndCompanyTitled BIT
	, dtmCreatedDate DATETIME
	, intUserId INT
	, strUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

DECLARE  @tempCollateral TABLE
(
	dblTotal NUMERIC(24, 10)
	, intCollateralId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, intContractDetailId INT
	, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, dtmOpenDate DATETIME
	, dblOriginalQuantity NUMERIC(24, 10)
	, dblRemainingQuantity NUMERIC(24, 10)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCommodityUnitMeasureId INT
	, intCompanyLocationId INT
	, intContractTypeId INT
	, intLocationId INT
	, intEntityId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmEndDate DATETIME
	, ysnIncludeInPriceRiskAndCompanyTitled BIT
	, dtmCreatedDate DATETIME
	, intUserId INT
	, strUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

insert into @tempCollateral
select * 
from  dbo.fnRKGetBucketCollateral(@dtmDate, @intCommodityId, @intVendorId) f


insert into @returntable(
	dblTotal 
	,intCollateralId
	,strLocationName
	,intItemId
	,strItemNo
	,strCategory
	,strEntityName
	,strReceiptNo
	,intContractHeaderId
	,strContractNumber
	,dtmOpenDate
	,dblOriginalQuantity 
	,dblRemainingQuantity 
	,intCommodityUnitMeasureId
	,intCompanyLocationId
	,intContractTypeId
	,intLocationId
	,intEntityId
	,intFutureMarketId
	,intFutureMonthId
	,strFutureMarket
	,strFutureMonth
	,dtmEndDate 
	,ysnIncludeInPriceRiskAndCompanyTitled
)
select
	dblTotal = sum(dblTotal)
	,intCollateralId
	,strLocationName
	,intItemId
	,strItemNo
	,strCategory
	,strEntityName
	,strReceiptNo
	,intContractHeaderId
	,strContractNumber
	,dtmOpenDate
	,dblOriginalQuantity  = sum(dblOriginalQuantity)
	,dblRemainingQuantity = sum(dblRemainingQuantity)
	,intCommodityUnitMeasureId
	,intCompanyLocationId
	,intContractTypeId
	,intLocationId
	,intEntityId
	,intFutureMarketId
	,intFutureMonthId
	,strFutureMarket
	,strFutureMonth
	,dtmEndDate 
	,ysnIncludeInPriceRiskAndCompanyTitled
from @tempCollateral
group by intCollateralId
	,strLocationName
	,intItemId
	,strItemNo
	,strCategory
	,strEntityName
	,strReceiptNo
	,intContractHeaderId
	,strContractNumber
	,dtmOpenDate
	--,dblOriginalQuantity 
	--,dblRemainingQuantity 
	,intCommodityUnitMeasureId
	,intCompanyLocationId
	,intContractTypeId
	,intLocationId
	,intEntityId
	,intFutureMarketId
	,intFutureMonthId
	,strFutureMarket
	,strFutureMonth
	,dtmEndDate 
	,ysnIncludeInPriceRiskAndCompanyTitled

	RETURN
END