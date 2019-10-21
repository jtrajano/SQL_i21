CREATE PROC uspRKDPRContractDetail
	@intCommodityId INT = NULL
	, @dtmToDate DATETIME = NULL

AS

SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC)
	, strCommodityCode
	, intCommodityId
	, intContractHeaderId
	, strContractNumber
	, strLocationName
	, dtmEndDate
	, strFutureMonth
	, dblBalance
	, intUnitMeasureId
	, intPricingTypeId
	, intContractTypeId
	, intCompanyLocationId
	, strContractType
	, strPricingType
	, intCommodityUnitMeasureId
	, intContractDetailId
	, intContractStatusId
	, intEntityId
	, intCurrencyId
	, strType
	, intItemId
	, strItemNo
	, dtmContractDate
	, strEntityName
	, strCustomerContract
	, intFutureMarketId
	, intFutureMonthId
	, intCategoryId
	, strCategory
	, strFutMarketName
FROM vyuRKContractDetail CD
WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
	AND CD.intContractStatusId <> 6