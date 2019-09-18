CREATE PROCEDURE uspRKM2MInquiryTransaction
	@intM2MBasisId INT = NULL
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL

AS

BEGIN

	DECLARE @ysnIncludeBasisDifferentialsInResults BIT
	DECLARE @dtmPriceDate DATETIME    
	DECLARE @dtmSettlemntPriceDate DATETIME  
	DECLARE @strLocationName NVARCHAR(200)
	DECLARE @ysnIncludeInventoryM2M BIT
	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
	DECLARE @ysnCanadianCustomer BIT
	DECLARE @intDefaultCurrencyId int
	DECLARE @intMarkExpiredMonthPositionId INT
	DECLARE @ysnIncludeDerivatives BIT
	DECLARE @ysnIncludeInTransitM2M BIT

SELECT @dtmPriceDate = dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId = @intM2MBasisId

SELECT TOP 1 @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
	, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
	, @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M
	, @ysnCanadianCustomer = ISNULL(ysnCanadianCustomer, 0)
	, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
	, @ysnIncludeDerivatives = ysnIncludeDerivatives
	, @ysnIncludeInTransitM2M = ysnIncludeInTransitM2M
FROM tblRKCompanyPreference

SELECT TOP 1 @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId
SELECT TOP 1 @strLocationName = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

SET @dtmTransactionDateUpTo = LEFT(CONVERT(VARCHAR, @dtmTransactionDateUpTo, 101), 10)

IF (@intCommodityId = 0) SET @intCommodityId = NULL
IF (@intLocationId = 0) SET @intLocationId = NULL
IF (@intMarketZoneId = 0) SET @intMarketZoneId = NULL

DECLARE @tblFinalDetail TABLE (intContractHeaderId int
	, intContractDetailId int
	, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intEntityId INT
	, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, intItemLocationId INT
	, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intOriginId INT
	, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intPricingTypeId INT
	, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblFutures NUMERIC(24, 10)
	, dblCash NUMERIC(24, 10)
	, dblCosts NUMERIC(24, 10)
	, dblMarketBasis1 NUMERIC(24, 10)
	, dblMarketBasisUOM NUMERIC(24, 10)
	, intMarketBasisCurrencyId INT
	, dblContractRatio NUMERIC(24, 10)
	, dblContractBasis NUMERIC(24, 10)
	, dblDummyContractBasis NUMERIC(24, 10)
	, dblFuturePrice1 NUMERIC(24, 10)
	, intFuturePriceCurrencyId INT
	, dblFuturesClosingPrice1 NUMERIC(24, 10)
	, intContractTypeId INT
	, intConcurrencyId INT
	, dblOpenQty NUMERIC(24, 10)
	, dblRate NUMERIC(24, 10)
	, intCommodityUnitMeasureId INT
	, intQuantityUOMId INT
	, intPriceUOMId INT
	, intCurrencyId INT
	, PriceSourceUOMId INT
	, dblltemPrice NUMERIC(24, 10)
	, dblMarketBasis NUMERIC(24, 10)
	, dblMarketRatio NUMERIC(24, 10)
	, dblCashPrice NUMERIC(24, 10)
	, dblAdjustedContractPrice NUMERIC(24, 10)
	, dblFuturesClosingPrice NUMERIC(24, 10)
	, dblFuturePrice NUMERIC(24, 10)
	, dblMarketPrice NUMERIC(24, 10)
	, dblResult NUMERIC(24, 10)
	, dblResultBasis1 NUMERIC(24, 10)
	, dblMarketFuturesResult NUMERIC(24, 10)
	, dblResultCash1 NUMERIC(24, 10)
	, dblContractPrice NUMERIC(24, 10)
	, dblResultCash NUMERIC(24, 10)
	, dblResultBasis NUMERIC(24, 10)
	, dblShipQty NUMERIC(24,10)
	, ysnSubCurrency BIT
	, intMainCurrencyId INT
	, intCent INT
	, dtmPlannedAvailabilityDate DATETIME
	, dblPricedQty NUMERIC(24, 10)
	, dblUnPricedQty NUMERIC(24, 10)
	, dblPricedAmount NUMERIC(24, 10)
	, intMarketZoneId INT
	, intCompanyLocationId INT
	, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblNotLotTrackedPrice NUMERIC(24, 10)
	, dblInvFuturePrice NUMERIC(24, 10)
	, dblInvMarketBasis NUMERIC(24, 10)
	, dblNoOfLots NUMERIC(24,10)
	, dblLotsFixed NUMERIC(24,10)
	, dblPriceWORollArb NUMERIC(24,10)
	, intSpreadMonthId INT
	, strSpreadMonth NVARCHAR(50)
	, dblSpreadMonthPrice NUMERIC(24, 20)
	, dblSpread NUMERIC(24, 10)
	, ysnExpired BIT)

DECLARE @GetContractDetailView TABLE (intCommodityUnitMeasureId INT
	, strLocationName NVARCHAR(100)
	, strCommodityDescription NVARCHAR(100)
	, intMainCurrencyId INT
	, intCent INT
	, dblDetailQuantity NUMERIC(24,10)
	, intContractTypeId INT
	, intContractHeaderId INT
	, strContractType NVARCHAR(100)
	, strContractNumber NVARCHAR(100)
	, strEntityName NVARCHAR(100)
	, intEntityId INT
	, strCommodityCode NVARCHAR(100)
	, intCommodityId INT
	, strPosition NVARCHAR(100)
	, dtmContractDate DATETIME
	, intContractBasisId INT
	, intContractSeq INT
	, dtmStartDate DATETIME
	, dtmEndDate DATETIME
	, intPricingTypeId INT
	, dblRatio NUMERIC(24,10)
	, dblBasis NUMERIC(24,10)
	, dblFutures NUMERIC(24,10)
	, intContractStatusId INT
	, dblCashPrice NUMERIC(24,10)
	, intContractDetailId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, intItemId INT
	, dblBalance NUMERIC(24,10)
	, intCurrencyId INT
	, dblRate NUMERIC(24,10)
	, intMarketZoneId INT
	, dtmPlannedAvailabilityDate DATETIME
	, strItemNo NVARCHAR(100)
	, strPricingType NVARCHAR(100)
	, intPriceUnitMeasureId INT
	, intUnitMeasureId INT
	, strFutureMonth NVARCHAR(100)
	, strFutMarketName NVARCHAR(100)
	, intOriginId INT
	, strLotTracking NVARCHAR(100)
	, dblNoOfLots NUMERIC(24,10)
	, dblLotsFixed NUMERIC(24,10)
	, dblPriceWORollArb NUMERIC(24,10)
	, dblHeaderNoOfLots NUMERIC(24,10)
	, ysnSubCurrency BIT
	, intCompanyLocationId INT
	, ysnExpired BIT
	, strPricingStatus NVARCHAR(100)
	, strOrgin NVARCHAR(100)
	, ysnMultiplePriceFixation BIT
	, intMarketUOMId INT
	, intMarketCurrencyId INT
	, dblInvoicedQuantity NUMERIC(24,10)
	, dblPricedQty NUMERIC(24,10)
	, dblUnPricedQty NUMERIC(24,10)
	, dblPricedAmount NUMERIC(24,10)
	, strMarketZoneCode NVARCHAR(200))

--There is an error "An INSERT EXEC statement cannot be nested." that is why we cannot directly call the uspRKDPRContractDetail and insert
DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
	, strCommodityCode NVARCHAR(100)
	, intCommodityId INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(100)
	, strLocationName NVARCHAR(100)
	, dtmEndDate DATETIME
	, dblBalance NUMERIC(24,10)
	, dblFutures NUMERIC(24,10)
	, dblBasis NUMERIC(24,10)
	, dblCash NUMERIC(24,10)
	, intUnitMeasureId INT
	, intPricingTypeId INT
	, intContractTypeId INT
	, intCompanyLocationId INT
	, strContractType NVARCHAR(100)
	, strPricingType NVARCHAR(100)
	, intCommodityUnitMeasureId INT
	, intContractDetailId INT
	, intContractStatusId INT
	, intEntityId INT
	, intCurrencyId INT
	, strType NVARCHAR(100)
	, intItemId INT
	, strItemNo NVARCHAR(100)
	, dtmContractDate DATETIME
	, strEntityName NVARCHAR(100)
	, strCustomerContract NVARCHAR(100)
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strPricingStatus NVARCHAR(50))

INSERT INTO @tblGetOpenContractDetail (intRowNum
	, strCommodityCode
	, intCommodityId
	, intContractHeaderId
	, strContractNumber
	, strLocationName
	, dtmEndDate
	, dblBalance
	, dblFutures
	, dblBasis
	, dblCash
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
	, strPricingStatus)
SELECT 
	ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC) intRowNum
	,strCommodityCode
	,intCommodityId
	,intContractHeaderId
	,strContract
	,strLocationName
	,dtmSeqEndDate
	,dblQuantity
	,dblFutures
	,dblBasis
	,dblCashPrice
	,intUnitMeasureId
	,intPricingTypeId
	,intContractTypeId
	,intCompanyLocationId
	,strContractType
	,strPricingTypeDesc
	,intCommodityUnitMeasureId = null
	,intContractDetailId
	,intContractStatusId
	,intEntityId
	,intCurrencyId
	,strType = strContractType + ' ' + strPricingTypeDesc
	,intItemId
	,strItemNo
	,dtmContractDate
	,strCustomer
	,strCustomerContract = ''
	,intFutureMarketId
	,intFutureMonthId
	,strPricingStatus
FROM tblCTContractBalance where CONVERT(DATETIME,CONVERT(VARCHAR, dtmEndDate, 101),101) = @dtmTransactionDateUpTo and intCommodityId = @intCommodityId

SELECT *
INTO #tblPriceFixationDetail
FROM (
	SELECT CD.intContractHeaderId
		, CD.intContractDetailId
		, PF.intPriceFixationId
		, PF.dblFinalPrice
		, PF.dblLotsFixed
		, PF.[dblTotalLots]
		, PF.dblPriceWORollArb
		, FD.dblQuantity
		, CASE WHEN CD.intPricingTypeId = 2 OR CD.intPricingTypeId = 8
					THEN CASE WHEN ISNULL(PF.[dblTotalLots],0) = 0 THEN 'Unpriced'
							ELSE CASE WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Fully Priced'
									WHEN ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Unpriced'
										ELSE 'Partially Priced' END
						END
				WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END strPricingStatus
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD on CD.intContractHeaderId=CH.intContractHeaderId and ISNULL(CH.ysnMultiplePriceFixation,0) = 0 and intContractStatusId NOT IN (2, 3, 6)
	LEFT JOIN tblCTPriceFixation PF on CD.intContractDetailId=PF.intContractDetailId
	LEFT JOIN (SELECT intPriceFixationId
					, SUM(dblQuantity) AS  dblQuantity
				FROM tblCTPriceFixationDetail
				GROUP BY intPriceFixationId) FD ON FD.intPriceFixationId = PF.intPriceFixationId
	
	UNION ALL SELECT CH.intContractHeaderId
		, CD.intContractDetailId
		, PF.intPriceFixationId
		, PF.dblFinalPrice
		, PF.dblLotsFixed
		, PF.[dblTotalLots]
		, PF.dblPriceWORollArb
		, FD.dblQuantity
		, CASE WHEN CD.intPricingTypeId = 2 OR CD.intPricingTypeId = 8 THEN
				CASE WHEN ISNULL(PF.[dblTotalLots],0) = 0 THEN 'Unpriced'
					ELSE CASE WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Fully Priced'
							WHEN ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' END END
				WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END strPricingStatus
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD on CD.intContractHeaderId=CH.intContractHeaderId and ISNULL(CH.ysnMultiplePriceFixation,0) = 1 and intContractStatusId NOT IN (2, 3, 6)
	LEFT JOIN tblCTPriceFixation PF on CH.intContractHeaderId=PF.intContractHeaderId
	LEFT JOIN (SELECT intPriceFixationId
					, SUM(dblQuantity) AS dblQuantity
				FROM tblCTPriceFixationDetail
				GROUP BY intPriceFixationId) FD ON FD.intPriceFixationId = PF.intPriceFixationId
) t

INSERT INTO @GetContractDetailView (intCommodityUnitMeasureId
	, strLocationName
	, strCommodityDescription
	, intMainCurrencyId
	, intCent
	, dblDetailQuantity
	, intContractTypeId
	, intContractHeaderId
	, strContractType
	, strContractNumber
	, strEntityName
	, intEntityId
	, strCommodityCode
	, intCommodityId
	, strPosition
	, dtmContractDate
	, intContractBasisId
	, intContractSeq
	, dtmStartDate
	, dtmEndDate
	, intPricingTypeId
	, dblRatio
	, dblBasis
	, dblFutures
	, intContractStatusId
	, dblCashPrice
	, intContractDetailId
	, intFutureMarketId
	, intFutureMonthId
	, intItemId
	, dblBalance
	, intCurrencyId
	, dblRate
	, intMarketZoneId
	, dtmPlannedAvailabilityDate
	, strItemNo
	, strPricingType
	, intPriceUnitMeasureId
	, intUnitMeasureId
	, strFutureMonth
	, strFutMarketName
	, intOriginId
	, strLotTracking
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, dblHeaderNoOfLots
	, ysnSubCurrency
	, intCompanyLocationId
	, ysnExpired
	, strPricingStatus
	, strOrgin
	, ysnMultiplePriceFixation
	, intMarketUOMId
	, intMarketCurrencyId    
	, dblInvoicedQuantity
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, strMarketZoneCode)
SELECT DISTINCT CH.intCommodityUOMId intCommodityUnitMeasureId
	, CL.strLocationName
	, CY.strDescription strCommodityDescription
	, CU.intMainCurrencyId
	, CU.intCent
	, CD.dblQuantity AS dblDetailQuantity
	, CH.intContractTypeId
	, CH.intContractHeaderId
	, TP.strContractType strContractType
	, CH.strContractNumber
	, EY.strName strEntityName
	, CH.intEntityId
	, CY.strCommodityCode
	, CH.intCommodityId
	, PO.strPosition strPosition
	, CONVERT(DATETIME, CONVERT(VARCHAR, OCD.dtmContractDate, 101),101) dtmContractDate
	, CH.intContractBasisId
	, CD.intContractSeq
	, CD.dtmStartDate
	, CD.dtmEndDate
	, CD.intPricingTypeId
	, CD.dblRatio
	, OCD.dblBasis
	, OCD.dblFutures
	, CD.intContractStatusId
	, CD.dblCashPrice
	, CD.intContractDetailId
	, CD.intFutureMarketId
	, CD.intFutureMonthId
	, CD.intItemId
	, ISNULL(OCD.dblBalance, CD.dblBalance) dblBalance
	, CD.intCurrencyId
	, CD.dblRate
	, CD.intMarketZoneId
	, CD.dtmPlannedAvailabilityDate
	, IM.strItemNo
	, OCD.strPricingType
	, PU.intUnitMeasureId AS intPriceUnitMeasureId
	, IU.intUnitMeasureId
	, MO.strFutureMonth
	, FM.strFutMarketName
	, IM.intOriginId
	, IM.strLotTracking
	, case when isnull(ysnMultiplePriceFixation,0)=1 then CH.dblNoOfLots else  CD.dblNoOfLots end dblNoOfLots
	, dblLotsFixed = NULL --PF.dblLotsFixed
	, dblPriceWORollArb = NULL --PF.dblPriceWORollArb
	, CH.dblNoOfLots dblHeaderNoOfLots
	, CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS ysnSubCurrency
	, CD.intCompanyLocationId
	, MO.ysnExpired
	, OCD.strPricingStatus
	, CA.strDescription as strOrgin
	, ISNULL(ysnMultiplePriceFixation,0) as ysnMultiplePriceFixation
	, FM.intUnitMeasureId intMarketUOMId
	, FM.intCurrencyId intMarketCurrencyId
	, dblInvoicedQty AS dblInvoicedQuantity
	, dblPricedQty = NULL --ISNULL(CASE WHEN CD.intPricingTypeId = 1 and PF.intPriceFixationId is NULL then CD.dblQuantity else PF.dblQuantity end,0) dblPricedQty
	,dblUnPricedQty = NULL
	--, ISNULL(CASE WHEN CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NOT NULL THEN ISNULL(CD.dblQuantity,0)-ISNULL(PF.dblQuantity ,0)
	--			WHEN CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NULL then ISNULL(CD.dblQuantity,0)
	--			ELSE 0 end,0) dblUnPricedQty
	, dblPricedAmount = NULL --ISNULL(CASE WHEN CD.intPricingTypeId =1 and PF.intPriceFixationId is NULL then CD.dblCashPrice else PF.dblFinalPrice end,0) dblPricedAmount
	, MZ.strMarketZoneCode
FROM tblCTContractHeader CH
INNER JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
INNER JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId--AND CD.intContractStatusId not in(2,3,6)
INNER JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
INNER JOIN tblICItem IM ON IM.intItemId = CD.intItemId
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
INNER JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
--INNER JOIN #tblPriceFixationDetail PF ON PF.intContractDetailId = CD.intContractDetailId
LEFT JOIN @tblGetOpenContractDetail OCD ON CD.intContractDetailId = OCD.intContractDetailId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = CD.intMarketZoneId
WHERE CH.intCommodityId = @intCommodityId
	--AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty,0)
	AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
	AND ISNULL(CD.intMarketZoneId, 0) = ISNULL(@intMarketZoneId, ISNULL(CD.intMarketZoneId, 0))
	--AND CD.intContractStatusId not in(2,3,6) 
	AND CONVERT(DATETIME,CONVERT(VARCHAR, OCD.dtmContractDate, 101),101) <= @dtmTransactionDateUpTo

SELECT intContractDetailId
	, sum(dblCosts) dblCosts
INTO #tblContractCost
FROM ( 
	SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyUOMId)
						* (CASE WHEN (M2M.strContractType = 'Both') OR (M2M.strContractType = 'Purchase' AND cd.strContractType = 'Purchase') OR (M2M.strContractType = 'Sale' AND cd.strContractType = 'Sale')
									THEN (CASE WHEN strAdjustmentType = 'Add' THEN ABS(CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
																							ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END)
												WHEN strAdjustmentType = 'Reduce' THEN CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
																							ELSE - SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END
												ELSE 0 END)
								ELSE 0 END)
		, strAdjustmentType
		, dc.intContractDetailId,cu.intCommodityUnitMeasureId a,cu1.intCommodityUnitMeasureId b,strCostMethod
	FROM @GetContractDetailView cd
	INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	INNER JOIN tblRKM2MConfiguration M2M ON dc.intItemId = M2M.intItemId AND ch.intFreightTermId = M2M.intFreightTermId
	INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
	LEFT  JOIN tblSMCurrency CU ON CU.intCurrencyID = dc.intCurrencyId
	LEFT  JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
	GROUP BY cu.intCommodityUnitMeasureId
		, cu1.intCommodityUnitMeasureId
		, strAdjustmentType
		, dc.intContractDetailId
		, dc.strCostMethod
		, CU.ysnSubCurrency
		, CU.intMainCurrencyId
		, dc.intCurrencyId
		, M2M.strContractType
		, cd.strContractType
) t 
GROUP BY intContractDetailId

DECLARE @tblSettlementPrice TABLE (intContractDetailId INT
	, dblFuturePrice NUMERIC(24, 10)
	, dblFutures NUMERIC(24, 10)
	, intFuturePriceCurrencyId INT)

DECLARE @tblGetSettlementPrice TABLE (dblLastSettle NUMERIC(24,10)
	, intFutureMonthId INT
	, intFutureMarketId INT)

IF (@intMarkExpiredMonthPositionId = 2 OR @intMarkExpiredMonthPositionId = 3)
BEGIN
	INSERT INTO @tblGetSettlementPrice
	SELECT dblLastSettle
		, intFutureMonthId
		, intFutureMarketId
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY pm.intFutureMonthId ORDER BY dtmPriceDate DESC) intRowNum
			, dblLastSettle
			, fm.intFutureMonthId
			, p.intFutureMarketId
			, fm.ysnExpired ysnExpired
			, strFutureMonth
		FROM tblRKFuturesSettlementPrice p
		INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId= pm.intFutureMonthId
		WHERE p.intFutureMarketId =fm.intFutureMarketId
			AND CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
	) t WHERE t.intRowNum = 1
END
ELSE
BEGIN
	INSERT INTO @tblGetSettlementPrice
	SELECT dblLastSettle
		, fm.intFutureMonthId
		, fm.intFutureMarketId
	FROM tblRKFuturesSettlementPrice p
	INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
	JOIN tblRKFuturesMonth fm on fm.intFutureMonthId = CASE WHEN ISNULL(fm.ysnExpired,0)=0 then pm.intFutureMonthId
															ELSE (SELECT TOP 1 intFutureMonthId
																	FROM tblRKFuturesMonth fm
																	WHERE ysnExpired = 0 AND fm.intFutureMarketId = p.intFutureMarketId
																		AND CONVERT(DATETIME,'01 '+strFutureMonth) > GETDATE()
																	ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC) END
	WHERE p.intFutureMarketId =fm.intFutureMarketId
		AND CONVERT(Nvarchar, dtmPriceDate, 111) = CONVERT(Nvarchar, @dtmSettlemntPriceDate, 111)
	ORDER BY dtmPriceDate DESC
END

SELECT DISTINCT intContractDetailId
	, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 then 100 else 1 end ) dblFuturePrice
	, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 then 100 else 1 end) dblFutures
	, fm.intCurrencyId intFuturePriceCurrencyId
INTO #tblSettlementPrice
FROM @GetContractDetailView cd
JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId and ffm.intFutureMarketId=cd.intFutureMarketId
JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
JOIN tblSMCurrency c on cd.intMarketCurrencyId=c.intCurrencyID and  cd.intCommodityId= @intCommodityId
JOIN tblSMCurrency c1 on cd.intCurrencyId=c1.intCurrencyID
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intMarketUOMId
JOIN tblICCommodityUnitMeasure PUOM on cd.intCommodityId=PUOM.intCommodityId and PUOM.intUnitMeasureId=cd.intPriceUnitMeasureId
JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId
JOIN @tblGetSettlementPrice sm on sm.intFutureMonthId=ffm.intFutureMonthId
WHERE cd.intCommodityId = @intCommodityId

SELECT intContractDetailId
	, (avgLot / intTotLot) dblFuture
INTO #tblContractFuture
FROM (
	SELECT SUM(ISNULL(pfd.[dblNoOfLots], 0)
			* dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,ISNULL(dblFixationPrice, 0)))
			/ MAX(CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			+ ((MAX(ISNULL(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots
								ELSE cdv.dblNoOfLots END, 0)) - SUM(ISNULL(pfd.[dblNoOfLots], 0)))
			* MAX(dblFuturePrice)) avgLot
		, MAX(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END) intTotLot
		, cdv.intContractDetailId intContractDetailId
	FROM tblCTContractDetail cdv
	JOIN #tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
	JOIN tblSMCurrency c on cdv.intCurrencyId=c.intCurrencyID
	JOIN tblCTContractHeader ch ON cdv.intContractHeaderId = ch.intContractHeaderId AND ch.intCommodityId = @intCommodityId AND cdv.dblBalance > 0
	JOIN tblCTPriceFixation pf ON CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
	JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
	JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId
	JOIN tblICItemUOM PU ON PU.intItemUOMId = cdv.intPriceItemUOMId
	JOIN tblICCommodityUnitMeasure PUOM on ch.intCommodityId=PUOM.intCommodityId and PUOM.intUnitMeasureId=PU.intUnitMeasureId
	GROUP BY cdv.intContractDetailId
) t

DECLARE @tblOpenContractList TABLE (intContractHeaderId int
	, intContractDetailId int
	, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intEntityId int
	, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutureMarketId int
	, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutureMonthId int
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intCommodityId int
	, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intItemId int
	, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intOriginId int
	, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intPricingTypeId int
	, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblContractRatio NUMERIC(24, 10)
	, dblContractBasis NUMERIC(24, 10)
	, dblDummyContractBasis NUMERIC(24, 10)
	, dblCash NUMERIC(24, 10)
	, dblFuturesClosingPrice1 NUMERIC(24, 10)
	, dblFutures NUMERIC(24, 10)
	, dblMarketRatio NUMERIC(24, 10)
	, dblMarketBasis1 NUMERIC(24, 10)
	, intMarketBasisUOM NUMERIC(24, 10)
	, intMarketBasisCurrencyId INT
	, dblFuturePrice1 NUMERIC(24, 10)
	, intFuturePriceCurrencyId INT
	, intContractTypeId INT
	, dblRate NUMERIC(24, 10)
	, intCommodityUnitMeasureId int
	, intQuantityUOMId int
	, intPriceUOMId int
	, intCurrencyId int
	, PriceSourceUOMId int
	, dblCosts NUMERIC(24, 10)
	, dblContractOriginalQty NUMERIC(24, 10)
	, ysnSubCurrency BIT
	, intMainCurrencyId int
	, intCent int
	, dtmPlannedAvailabilityDate datetime
	, intCompanyLocationId int
	, intMarketZoneId int
	, intContractStatusId int
	, dtmContractDate datetime
	, ysnExpired BIT
	, dblInvoicedQuantity NUMERIC(24,10)
	, dblPricedQty NUMERIC(24,10)
	, dblUnPricedQty NUMERIC(24,10)
	, dblPricedAmount NUMERIC(24,10)
	, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblNoOfLots NUMERIC(24,10)
	, dblLotsFixed NUMERIC(24,10)
	, dblPriceWORollArb NUMERIC(24,10)
	, dblCashPrice NUMERIC(24,10))

INSERT INTO @tblOpenContractList (intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, strFutMarketName
	, intFutureMarketId
	, strFutureMonth
	, intFutureMonthId
	, strCommodityCode
	, intCommodityId
	, strItemNo
	, intItemId
	, strOrgin
	, intOriginId
	, strPosition
	, strPeriod
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblContractRatio
	, dblContractBasis
	, dblDummyContractBasis
	, dblCash
	, dblFuturesClosingPrice1
	, dblFutures
	, dblMarketRatio
	, dblMarketBasis1
	, intMarketBasisUOM
	, intMarketBasisCurrencyId
	, dblFuturePrice1
	, intFuturePriceCurrencyId
	, intContractTypeId
	, dblRate
	, intCommodityUnitMeasureId
	, intQuantityUOMId
	, intPriceUOMId
	, intCurrencyId
	, PriceSourceUOMId
	, dblCosts
	, dblContractOriginalQty
	, ysnSubCurrency
	, intMainCurrencyId
	, intCent
	, dtmPlannedAvailabilityDate
	, intCompanyLocationId
	, intMarketZoneId
	, intContractStatusId
	, dtmContractDate
	, ysnExpired
	, dblInvoicedQuantity
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, strMarketZoneCode
	, strLocationName
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, dblCashPrice)
SELECT intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, strFutMarketName
	, intFutureMarketId
	, strFutureMonth
	, intFutureMonthId
	, strCommodityCode
	, intCommodityId
	, strItemNo
	, intItemId
	, strOrgin
	, intOriginId
	, strPosition
	, strPeriod
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblRatio
	, CASE WHEN ISNULL(intPricingTypeId, 0) = 3 THEN dblMarketBasis1 ELSE dblContractBasis END dblContractBasis
	, dblDummyContractBasis
	, dblCash
	, dblFuturesClosingPrice1
	, dblFutures = dblFutures / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
	, dblMarketRatio
	, CASE WHEN intPricingTypeId = 6 THEN 0 ELSE dblMarketBasis1 END dblMarketBasis1
	, intMarketBasisUOM
	, intMarketBasisCurrencyId
	, dblFuturePrice1
	, intFuturePriceCurrencyId
	, intContractTypeId 
	, dblRate
	, intCommodityUnitMeasureId
	, intQuantityUOMId
	, intPriceUOMId
	, intCurrencyId
	, PriceSourceUOMId
	, dblCosts
	, dblContractOriginalQty
	, ysnSubCurrency
	, intMainCurrencyId
	, intCent
	, dtmPlannedAvailabilityDate
	, intCompanyLocationId
	, intMarketZoneId
	, intContractStatusId
	, dtmContractDate
	, ysnExpired
	, dblInvoicedQuantity
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, strMarketZoneCode
	, strLocationName 
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, CASE WHEN intPricingTypeId = 6 THEN dblMarketCashPrice ELSE 0 END dblCashPrice
FROM (
	SELECT DISTINCT cd.intContractHeaderId
		, cd.intContractDetailId
		, 'Contract'+'('+LEFT(cd.strContractType,1)+')' as strContractOrInventoryType
		, cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq
		, cd.strEntityName strEntityName
		, cd.intEntityId
		, cd.strFutMarketName
		, cd.intFutureMarketId
		, cd.strFutureMonth
		, cd.intFutureMonthId
		, cd.strCommodityCode
		, cd.intCommodityId
		, cd.strItemNo
		, cd.intItemId as intItemId
		, cd.strOrgin
		, cd.intOriginId
		, cd.strPosition
		, RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod
		, SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8) AS strPeriodTo
		, cd.strPricingStatus as strPriOrNotPriOrParPriced
		, cd.intPricingTypeId
		, cd.strPricingType
		, cd.dblRatio
		, ISNULL(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN ISNULL(cd.dblBasis,0)
						ELSE 0 END,0) / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END dblContractBasis
		, ISNULL(cd.dblBasis,0) dblDummyContractBasis
		, CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice
				ELSE NULL END dblCash
		, dblFuturePrice as dblFuturesClosingPrice1
		,CASE WHEN cd.intPricingTypeId=2 and strPricingStatus IN('Unpriced','Partially Priced') THEN 
					0--dblFuturePrice
				ELSE                                                        
					case when cd.intPricingTypeId in(1,3) then isnull(cd.dblFutures,0) else ISNULL(cd.dblFutures,0) end 
			 END AS dblFutures
		, ISNULL((SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
			LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
			WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
				AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
				),0) AS dblMarketRatio
		, ISNULL((SELECT top 1 (ISNULL(dblBasisOrDiscount,0)+ISNULL(dblCashOrFuture,0))
									/ case when c.ysnSubCurrency= 1 then 100 else 1 end
					FROM tblRKM2MBasisDetail temp
					LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy')  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract' and cd.strPricingType <> 'HTA'
					),0) AS dblMarketBasis1
		, ISNULL((SELECT top 1 (ISNULL(dblBasisOrDiscount,0)+ISNULL(dblCashOrFuture,0))
									/ case when c.ysnSubCurrency= 1 then 100 else 1 end
					FROM tblRKM2MBasisDetail temp
					LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy')  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract' and cd.strPricingType <> 'HTA'
					),0) AS dblMarketCashPrice
		, ISNULL((SELECT top 1 intCommodityUnitMeasureId as intMarketBasisUOM FROM tblRKM2MBasisDetail temp
					JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0) END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy')  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
					),0) AS intMarketBasisUOM
		, ISNULL((SELECT top 1 intCurrencyId as intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
					JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
					),0) AS intMarketBasisCurrencyId
		, dblFuturePrice1 = CASE WHEN cd.strPricingType IN ('Basis', 'Ratio') THEN 0 ELSE p.dblFuturePrice END
		, intFuturePriceCurrencyId
		, CONVERT(int,cd.intContractTypeId) intContractTypeId
		, cd.dblRate
		, cuc.intCommodityUnitMeasureId
		, cuc1.intCommodityUnitMeasureId intQuantityUOMId
		, cuc2.intCommodityUnitMeasureId intPriceUOMId
		, cd.intCurrencyId
		, convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId
		, ISNULL(dblCosts,0) dblCosts
		, cd.dblBalance as dblContractOriginalQty
		, cd.ysnSubCurrency
		, cd.intMainCurrencyId
		, cd.intCent
		, cd.dtmPlannedAvailabilityDate
		, cd.intCompanyLocationId
		, cd.intMarketZoneId
		, cd.intContractStatusId
		, dtmContractDate
		, ffm.ysnExpired
		, cd.dblInvoicedQuantity
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, strMarketZoneCode
		, strLocationName
		, cd.dblNoOfLots
		, cd.dblLotsFixed
		, cd.dblPriceWORollArb
		, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
		, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
	FROM @GetContractDetailView cd
	JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId = cd.intUnitMeasureId and cd.intCommodityId = @intCommodityId
	JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId = @intQuantityUOMId
	JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and  cuc2.intUnitMeasureId = @intPriceUOMId
	LEFT JOIN #tblSettlementPrice p on cd.intContractDetailId=p.intContractDetailId
	LEFT JOIN #tblContractCost cc on cd.intContractDetailId=cc.intContractDetailId
	LEFT JOIN #tblContractFuture cf on cf.intContractDetailId=cd.intContractDetailId
	LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
	LEFT JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId 
	WHERE cd.intCommodityId = @intCommodityId 
)t

SELECT *
INTO #tempIntransit
FROM (
	SELECT intLineNo = (SELECT TOP 1 intLineNo FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentItemId = InTran.intTransactionDetailId AND intOrderId IS NOT NULL AND InTran.strTransactionId NOT LIKE 'LS-%')
		, dblBalanceToInvoice = SUM(dblInTransitQty)
		, InTran.intItemId
		, InTran.strItemNo
		, InTran.intItemUOMId
		, Com.intCommodityId
		, Com.strCommodityCode
		, Inv.strEntity
		, Inv.intEntityId
		, strTransactionId = InTran.strTransactionId
		, InTran.intTransactionDetailId
		, UOM.intUnitMeasureId
		, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), Inv.dtmDate, 106), 8)
		, Inv.intLocationId
		, Inv.strLocationName
		, Inv.intItemLocationId
	FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmTransactionDateUpTo) InTran
				INNER JOIN vyuICGetInventoryValuation Inv ON InTran.intInventoryTransactionId = Inv.intInventoryTransactionId
				INNER JOIN tblICItem Itm ON InTran.intItemId = Itm.intItemId
				INNER JOIN tblICCommodity Com ON Itm.intCommodityId = Com.intCommodityId
				INNER JOIN tblICCategory Cat ON Itm.intCategoryId = Cat.intCategoryId
				INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InTran.intItemUOMId
				INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmTransactionDateUpTo)
	GROUP BY
		 InTran.intItemId
		, InTran.strItemNo
		, InTran.intItemUOMId
		, Com.intCommodityId
		, Com.strCommodityCode
		, Inv.strEntity
		, Inv.intEntityId
		, InTran.strTransactionId
		, InTran.intTransactionDetailId
		, UOM.intUnitMeasureId
		, Inv.dtmDate
		, Inv.intLocationId
		, Inv.strLocationName
		, Inv.intItemLocationId
) tbl

-- intransit
INSERT INTO @tblFinalDetail (intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
    , strContractSeq
    , strEntityName
    , intEntityId
    , strFutMarketName
    , intFutureMarketId
    , strFutureMonth
    , intFutureMonthId 
    , strCommodityCode
    , intCommodityId
    , strItemNo 
    , intItemId 
	, intItemLocationId
    , strOrgin 
    , intOriginId 
    , strPosition 
    , strPeriod 
    , strPeriodTo
	, strStartDate
	, strEndDate
    , strPriOrNotPriOrParPriced 
    , intPricingTypeId 
    , strPricingType 
    , dblFutures
    , dblCash
    , dblCosts
    , dblMarketBasis1
    , dblMarketBasisUOM
    , intMarketBasisCurrencyId
    , dblContractRatio
    , dblContractBasis
    , dblDummyContractBasis
    , dblFuturePrice1 
    , intFuturePriceCurrencyId
    , dblFuturesClosingPrice1 
    , intContractTypeId 
    , intConcurrencyId 
    , dblOpenQty 
    , dblRate 
    , intCommodityUnitMeasureId
    , intQuantityUOMId 
    , intPriceUOMId 
    , intCurrencyId 
    , PriceSourceUOMId 
    , dblMarketRatio
    , dblMarketBasis 
    , dblCashPrice 
    , dblAdjustedContractPrice 
    , dblFuturesClosingPrice 
    , dblFuturePrice 
    , dblResult 
    , dblMarketFuturesResult 
    , dblResultCash1 
    , dblContractPrice 
    , dblResultCash 
    , dblResultBasis
    , dblShipQty
    , ysnSubCurrency
    , intMainCurrencyId
    , intCent
    , dtmPlannedAvailabilityDate
    , intMarketZoneId  
    , intCompanyLocationId
    , strMarketZoneCode
    , strLocationName 
    , dblNoOfLots
    , dblLotsFixed
	, dblPriceWORollArb
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired)
SELECT intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, strFutMarketName
	, intFutureMarketId
	, strFutureMonth
	, intFutureMonthId
	, strCommodityCode
	, intCommodityId
	, strItemNo
	, intItemId
	, intItemLocationId
	, strOrgin
	, intOriginId
	, strPosition
	, strPeriod
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblFutures
	, dblCash
	, dblCosts
	, dblMarketBasis1
	, dblMarketBasisUOM
	, intMarketBasisCurrencyId
	, dblContractRatio
	, dblContractBasis
	, dblDummyContractBasis
	, dblFuturePrice1
	, intFuturePriceCurrencyId
	, dblFuturesClosingPrice1
	, intContractTypeId
	, intConcurrencyId
	, dblOpenQty
	, dblRate
	, intCommodityUnitMeasureId
	, intQuantityUOMId
	, intPriceUOMId
	, intCurrencyId
	, PriceSourceUOMId
	, dblMarketRatio
	, dblMarketBasis
	, dblCashPrice
	, dblAdjustedContractPrice
	, dblFuturesClosingPrice
	, dblFuturePrice
	, dblResult
	, dblMarketFuturesResult
	, dblResultCash1
	, dblContractPrice
	, case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
	, dblResultBasis
	, 0 as dblShipQty
	, ysnSubCurrency
	, intMainCurrencyId
	, intCent
	, dtmPlannedAvailabilityDate
	, intMarketZoneId
	, intCompanyLocationId
	, strMarketZoneCode
	, strLocationName
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired
FROM (
	SELECT *
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResult
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResultBasis
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblMarketFuturesResult
		, (ISNULL(dblMarketBasis,0)-ISNULL(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) dblResultCash1
		, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)),0)+(ISNULL(dblFutures,0)*ISNULL(dblContractRatio,1)) dblContractPrice
	FROM (
		SELECT *
			, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,ISNULL(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
			, CASE WHEN intPricingTypeId = 6  then  ISNULL(dblCosts,0)+(ISNULL(dblCash,0)) + CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate,0)=0 then dblFutures else dblFutures end) + ISNULL(dblCosts,0) end dblAdjustedContractPrice
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end ,ISNULL(dblOpenQty1,0)) as dblOpenQty
		FROM (
			SELECT
				  ch.intContractHeaderId
				, cd.intContractDetailId
                , 'In-transit' + '(S)' as strContractOrInventoryType
                , strContractSeq = it.strTransactionId
                , strEntityName = e.strName
                , ch.intEntityId
                , fm.strFutMarketName
                , cd.intFutureMarketId
                , fmo.strFutureMonth
                , cd.intFutureMonthId
                , com.strCommodityCode
                , ch.intCommodityId
                , i.strItemNo
                , cd.intItemId
				, it.intItemLocationId
                , strOrgin = NULL --cd.strOrgin
                , i.intOriginId
                , strPosition = NULL --cd.strPosition
				, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
				, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8)
				, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
				, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
				, strPriOrNotPriOrParPriced = ISNULL((select strPricingStatus from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId), pt.strPricingType)
                , intPricingTypeId = ISNULL((select intPricingTypeId from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId),pt.intPricingTypeId)
                , strPricingType = ISNULL((select strPricingType from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId), pt.strPricingType)
				, dblContractRatio = cd.dblRatio
                , dblContractBasis = cd.dblBasis
				, dblDummyContractBasis = null
				, cd.dblFutures
				, dblCash =  CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
				, ISNULL((SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
					LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
						),0) AS dblMarketRatio
				, ISNULL((SELECT top 1 (ISNULL(dblBasisOrDiscount,0)+ISNULL(dblCashOrFuture,0))
											/ case when c.ysnSubCurrency= 1 then 100 else 1 end
							FROM tblRKM2MBasisDetail temp
							LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy')  END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS dblMarketBasis1
				, ISNULL((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp
							JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0) END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS dblMarketBasisUOM
				, ISNULL((SELECT top 1 intCurrencyId as intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
							JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS intMarketBasisCurrencyId
				, dblFuturePrice1 = p.dblLastSettle
				, intFuturePriceCurrencyId = null
				, dblFuturesClosingPrice1 = p.dblLastSettle
				, ch.intContractTypeId
				, 0 as intConcurrencyId
				, it.dblBalanceToInvoice dblOpenQty1
				, cd.dblRate
				, intCommodityUnitMeasureId = cuc.intCommodityUnitMeasureId
				, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
				, intPriceUOMId = cuc2.intCommodityUnitMeasureId
				, cd.intCurrencyId
				, PriceSourceUOMId = convert(int,cuc3.intCommodityUnitMeasureId)
				, dblCosts = ISNULL(cc.dblCosts,0)
				, ysnSubCurrency = CAST(ISNULL(cu.intMainCurrencyId,0) AS BIT)
				, cu.intMainCurrencyId
				, cu.intCent
				, cd.dtmPlannedAvailabilityDate
				, dblInvoicedQuantity = cd.dblInvoicedQty
				, cd.intMarketZoneId
				, cd.intCompanyLocationId
				, mz.strMarketZoneCode
				, cl.strLocationName
				, dblNoOfLots = case when isnull(ch.ysnMultiplePriceFixation,0)=1 then ch.dblNoOfLots else  cd.dblNoOfLots end
				, dblLotsFixed = NULL --cd.dblLotsFixed
				, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
				, dblCashPrice = 0.00
				, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
				, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
				, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearByFuturePrice ELSE NULL END ELSE NULL END
				, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblSpread ELSE NULL END ELSE NULL END
				, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
			FROM #tempIntransit it
			JOIN tblCTContractDetail cd on cd.intContractDetailId = it.intLineNo
			JOIN tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			JOIN tblICItem i on cd.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and iuom.intItemUOMId = cd.intBasisUOMId
			JOIN tblEMEntity e on ch.intEntityId = e.intEntityId
			JOIN tblICCommodity com on ch.intCommodityId = com.intCommodityId
			JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
			JOIN tblRKFuturesMonth fmo on cd.intFutureMonthId = fmo.intFutureMonthId
			JOIN tblCTPricingType pt on cd.intPricingTypeId = pt.intPricingTypeId
			JOIN tblICCommodityUnitMeasure cuc on ch.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId = it.intUnitMeasureId and ch.intCommodityId = @intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 on ch.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId = @intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cuc2 on ch.intCommodityId=cuc2.intCommodityId and  cuc2.intUnitMeasureId = @intPriceUOMId
			JOIN tblICCommodityUnitMeasure cuc3 on ch.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId= iuom.intUnitMeasureId
			LEFT JOIN @tblGetSettlementPrice p on cd.intFutureMonthId = p.intFutureMonthId
			LEFT JOIN #tblContractCost cc on cd.intContractDetailId=cc.intContractDetailId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
			LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
			JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId
			CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, p.dblLastSettle) rk
				WHERE rk.intContractDetailId = cd.intContractDetailId
					AND rk.intFutureMonthId = cd.intFutureMonthId

			UNION ALL --Logistics Sale
			SELECT
				  ch.intContractHeaderId
				, cd.intContractDetailId
                , 'In-transit' + '(S)' as strContractOrInventoryType
                , strContractSeq = it.strTransactionId 
                , strEntityName = e.strName
                , ch.intEntityId
                , fm.strFutMarketName
                , cd.intFutureMarketId
                , fmo.strFutureMonth
                , cd.intFutureMonthId
                , com.strCommodityCode
                , ch.intCommodityId
                , i.strItemNo
                , cd.intItemId
				, it.intItemLocationId
                , strOrgin = NULL --cd.strOrgin
                , i.intOriginId
                , strPosition = NULL --cd.strPosition
				, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
				, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8)
				, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
				, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
				, strPriOrNotPriOrParPriced = ISNULL((select strPricingStatus from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId), pt.strPricingType)
                , intPricingTypeId = ISNULL((select intPricingTypeId from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId),pt.intPricingTypeId)
                , strPricingType = ISNULL((select strPricingType from @tblGetOpenContractDetail where intContractDetailId = cd.intContractDetailId), pt.strPricingType)
				, dblContractRatio = cd.dblRatio
                , dblContractBasis = cd.dblBasis
				, dblDummyContractBasis = null
				, cd.dblFutures
				, dblCash =  CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
				, ISNULL((SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
					LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
						),0) AS dblMarketRatio
				, ISNULL((SELECT top 1 (ISNULL(dblBasisOrDiscount,0)+ISNULL(dblCashOrFuture,0))
											/ case when c.ysnSubCurrency= 1 then 100 else 1 end
							FROM tblRKM2MBasisDetail temp
							LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy')  END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS dblMarketBasis1
				, ISNULL((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp
							JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0) END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS dblMarketBasisUOM
				, ISNULL((SELECT top 1 intCurrencyId as intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
							JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
							WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
								and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
								and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
								and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
								AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
								THEN ISNULL(temp.strPeriodTo,'') ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END else ISNULL(temp.strPeriodTo,'') end
								AND temp.strContractInventory = 'Contract'
							),0) AS intMarketBasisCurrencyId
				, dblFuturePrice1 = p.dblLastSettle
				, intFuturePriceCurrencyId = null
				, dblFuturesClosingPrice1 = p.dblLastSettle
				, ch.intContractTypeId
				, 0 as intConcurrencyId
				, it.dblBalanceToInvoice dblOpenQty1
				, cd.dblRate
				, intCommodityUnitMeasureId = cuc.intCommodityUnitMeasureId
				, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
				, intPriceUOMId = cuc2.intCommodityUnitMeasureId
				, cd.intCurrencyId
				, PriceSourceUOMId = convert(int,cuc3.intCommodityUnitMeasureId)
				, dblCosts = ISNULL(cc.dblCosts,0)
				, ysnSubCurrency = CAST(ISNULL(cu.intMainCurrencyId,0) AS BIT)
				, cu.intMainCurrencyId
				, cu.intCent
				, cd.dtmPlannedAvailabilityDate
				, dblInvoicedQuantity = 0
				, cd.intMarketZoneId
				, cd.intCompanyLocationId
				, mz.strMarketZoneCode
				, cl.strLocationName
				, dblNoOfLots = case when isnull(ch.ysnMultiplePriceFixation,0)=1 then ch.dblNoOfLots else  cd.dblNoOfLots end
				, dblLotsFixed = NULL --cd.dblLotsFixed
				, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
				, dblCashPrice = 0.00
				, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
				, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
				, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearByFuturePrice ELSE NULL END ELSE NULL END
				, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblSpread ELSE NULL END ELSE NULL END
				, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
			FROM #tempIntransit it
			JOIN tblLGLoadDetail ld on ld.intLoadDetailId = it.intTransactionDetailId
			JOIN tblCTContractDetail cd on cd.intContractDetailId = ld.intSContractDetailId
			JOIN tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			JOIN tblICItem i on cd.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and iuom.intItemUOMId = cd.intBasisUOMId
			JOIN tblEMEntity e on ch.intEntityId = e.intEntityId
			JOIN tblICCommodity com on ch.intCommodityId = com.intCommodityId
			JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
			JOIN tblRKFuturesMonth fmo on cd.intFutureMonthId = fmo.intFutureMonthId
			JOIN tblCTPricingType pt on cd.intPricingTypeId = pt.intPricingTypeId
			JOIN tblICCommodityUnitMeasure cuc on ch.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId = it.intUnitMeasureId and ch.intCommodityId = @intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 on ch.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId = @intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cuc2 on ch.intCommodityId=cuc2.intCommodityId and  cuc2.intUnitMeasureId = @intPriceUOMId
			JOIN tblICCommodityUnitMeasure cuc3 on ch.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId= iuom.intUnitMeasureId
			LEFT JOIN @tblGetSettlementPrice p on cd.intFutureMonthId = p.intFutureMonthId
			LEFT JOIN #tblContractCost cc on cd.intContractDetailId=cc.intContractDetailId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
			LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
			JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId
			CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, p.dblLastSettle) rk
			WHERE rk.intContractDetailId = cd.intContractDetailId
				AND rk.intFutureMonthId = cd.intFutureMonthId
				AND it.intLineNo IS NULL
				AND it.strTransactionId LIKE 'LS-%'

			UNION ALL
			SELECT 
				  intContractHeaderId = NULL
				, intContractDetailId = NULL
                , 'In-transit' + '(S)' as strContractOrInventoryType
                , strContractSeq = it.strTransactionId  
                , strEntityName = it.strEntity
                , it.intEntityId
                , strFutMarketName = NULL
                , intFutureMarketId = NULL
                , strFutureMonth = NULL
                , intFutureMonthId = NULL
                , it.strCommodityCode
                , it.intCommodityId
                , it.strItemNo
                , it.intItemId
				, it.intItemLocationId
                , strOrgin = NULL --cd.strOrgin
                , intOriginId = NULL
                , strPosition = NULL --cd.strPosition
				, strPeriod = NULL
				, strPeriodTo = NULL
				, strStartDate = NULL
				, strEndDate = NULL
				, strPriOrNotPriOrParPriced = NULL
                , intPricingTypeId = NULL
                , strPricingType = NULL
				, dblContractRatio = 0
                , dblContractBasis = 0
				, dblDummyContractBasis = 0
				, dblFutures = 0
				, dblCash =  ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmTransactionDateUpTo), 0) --it.dblPrice
				, dblMarketRatio = 0
				, dblMarketBasis1 = 0
				, dblMarketBasisUOM = 0
				, intMarketBasisCurrencyId = NULL
				, dblFuturePrice1 = 0
				, intFuturePriceCurrencyId = NULL
				, dblFuturesClosingPrice1 = 0
				, intContractTypeId = NULL
				, 0 as intConcurrencyId
				, dblOpenQty1 = -it.dblBalanceToInvoice
				, dblRate = NULL
				, intCommodityUnitMeasureId = NULL
				, intQuantityUOMId = NULL
				, intPriceUOMId = NULL
				, intCurrencyId = NULL
				, PriceSourceUOMId = NULL
				, dblCosts = 0
				, ysnSubCurrency = NULL
				, intMainCurrencyId = NULL
				, intCent = NULL
				, dtmPlannedAvailabilityDate = NULL
				, dblInvoicedQuantity = NULL
				, intMarketZoneId = NULL
				, intCompanyLocationId = it.intLocationId
				, strMarketZoneCode = NULL
				, it.strLocationName
				, dblNoOfLots = NULL
				, dblLotsFixed = NULL --cd.dblLotsFixed
				, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
				, dblCashPrice = ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE it.intCommodityId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE it.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(it.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0),4)
				, intSpreadMonthId = NULL
				, strSpreadMonth = NULL
				, dblSpreadMonthPrice = NULL
				, dblSpread = NULL
				, ysnExpired = NULL
			FROM #tempIntransit it
			WHERE it.intLineNo IS NULL
			AND it.strTransactionId NOT LIKE 'LS-%'

		)t
	)t
)t2
---- intransitv(p)
 
select sum(dblPurchaseContractShippedQty) dblPurchaseContractShippedQty, intContractDetailId into #tblPIntransitView  from vyuRKPurchaseIntransitView group by intContractDetailId
 
INSERT INTO @tblFinalDetail (
    intContractHeaderId
    ,intContractDetailId
    ,strContractOrInventoryType
    ,strContractSeq
    ,strEntityName
    ,intEntityId
    ,strFutMarketName
    ,intFutureMarketId
    ,strFutureMonth
    ,intFutureMonthId 
    ,strCommodityCode
    ,intCommodityId
    ,strItemNo 
    ,intItemId 
    ,strOrgin 
    ,intOriginId 
    ,strPosition 
    ,strPeriod 
    ,strPeriodTo
	, strStartDate
	, strEndDate
    ,strPriOrNotPriOrParPriced 
    ,intPricingTypeId 
    ,strPricingType 
    ,dblFutures
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblContractRatio
	,dblContractBasis
	,dblDummyContractBasis
	,dblFuturePrice1 
	,intFuturePriceCurrencyId
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblRate 
	,intCommodityUnitMeasureId
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,dblMarketRatio
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis
	,dblShipQty
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,intMarketZoneId  
	,intCompanyLocationId
	,strMarketZoneCode
	,strLocationName 
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired) 
SELECT DISTINCT 
	intContractHeaderId
	,intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPeriodTo
	, strStartDate
	, strEndDate
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,intMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblContractRatio
	,dblContractBasis 
	,dblDummyContractBasis
	,dblFuturePrice1 
	,intFuturePriceCurrencyId
	,dblFuturesClosingPrice1
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,dblMarketRatio
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturePrice 
	,dblFuturePrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
	,dblResultBasis
	,0 as dblShipQty
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,intMarketZoneId
	,intCompanyLocationId
	,strMarketZoneCode
	,strLocationName
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb 
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired
FROM(
                SELECT 
                                *
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult
                                ,(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
                                ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+(isnull(dblFutures,0)*isnull(dblContractRatio,1)) dblContractPrice
                FROM (
SELECT 
            *
   ,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(intMarketBasisUOM,0)=0 then PriceSourceUOMId else intMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
   --,CASE when intPricingTypeId=6 then dblCashPrice else  0 end dblCashPrice
   ,CASE WHEN intPricingTypeId = 6  THEN  
     isnull(dblCosts,0)+(isnull(dblCash,0))  
    ELSE 
     CONVERT(DECIMAL(24,6),
        CASE WHEN ISNULL(dblRate,0)=0 THEN 
          dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
         ELSE
          CASE WHEN (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId THEN 
             dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*isnull(dblRate,0) 
            ELSE
             dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) 
          END 
        END) 
     + 
     CONVERT(decimal(24,6), 
        case when isnull(dblRate,0)=0 then 
          dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
         else
          case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId THEN 
            dblFutures*isnull(dblRate,0) 
           else 
            dblFutures 
          end 
        end) 
     + 
     isnull(dblCosts,0)
    END AS dblAdjustedContractPrice
    ,dblFuturePrice1 as dblFuturePrice
    ,
    isnull(convert(decimal(24,6),
        case when isnull(intCommodityUnitMeasureId,0) = 0 then 
          InTransQty 
         else 
          dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,InTransQty)
        end),0)
 
    as dblOpenQty
            
                                FROM (
SELECT  distinct  
                cd.intContractHeaderId
                ,cd.intContractDetailId
                ,'In-transit'+'(P)'  as strContractOrInventoryType
                ,cd.strContractSeq
                ,cd.strEntityName
                ,cd.intEntityId
                ,cd.strFutMarketName
                ,cd.intFutureMarketId
                ,cd.strFutureMonth
                ,cd.intFutureMonthId
                ,cd.strCommodityCode
                ,cd.intCommodityId
                ,cd.strItemNo
                ,cd.intItemId
                ,cd.strOrgin
                ,cd.intOriginId
                ,cd.strPosition
      ,cd.strPeriod
      ,cd.strPeriodTo
	  ,cd.strStartDate
	  ,cd.strEndDate
      ,cd.strPriOrNotPriOrParPriced
      ,cd.intPricingTypeId
      ,cd.strPricingType
      ,cd.dblContractRatio
      ,cd.dblContractBasis
      ,dblDummyContractBasis
      ,cd.dblFutures
      ,cd.dblCash
      ,cd.dblMarketRatio
      ,cd.dblMarketBasis1  
      ,cd.intMarketBasisUOM
      ,cd.intMarketBasisCurrencyId                                                             
      ,cd.dblFuturePrice1
      ,cd.intFuturePriceCurrencyId
      ,cd.dblFuturesClosingPrice1                         
      ,cd.intContractTypeId 
      ,0 as intConcurrencyId                  
      ,cd.dblContractOriginalQty
      ,LG.dblQuantity as InTransQty   
      ,cd.dblRate
      ,cd.intCommodityUnitMeasureId
      ,cd.intQuantityUOMId
      ,cd.intPriceUOMId
      ,cd.intCurrencyId
      ,cd.PriceSourceUOMId 
      ,cd.dblCosts
      ,cd.ysnSubCurrency
      ,cd.intMainCurrencyId
      ,cd.intCent
      ,cd.dtmPlannedAvailabilityDate
      ,cd.dblInvoicedQuantity
      ,cd.intMarketZoneId
      ,cd.intCompanyLocationId
      ,cd.strMarketZoneCode
      ,cd.strLocationName 
      ,cd.dblNoOfLots
      ,cd.dblLotsFixed
      ,cd.dblPriceWORollArb ,dblCashPrice
	  , intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
		, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
		, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearByFuturePrice ELSE NULL END ELSE NULL END
		, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblSpread ELSE NULL END ELSE NULL END
		, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
        FROM @tblOpenContractList cd
        LEFT JOIN (
       select 
        sum(LD.dblQuantity)dblQuantity
        ,PCT.intContractDetailId 
       from tblLGLoad L 
        JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
        JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId and  PCT.dblQuantity > isnull(PCT.dblInvoicedQty,0)
       group by PCT.intContractDetailId
       union 
       select 
        sum(LD.dblQuantity)dblQuantity
        ,PCT.intContractDetailId 
       from tblLGLoad L 
        JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
        JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId and  PCT.dblQuantity > PCT.dblInvoicedQty
       group by PCT.intContractDetailId
       ) AS LG 
        ON LG.intContractDetailId = cd.intContractDetailId
		CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
		WHERE rk.intContractDetailId = cd.intContractDetailId
			AND rk.intFutureMonthId = cd.intFutureMonthId
			AND cd.intPricingTypeId = 2 
                                )t       
                )t
)t2  

IF ISNULL(@ysnIncludeInventoryM2M, 0) = 1
BEGIN
	INSERT INTO @tblFinalDetail (intContractHeaderId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, strFutMarketName
		, intFutureMarketId
		, strFutureMonth
		, intFutureMonthId 
		, strCommodityCode
		, intCommodityId 
		, strItemNo 
		, intItemId 
		, strOrgin 
		, intOriginId 
		, strPosition 
		, strPeriod 
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced 
		, intPricingTypeId 
		, strPricingType 
		, dblFutures
		, dblCash
		, dblCosts
		, dblMarketBasis1
		, dblMarketBasisUOM
		, intMarketBasisCurrencyId
		, dblContractRatio
		, dblContractBasis 
		, dblDummyContractBasis
		, dblFuturePrice1 
		, intFuturePriceCurrencyId
		, dblFuturesClosingPrice1 
		, intContractTypeId 
		, intConcurrencyId 
		, dblOpenQty 
		, dblRate 
		, intCommodityUnitMeasureId 
		, intQuantityUOMId 
		, intPriceUOMId 
		, intCurrencyId 
		, PriceSourceUOMId 
		, dblMarketRatio
		, dblMarketBasis 
		, dblCashPrice 
		, dblAdjustedContractPrice 
		, dblFuturesClosingPrice 
		, dblFuturePrice 
		, dblResult 
		, dblMarketFuturesResult 
		, dblResultCash1 
		, dblContractPrice 
		, dblResultCash 
		, dblResultBasis
		, dblShipQty
		, ysnSubCurrency
		, intMainCurrencyId
		, intCent
		, dtmPlannedAvailabilityDate
		, intMarketZoneId  
		, intCompanyLocationId
		, strMarketZoneCode
		, strLocationName 
		, dblNoOfLots
		, dblLotsFixed
		, dblPriceWORollArb
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread
		, ysnExpired)
	SELECT DISTINCT intContractHeaderId
		, intContractDetailId 
		, strContractOrInventoryType 
		, strContractSeq 
		, strEntityName 
		, intEntityId 
		, strFutMarketName 
		, intFutureMarketId 
		, strFutureMonth 
		, intFutureMonthId 
		, strCommodityCode 
		, intCommodityId 
		, strItemNo 
		, intItemId 
		, strOrgin 
		, intOriginId 
		, strPosition 
		, strPeriod 
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced 
		, intPricingTypeId 
		, strPricingType 
		, dblFutures
		, dblCash
		, dblCosts
		, dblMarketBasis1
		, intMarketBasisUOM
		, intMarketBasisCurrencyId
		, dblContractRatio
		, dblContractBasis 
		, dblDummyContractBasis
		, dblFuturePrice1 
		, intFuturePriceCurrencyId
		, dblFuturesClosingPrice1 
		, intContractTypeId 
		, intConcurrencyId 
		, dblOpenQty 
		, dblRate 
		, intCommodityUnitMeasureId 
		, intQuantityUOMId 
		, intPriceUOMId 
		, intCurrencyId 
		, PriceSourceUOMId 
		, dblMarketRatio
		, dblMarketBasis 
		, dblCashPrice 
		, dblAdjustedContractPrice 
		, dblFuturesClosingPrice 
		, dblFuturePrice 
		, dblResult 
		, dblMarketFuturesResult 
		, dblResultCash1 
		, dblContractPrice 
		, case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
		, dblResultBasis
		, 0 as dblShipQty
		, ysnSubCurrency
		, intMainCurrencyId
		, intCent
		, dtmPlannedAvailabilityDate
		, intMarketZoneId 
		, intCompanyLocationId 
		, strMarketZoneCode
		, strLocationName 
		, dblNoOfLots
		, dblLotsFixed
		, dblPriceWORollArb
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread
		, ysnExpired
	FROM (
		SELECT *
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResult
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResultBasis
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblMarketFuturesResult
			, (ISNULL(dblMarketBasis,0)-ISNULL(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty1,0))) dblResultCash1
			, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)),0)+(ISNULL(dblFutures,0) * ISNULL(dblContractRatio,1)) dblContractPrice
		FROM (
			SELECT *
				, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(intMarketBasisUOM,0)=0 then PriceSourceUOMId else intMarketBasisUOM end,ISNULL(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
				, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts,0)+(ISNULL(dblCash,0))
					ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate,0)=0
														THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))
													ELSE CASE WHEN (CASE WHEN ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId
																	THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)) * dblRate
															ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)) end end)
						+  convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
														else case when (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId THEN dblFutures * dblRate
																else dblFutures end end)
						+ ISNULL(dblCosts,0) end dblAdjustedContractPrice
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(intMarketBasisUOM,0)=0 then PriceSourceUOMId else intMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice
				, dblFuturePrice1 as dblFuturePrice
				, ISNULL(CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId,0) = 0 THEN dblOpenQty1
													ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty1) end),0) as dblOpenQty
			FROM (
				SELECT DISTINCT cd.intContractHeaderId
					, cd.intContractDetailId
					, 'Inventory (P)' as strContractOrInventoryType
					, cd.strContractSeq
					, cd.strEntityName
					, cd.intEntityId
					, cd.strFutMarketName
					, cd.intFutureMarketId
					, cd.strFutureMonth
					, cd.intFutureMonthId
					, cd.strCommodityCode
					, cd.intCommodityId
					, cd.strItemNo
					, cd.intItemId
					, cd.strOrgin
					, cd.intOriginId
					, cd.strPosition
					, cd.strPeriod
					, cd.strPeriodTo
					, cd.strStartDate
					, cd.strEndDate
					, cd.strPriOrNotPriOrParPriced
					, cd.intPricingTypeId
					, cd.strPricingType
					, cd.dblContractRatio
					, cd.dblContractBasis
					, cd.dblDummyContractBasis
					, cd.dblFutures
					, cd.dblCash
					, cd.dblMarketRatio
					, cd.dblMarketBasis1
					, cd.intMarketBasisUOM
					, cd.intMarketBasisCurrencyId
					, cd.dblFuturePrice1
					, cd.intFuturePriceCurrencyId
					, cd.dblFuturesClosingPrice1
					, cd.intContractTypeId 
					, 0 as intConcurrencyId 
					, dblLotQty dblOpenQty1
					, cd.dblRate
					, cd.intCommodityUnitMeasureId
					, cd.intQuantityUOMId
					, cd.intPriceUOMId
					, cd.intCurrencyId
					, cd.PriceSourceUOMId
					, cd.dblCosts
					, cd.dblInvoicedQuantity dblInvoiceQty
					, cd.ysnSubCurrency
					, cd.intMainCurrencyId
					, cd.intCent
					, cd.dtmPlannedAvailabilityDate
					, cd.intMarketZoneId
					, cd.intCompanyLocationId 
					, cd.strMarketZoneCode
					, cd.strLocationName
					, cd.dblNoOfLots
					, cd.dblLotsFixed
					, cd.dblPriceWORollArb
					, dblCashPrice
					, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
					, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
					, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearByFuturePrice ELSE NULL END ELSE NULL END
					, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblSpread ELSE NULL END ELSE NULL END
					, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
				FROM @tblOpenContractList cd
				JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId =l.intContractDetailId
				JOIN tblICItem i on cd.intItemId= i.intItemId and i.strLotTracking<>'No'
				CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
				WHERE rk.intContractDetailId = cd.intContractDetailId
					AND rk.intFutureMonthId = cd.intFutureMonthId
					AND cd.intCommodityId = @intCommodityId
			)t
		)t1
	)t2
	WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory (P)' else '' end
END

---- contract
INSERT INTO @tblFinalDetail (intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, strFutMarketName
	, intFutureMarketId
	, strFutureMonth
	, intFutureMonthId
	, strCommodityCode
	, intCommodityId
	, strItemNo
	, intItemId
	, strOrgin
	, intOriginId
	, strPosition
	, strPeriod
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblFutures
	, dblCash
	, dblCosts
	, dblMarketBasis1
	, dblMarketBasisUOM
	, intMarketBasisCurrencyId
	, dblContractRatio
	, dblContractBasis
	, dblDummyContractBasis
	, dblFuturePrice1
	, intFuturePriceCurrencyId
	, dblFuturesClosingPrice1
	, intContractTypeId
	, intConcurrencyId
	, dblOpenQty
	, dblRate
	, intCommodityUnitMeasureId 
	, intQuantityUOMId 
	, intPriceUOMId 
	, intCurrencyId 
	, PriceSourceUOMId 
	, dblMarketRatio
	, dblMarketBasis 
    , dblCashPrice 
	, dblAdjustedContractPrice 
	, dblFuturesClosingPrice 
	, dblFuturePrice 
	, dblResult 
	, dblMarketFuturesResult 
	, dblResultCash1 
	, dblContractPrice 
    , dblResultCash 
	, dblResultBasis
	, ysnSubCurrency
	, intMainCurrencyId
	, intCent
	, dtmPlannedAvailabilityDate
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, intMarketZoneId 
	, intCompanyLocationId
	, strMarketZoneCode
	, strLocationName 
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired)
SELECT DISTINCT intContractHeaderId
	, intContractDetailId 
	, strContractOrInventoryType 
	, strContractSeq 
	, strEntityName 
	, intEntityId 
	, strFutMarketName 
	, intFutureMarketId 
	, strFutureMonth 
	, intFutureMonthId 
    , strCommodityCode 
	, intCommodityId 
	, strItemNo 
	, intItemId 
	, strOrgin 
	, intOriginId 
	, strPosition 
	, strPeriod 
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced 
	, intPricingTypeId 
	, strPricingType 
    , dblFutures
	, dblCash
	, dblCosts
	, dblMarketBasis1
	, intMarketBasisUOM
	, intMarketBasisCurrencyId
	, dblContractRatio
	, dblContractBasis 
	, dblDummyContractBasis
	, dblFuturePrice1 
	, intFuturePriceCurrencyId
	, dblFuturesClosingPrice1 
	, intContractTypeId 
    , 0 as intConcurrencyId 
	, dblOpenQty 
	, dblRate 
	, intCommodityUnitMeasureId 
	, intQuantityUOMId 
	, intPriceUOMId 
	, intCurrencyId 
	, PriceSourceUOMId 
	, dblMarketRatio
	, dblMarketBasis 
    , dblCashPrice 
	, dblAdjustedContractPrice
	, dblFuturePrice 
	, dblFuturePrice 
	, dblResult 
	, dblMarketFuturesResult 
	, dblResultCash1 
	, dblContractPrice 
    , case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
	, dblResultBasis
	, ysnSubCurrency
	, intMainCurrencyId
	, intCent
	, dtmPlannedAvailabilityDate
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, intMarketZoneId
	, intCompanyLocationId
	, strMarketZoneCode
	, strLocationName  
	, dblNoOfLots
	, dblLotsFixed
	, dblPriceWORollArb
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
	, ysnExpired
FROM (
	SELECT *
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResult
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResultBasis
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblMarketFuturesResult
		, (ISNULL(dblMarketBasis,0)-ISNULL(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) dblResultCash1
		, 0 dblContractPrice
	FROM (
		SELECT *
			, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(intMarketBasisUOM,0)=0 then PriceSourceUOMId else intMarketBasisUOM end,ISNULL(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
			, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts,0)+(ISNULL(dblCash,0))
					ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate,0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))
													ELSE CASE WHEN (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId
																THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))*ISNULL(dblRate,0) 
															ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)) END END) 
						+ CONVERT(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
													else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId THEN dblFutures*ISNULL(dblRate,0)
															else dblFutures end end)
						+ ISNULL(dblCosts,0) END AS dblAdjustedContractPrice
			, dblFuturePrice1 as dblFuturePrice
			, convert(decimal(24,6), case when ISNULL(intCommodityUnitMeasureId,0) = 0 then dblContractOriginalQty
										else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblContractOriginalQty) end)
				 as dblOpenQty
		FROM (
			SELECT cd.intContractHeaderId
				, cd.intContractDetailId
				, cd.strContractOrInventoryType
				, cd.strContractSeq
				, cd.strEntityName
				, cd.intEntityId
				, cd.strFutMarketName
				, cd.intFutureMarketId
				, cd.strFutureMonth
				, cd.intFutureMonthId
				, cd.strCommodityCode
				, cd.intCommodityId
				, cd.strItemNo
				, cd.intItemId
				, cd.strOrgin
				, cd.intOriginId
				, cd.strPosition
				, cd.strPeriod
				, cd.strPeriodTo
				, strStartDate
				, strEndDate
				, cd.strPriOrNotPriOrParPriced
				, cd.intPricingTypeId
				, cd.strPricingType
				, cd.dblContractRatio
				, cd.dblContractBasis
				, cd.dblDummyContractBasis
				, cd.dblCash
				, cd.dblFuturesClosingPrice1
				, cd.dblFutures
				, cd.dblMarketRatio
				, cd.dblMarketBasis1
				, cd.intMarketBasisUOM
				, cd.intMarketBasisCurrencyId
				, cd.dblFuturePrice1
				, cd.intFuturePriceCurrencyId
				, cd.intContractTypeId
				, cd.dblRate
				, cd.intCommodityUnitMeasureId
				, cd.intQuantityUOMId
				, cd.intPriceUOMId
				, cd.intCurrencyId
				, convert(int,cd.PriceSourceUOMId) PriceSourceUOMId
				, cd.dblCosts
				, cd.dblContractOriginalQty
				, LG.dblQuantity as InTransQty
				, cd.dblInvoicedQuantity
				, cd.ysnSubCurrency
				, cd.intMainCurrencyId
				, cd.intCent
				, cd.dtmPlannedAvailabilityDate
				, cd.intCompanyLocationId
				, cd.intMarketZoneId
				, cd.intContractStatusId
				, cd.dtmContractDate
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, strMarketZoneCode
				, strLocationName
				, cd.dblNoOfLots
				, cd.dblLotsFixed
				, cd.dblPriceWORollArb
				, dblCashPrice
				, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
				, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
				, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearByFuturePrice ELSE NULL END ELSE NULL END
				, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblSpread ELSE NULL END ELSE NULL END
				, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
			FROM @tblOpenContractList cd
			LEFT JOIN (SELECT sum(LD.dblQuantity)dblQuantity
							, PCT.intContractDetailId
						FROM tblLGLoad L
						JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
						JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId and  PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty,0)
						GROUP BY PCT.intContractDetailId
						
						UNION ALL SELECT sum(LD.dblQuantity)dblQuantity
							, PCT.intContractDetailId
						from tblLGLoad L
						JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
						JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId and  PCT.dblQuantity > PCT.dblInvoicedQty
						group by PCT.intContractDetailId
			) AS LG ON LG.intContractDetailId = cd.intContractDetailId
			CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
			WHERE rk.intContractDetailId = cd.intContractDetailId
				AND rk.intFutureMonthId = cd.intFutureMonthId
		) t
	) t where ISNULL(dblOpenQty,0) > 0
) t1

SELECT *
	, dblContractPrice = ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
	, dblResult = CONVERT(DECIMAL(24, 6), ((ISNULL(dblMarketBasis, 0) - ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0))) * ISNULL(dblResultBasis1, 0)) + CONVERT(DECIMAL(24, 6),((ISNULL(dblFutures, 0) - ISNULL(dblFuturePrice, 0)) * ISNULL(dblMarketFuturesResult1, 0)))
	, dblResultBasis = CONVERT(DECIMAL(24, 6), ((ISNULL(dblMarketBasis, 0) - (ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0)) - (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END))) * ISNULL(dblOpenQty, 0)) 
	, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 THEN CONVERT(DECIMAL(24, 6), ((ISNULL(dblFuturePrice, 0) - ISNULL(dblFutures, 0)) * ISNULL(dblOpenQty, 0)))
									ELSE 0 END
	, dblResultCash = CASE WHEN strPricingType = 'Cash' THEN CONVERT(DECIMAL(24, 6), (ISNULL(dblCash, 0) - ISNULL(dblCashPrice, 0)) * ISNULL(dblResult1, 0))
							ELSE 0 END
INTO #Temp
FROM (
	SELECT intContractHeaderId
		, intContractDetailId
		, intTransactionId = intContractHeaderId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, strFutMarketName
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMonth
		, dblContractRatio
		, strCommodityCode
		, intCommodityId
		, strItemNo
		, intItemId
		, intOriginId
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced
		, case when intContractTypeId = 2 then - dblOpenQty
				else dblOpenQty end dblOpenQty
		, intPricingTypeId
		, strPricingType
		, convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblDummyContractBasis,0))
									else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId
															then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblDummyContractBasis,0)) * dblRate
											else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblDummyContractBasis,0)) end end) as dblDummyContractBasis
		, case when @ysnCanadianCustomer= 1 then dblContractBasis
			else convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))
											else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId
														then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))*dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)) end end) end as dblContractBasis
		, convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))
									else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId
															then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0))*dblRate 
											else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)) end end) as dblCanadianContractBasis
		, case when @ysnCanadianCustomer = 1 then dblFutures
				else convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblFutures,0))
			else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblFutures,0)) * dblRate
					else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblFutures,0)) end end) end as dblFutures
		, convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash
		, dblCosts as dblCosts
		, dblMarketRatio
		, case when @ysnCanadianCustomer= 1 then dblMarketBasis
			else convert(decimal(24,6),case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0))
											else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId
														then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0)) * dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0)) end end) end as dblMarketBasis
		, intMarketBasisCurrencyId
		, dblFuturePrice = CASE WHEN strPricingType = 'Basis' THEN 0 ELSE dblFuturePrice1 END
		, intFuturePriceCurrencyId
		, convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice
		, CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId
		, dblAdjustedContractPrice
		, dblCashPrice as dblCashPrice
		, case when ysnSubCurrency = 1 then (convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash))) / ISNULL(intCent,0)
				else convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)) end as dblResultCash1
		, dblResult as dblResult1
		, case when ISNULL(@ysnIncludeBasisDifferentialsInResults,0) = 0 then 0 else dblResultBasis end as dblResultBasis1
		, dblMarketFuturesResult as dblMarketFuturesResult1
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, intCent
		, dtmPlannedAvailabilityDate
		, CONVERT(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId) * dblFutures
									else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then dblFutures * dblRate
											else dblFutures end end) dblCanadianFutures
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName
		, dblNotLotTrackedPrice
		, dblInvFuturePrice
		, dblInvMarketBasis
		, dblNoOfLots
		, dblLotsFixed
		, dblPriceWORollArb
		, intCurrencyId
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread
		, ysnExpired
	FROM @tblFinalDetail
) t
ORDER BY intCommodityId,strContractSeq DESC

------------- Calculation of Results ----------------------
--UPDATE #Temp
--SET dblResultBasis = CASE WHEN intContractTypeId = 1 and (ISNULL(dblContractBasis,0) <= dblMarketBasis) THEN abs(dblResultBasis)
--						WHEN intContractTypeId = 1 and (ISNULL(dblContractBasis,0) > dblMarketBasis) THEN - abs(dblResultBasis)
--						WHEN intContractTypeId = 2  and (ISNULL(dblContractBasis,0) >= dblMarketBasis) THEN abs(dblResultBasis)
--						WHEN intContractTypeId = 2  and (ISNULL(dblContractBasis,0) < dblMarketBasis) THEN - abs(dblResultBasis) END
	--, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 and (ISNULL(dblFutures,0) <= ISNULL(dblFuturesClosingPrice,0)) THEN abs(dblMarketFuturesResult)
	--								WHEN intContractTypeId = 1 and (ISNULL(dblFutures,0) > ISNULL(dblFuturesClosingPrice,0)) THEN - abs(dblMarketFuturesResult)
	--								WHEN intContractTypeId = 2  and (ISNULL(dblFutures,0) >= ISNULL(dblFuturesClosingPrice,0)) THEN abs(dblMarketFuturesResult)
	--								WHEN intContractTypeId = 2  and (ISNULL(dblFutures,0) < ISNULL(dblFuturesClosingPrice,0)) THEN - abs(dblMarketFuturesResult) END
--------------END ---------------

IF ISNULL(@ysnIncludeInventoryM2M, 0) = 1
BEGIN
	DECLARE @intSpotMonthId int
		, @strSpotMonth NVARCHAR(100)
	
	SELECT TOP 1 @intSpotMonthId = intFutureMonthId
		, @strSpotMonth = strFutureMonth
	FROM tblRKFuturesMonth
	WHERE ysnExpired = 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmSpotDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10),getdate(), 110), 110)
		AND intFutureMarketId = 1
	ORDER BY dtmSpotDate DESC
	
	INSERT INTO #Temp (strContractOrInventoryType
		, strCommodityCode
		, intCommodityId
		, strItemNo
		, intItemId
		, strLocationName
		, intCompanyLocationId
		, strFutureMonth
		, intFutureMonthId
		, intFutureMarketId
		, dblContractRatio
		, dblFutures
		, dblCash
		, dblNotLotTrackedPrice
		, dblInvFuturePrice
		, dblInvMarketBasis
		, dblMarketRatio
		, dblCosts
		, dblOpenQty
		, dblResult
		, dblCashPrice
		, intCurrencyId)
	SELECT * FROM (
		SELECT strContractOrInventoryType
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strLocationName
			, intLocationId
			, @strSpotMonth strFutureMonth
			, @intSpotMonthId intFutureMonthId
			, intFutureMarketId
			, dblContractRatio = 0
			, dblFutures = 0
			, dblCash = dblNotLotTrackedPrice
			, dblNotLotTrackedPrice
			, dblInvFuturePrice = 0
			, dblInvMarketBasis = 0
			, dblMarketRatio = 0
			, dblCosts = 0
			, SUM(dblOpenQty) dblOpenQty
			, SUM(dblOpenQty) dblResult
			, dblCashOrFuture  = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, intMarketBasisUOM, dblCashOrFuture)
			,intCurrencyId
		FROM (
			SELECT 
				'Inventory' as strContractOrInventoryType
				, s.strLocationName
				, s.intLocationId
				, c.strCommodityCode
				, c.intCommodityId
				, i.strItemNo
				, i.intItemId
				, dblOpenQty = SUM(dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0))))  
						+ 
						ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(col.intUnitMeasureId,@intQuantityUOMId,col.dblOriginalQuantity - ca.dblAdjustmentAmount)
									* CASE WHEN col.strType = 'Sale' THEN -1 ELSE 1 END
							FROM tblRKCollateral col
							LEFT JOIN (
								SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
								WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmTransactionDateUpTo)
								GROUP BY intCollateralId

							) ca on col.intCollateralId = ca.intCollateralId
							WHERE col.intCommodityId = c.intCommodityId
							AND col.intItemId = i.intItemId
							AND col.intLocationId = s.intLocationId
							AND col.ysnIncludeInPriceRiskAndCompanyTitled = 1
						),0)
				, ISNULL((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE c.intCommodityId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE i.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(s.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0) as PriceSourceUOMId
				, dblInvMarketBasis = 0
				,ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE c.intCommodityId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE i.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(s.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0),4) as dblCashOrFuture
				,ISNULL((SELECT TOP 1 ISNULL(temp.intUnitMeasureId,0) FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE c.intCommodityId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE i.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(s.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0) as intMarketBasisUOM
				,ISNULL((SELECT TOP 1 ISNULL(intCurrencyId,0) FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE c.intCommodityId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE i.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(s.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0) as intCurrencyId
				, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) strFutureMonth
				, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) intFutureMonthId
				, c.intFutureMarketId
				, dblNotLotTrackedPrice = dbo.fnCalculateQtyBetweenUOM(iuomTo.intItemUOMId, iuomStck.intItemUOMId,  ISNULL(dbo.fnCalculateValuationAverageCost(i.intItemId, s.intItemLocationId, @dtmTransactionDateUpTo), 0))
				, cu2.intCommodityUnitMeasureId intToPriceUOM
			FROM vyuRKGetInventoryValuation s
			JOIN tblICItem i on i.intItemId=s.intItemId
			JOIN tblICCommodity c on i.intCommodityId = c.intCommodityId
			JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
			JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
			JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cu2 on cu2.intCommodityId=c.intCommodityId and cu2.intUnitMeasureId=@intPriceUOMId
			JOIN tblICCommodityUnitMeasure cu1 on cu1.intCommodityId=c.intCommodityId and cu1.ysnStockUnit = 1
			LEFT JOIN tblSCTicket t on s.intSourceId = t.intTicketId
			LEFT JOIN tblICItemPricing p on i.intItemId = p.intItemId and s.intItemLocationId=p.intItemLocationId
			WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <>0 
				AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) 
				AND ISNULL(strTicketStatus,'') <> 'V'
				AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmTransactionDateUpTo)
				AND ysnInTransit = 0
			GROUP BY i.intItemId
					,i.strItemNo
					,s.intItemLocationId
					,s.intLocationId
					,strLocationName
					,strCommodityCode
					,c.intCommodityId
					,c.intFutureMarketId
					,cuom.intCommodityUnitMeasureId
					,iuomTo.intItemUOMId
					,iuomStck.intItemUOMId
					,cu2.intCommodityUnitMeasureId
					
		) t1
		GROUP BY strContractOrInventoryType
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, PriceSourceUOMId
			, strLocationName
			, intLocationId
			, strFutureMonth
			, intFutureMonthId
			, intFutureMarketId
			, dblNotLotTrackedPrice
			, dblInvMarketBasis
			, intMarketBasisUOM
			, PriceSourceUOMId
			,intCurrencyId,dblCashOrFuture
	)t2 WHERE ISNULL(dblOpenQty,0) <> 0
END


	IF @ysnIncludeInTransitM2M = 1
	BEGIN
		INSERT INTO #Temp (strContractOrInventoryType
			, strContractSeq
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strLocationName
			, intCompanyLocationId
			, strFutureMonth
			, intFutureMonthId
			, intFutureMarketId
			, dblContractRatio
			, dblFutures
			, dblCash
			, dblNotLotTrackedPrice
			, dblInvFuturePrice
			, dblInvMarketBasis
			, dblMarketRatio
			, dblCosts
			, dblOpenQty
			, dblResult
			, dblCashPrice
			, intCurrencyId)
		SELECT * FROM (
			SELECT strContractOrInventoryType
				, strContractSeq
				, strCommodityCode
				, intCommodityId
				, strItemNo
				, intItemId
				, strLocationName
				, intCompanyLocationId
				, @strSpotMonth strFutureMonth
				, @intSpotMonthId intFutureMonthId
				, intFutureMarketId
				, dblContractRatio = 0
				, dblFutures = 0
				, dblCash = dblNotLotTrackedPrice
				, dblNotLotTrackedPrice
				, dblInvFuturePrice = 0
				, dblInvMarketBasis = 0
				, dblMarketRatio = 0
				, dblCosts = 0
				, dblOpenQty
				, dblResult = dblOpenQty
				, dblCashOrFuture  = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, intMarketBasisUOM, dblCashOrFuture)
				,intCurrencyId
			FROM (
				SELECT 
					'In-transit(I)' as strContractOrInventoryType
					, strContractSeq
					, strLocationName
					, intCompanyLocationId
					, strCommodityCode
					, intCommodityId
					, strItemNo
					, intItemId
					, dblOpenQty = ABS(dblOpenQty)
					, ISNULL((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE intCommodityId END
								AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE intItemId END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId,0) END
								AND temp.strContractInventory = 'Inventory'),0) as PriceSourceUOMId
					, dblInvMarketBasis = 0
					,ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE intCommodityId END
								AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE intItemId END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId,0) END
								AND temp.strContractInventory = 'Inventory'),0),4) as dblCashOrFuture
					,ISNULL((SELECT TOP 1 ISNULL(temp.intUnitMeasureId,0) FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE intCommodityId END
								AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE intItemId END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId,0) END
								AND temp.strContractInventory = 'Inventory'),0) as intMarketBasisUOM
					,ISNULL((SELECT TOP 1 ISNULL(intCurrencyId,0) FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND ISNULL(temp.intCommodityId,0) = CASE WHEN ISNULL(temp.intCommodityId,0)= 0 THEN 0 ELSE intCommodityId END
								AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE intItemId END
								AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId,0) END
								AND temp.strContractInventory = 'Inventory'),0) as intCurrencyId
					, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =intFutureMarketId  ORDER BY 1 DESC) strFutureMonth
					, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =intFutureMarketId  ORDER BY 1 DESC) intFutureMonthId
					, intFutureMarketId
					, dblNotLotTrackedPrice =  ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmTransactionDateUpTo), 0)
				FROM @tblFinalDetail
				WHERE strContractOrInventoryType = 'In-transit(S)'
					
					
			) t1
		)t2 WHERE ISNULL(dblOpenQty,0) <> 0
	END

	--Derivative Entries
	IF @ysnIncludeDerivatives = 1
	BEGIN
		
		INSERT INTO #Temp (strContractOrInventoryType
			, intTransactionId
			, strContractSeq
			, strEntityName
			, intEntityId
			, strCommodityCode
			, intCommodityId
			, strLocationName
			, intCompanyLocationId
			, strFutureMonth
			, intFutureMonthId
			, strFutMarketName
			, intFutureMarketId
			, dblFutures
			, dblOpenQty
			, dblInvFuturePrice
			, intCurrencyId)
		SELECT  
			  strContractOrInventoryType = CASE WHEN strNewBuySell = 'Buy' THEN 'Futures(B)' ELSE 'Futures(S)' END
			, intFutOptTransactionHeaderId
			, strInternalTradeNo
			, strBroker
			, intEntityId
			, strCommodityCode
			, intCommodityId
			, strLocationName
			, intLocationId
			, strFutureMonth
			, DER.intFutureMonthId
			, strFutureMarket
			, DER.intFutureMarketId
			, dblPrice
			, dblOpenQty = dblOpenContract * dblContractSize
			, dblInvFuturePrice = SP.dblLastSettle
			, intCurrencyId
		FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900',@dtmTransactionDateUpTo, 1) DER
		LEFT JOIN @tblGetSettlementPrice SP ON SP.intFutureMarketId = DER.intFutureMarketId AND SP.intFutureMonthId = DER.intFutureMonthId
		WHERE intCommodityId = @intCommodityId 
			AND ysnPreCrush = 0 
			AND ysnExpired = 0
			AND intInstrumentTypeId = 1
			AND dblOpenContract <> 0

	END


DECLARE @strM2MCurrency NVARCHAR(20)
	, @dblRateConfiguration NUMERIC(18,6)

SELECT @strM2MCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyUOMId

SELECT TOP 1 @dblRateConfiguration = dblRate
FROM vyuSMForex
WHERE intFromCurrencyId = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'CAD')
	AND intToCurrencyId = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD')
	AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
ORDER BY dtmValidFromDate DESC

DECLARE @intCurrencyExchangeRateId INT
SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
FROM tblSMCurrencyExchangeRate CER
INNER JOIN tblSMCurrency Cur1 ON CER.intFromCurrencyId = Cur1.intCurrencyID
INNER JOIN tblSMCurrency Cur2 ON CER.intToCurrencyId = Cur2.intCurrencyID
WHERE Cur1.strCurrency = 'CAD' AND Cur2.strCurrency = 'USD'

---------------------------------
SELECT intRowNum = CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC))
	, intConcurrencyId = 0
	, intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dblOpenQty dblOpenQty
	, strCommodityCode
	, intCommodityId
	, intItemId
	, strItemNo
	, strOrgin
	, strPosition
	, strPeriod
	, strPeriodTo
	, strStartDate
	, strEndDate
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblContractRatio
	, dblContractBasis
	, dblFutures
	, dblCash
	, dblCosts
	, dblMarketBasis
	, dblMarketRatio
	, dblFuturePrice
	, intContractTypeId
	, dblAdjustedContractPrice
	, dblCashPrice
	, dblMarketPrice
	, dblResultBasis
	, dblResultCash
	, dblContractPrice
	, intQuantityUOMId
	, intCommodityUnitMeasureId
	, intPriceUOMId
	, intCent
	, dtmPlannedAvailabilityDate
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, intCompanyLocationId
	, intMarketZoneId
	, strMarketZoneCode
	, strLocationName 
	, dblResult = case when strPricingType='Cash' then 
							ROUND(dblResultCash,2) 
						else 
							ROUND((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty,2)
				  end
	, dblMarketFuturesResult = CASE WHEN strContractOrInventoryType = 'Inventory' THEN 0
									WHEN strPricingType = 'Basis' then 0
									ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) + (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty)
									END
	, dblResultRatio = (CASE WHEN dblContractRatio <> 0 AND dblMarketRatio  <> 0 THEN ((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty)
								- (CASE WHEN strContractOrInventoryType = 'Inventory' THEN 0
										WHEN strPricingType = 'Basis' then 0
										ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) + (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty) END)
								- dblResultBasis
							WHEN strContractOrInventoryType = 'Inventory' THEN
								0
							ELSE 0 END)
	, intSpreadMonthId
	, strSpreadMonth
	, dblSpreadMonthPrice
	, dblSpread
FROM (
	SELECT intConcurrencyId = 0
		, intContractHeaderId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dblOpenQty
		, strCommodityCode
		, intCommodityId
		, intItemId
		, strItemNo
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio = ISNULL(dblContractRatio,0)
		--Contract Basisc
		, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
									THEN (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
												--CAD/CAD
												THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId THEN dblContractBasis
														--USD/CAD
														WHEN strMainCurrency = 'USD'
															THEN (CASE WHEN @strRateType = 'Contract'
																		--Formula: Contract Price - Contract Futures
																		THEN ((ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																			/ dblRate)
																			- (dblCalculatedFutures)
																	--Configuration
																	--Formula: Contract Price - Contract Futures
																	ELSE ((ISNULL(dblContractBasis, 0)
																			+ (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1))
																			+ ISNULL(dblCash, 0)) / @dblRateConfiguration)
																		- dblCalculatedFutures END)
														--Can be used other currency exchange
														ELSE dblContractBasis END)
												ELSE dblContractBasis END)
								ELSE 0 END)
		--Contract Futures
		, dblActualFutures = dblCalculatedFutures
		, dblFutures = (CASE WHEN strPricingType = 'Basis' AND strPriOrNotPriOrParPriced = 'Partially Priced' THEN dblFutures --((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
				WHEN strPricingType = 'Basis' THEN ISNULL(dblFutures,0)
				WHEN strPricingType = 'Priced' THEN ISNULL(dblFutures,0)
				ELSE dblCalculatedFutures END)
		, dblCash  --Contract Cash
		, dblCosts = ABS(dblCosts)
		--Market Basis
		, dblMarketBasis = (CASE WHEN strPricingType != 'HTA' THEN
								CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															--Formula: Market Price - Market Futures
															THEN ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0))
																/ dblRate)
																- dblConvertedFuturePrice
														--Configuration
														--Formula: Market Price - Market Futures
														ELSE ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0))
															/ @dblRateConfiguration) - dblConvertedFuturePrice END)
											--When both currencies is not equal to M2M currency
											WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
												THEN ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0)
											--Can be used other currency exchange
											ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END)
								ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END

							ELSE 0 END)
		, dblMarketRatio
		, dblFuturePrice = dblConvertedFuturePrice  --Market Futures
		, intContractTypeId
		, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
														--CAD/CAD
														THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts,0)
													WHEN strMainCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) +  ISNULL(dblCash, 0) + ISNULL(dblCosts,0))
																		/ dblRate
																--Configuration
																ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts,0))
																	/ @dblRateConfiguration END)
													--Can be used other currency exchange
													ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts,0) END)
										ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts,0) END)
		, dblCashPrice
		--Market Price
		, dblMarketPrice = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															THEN (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0))
																/ dblRate
															--Configuration
															ELSE (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0))
																/ @dblRateConfiguration END)
											--When both currencies is not equal to M2M currency
											WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
												THEN ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0)
											--Can be used other currency exchange
											ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0) END)
								ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblConvertedFuturePrice,0) * case when ISNULL(dblMarketRatio, 0)=0 then 1 else ISNULL(dblMarketRatio, 0) end) + ISNULL(dblCashPrice, 0) END
		, dblResultBasis = dblResultBasis
		, dblResultCash
		--Contract Price
		, dblContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
												--CAD/CAD
												THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) +  ISNULL(dblCash, 0)
											WHEN strMainCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																/ dblRate
														--Configuration
														ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
															/ @dblRateConfiguration END)
											--Can be used other currency exchange
											ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
								ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, t.intCent
		, dtmPlannedAvailabilityDate
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread
		, t.ysnExpired
	FROM (
		SELECT t.*
			, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' then dblConvertedFuturePrice
										WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
											THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
										ELSE dblFutures END), 0)
		FROM (
			SELECT #Temp.*
				, dblRate = ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
									WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
										AND ISNULL(dblRate, 0) <> 0
										AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
										AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
				, dblConvertedFuturePrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
													--CAD/CAD
													THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId THEN ISNULL(dblFuturePrice, 0)
															--USD/CAD
															WHEN Currency.strCurrency = 'USD'
																THEN (CASE WHEN @strRateType = 'Contract' THEN ISNULL(dblFuturePrice, 0) / 
																		ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
																				WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																					AND ISNULL(dblRate, 0) <> 0
																					AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																					AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
																		ELSE ISNULL(dblFuturePrice, 0) / @dblRateConfiguration END)
															--Can be used other currency exchange
															ELSE ISNULL(dblFuturePrice, 0) END)
													ELSE ISNULL(dblFuturePrice, 0) END)
												
				, strMainCurrency = Currency.strCurrency
				, strMBCurrency = MBCurrency.strCurrency
				, strFPCurrency = FPCurrency.strCurrency
			FROM #Temp
			LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = #Temp.intCurrencyId
			LEFT JOIN tblSMCurrency MBCurrency ON MBCurrency.intCurrencyID = #Temp.intMarketBasisCurrencyId
			LEFT JOIN tblSMCurrency FPCurrency ON FPCurrency.intCurrencyID = #Temp.intFuturePriceCurrencyId
		) t
	) t
	WHERE dblOpenQty <> 0 and intContractHeaderId is not NULL 
	
	UNION ALL SELECT intConcurrencyId = 0
		, intContractHeaderId = intTransactionId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dblOpenQty
		, strCommodityCode
		, intCommodityId
		, intItemId
		, strItemNo
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio
		, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
									THEN (CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0
											ELSE (CASE WHEN @ysnCanadianCustomer = 1 THEN dblCanadianFutures + dblCanadianContractBasis - ISNULL(dblFutures, 0)
													ELSE dblContractBasis END) END)
								ELSE 0 END)
		, dblActualFutures = dblFutures
		, dblFutures = (CASE WHEN strPricingType = 'Basis' THEN 0
							ELSE dblFutures END)
		, dblCash = ISNULL(dblCash,0)
		, dblCosts = ABS(ISNULL(dblCosts,0))
		, dblMarketBasis = ISNULL(dblInvMarketBasis,0)
		, dblMarketRatio = ISNULl(dblMarketRatio,0)
		, dblFuturePrice = ISNULL(dblInvFuturePrice,0)
		, intContractTypeId
		, dblAdjustedContractPrice =  CASE WHEN strContractOrInventoryType like 'Futures%' THEN dblFutures ELSE  ISNULL(dblCash,0) END
		, dblCashPrice  = ISNULL(dblCashPrice,0)
		, dblMarketPrice = ISNULL(dblInvMarketBasis, 0) + ISNULL(dblInvFuturePrice, 0)  + ISNULL(dblCashPrice,0)
		, dblResultBasis = 0
		, dblResultCash =  ROUND((ISNULL(dblCashPrice,0) - ISNULL(dblCash, 0)) * Round(dblOpenQty,2),2)
		, dblContractPrice = CASE WHEN strContractOrInventoryType like 'Futures%' THEN dblFutures ELSE  ISNULL(dblCash,0) END
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, intCent
		, dtmPlannedAvailabilityDate
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName 
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread
		, ysnExpired
	FROM #Temp 
	WHERE  dblOpenQty <> 0 AND intContractHeaderId IS NULL
)t 
ORDER BY intContractHeaderId DESC

DROP TABLE #tblPriceFixationDetail
DROP TABLE #tblContractCost
DROP TABLE #tblSettlementPrice
DROP TABLE #tblContractFuture
DROP TABLE #tempIntransit
DROP TABLE #tblPIntransitView
DROP TABLE #Temp

END
