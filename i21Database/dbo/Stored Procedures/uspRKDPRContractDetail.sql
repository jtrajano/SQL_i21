CREATE PROC uspRKDPRContractDetail 
	@intCommodityId INT = NULL
	,@dtmToDate DATETIME = NULL
AS
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

	
SELECT  
	ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC) intRowNum,
	strCommodityCode,
	intCommodityId,
	intContractHeaderId,
	strContractNumber,
	strLocationName,
	dtmEndDate,
	strFutureMonth,
	dblBalance,
	intUnitMeasureId,
	intPricingTypeId,
	intContractTypeId,
	intCompanyLocationId,
	strContractType,
	strPricingType,
	intCommodityUnitMeasureId,
	intContractDetailId,
	intContractStatusId,
	intEntityId,
	intCurrencyId,
	strType,
	intItemId,
	strItemNo,
	dtmContractDate,
	strEntityName,
	strCustomerContract,
	NULL intFutureMarketId,
	NULL intFutureMonthId
FROM 
vyuRKContractDetail CD
WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate 
AND CD.intContractStatusId <> 6