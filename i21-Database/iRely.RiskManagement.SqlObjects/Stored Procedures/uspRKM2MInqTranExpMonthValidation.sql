CREATE PROC [dbo].[uspRKM2MInqTranExpMonthValidation] @intM2MBasisId INT = NULL
	,@intFutureSettlementPriceId INT = NULL
	,@intQuantityUOMId INT = NULL
	,@intPriceUOMId INT = NULL
	,@intCurrencyUOMId INT = NULL
	,@dtmTransactionDateUpTo DATETIME = NULL
	,@strRateType NVARCHAR(200) = NULL
	,@intCommodityId INT = NULL
	,@intLocationId INT = NULL
	,@intMarketZoneId INT = NULL
AS
SET @dtmTransactionDateUpTo = left(convert(VARCHAR, @dtmTransactionDateUpTo, 101), 10)

SELECT CD.intContractDetailId
	,CH.intContractHeaderId
	,NULL AS intFutOptTransactionHeaderId
	,CL.strLocationName
	,CY.strCommodityCode
	,TP.strContractType strContractType
	,CH.strContractNumber + '-' + convert(NVARCHAR(10), CD.intContractSeq) strContractNumber
	,EY.strName strEntityName
	,IM.strItemNo
	,PT.strPricingType
	,MO.strFutureMonth
	,FM.strFutMarketName
	,MO.dtmLastTradingDate
	,'Physical' strPhysicalOrFuture
FROM tblCTContractHeader CH
JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
JOIN tblICItem IM ON IM.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
WHERE CH.intCommodityId = @intCommodityId AND CD.dblQuantity > isnull(CD.dblInvoicedQty, 0) AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END AND isnull(CD.intMarketZoneId, 0) = CASE WHEN isnull(@intMarketZoneId, 0) = 0 THEN isnull(CD.intMarketZoneId, 0) ELSE @intMarketZoneId END AND intContractStatusId NOT IN (2, 3, 6) AND dtmContractDate <= @dtmTransactionDateUpTo AND MO.intFutureMonthId IN (
		SELECT intFutureMonthId
		FROM tblRKFuturesMonth
		WHERE isnull(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE()
		)

UNION ALL

SELECT CT.intFutOptTransactionId intContractDetailId
	,NULL AS intContractHeaderId
	,CT.intFutOptTransactionHeaderId
	,CL.strLocationName
	,C.strCommodityCode
	,strBuySell strContractType
	,CT.strInternalTradeNo strContractNumber
	,EY.strName strEntityName
	,'' strItemNo
	,'' strPricingType
	,MO.strFutureMonth
	,FM.strFutMarketName
	,MO.dtmLastTradingDate
	,'Derivative' strPhysicalOrFuture
FROM vyuRKGetOpenContract OC
JOIN tblRKFutOptTransaction CT ON CT.intFutOptTransactionId = OC.intFutOptTransactionId
JOIN tblICCommodity C ON C.intCommodityId = CT.intCommodityId
JOIN tblEMEntity EY ON EY.intEntityId = CT.intEntityId
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CT.intFutureMarketId
JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CT.intFutureMonthId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CT.intLocationId
WHERE CT.intCommodityId = @intCommodityId AND OC.intOpenContract > 0 AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END AND left(convert(VARCHAR, CT.dtmFilledDate, 101), 10) <= @dtmTransactionDateUpTo AND MO.intFutureMonthId IN (
		SELECT intFutureMonthId
		FROM tblRKFuturesMonth
		WHERE isnull(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE()
		)
