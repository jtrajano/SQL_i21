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
	DECLARE @intDefaultCurrencyId INT
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

	DECLARE @tblFinalDetail TABLE (intContractHeaderId INT
		, intContractDetailId INT
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
		, dblPriceWORollArb NUMERIC(24,10)
		, intActualQuantityUOMId INT
		, dblActualMarketBasisUOM NUMERIC(18, 6)
		, intActualPriceSourceUOMId INT
		, intActualCurrencyId INT)

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

	--There is an error "An INSERT EXEC statement cannot be nested." that is why we cannot directly call the uspRKDPRContractDetail AND insert
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
	SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC) intRowNum
		, strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContract
		, strLocationName
		, dtmSeqEndDate
		, dblQuantity
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCompanyLocationId
		, strContractType
		, strPricingTypeDesc
		, intCommodityUnitMeasureId = null
		, intContractDetailId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strType = strContractType + ' ' + strPricingTypeDesc
		, intItemId
		, strItemNo
		, dtmContractDate
		, strCustomer
		, strCustomerContract = ''
		, intFutureMarketId
		, intFutureMonthId
	FROM tblCTContractBalance WHERE CONVERT(DATETIME, CONVERT(VARCHAR, dtmEndDate, 101),101) = @dtmTransactionDateUpTo AND intCommodityId = @intCommodityId

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
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 2 OR CD.intPricingTypeId = 8
										THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0 THEN 'Unpriced'
												ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0) - ISNULL(PF.dblLotsFixed, 0) = 0 THEN 'Fully Priced'
														WHEN ISNULL(PF.dblLotsFixed, 0) = 0 THEN 'Unpriced'
														ELSE 'Partially Priced' END END
									WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND ISNULL(CH.ysnMultiplePriceFixation, 0) = 0 AND intContractStatusId NOT IN (2, 3, 6)
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN (SELECT intPriceFixationId, dblQuantity = SUM(dblQuantity)
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
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 2 OR CD.intPricingTypeId = 8
										THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0 THEN 'Unpriced'
												ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0)-ISNULL(PF.dblLotsFixed, 0) = 0 THEN 'Fully Priced'
														WHEN ISNULL(PF.dblLotsFixed, 0) = 0 THEN 'Unpriced'
														ELSE 'Partially Priced' END END
									WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND ISNULL(CH.ysnMultiplePriceFixation, 0) = 1 AND intContractStatusId NOT IN (2, 3, 6)
		LEFT JOIN tblCTPriceFixation PF ON CH.intContractHeaderId = PF.intContractHeaderId
		LEFT JOIN (SELECT intPriceFixationId, dblQuantity = SUM(dblQuantity)
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
	SELECT DISTINCT intCommodityUnitMeasureId = CH.intCommodityUOMId
		, CL.strLocationName
		, strCommodityDescription = CY.strDescription
		, CU.intMainCurrencyId
		, CU.intCent
		, dblDetailQuantity = CD.dblQuantity
		, CH.intContractTypeId
		, CH.intContractHeaderId
		, TP.strContractType
		, CH.strContractNumber
		, strEntityName = EY.strName
		, CH.intEntityId
		, CY.strCommodityCode
		, CH.intCommodityId
		, PO.strPosition
		, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, OCD.dtmContractDate, 101), 101)
		, CH.intContractBasisId
		, CD.intContractSeq
		, CD.dtmStartDate
		, CD.dtmEndDate
		, CD.intPricingTypeId
		, CD.dblRatio
		, dblBasis = CD.dblConvertedBasis
		, CD.dblFutures
		, CD.intContractStatusId
		, CD.dblCashPrice
		, CD.intContractDetailId
		, CD.intFutureMarketId
		, CD.intFutureMonthId
		, CD.intItemId
		, dblBalance = ISNULL(OCD.dblBalance, CD.dblBalance)
		, CD.intCurrencyId
		, CD.dblRate
		, CD.intMarketZoneId
		, CD.dtmPlannedAvailabilityDate
		, IM.strItemNo
		, OCD.strPricingType
		, intPriceUnitMeasureId = PU.intUnitMeasureId
		, IU.intUnitMeasureId
		, MO.strFutureMonth
		, FM.strFutMarketName
		, IM.intOriginId
		, IM.strLotTracking
		, dblNoOfLots = CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN CH.dblNoOfLots ELSE CD.dblNoOfLots END
		, PF.dblLotsFixed
		, PF.dblPriceWORollArb
		, CH.dblNoOfLots dblHeaderNoOfLots
		, ysnSubCurrency = CAST(ISNULL(CU.intMainCurrencyId, 0) AS BIT)
		, CD.intCompanyLocationId
		, MO.ysnExpired
		, strPricingStatus
		, strOrgin = CA.strDescription
		, ysnMultiplePriceFixation = ISNULL(ysnMultiplePriceFixation, 0)
		, FM.intUnitMeasureId intMarketUOMId
		, FM.intCurrencyId intMarketCurrencyId
		, dblInvoicedQuantity = dblInvoicedQty
		, dblPricedQty = ISNULL(CASE WHEN CD.intPricingTypeId = 1 AND PF.intPriceFixationId IS NULL THEN CD.dblQuantity ELSE PF.dblQuantity END, 0)
		, dblUnPricedQty = ISNULL(CASE WHEN CD.intPricingTypeId <> 1 AND PF.intPriceFixationId IS NOT NULL THEN ISNULL(CD.dblQuantity, 0) - ISNULL(PF.dblQuantity , 0)
									WHEN CD.intPricingTypeId <> 1 AND PF.intPriceFixationId IS NULL THEN ISNULL(CD.dblQuantity, 0)
									ELSE 0 END, 0)
		, dblPricedAmount = ISNULL(CASE WHEN CD.intPricingTypeId = 1 AND PF.intPriceFixationId IS NULL THEN CD.dblCashPrice ELSE PF.dblFinalPrice END, 0)
		, MZ.strMarketZoneCode
	FROM tblCTContractHeader CH
	INNER JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
	INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
	INNER JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
	INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId AND CD.intContractStatusId NOT IN(2, 3, 6)
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
		AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)
		AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
		AND ISNULL(CD.intMarketZoneId, 0) = ISNULL(@intMarketZoneId, ISNULL(CD.intMarketZoneId, 0))
		AND CD.intContractStatusId NOT IN (2, 3, 6) 
		AND CONVERT(DATETIME, CONVERT(VARCHAR, OCD.dtmContractDate, 101), 101) <= @dtmTransactionDateUpTo

	SELECT intContractDetailId
		, dblCosts = SUM(dblCosts)
	INTO #tblContractCost
	FROM ( 
		SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyUOMId)
							* CASE WHEN strAdjustmentType = 'Add'
										THEN ABS(CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
													ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END)
									WHEN strAdjustmentType = 'Reduce'
										THEN CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
												ELSE - SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END ELSE 0 END
			, strAdjustmentType
			, dc.intContractDetailId
			, a = cu.intCommodityUnitMeasureId
			, b = cu1.intCommodityUnitMeasureId
			, strCostMethod
		FROM @GetContractDetailView cd
		INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblRKM2MConfiguration M2M ON dc.intItemId = M2M.intItemId AND ch.intFreightTermId = M2M.intFreightTermId
		INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
		LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = dc.intCurrencyId
		LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
		GROUP BY cu.intCommodityUnitMeasureId
			, cu1.intCommodityUnitMeasureId
			, strAdjustmentType
			, dc.intContractDetailId
			, dc.strCostMethod
			, CU.ysnSubCurrency
			, CU.intMainCurrencyId
			, dc.intCurrencyId
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
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = pm.intFutureMonthId
			WHERE p.intFutureMarketId = fm.intFutureMarketId
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
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = CASE WHEN ISNULL(fm.ysnExpired, 0)=0 THEN pm.intFutureMonthId
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
		, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
		, dblFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
		, intFuturePriceCurrencyId = fm.intCurrencyId
	INTO #tblSettlementPrice
	FROM @GetContractDetailView cd
	JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId= cd.intFutureMonthId AND ffm.intFutureMarketId=cd.intFutureMarketId
	JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
	JOIN tblSMCurrency c ON cd.intMarketCurrencyId=c.intCurrencyID AND cd.intCommodityId= @intCommodityId
	JOIN tblSMCurrency c1 ON cd.intCurrencyId=c1.intCurrencyID
	JOIN tblICCommodityUnitMeasure cuc ON cd.intCommodityId=cuc.intCommodityId AND cuc.intUnitMeasureId=cd.intMarketUOMId
	JOIN tblICCommodityUnitMeasure PUOM ON cd.intCommodityId=PUOM.intCommodityId AND PUOM.intUnitMeasureId=cd.intPriceUnitMeasureId
	JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId=@intCommodityId AND cu.intUnitMeasureId=@intPriceUOMId
	JOIN @tblGetSettlementPrice sm ON sm.intFutureMonthId=ffm.intFutureMonthId
	WHERE cd.intCommodityId = @intCommodityId


	SELECT intContractDetailId
		, dblFuture = (avgLot / intTotLot)
	INTO #tblContractFuture
	FROM (
		SELECT avgLot = SUM(ISNULL(pfd.[dblNoOfLots], 0)
						* dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, ISNULL(dblFixationPrice, 0)))
						/ MAX(CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
						+ ((MAX(ISNULL(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots
											ELSE cdv.dblNoOfLots END, 0)) - SUM(ISNULL(pfd.[dblNoOfLots], 0)))
						* MAX(dblFuturePrice))
			, intTotLot = MAX(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END)
			, cdv.intContractDetailId
		FROM tblCTContractDetail cdv
		JOIN #tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
		JOIN tblSMCurrency c ON cdv.intCurrencyId = c.intCurrencyID
		JOIN tblCTContractHeader ch ON cdv.intContractHeaderId = ch.intContractHeaderId AND ch.intCommodityId = @intCommodityId AND cdv.dblBalance > 0
		JOIN tblCTPriceFixation pf ON CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
		JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
		JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
		JOIN tblICItemUOM PU ON PU.intItemUOMId = cdv.intPriceItemUOMId
		JOIN tblICCommodityUnitMeasure PUOM ON ch.intCommodityId = PUOM.intCommodityId AND PUOM.intUnitMeasureId = PU.intUnitMeasureId
		GROUP BY cdv.intContractDetailId
	) t

	DECLARE @tblOpenContractList TABLE (intContractHeaderId INT
		, intContractDetailId INT
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
		, intCommodityUnitMeasureId INT
		, intQuantityUOMId INT
		, intPriceUOMId INT
		, intCurrencyId INT
		, PriceSourceUOMId INT
		, dblCosts NUMERIC(24, 10)
		, dblContractOriginalQty NUMERIC(24, 10)
		, ysnSubCurrency BIT
		, intMainCurrencyId INT
		, intCent INT
		, dtmPlannedAvailabilityDate DATETIME
		, intCompanyLocationId INT
		, intMarketZoneId INT
		, intContractStatusId INT
		, dtmContractDate DATETIME
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
		, dblContractBasis = CASE WHEN ISNULL(intPricingTypeId, 0) = 3 THEN dblMarketBasis1 ELSE dblContractBasis END
		, dblDummyContractBasis
		, dblCash
		, dblFuturesClosingPrice1
		, dblFutures 
		, dblMarketRatio
		, dblMarketBasis1 = CASE WHEN intPricingTypeId = 6 THEN 0 ELSE dblMarketBasis1 END
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
		, dblCashPrice = CASE WHEN intPricingTypeId = 6 THEN dblMarketCashPrice ELSE 0 END
	FROM (
		SELECT DISTINCT cd.intContractHeaderId
			, cd.intContractDetailId
			, strContractOrInventoryType = 'Contract' + '(' + LEFT(cd.strContractType, 1) + ')'
			, strContractSeq = cd.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)
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
			, strPeriod = RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5)
			, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), cd.dtmEndDate, 106), 4, 8)
			, strPriOrNotPriOrParPriced = cd.strPricingStatus
			, cd.intPricingTypeId
			, cd.strPricingType
			, cd.dblRatio
			, dblContractBasis = ISNULL(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN ISNULL(cd.dblBasis, 0)
											ELSE 0 END, 0) / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
			, dblDummyContractBasis = ISNULL(cd.dblBasis, 0)
			, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
			, dblFuturesClosingPrice1 = dblFuturePrice
			, dblFutures = CASE WHEN cd.intPricingTypeId = 2 AND strPricingStatus = 'Unpriced' THEN dblFuturePrice
								ELSE CASE WHEN cd.intPricingTypeId IN (1, 3) THEN ISNULL(p.dblFutures, 0) ELSE dblFuture END END
			, dblMarketRatio = ISNULL((SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
								LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
								WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
									AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
									AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
									AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE cd.intContractTypeId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
									AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																			THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(cd.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
									AND temp.strContractInventory = 'Contract'), 0)
			, dblMarketBasis1 = ISNULL((SELECT TOP 1 (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
										FROM tblRKM2MBasisDetail temp
										LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
										WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
											AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
											AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
											AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE cd.intContractTypeId END
											AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
											AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																					THEN ISNULL(temp.strPeriodTo, '') ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END ELSE ISNULL(temp.strPeriodTo, '') END
											AND temp.strContractInventory = 'Contract'), 0)
			, dblMarketCashPrice = ISNULL((SELECT TOP 1 (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
											FROM tblRKM2MBasisDetail temp
											LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
											WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
												AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
												AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
												AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE cd.intContractTypeId END
												AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
												AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																						THEN ISNULL(temp.strPeriodTo, '') ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END ELSE ISNULL(temp.strPeriodTo, '') END
												AND temp.strContractInventory = 'Contract'), 0)
			, dblMarketBasisUOM = ISNULL((SELECT TOP 1 intCommodityUnitMeasureId AS dblMarketBasisUOM FROM tblRKM2MBasisDetail temp
											JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
											WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
												AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
												AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
												AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE cd.intContractTypeId END
												AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
												AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																						THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(cd.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
												AND temp.strContractInventory = 'Contract'), 0)
			, intMarketBasisCurrencyId = ISNULL((SELECT TOP 1 intCurrencyId AS intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
												JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
												WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
													AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
													AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
													AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE cd.intContractTypeId END
													AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
													AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																							THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(cd.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
													AND temp.strContractInventory = 'Contract'), 0)
			, dblFuturePrice1 = p.dblFuturePrice
			, intFuturePriceCurrencyId
			, intContractTypeId = CONVERT(INT, cd.intContractTypeId)
			, cd.dblRate
			, cuc.intCommodityUnitMeasureId
			, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
			, intPriceUOMId = cuc2.intCommodityUnitMeasureId
			, cd.intCurrencyId
			, PriceSourceUOMId = CONVERT(INT, cuc3.intCommodityUnitMeasureId)
			, dblCosts = ISNULL(dblCosts, 0)
			, dblContractOriginalQty = cd.dblBalance
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
		JOIN tblICCommodityUnitMeasure cuc ON cd.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = cd.intUnitMeasureId AND cd.intCommodityId = @intCommodityId
		JOIN tblICCommodityUnitMeasure cuc1 ON cd.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
		JOIN tblICCommodityUnitMeasure cuc2 ON cd.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
		LEFT JOIN #tblSettlementPrice p ON cd.intContractDetailId = p.intContractDetailId
		LEFT JOIN #tblContractCost cc ON cd.intContractDetailId = cc.intContractDetailId
		LEFT JOIN #tblContractFuture cf ON cf.intContractDetailId = cd.intContractDetailId
		LEFT JOIN tblICCommodityUnitMeasure cuc3 ON cd.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId = cd.intPriceUnitMeasureId
		LEFT JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId = cd.intFutureMonthId 
		WHERE cd.intCommodityId = @intCommodityId 
	)t

	SELECT *
	INTO #tempIntransit
	FROM (
		SELECT intLineNo = (SELECT TOP 1 intLineNo FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentItemId = InTran.intTransactionDetailId AND intOrderId IS NOT NULL)
			, dblBalanceToInvoice = SUM(dblInTransitQty)
			, InTran.intItemId
			, InTran.strItemNo
			, InTran.intItemUOMId
			, Com.intCommodityId
			, Com.strCommodityCode
			, Inv.strEntity
			, Inv.intEntityId
			, SI.dblPrice
			, strTransactionId = InTran.strTransactionId
			, intUnitMeasureId
			, SI.intCurrencyId
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), Inv.dtmDate, 106), 8)
			, Inv.intLocationId
			, Inv.strLocationName
		FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmTransactionDateUpTo) InTran
		INNER JOIN vyuICGetInventoryValuation Inv ON InTran.intInventoryTransactionId = Inv.intInventoryTransactionId
		INNER JOIN tblICItem Itm ON InTran.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity Com ON Itm.intCommodityId = Com.intCommodityId
		INNER JOIN tblICCategory Cat ON Itm.intCategoryId = Cat.intCategoryId
		LEFT JOIN vyuICGetInventoryShipmentItem SI ON InTran.intTransactionDetailId = SI.intInventoryShipmentItemId
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmTransactionDateUpTo)
		GROUP BY InTran.intItemId
			, InTran.strItemNo
			, InTran.intItemUOMId
			, Com.intCommodityId
			, Com.strCommodityCode
			, Inv.strEntity
			, Inv.intEntityId
			, SI.dblPrice
			, InTran.strTransactionId
			, InTran.intTransactionDetailId
			, intUnitMeasureId
			, SI.intCurrencyId
			, Inv.dtmDate
			, Inv.intLocationId
			, Inv.strLocationName
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
		, dblPriceWORollArb
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId)
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
		, dblResultCash = CASE WHEN intPricingTypeId = 6 THEN dblResult ELSE 0 END
		, dblResultBasis
		, dblShipQty = 0
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
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId
	FROM (
		SELECT *
			, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblResultCash1 = (ISNULL(dblMarketBasis, 0) - ISNULL(dblCash, 0)) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId,intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
		FROM (
			SELECT *
				, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, ISNULL(dblMarketBasis1, 0)) ELSE 0 END
				, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0)) + CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dblFutures ELSE dblFutures END) + ISNULL(dblCosts, 0) END
				, dblFuturesClosingPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, dblFuturesClosingPrice1)
				, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, dblFuturePrice1)
				, dblOpenQty = (ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblOpenQty1 ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, ISNULL(dblOpenQty1, 0)) END), 0))
								- (ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblInvoicedQuantity ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, ISNULL(dblInvoicedQuantity, 0)) END), 0))
			FROM (
				SELECT *
					, dblActualMarketBasisUOM = CASE WHEN ISNULL(dblMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE dblMarketBasisUOM END
				FROM (
					SELECT DISTINCT cd.intContractHeaderId
						, cd.intContractDetailId
						, strContractOrInventoryType = 'In-transit' + '(S)'
						, strContractSeq = ch.strContractNumber + '-' + CONVERT(nvarchar,cd.intContractSeq)
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
						, strOrgin = NULL --cd.strOrgin
						, i.intOriginId
						, strPosition = NULL --cd.strPosition
						, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
						, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8)
						, strPriOrNotPriOrParPriced = pt.strPricingType
						, intPricingTypeId = cd.intPricingTypeId
						, pt.strPricingType
						, dblContractRatio = cd.dblRatio
						, dblContractBasis = cd.dblBasis
						, dblDummyContractBasis = null
						, cd.dblFutures
						, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
						, dblMarketRatio = ISNULL((SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp
												LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
												WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
													AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
													AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
													AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE ch.intContractTypeId END
													AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
													AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																							THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(fmo.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
													AND temp.strContractInventory = 'Contract'), 0)
						, dblMarketBasis1 = ISNULL((SELECT TOP 1 (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency= 1 THEN 100 ELSE 1 END
													FROM tblRKM2MBasisDetail temp
													LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
													WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
														AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
														AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
														AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE ch.intContractTypeId END
														AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
														AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																								THEN ISNULL(temp.strPeriodTo, '') ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END ELSE ISNULL(temp.strPeriodTo, '') END
														AND temp.strContractInventory = 'Contract'), 0)
						, dblMarketBasisUOM = ISNULL((SELECT TOP 1 intCommodityUnitMeasureId AS dblMarketBasisUOM FROM tblRKM2MBasisDetail temp
													JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
													WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
														AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
														AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
														AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE ch.intContractTypeId END
														AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
														AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '') = ''
																								THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(fmo.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
														AND temp.strContractInventory = 'Contract'), 0)
						, intMarketBasisCurrencyId = ISNULL((SELECT TOP 1 intCurrencyId AS intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp
															JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
															WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId
																AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE cd.intFutureMarketId END
																AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE cd.intItemId END
																AND ISNULL(temp.intContractTypeId, 0) = CASE WHEN ISNULL(temp.intContractTypeId, 0) = 0 THEN 0 ELSE ch.intContractTypeId END
																AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(cd.intCompanyLocationId, 0) END
																AND ISNULL(temp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN ISNULL(temp.strPeriodTo, '')= '' 
																										THEN ISNULL(temp.strPeriodTo, '') ELSE (RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, STUFF(fmo.strFutureMonth, 5, 0, '20')), 106), 8)) END ELSE ISNULL(temp.strPeriodTo, '') END
																AND temp.strContractInventory = 'Contract'), 0)
						, dblFuturePrice1 = p.dblFuturePrice
						, intFuturePriceCurrencyId =p.intContractDetailId
						, dblFuturesClosingPrice1 = p.dblFuturePrice
						, ch.intContractTypeId
						, intConcurrencyId = 0
						, it.dblBalanceToInvoice dblOpenQty1
						, cd.dblRate
						, intCommodityUnitMeasureId = cuc.intCommodityUnitMeasureId
						, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
						, intPriceUOMId = cuc2.intCommodityUnitMeasureId
						, cd.intCurrencyId
						, PriceSourceUOMId = CONVERT(INT, cuc3.intCommodityUnitMeasureId)
						, cc.dblCosts
						, ysnSubCurrency = CAST(ISNULL(cu.intMainCurrencyId, 0) AS BIT)
						, cu.intMainCurrencyId
						, cu.intCent
						, cd.dtmPlannedAvailabilityDate
						, dblInvoicedQuantity = cd.dblInvoicedQty
						, cd.intMarketZoneId
						, cd.intCompanyLocationId
						, mz.strMarketZoneCode
						, cl.strLocationName
						, dblNoOfLots = CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cd.dblNoOfLots END
						, dblLotsFixed = NULL --cd.dblLotsFixed
						, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
						, dblCashPrice
						, intActualQuantityUOMId = CASE WHEN ISNULL(cuc1.intCommodityUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END
						, intActualPriceSourceUOMId = CASE WHEN ISNULL(CONVERT(INT, cuc3.intCommodityUnitMeasureId), 0) = 0 THEN cuc2.intCommodityUnitMeasureId ELSE CONVERT(INT, cuc3.intCommodityUnitMeasureId) END
						, intActualCurrencyId = CASE WHEN CAST(ISNULL(cu.intMainCurrencyId, 0) AS BIT) = 1 THEN cu.intMainCurrencyId ELSE cd.intCurrencyId END
					FROM #tempIntransit it
					JOIN tblCTContractDetail cd ON cd.intContractDetailId = it.intLineNo
					JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
					JOIN tblICItem i ON cd.intItemId=i.intItemId
					JOIN tblICItemUOM iuom ON i.intItemId=iuom.intItemId AND ysnStockUnit=1
					JOIN tblEMEntity e ON ch.intEntityId = e.intEntityId
					JOIN tblICCommodity com ON ch.intCommodityId = com.intCommodityId
					JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
					JOIN tblRKFuturesMonth fmo ON cd.intFutureMonthId = fmo.intFutureMonthId
					JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
					JOIN tblICCommodityUnitMeasure cuc ON ch.intCommodityId=cuc.intCommodityId AND cuc.intUnitMeasureId = cd.intUnitMeasureId AND ch.intCommodityId = @intCommodityId
					JOIN tblICCommodityUnitMeasure cuc1 ON ch.intCommodityId=cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
					JOIN tblICCommodityUnitMeasure cuc2 ON ch.intCommodityId=cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
					JOIN tblICCommodityUnitMeasure cuc3 ON ch.intCommodityId=cuc3.intCommodityId AND cuc3.intUnitMeasureId= iuom.intUnitMeasureId
					LEFT JOIN #tblSettlementPrice p ON cd.intContractDetailId=p.intContractDetailId
					LEFT JOIN #tblContractCost cc ON cd.intContractDetailId=cc.intContractDetailId
					JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
					LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
					JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId

					UNION ALL
					SELECT DISTINCT intContractHeaderId = NULL
						, intContractDetailId = NULL
						, strContractOrInventoryType = 'In-transit' + '(S)'
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
						, strOrgin = NULL --cd.strOrgin
						, intOriginId = NULL
						, strPosition = NULL --cd.strPosition
						, strPeriod = NULL
						, strPeriodTo = NULL
						, strPriOrNotPriOrParPriced = NULL
						, intPricingTypeId = NULL
						, strPricingType = NULL
						, dblContractRatio = NULL
						, dblContractBasis = 0
						, dblDummyContractBasis = null
						, dblFutures = 0
						, dblCash = it.dblPrice
						, dblMarketRatio = NULL
						, dblMarketBasis1 = NULL
						, dblMarketBasisUOM = NULL
						, intMarketBasisCurrencyId = NULL
						, dblFuturePrice1 = NULL
						, intFuturePriceCurrencyId = NULL
						, dblFuturesClosingPrice1 = NULL
						, intContractTypeId = NULL
						, intConcurrencyId = 0
						, dblOpenQty1 = - it.dblBalanceToInvoice
						, dblRate = NULL
						, intCommodityUnitMeasureId = NULL
						, intQuantityUOMId = NULL
						, intPriceUOMId = it.intUnitMeasureId
						, it.intCurrencyId
						, PriceSourceUOMId = NULL
						, dblCosts = NULL
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
						, dblLotsFixed = NULL
						, dblPriceWORollArb = NULL
						, dblCashPrice = NULL
						, intActualQuantityUOMId = NULL
						, intActualPriceSourceUOMId = NULL
						, intActualCurrencyId = NULL
					FROM #tempIntransit it
					WHERE it.intLineNo IS NULL
				)t
			)t
		)t
	)t2

	---- intransitv(p)
 
	SELECT dblPurchaseContractShippedQty = SUM(dblPurchaseContractShippedQty)
		, intContractDetailId
	INTO #tblPIntransitView
	FROM vyuRKPurchaseIntransitView
	GROUP BY intContractDetailId
	
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
		, dblPriceWORollArb
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId)
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
		, dblFuturePrice
		, dblFuturePrice
		, dblResult
		, dblMarketFuturesResult
		, dblResultCash1
		, dblContractPrice
		, dblResultCash = CASE WHEN intPricingTypeId = 6 THEN dblResult ELSE 0 END
		, dblResultBasis
		, dblShipQty = 0
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
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId
	FROM (
		SELECT *
			, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblResultCash1 = (ISNULL(dblMarketBasis, 0) - ISNULL(dblCash, 0)) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
		FROM (
			SELECT *
				, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, ISNULL(dblMarketBasis1, 0)) ELSE 0 END
				, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
												ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0))
																				ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) * ISNULL(dblRate, 0)
																						ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) END END)
													+ CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dblFutures
																				ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dblFutures * ISNULL(dblRate, 0)
																						ELSE dblFutures END END) 
													+ ISNULL(dblCosts, 0) END
				, dblFuturePrice = dblFuturePrice1
				, dblOpenQty = ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN InTransQty
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, InTransQty) END), 0)
			FROM (
				SELECT DISTINCT cd.intContractHeaderId
					, cd.intContractDetailId
					, strContractOrInventoryType = 'In-transit' + '(P)'
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
					, intConcurrencyId = 0
					, cd.dblContractOriginalQty
					, InTransQty = LG.dblQuantity
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
					, intActualQuantityUOMId = CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END
					, dblActualMarketBasisUOM = CASE WHEN ISNULL(dblMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE dblMarketBasisUOM END
					, intActualPriceSourceUOMId = CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END
					, intActualCurrencyId = CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END
				FROM @tblOpenContractList cd
				LEFT JOIN (
					SELECT dblQuantity = SUM(LD.dblQuantity), PCT.intContractDetailId
					FROM tblLGLoad L
					JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) -- 1.purchase 2.outbound
					JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId AND PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty, 0)
					GROUP BY PCT.intContractDetailId
							
					UNION ALL SELECT dblQuantity = SUM(LD.dblQuantity), PCT.intContractDetailId
					FROM tblLGLoad L
					JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) -- 1.purchase 2.outbound
					JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId AND PCT.dblQuantity > PCT.dblInvoicedQty
					GROUP BY PCT.intContractDetailId
				) AS LG ON LG.intContractDetailId = cd.intContractDetailId
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
			, dblPriceWORollArb
			, intActualQuantityUOMId
			, dblActualMarketBasisUOM
			, intActualPriceSourceUOMId
			, intActualCurrencyId)
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
			, CASE WHEN intPricingTypeId=6 THEN dblResult ELSE 0 END dblResultCash
			, dblResultBasis
			, 0 AS dblShipQty
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
			, intActualQuantityUOMId
			, dblActualMarketBasisUOM
			, intActualPriceSourceUOMId
			, intActualCurrencyId
		FROM (
			SELECT *
				, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultCash1 = (ISNULL(dblMarketBasis, 0) - ISNULL(dblCash, 0)) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId,  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty1, 0)))
				, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
			FROM (
				SELECT *
					, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, ISNULL(dblMarketBasis1, 0)) ELSE 0 END
					, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0)+(ISNULL(dblCash, 0))
													ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0)=0
																						THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0))
																					ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																									THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) * dblRate
																							ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) END END)
														+ convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId)* dblFutures
																						ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dblFutures * dblRate
																								ELSE dblFutures END END)
														+ ISNULL(dblCosts, 0) END
					, dblFuturesClosingPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, dblFuturesClosingPrice1)
					, dblFuturePrice = dblFuturePrice1
					, dblOpenQty = ISNULL(CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblOpenQty1
														ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, dblOpenQty1) END), 0)
				FROM (
					SELECT DISTINCT cd.intContractHeaderId
						, cd.intContractDetailId
						, strContractOrInventoryType = 'Inventory (P)'
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
						, intConcurrencyId = 0 
						, dblLotQty dblOpenQty1
						, cd.dblRate
						, cd.intCommodityUnitMeasureId
						, cd.intQuantityUOMId
						, cd.intPriceUOMId
						, cd.intCurrencyId
						, cd.PriceSourceUOMId
						, cd.dblCosts
						, dblInvoiceQty = cd.dblInvoicedQuantity
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
						, intActualQuantityUOMId = CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END
						, dblActualMarketBasisUOM = CASE WHEN ISNULL(dblMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE dblMarketBasisUOM END
						, intActualPriceSourceUOMId = CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END
						, intActualCurrencyId = CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END
					FROM @tblOpenContractList cd
					JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId = l.intContractDetailId
					JOIN tblICItem i ON cd.intItemId = i.intItemId AND i.strLotTracking <> 'No'
					WHERE cd.intCommodityId = @intCommodityId
				)t
			)t1
		)t2
		WHERE strContractOrInventoryType = CASE WHEN @ysnIncludeInventoryM2M = 1 THEN 'Inventory (P)' ELSE '' END
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
		, dblPriceWORollArb
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId)
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
		, intConcurrencyId = 0 
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
		, dblResultCash = CASE WHEN intPricingTypeId = 6 THEN dblResult ELSE 0 END
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
		, intActualQuantityUOMId
		, dblActualMarketBasisUOM
		, intActualPriceSourceUOMId
		, intActualCurrencyId
	FROM (
		SELECT *
			, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) 
			, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblResultCash1 = (ISNULL(dblMarketBasis, 0) - ISNULL(dblCash, 0)) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intActualQuantityUOMId, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
			, dblContractPrice = 0
		FROM (
			SELECT *
				, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, dblActualMarketBasisUOM, ISNULL(dblMarketBasis1, 0)) ELSE 0 END
				, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0)+(ISNULL(dblCash, 0))
												ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId,ISNULL(dblContractBasis, 0))
																				ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																							THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																						ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) END END) 
													+ CONVERT(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId,@intCurrencyUOMId)* dblFutures
																				ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dblFutures*ISNULL(dblRate, 0)
																						ELSE dblFutures END END)
													+ ISNULL(dblCosts, 0) END
				, dblFuturePrice = dblFuturePrice1
				, dblOpenQty = CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblContractOriginalQty
														ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, dblContractOriginalQty) END)
								- ISNULL(CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN InTransQty
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, InTransQty) END), 0)
								- ISNULL(CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblInvoicedQuantity
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, intActualQuantityUOMId, dblInvoicedQuantity) END), 0)
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
					, PriceSourceUOMId = CONVERT(INT, cd.PriceSourceUOMId)
					, cd.dblCosts
					, cd.dblContractOriginalQty
					, InTransQty = LG.dblQuantity
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
					, intActualQuantityUOMId = CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END
					, dblActualMarketBasisUOM = CASE WHEN ISNULL(dblMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE dblMarketBasisUOM END
					, intActualPriceSourceUOMId = CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END
					, intActualCurrencyId = CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END
				FROM @tblOpenContractList cd
				LEFT JOIN (
					SELECT dblQuantity = SUM(LD.dblQuantity)
						, PCT.intContractDetailId
					FROM tblLGLoad L
					JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) -- 1.purchase 2.outbound
					JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId AND PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty, 0)
					GROUP BY PCT.intContractDetailId
						
					UNION ALL SELECT dblQuantity = SUM(LD.dblQuantity)
						, PCT.intContractDetailId
					FROM tblLGLoad L
					JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) -- 1.purchase 2.outbound
					JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId AND PCT.dblQuantity > PCT.dblInvoicedQty
					GROUP BY PCT.intContractDetailId
				) LG ON LG.intContractDetailId = cd.intContractDetailId
			) t
		) t WHERE ISNULL(dblOpenQty, 0) > 0
	) t1

	SELECT *
		, dblContractPrice = ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio,1))
		, dblResult = CONVERT(DECIMAL(24, 6), ((ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0)) - ISNULL(dblMarketBasis, 0)) * ISNULL(dblResultBasis1, 0)) + CONVERT(DECIMAL(24, 6), ((ISNULL(dblFutures, 0) - ISNULL(dblFuturePrice, 0)) * ISNULL(dblMarketFuturesResult1, 0)))
		, dblResultBasis = CASE WHEN intContractTypeId = 1 THEN CONVERT(DECIMAL(24, 6), (ISNULL(dblMarketBasis, 0) - (ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0))) * ISNULL(dblOpenQty, 0))
								ELSE CONVERT(DECIMAL(24, 6), ((ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0)) - ISNULL(dblMarketBasis, 0)) * ISNULL(dblOpenQty, 0)) END
		, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 THEN CONVERT(DECIMAL(24, 6), ((ISNULL(dblFuturePrice, 0) - ISNULL(dblFutures, 0)) * ISNULL(dblOpenQty, 0)))
										ELSE CONVERT(DECIMAL(24, 6), ((ISNULL(dblFutures, 0)- ISNULL(dblFuturePrice, 0)) * ISNULL(dblOpenQty, 0))) END 
		, dblResultCash = CASE WHEN strPricingType = 'Cash' THEN CONVERT(DECIMAL(24, 6), (ISNULL(dblCash, 0) - ISNULL(dblCashPrice, 0)) * ISNULL(dblResult1, 0)) ELSE NULL END
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
			, dblOpenQty = CASE WHEN intContractTypeId = 2 THEN - dblOpenQty
								ELSE dblOpenQty END
			, intPricingTypeId
			, strPricingType
			, dblDummyContractBasis = CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblDummyContractBasis, 0))
																ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																			THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblDummyContractBasis, 0)) * dblRate
																		ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblDummyContractBasis, 0)) END END)
			, dblContractBasis = CASE WHEN @ysnCanadianCustomer = 1 THEN dblContractBasis
									ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0))
																	ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																				THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) * dblRate
																			ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) END END) END
			, dblCanadianContractBasis = CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0))
																	ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																				THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) * dblRate
																			ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblContractBasis, 0)) END END)
			, dblFutures = CASE WHEN @ysnCanadianCustomer = 1 THEN dblFutures
								ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dblFutures
																ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dblFutures * dblRate
																		ELSE dblFutures END END) END
			, dblCash = CONVERT(DECIMAL(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, dblCash))
			, dblCosts
			, dblMarketRatio
			, dblMarketBasis = CASE WHEN @ysnCanadianCustomer = 1 THEN dblMarketBasis
									ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblMarketBasis, 0))
																	ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId
																				THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblMarketBasis, 0)) * dblRate
																			ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, ISNULL(dblMarketBasis, 0)) END END) END
			, intMarketBasisCurrencyId
			, dblFuturePrice = dblFuturePrice1
			, intFuturePriceCurrencyId
			, dblFuturesClosingPrice = CONVERT(DECIMAL(24, 6), dblFuturesClosingPrice)
			, intContractTypeId = CONVERT(INT, intContractTypeId)
			, intConcurrencyId = 0
			, dblAdjustedContractPrice
			, dblCashPrice
			, dblResultCash1 = CASE WHEN ysnSubCurrency = 1 THEN (CONVERT(DECIMAL(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, dblResultCash))) / ISNULL(intCent, 0)
									ELSE CONVERT(DECIMAL(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, intActualPriceSourceUOMId, dblResultCash)) END
			, dblResult1 = dblResult
			, dblResultBasis1 = CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0 ELSE dblResultBasis END
			, dblMarketFuturesResult1 = dblMarketFuturesResult
			, intQuantityUOMId
			, intCommodityUnitMeasureId
			, intPriceUOMId
			, intCent
			, dtmPlannedAvailabilityDate
			, dblCanadianFutures = CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(intActualCurrencyId, @intCurrencyUOMId) * dblFutures
																ELSE CASE WHEN intActualCurrencyId <> @intCurrencyUOMId THEN dblFutures * dblRate ELSE dblFutures END END)
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
			, intActualQuantityUOMId
			, dblActualMarketBasisUOM
			, intActualPriceSourceUOMId
			, intActualCurrencyId
		FROM @tblFinalDetail
	) t
	ORDER BY intCommodityId
		, strContractSeq DESC

	------------- Calculation of Results ----------------------
	--UPDATE #Temp
	--SET dblResultBasis = CASE WHEN intContractTypeId = 1 AND (ISNULL(dblContractBasis, 0) <= dblMarketBasis) THEN abs(dblResultBasis)
	--						WHEN intContractTypeId = 1 AND (ISNULL(dblContractBasis, 0) > dblMarketBasis) THEN - abs(dblResultBasis)
	--						WHEN intContractTypeId = 2 AND (ISNULL(dblContractBasis, 0) >= dblMarketBasis) THEN abs(dblResultBasis)
	--						WHEN intContractTypeId = 2 AND (ISNULL(dblContractBasis, 0) < dblMarketBasis) THEN - abs(dblResultBasis) END
		--, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 AND (ISNULL(dblFutures, 0) <= ISNULL(dblFuturesClosingPrice, 0)) THEN abs(dblMarketFuturesResult)
		--								WHEN intContractTypeId = 1 AND (ISNULL(dblFutures, 0) > ISNULL(dblFuturesClosingPrice, 0)) THEN - abs(dblMarketFuturesResult)
		--								WHEN intContractTypeId = 2 AND (ISNULL(dblFutures, 0) >= ISNULL(dblFuturesClosingPrice, 0)) THEN abs(dblMarketFuturesResult)
		--								WHEN intContractTypeId = 2 AND (ISNULL(dblFutures, 0) < ISNULL(dblFuturesClosingPrice, 0)) THEN - abs(dblMarketFuturesResult) END
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
				SELECT 
					'Inventory' AS strContractOrInventoryType
					, s.strLocationName
					, c.strCommodityCode
					, c.intCommodityId
					, i.strItemNo
					, i.intItemId
					, SUM(dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))) dblOpenQty
					, SUM(dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))) dblOpenQty1
					, ISNULL((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND temp.intItemId = i.intItemId
								AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE c.intFutureMarketId END
								AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE i.intItemId END
								AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(s.intLocationId, 0) END
								AND temp.strContractInventory = 'Inventory'), 0) AS PriceSourceUOMId
					, ISNULL((SELECT TOP 1 ISNULL(dblBasisOrDiscount, 0) FROM tblRKM2MBasisDetail temp
							WHERE temp.intM2MBasisId = @intM2MBasisId
								AND temp.intItemId = i.intItemId
								AND ISNULL(temp.intFutureMarketId, 0) = CASE WHEN ISNULL(temp.intFutureMarketId, 0) = 0 THEN 0 ELSE c.intFutureMarketId END
								AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE i.intItemId END
								AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(s.intLocationId, 0) END
								AND temp.strContractInventory = 'Inventory'), 0) AS dblInvMarketBasis
					, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId ORDER BY 1 DESC) strFutureMonth
					, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId ORDER BY 1 DESC) intFutureMonthId
					, c.intFutureMarketId
					, fm.strFutMarketName
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(cu2.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,SUM(ISNULL(p.dblAverageCost, 0))) dblNotLotTrackedPrice
					, cu2.intCommodityUnitMeasureId intToPriceUOM
					, cu3.intCommodityUnitMeasureId intFutMarketCurrency
				FROM vyuRKGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId=s.intItemId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
				JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
				JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
				JOIN tblRKFutureMarket fm ON c.intFutureMarketId=fm.intFutureMarketId
				JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId=c.intCommodityId AND cu2.intUnitMeasureId=@intPriceUOMId
				JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId=c.intCommodityId AND ISNULL(cu1.ysnStockUOM, 0)=1
				JOIN tblICCommodityUnitMeasure cu3 ON cu3.intCommodityId=@intCommodityId AND cu3.intUnitMeasureId=fm.intUnitMeasureId
				LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
				LEFT JOIN tblICItemPricing p ON i.intItemId = p.intItemId AND s.intItemLocationId=p.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <>0 
					AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) 
					AND ISNULL(strTicketStatus, '') <> 'V'
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmTransactionDateUpTo)
					AND ysnInTransit = 0
				GROUP BY i.intItemId
					, i.strItemNo
					, s.intLocationId
					, strLocationName
					, strFutMarketName
					, strCommodityCode
					, c.intCommodityId
					, c.intFutureMarketId
					, cuom.intCommodityUnitMeasureId
					, cu1.intCommodityUnitMeasureId
					, cu2.intCommodityUnitMeasureId
					, cu3.intCommodityUnitMeasureId
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
		)t2 WHERE ISNULL(dblOpenQty, 0) > 0
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
		, dblResult = CASE WHEN strPricingType='Cash' THEN dblResultCash 
							WHEN intContractTypeId = 1 THEN (dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty
							ELSE (dblAdjustedContractPrice - dblMarketPrice) * dblOpenQty END
		, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 THEN (dblFuturePrice - dblActualFutures ) * dblOpenQty
										ELSE (dblActualFutures - dblFuturePrice) * dblOpenQty END
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
			, dblCash --Contract Cash
			, dblCosts = ABS(dblCosts)
			--Market Basis
			, dblMarketBasis = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
										THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
													--USD/CAD
													THEN (CASE WHEN @strRateType = 'Contract'
																--Formula: Market Price - Market Futures
																THEN ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0))
																	/ dblRate)
																	- dblConvertedFuturePrice
															--Configuration
															--Formula: Market Price - Market Futures
															ELSE ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0))
																/ @dblRateConfiguration) - dblConvertedFuturePrice END)
												--When both currencies is not equal to M2M currency
												WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
													THEN ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0)
												--Can be used other currency exchange
												ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END)
									ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END
			, dblMarketRatio
			, dblFuturePrice = dblConvertedFuturePrice --Market Futures
			, intContractTypeId
			, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
												THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
															--CAD/CAD
															THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts
														WHEN strMainCurrency = 'USD'
															--USD/CAD
															THEN (CASE WHEN @strRateType = 'Contract'
																		THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts)
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
																THEN (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0))
																	/ dblRate
																--Configuration
																ELSE (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0))
																	/ @dblRateConfiguration END)
												--When both currencies is not equal to M2M currency
												WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
													THEN ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0)
												--Can be used other currency exchange
												ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0) END)
									ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * dblMarketRatioMultiplier) + ISNULL(dblCashPrice, 0) END
			, dblResultBasis
			, dblResultCash
			--Contract Price
			, dblContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
										THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
													--CAD/CAD
													THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0)
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
				, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' THEN dblConvertedFuturePrice
											WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
												THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
											ELSE dblFutures END), 0)
				, dblMarketRatioMultiplier = CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END
			FROM (
				SELECT #Temp.*
					, dblRate = ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
										WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
											AND ISNULL(dblRate, 0) <> 0
											AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
											AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
					, dblConvertedFuturePrice = ISNULL((CASE WHEN strPricingType != 'HTA'
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
		WHERE dblOpenQty <> 0 AND intContractHeaderId is not NULL 
	
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
			, dblAdjustedContractPrice = ISNULL(dblNotLotTrackedPrice, 0) + ISNULL(dblCash, 0)
			, dblCashPrice
			, dblMarketPrice = ISNULL(dblInvMarketBasis, 0) + ISNULL(dblInvFuturePrice, 0)
			, dblResultBasis = NULL
			, dblResultCash = NULL
			, dblContractPrice = ISNULL(dblNotLotTrackedPrice, 0) + ISNULL(dblCash, 0)
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
		WHERE dblOpenQty <> 0 AND intContractHeaderId IS NULL
	)t 
	ORDER BY intContractHeaderId DESC
END