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
				       
DECLARE @ysnIncludeBasisDifferentialsInResults BIT
DECLARE @dtmPriceDate DATETIME    
DECLARE @dtmSettlemntPriceDate DATETIME  
DECLARE @strLocationName NVARCHAR(200)
DECLARE @ysnIncludeInventoryM2M BIT
DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
DECLARE @ysnCanadianCustomer BIT
DECLARE @intDefaultCurrencyId int
DECLARE @ysnM2MAllowExpiredMonth BIT = 0

SELECT @dtmPriceDate = dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId = @intM2MBasisId

SELECT TOP 1 @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
	, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
	, @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M
	, @ysnCanadianCustomer = ISNULL(ysnCanadianCustomer, 0)
	, @ysnM2MAllowExpiredMonth = ysnM2MAllowExpiredMonth
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
	, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intOriginId INT
	, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
	, dblPriceWORollArb NUMERIC(24,10))

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
	, dblBalance DECIMAL(24,10)
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
	, intFutureMonthId INT)

INSERT INTO @tblGetOpenContractDetail (intRowNum
	, strCommodityCode
	, intCommodityId
	, intContractHeaderId
	, strContractNumber
	, strLocationName
	, dtmEndDate
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
	, intFutureMonthId)
SELECT 
	ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC) intRowNum
	,strCommodityCode
	,intCommodityId
	,intContractHeaderId
	,strContract
	,strLocationName
	,dtmSeqEndDate
	,dblQuantity
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
	, CD.dblConvertedBasis dblBasis
	, CD.dblFutures
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
	, CD.dblNoOfLots
	, PF.dblLotsFixed
	, PF.dblPriceWORollArb
	, CH.dblNoOfLots dblHeaderNoOfLots
	, CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS ysnSubCurrency
	, CD.intCompanyLocationId
	, MO.ysnExpired
	, strPricingStatus
	, CA.strDescription as strOrgin
	, ISNULL(ysnMultiplePriceFixation,0) as ysnMultiplePriceFixation
	, FM.intUnitMeasureId intMarketUOMId
	, FM.intCurrencyId intMarketCurrencyId
	, dblInvoicedQty AS dblInvoicedQuantity
	, ISNULL(CASE WHEN CD.intPricingTypeId = 1 and PF.intPriceFixationId is NULL then CD.dblQuantity else PF.dblQuantity end,0) dblPricedQty
	, ISNULL(CASE WHEN CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NOT NULL THEN ISNULL(CD.dblQuantity,0)-ISNULL(PF.dblQuantity ,0)
				WHEN CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NULL then ISNULL(CD.dblQuantity,0)
				ELSE 0 end,0) dblUnPricedQty
	, ISNULL(CASE WHEN CD.intPricingTypeId =1 and PF.intPriceFixationId is NULL then CD.dblCashPrice else PF.dblFinalPrice end,0) dblPricedAmount
	, MZ.strMarketZoneCode
FROM tblCTContractHeader CH
INNER JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
INNER JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId AND CD.intContractStatusId not in(2,3,6)
INNER JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
INNER JOIN tblICItem IM ON IM.intItemId = CD.intItemId
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
INNER JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
INNER JOIN #tblPriceFixationDetail PF ON PF.intContractDetailId = CD.intContractDetailId
LEFT JOIN @tblGetOpenContractDetail OCD ON CD.intContractDetailId = OCD.intContractDetailId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = CD.intMarketZoneId
WHERE CH.intCommodityId = @intCommodityId
	AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty,0)
	AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
	AND ISNULL(CD.intMarketZoneId, 0) = ISNULL(@intMarketZoneId, ISNULL(CD.intMarketZoneId, 0))
	AND CD.intContractStatusId not in(2,3,6) 
	AND CONVERT(DATETIME,CONVERT(VARCHAR, OCD.dtmContractDate, 101),101) <= @dtmTransactionDateUpTo

SELECT intContractDetailId
	, SUM(dblCosts) dblCosts
INTO #tblContractCost
FROM (
	SELECT CASE WHEN strAdjustmentType = 'Add'
					THEN ABS(CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
								ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate,0))) END)
				WHEN strAdjustmentType = 'Reduce'
					THEN CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
							ELSE - SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate,0))) END
					ELSE 0 END dblCosts
		, strAdjustmentType
		, dc.intContractDetailId
	FROM @GetContractDetailView cd
	INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	INNER JOIN tblRKM2MConfiguration M2M ON dc.intItemId = M2M.intItemId AND ch.intContractBasisId = M2M.intContractBasisId AND dc.intItemId = M2M.intItemId
	INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
	LEFT  JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
	GROUP BY cu.intCommodityUnitMeasureId
		, cu1.intCommodityUnitMeasureId
		, strAdjustmentType
		, dc.intContractDetailId
		, dc.strCostMethod
) t
GROUP BY intContractDetailId

DECLARE @tblSettlementPrice TABLE (intContractDetailId INT
	, dblFuturePrice NUMERIC(24, 10)
	, dblFutures NUMERIC(24, 10)
	, intFuturePriceCurrencyId INT)

DECLARE @tblGetSettlementPrice TABLE (dblLastSettle NUMERIC(24,10)
	, intFutureMonthId INT
	, intFutureMarketId INT)

IF (@ysnM2MAllowExpiredMonth = 1)
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
	, dblMarketBasisUOM NUMERIC(24, 10)
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
	, dblMarketBasisUOM
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
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblRatio
	, CASE WHEN ISNULL(intPricingTypeId, 0) = 3 THEN dblMarketBasis1 ELSE dblContractBasis END dblContractBasis
	, dblDummyContractBasis
	, dblCash
	, dblFuturesClosingPrice1
	, dblFutures 
	, dblMarketRatio
	, CASE WHEN intPricingTypeId = 6 THEN 0 ELSE dblMarketBasis1 END dblMarketBasis1
	, dblMarketBasisUOM
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
	, CASE WHEN intPricingTypeId = 6 THEN dblMarketBasis1 ELSE 0 END dblCashPrice
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
		, CASE WHEN cd.intPricingTypeId=2 THEN dblFuturePrice
				ELSE case when cd.intPricingTypeId in(1,3) then ISNULL(p.dblFutures,0) else dblFuture end END AS dblFutures
		, (SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
			LEFT JOIN tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
			WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
				AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,stuff(cd.strFutureMonth,5,0,'20')),106),8))  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
				) AS dblMarketRatio
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
						THEN ISNULL(temp.strPeriodTo,'') ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,stuff(cd.strFutureMonth,5,0,'20')),106),8))  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
					),0) AS dblMarketBasis1
		, ISNULL((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp
					JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0) END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,stuff(cd.strFutureMonth,5,0,'20')),106),8))  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
					),0) AS dblMarketBasisUOM
		, ISNULL((SELECT top 1 intCurrencyId as intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
					JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
					WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
						and ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
						and ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
						and ISNULL(temp.intContractTypeId,0) = CASE WHEN ISNULL(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
						AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId,0)  END
						AND ISNULL(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo,'')= '' 
						THEN ISNULL(temp.strPeriodTo,'') ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,stuff(cd.strFutureMonth,5,0,'20')),106),8))  END else ISNULL(temp.strPeriodTo,'') end
						AND temp.strContractInventory = 'Contract'
					),0) AS intMarketBasisCurrencyId
		, p.dblFuturePrice as dblFuturePrice1
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
	SELECT intLineNo = (SELECT TOP 1 intLineNo FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intOrderId IS NOT NULL)
		, dblBalanceToInvoice = SUM(Inv.dblQuantity)
			+ ISNULL((SELECT SUM(iv.dblQty) FROM tblARInvoiceDetail id
					JOIN tblARInvoice i on id.intInvoiceId = i.intInvoiceId
					JOIN tblICInventoryTransaction iv ON id.intInvoiceDetailId = iv.intTransactionDetailId
					WHERE iv.intInTransitSourceLocationId IS NOT NULL
						AND intTransactionTypeId = 33 --'Invoice'
						and iv.intItemId = Inv.intItemId
						and id.strDocumentNumber = Inv.strTransactionId
						and CONVERT(DATETIME,@dtmTransactionDateUpTo) = CONVERT(DATETIME, CONVERT(VARCHAR(10), i.dtmPostDate, 110), 110)), 0)
		, ysnInvoicePosted = (CASE WHEN CONVERT(DATETIME,@dtmTransactionDateUpTo) = CONVERT(DATETIME, CONVERT(VARCHAR(10), i.dtmPostDate, 110), 110) AND i.ysnPosted = 1 THEN 1 ELSE 0 END)
		, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), Inv.dtmDate, 106), 8)
	FROM vyuRKGetInventoryValuation Inv
	INNER JOIN tblICItem I ON Inv.intItemId = I.intItemId
	INNER JOIN tblICCommodity C ON I.intCommodityId = C.intCommodityId
	LEFT JOIN tblARInvoiceDetail invD ON  Inv.intTransactionDetailId = invD.intInventoryShipmentItemId AND invD.strDocumentNumber = Inv.strTransactionId
	LEFT JOIN tblARInvoice i ON invD.intInvoiceId = i.intInvoiceId
	OUTER APPLY (SELECT ch.intContractHeaderId, strFutureMonth, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
				FROM @GetContractDetailView ch
				WHERE ch.intContractHeaderId = (SELECT TOP 1  intOrderId FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intOrderId IS NOT NULL)
					AND intContractSeq = (SELECT TOP 1  intContractSeq FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intOrderId IS NOT NULL)) CT
	WHERE Inv.ysnInTransit = 1
		AND Inv.strTransactionType = 'Inventory Shipment'
		AND C.intCommodityId = @intCommodityId
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmTransactionDateUpTo)
	GROUP BY Inv.strTransactionId
		, Inv.intTransactionId
		, Inv.dtmDate
		, Inv.strLocationName
		, Inv.strUOM
		, Inv.intEntityId
		, Inv.strEntity
		, C.intCommodityId
		, Inv.intItemId
		, Inv.strItemNo
		, Inv.strCategory
		, Inv.intCategoryId
		, i.ysnPosted
		, i.dtmPostDate
		, CT.strFutureMonth
		, CT.strDeliveryDate
) tbl
WHERE dblBalanceToInvoice <> 0 AND ISNULL(ysnInvoicePosted,0) <> 1

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
    , strOrgin 
    , intOriginId 
    , strPosition 
    , strPeriod 
    , strPeriodTo
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
    , dblPriceWORollArb)
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
			, (ISNULL(convert(decimal(24,6),case when ISNULL(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,ISNULL(dblOpenQty1,0))end),0))
				-(ISNULL(convert(decimal(24,6),case when ISNULL(intCommodityUnitMeasureId,0) = 0 then dblInvoicedQuantity else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,ISNULL(dblInvoicedQuantity,0))end),0)) as dblOpenQty
		FROM (
			SELECT DISTINCT cd.intContractHeaderId
				, cd.intContractDetailId
                , 'In-transit' + '(S)' as strContractOrInventoryType
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
				, cd.strPriOrNotPriOrParPriced
                , cd.intPricingTypeId
                , cd.strPricingType
				, cd.dblContractRatio
                , cd.dblContractBasis
				, dblDummyContractBasis
				, cd.dblFutures
				, cd.dblCash
				, cd.dblMarketRatio
				, cd.dblMarketBasis1
				, cd.dblMarketBasisUOM
				, cd.intMarketBasisCurrencyId
				, cd.dblFuturePrice1
				, cd.intFuturePriceCurrencyId
				, cd.dblFuturesClosingPrice1
				, cd.intContractTypeId
				, 0 as intConcurrencyId
				, sum(it.dblBalanceToInvoice) over (partition By cd.intContractDetailId) dblOpenQty1
				, cd.dblRate
				, cd.intCommodityUnitMeasureId
				, cd.intQuantityUOMId
				, cd.intPriceUOMId
				, cd.intCurrencyId
				, cd.PriceSourceUOMId
				, cd.dblCosts
				, cd.ysnSubCurrency
				, cd.intMainCurrencyId
				, cd.intCent
				, cd.dtmPlannedAvailabilityDate
				, cd.dblInvoicedQuantity
				, cd.intMarketZoneId
				, cd.intCompanyLocationId
				, cd.strMarketZoneCode
				, cd.strLocationName
				, cd.dblNoOfLots
				, cd.dblLotsFixed
				, cd.dblPriceWORollArb
				, dblCashPrice
			FROM #tempIntransit it
			JOIN @tblOpenContractList cd on cd.intContractDetailId = it.intLineNo
			JOIN tblICItem i on cd.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
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
		, dblPriceWORollArb)
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
	FROM (
		SELECT *
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResult
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResultBasis
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblMarketFuturesResult
			, (ISNULL(dblMarketBasis,0)-ISNULL(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty1,0))) dblResultCash1
			, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblContractBasis,0)),0)+(ISNULL(dblFutures,0) * ISNULL(dblContractRatio,1)) dblContractPrice
		FROM (
			SELECT *
				, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,ISNULL(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
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
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice
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
					, cd.dblMarketBasisUOM
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
					, cd.dblPriceWORollArb,dblCashPrice
				FROM @tblOpenContractList cd
				JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId =l.intContractDetailId
				JOIN tblICItem i on cd.intItemId= i.intItemId and i.strLotTracking<>'No'
				WHERE cd.intCommodityId= @intCommodityId
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
	, dblPriceWORollArb)
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
FROM (
	SELECT *
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResult
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblResultBasis
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) as dblMarketFuturesResult
		, (ISNULL(dblMarketBasis,0)-ISNULL(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty,0))) dblResultCash1
		, 0 dblContractPrice
	FROM (
		SELECT *
			, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when ISNULL(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,ISNULL(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
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
				- ISNULL(convert(decimal(24,6), case when ISNULL(intCommodityUnitMeasureId,0) = 0 then InTransQty
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,InTransQty) end),0)
				- ISNULL(convert(decimal(24,6), case when ISNULL(intCommodityUnitMeasureId,0) = 0 then dblInvoicedQuantity
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when ISNULL(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblInvoicedQuantity) end),0) as dblOpenQty
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
				, cd.dblMarketBasisUOM
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
				, cd.ysnExpired
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, strMarketZoneCode
				, strLocationName
				, cd.dblNoOfLots
				, cd.dblLotsFixed
				, cd.dblPriceWORollArb
				, dblCashPrice
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
		) t
	) t where ISNULL(dblOpenQty,0) > 0
) t1

SELECT *
	, ISNULL(dblContractBasis,0) + (ISNULL(dblFutures,0) * ISNULL(dblContractRatio,1)) as dblContractPrice
	, convert(decimal(24,6),((ISNULL(dblContractBasis,0)+ISNULL(dblCosts,0))-ISNULL(dblMarketBasis,0))*ISNULL(dblResultBasis1,0)) + convert(decimal(24,6),((ISNULL(dblFutures,0)- ISNULL(dblFuturePrice,0))*ISNULL(dblMarketFuturesResult1,0))) dblResult
	, convert(decimal(24,6),((ISNULL(dblContractBasis,0)+ISNULL(dblCosts,0))-ISNULL(dblMarketBasis,0))*ISNULL(dblResultBasis1,0)) dblResultBasis
	, convert(decimal(24,6),((ISNULL(dblFutures,0)- ISNULL(dblFuturePrice,0))*ISNULL(dblMarketFuturesResult1,0))) dblMarketFuturesResult
	, case when strPricingType='Cash' then convert(decimal(24,6),(ISNULL(dblCash,0)-ISNULL(dblCashPrice,0))*ISNULL(dblResult1,0))
			else NULL end as dblResultCash
INTO #Temp
FROM (
	SELECT intContractHeaderId
		, intContractDetailId
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
				else convert(decimal(24,6), case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId) * dblFutures
			else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then dblFutures * dblRate
					else dblFutures end end) end as dblFutures
		, convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash
		, dblCosts as dblCosts
		, dblMarketRatio
		, case when @ysnCanadianCustomer= 1 then dblMarketBasis
			else convert(decimal(24,6),case when ISNULL(dblRate,0)=0 then dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0))
											else case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId
														then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0)) * dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when ISNULL(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,ISNULL(dblMarketBasis,0)) end end) end as dblMarketBasis
		, intMarketBasisCurrencyId
		, dblFuturePrice1 as dblFuturePrice
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
	FROM @tblFinalDetail
) t
ORDER BY intCommodityId,strContractSeq DESC

------------- Calculation of Results ----------------------
UPDATE #Temp
SET dblResultBasis = CASE WHEN intContractTypeId = 1 and (ISNULL(dblContractBasis,0) <= dblMarketBasis) THEN abs(dblResultBasis)
						WHEN intContractTypeId = 1 and (ISNULL(dblContractBasis,0) > dblMarketBasis) THEN - abs(dblResultBasis)
						WHEN intContractTypeId = 2  and (ISNULL(dblContractBasis,0) >= dblMarketBasis) THEN abs(dblResultBasis)
						WHEN intContractTypeId = 2  and (ISNULL(dblContractBasis,0) < dblMarketBasis) THEN - abs(dblResultBasis) END
	, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 and (ISNULL(dblFutures,0) <= ISNULL(dblFuturesClosingPrice,0)) THEN abs(dblMarketFuturesResult)
									WHEN intContractTypeId = 1 and (ISNULL(dblFutures,0) > ISNULL(dblFuturesClosingPrice,0)) THEN - abs(dblMarketFuturesResult)
									WHEN intContractTypeId = 2  and (ISNULL(dblFutures,0) >= ISNULL(dblFuturesClosingPrice,0)) THEN abs(dblMarketFuturesResult)
									WHEN intContractTypeId = 2  and (ISNULL(dblFutures,0) < ISNULL(dblFuturesClosingPrice,0)) THEN - abs(dblMarketFuturesResult) END
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
		, strFutureMonth
		, intFutureMonthId
		, intFutureMarketId
		, strFutMarketName
		, dblNotLotTrackedPrice
		, dblInvFuturePrice
		, dblInvMarketBasis
		, dblOpenQty
		, dblResult)
	SELECT * FROM (
		SELECT strContractOrInventoryType
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strLocationName
			, @strSpotMonth strFutureMonth
			, @intSpotMonthId intFutureMonthId
			, intFutureMarketId
			, strFutMarketName
			, dblNotLotTrackedPrice
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM, intFutMarketCurrency, (SELECT TOP 1 dblLastSettle
																								FROM tblRKFuturesSettlementPrice p
																								INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
																								WHERE p.intFutureMarketId = t1.intFutureMarketId AND pm.intFutureMonthId = @intSpotMonthId
																								ORDER BY dtmPriceDate DESC)) dblInvFuturePrice
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM,PriceSourceUOMId,ISNULL(dblInvMarketBasis, 0)) dblInvMarketBasis
			, SUM(dblOpenQty) dblOpenQty
			, SUM(dblOpenQty1) dblResult
		FROM (
			SELECT DISTINCT 'Inventory' as strContractOrInventoryType
				, iv.strLocationName
				, c.strCommodityCode
				, iv.intCommodityId
				, iv.strItemNo
				, iv.intItemId as intItemId
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId,cu.intCommodityUnitMeasureId,ISNULL(iv.dblOnHand, 0)) dblOpenQty
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId,cu2.intCommodityUnitMeasureId,ISNULL(iv.dblOnHand, 0)) dblOpenQty1
				, ISNULL((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND temp.intItemId = iv.intItemId
							AND ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE c.intFutureMarketId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE iv.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(iv.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0) as PriceSourceUOMId
				, ISNULL((SELECT TOP 1 ISNULL(dblBasisOrDiscount,0) FROM tblRKM2MBasisDetail temp
						WHERE temp.intM2MBasisId = @intM2MBasisId
							AND temp.intItemId = iv.intItemId
							AND ISNULL(temp.intFutureMarketId,0) = CASE WHEN ISNULL(temp.intFutureMarketId,0)= 0 THEN 0 ELSE c.intFutureMarketId END
							AND ISNULL(temp.intItemId,0) = CASE WHEN ISNULL(temp.intItemId,0)= 0 THEN 0 ELSE iv.intItemId END
							AND ISNULL(temp.intCompanyLocationId,0) = CASE WHEN ISNULL(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE ISNULL(iv.intLocationId,0) END
							AND temp.strContractInventory = 'Inventory'),0) as dblInvMarketBasis
				, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) strFutureMonth
				, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) intFutureMonthId
				, c.intFutureMarketId
				, fm.strFutMarketName
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu2.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,ISNULL(p.dblAverageCost, 0)) dblNotLotTrackedPrice
				, cu2.intCommodityUnitMeasureId intToPriceUOM
				, cu3.intCommodityUnitMeasureId intFutMarketCurrency
			FROM vyuICGetItemStockUOM iv
			JOIN tblICCommodity c on iv.intCommodityId=c.intCommodityId and ysnStockUnit=1
			JOIN tblRKFutureMarket fm on c.intFutureMarketId=fm.intFutureMarketId
			JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=c.intCommodityId and cu.intUnitMeasureId=@intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cu2 on cu2.intCommodityId=c.intCommodityId and cu2.intUnitMeasureId=@intPriceUOMId
			JOIN tblICCommodityUnitMeasure cu1 on cu1.intCommodityId=c.intCommodityId and ISNULL(cu1.ysnStockUOM,0)=1
			JOIN tblICCommodityUnitMeasure cu3 on cu3.intCommodityId=@intCommodityId and cu3.intUnitMeasureId=fm.intUnitMeasureId
			LEFT JOIN tblICItemPricing p on iv.intItemId = p.intItemId and iv.intItemLocationId=p.intItemLocationId
			WHERE iv.intCommodityId= @intCommodityId and iv.strLotTracking='No' and iv.dblOnHand <> 0
				AND strLocationName= case when ISNULL(@strLocationName, '') = '' then strLocationName else @strLocationName end
		) t1
		GROUP BY strContractOrInventoryType
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, PriceSourceUOMId
			, strLocationName
			, strFutureMonth
			, intFutureMonthId
			, intFutureMarketId
			, strFutMarketName
			, dblNotLotTrackedPrice
			, dblInvMarketBasis
			, intToPriceUOM
			, PriceSourceUOMId
			, intFutMarketCurrency
	)t2 WHERE ISNULL(dblOpenQty,0) > 0
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
	, dblResult = case when strPricingType='Cash' then dblResultCash else (dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty end
	, dblMarketFuturesResult = (dblFuturePrice - dblActualFutures) * dblOpenQty
	, dblResultRatio = (CASE WHEN dblContractRatio IS NOT NULL AND dblMarketRatio IS NOT NULL THEN ((dblMarketPrice - dblContractPrice) * dblOpenQty)
								- ((dblFuturePrice - dblActualFutures) * dblOpenQty) - dblResultBasis
							ELSE 0 END)
FROM (
	SELECT DISTINCT intConcurrencyId = 0
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
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio
		--Contract Basis
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
		, dblFutures = (CASE WHEN strPricingType = 'Basis' AND strPriOrNotPriOrParPriced = 'Partially Priced' THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
				WHEN strPricingType = 'Basis' THEN dblFutures
				ELSE dblCalculatedFutures END)
		, dblCash  --Contract Cash
		, dblCosts = ABS(dblCosts)
		--Market Basis
		, dblMarketBasis = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
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
		, dblMarketRatio
		, dblFuturePrice = dblHTAConvertedFuturePrice  --Market Futures
		, intContractTypeId
		, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
														--CAD/CAD
														THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts
													WHEN strMainCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) +  ISNULL(dblCash, 0) + dblCosts)
																		/ dblRate
																--Configuration
																ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts)
																	/ @dblRateConfiguration END)
													--Can be used other currency exchange
													ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts END)
										ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts END)
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
								ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * case when ISNULL(dblMarketRatio, 0)=0 then 1 else dblMarketRatio end) + ISNULL(dblCashPrice, 0) END
		, dblResultBasis
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
	FROM (
		SELECT t.*
			, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' then dblConvertedFuturePrice
										WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
											THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
										ELSE dblFutures END), 0)
			, dblHTACalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' then dblHTAConvertedFuturePrice
										WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
											THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblHTAConvertedFuturePrice)) / dblNoOfLots
										ELSE dblFutures END), 0)
		FROM (
			SELECT #Temp.*
				, dblRate = ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
									WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
										AND ISNULL(dblRate, 0) <> 0
										AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
										AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
				, dblConvertedFuturePrice = ISNULL((CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
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
															ELSE ISNULL(dblFuturePrice, 0) END), 0)
				, dblHTAConvertedFuturePrice = ISNULL((CASE WHEN strPricingType != 'HTA'
													THEN (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
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
												ELSE 0 END), 0)
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
	
	UNION ALL SELECT DISTINCT intConcurrencyId = 0
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
		, dblCash
		, dblCosts = ABS(dblCosts)
		, dblMarketBasis = ISNULL(dblInvMarketBasis, 0)
		, dblMarketRatio
		, dblFuturePrice = ISNULL(dblInvFuturePrice, 0)
		, intContractTypeId
		, dblAdjustedContractPrice = NULL
		, dblCashPrice
		, dblMarketPrice = ISNULL(dblInvMarketBasis, 0) + ISNULL(dblInvFuturePrice, 0)
		, dblResultBasis = NULL
		, dblResultCash = NULL
		, dblContractPrice = ISNULL(dblNotLotTrackedPrice, 0)
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
	FROM #Temp 
	WHERE  dblOpenQty <> 0 AND intContractHeaderId IS NULL
)t 
ORDER BY intContractHeaderId DESC