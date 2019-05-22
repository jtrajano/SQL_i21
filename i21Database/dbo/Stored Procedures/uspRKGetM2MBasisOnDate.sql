CREATE PROCEDURE [dbo].[uspRKGetM2MBasisOnDate]
	@intM2MBasisId INT
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @strPricingType NVARCHAR(50)
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL

AS

BEGIN
	IF (ISNULL(@intCommodityId, 0) = 0)
	BEGIN
		SET @intCommodityId = NULL
	END

	DECLARE @#tempInquiryTransaction TABLE (intRowNum INT
		, intConcurrencyId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intEntityId INT
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblOpenQty NUMERIC(24, 10)
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblContractRatio NUMERIC(24, 10)
		, dblContractBasis NUMERIC(24, 10)
		, dblFutures NUMERIC(24, 10)
		, dblCash NUMERIC(24, 10)
		, dblCosts NUMERIC(24, 10)
		, dblMarketBasis NUMERIC(24, 10)
		, dblMarketRatio NUMERIC(24, 10)
		, dblFuturePrice NUMERIC(24, 10)
		, intContractTypeId INT
		, dblAdjustedContractPrice NUMERIC(24, 10)
		, dblCashPrice NUMERIC(24, 10)
		, dblMarketPrice NUMERIC(24, 10)
		, dblResultBasis NUMERIC(24, 10)
		, dblResultCash NUMERIC(24, 10)
		, dblContractPrice NUMERIC(24, 10)
		, intQuantityUOMId INT
		, intCommodityUnitMeasureId INT
		, intPriceUOMId INT
		, intCent INT
		, dtmPlannedAvailabilityDate DATETIME
		, dblPricedQty NUMERIC(24, 10)
		, dblUnPricedQty NUMERIC(24, 10)
		, dblPricedAmount NUMERIC(24, 10)
		, intCompanyLocationId INT
		, intMarketZoneId INT
		, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblResult NUMERIC(24, 10)
		, dblMarketFuturesResult NUMERIC(24, 10)
		, dblResultRatio NUMERIC(24, 10))
	
	INSERT INTO @#tempInquiryTransaction
	EXEC uspRKM2MInquiryTransaction @intM2MBasisId = @intM2MBasisId
		, @intFutureSettlementPriceId = @intFutureSettlementPriceId
		, @intQuantityUOMId = @intQuantityUOMId
		, @intPriceUOMId = @intPriceUOMId
		, @intCurrencyUOMId = @intCurrencyUOMId
		, @dtmTransactionDateUpTo = @dtmTransactionDateUpTo
		, @strRateType = @strRateType
		, @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId
		, @intMarketZoneId = @intMarketZoneId
	
	DECLARE @strItemIds NVARCHAR(MAX)
		, @strPeriodTos NVARCHAR(MAX)
		, @strLocationIds NVARCHAR(MAX)
		, @strZoneIds NVARCHAR(MAX)
	
	--Get the unique items from transactions
	SELECT @strItemIds = COALESCE(@strItemIds + ',', '') + ISNULL(intItemId, '')
	FROM (
		SELECT DISTINCT CASE WHEN intItemId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intItemId) END AS intItemId FROM @#tempInquiryTransaction
	) tbl
	
	SELECT @strPeriodTos = COALESCE(@strPeriodTos + ',', '') + CONVERT(NVARCHAR(50), strPeriodTo)
	FROM (
		SELECT DISTINCT strPeriodTo FROM @#tempInquiryTransaction
	) tbl
	
	SELECT @strLocationIds = COALESCE(@strLocationIds + ',', '') + ISNULL(intCompanyLocationId, '')
	FROM (
		SELECT DISTINCT CASE WHEN intCompanyLocationId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intCompanyLocationId) END AS intCompanyLocationId FROM @#tempInquiryTransaction
	) tbl
	
	SELECT @strZoneIds = COALESCE(@strZoneIds + ',', '') + ISNULL(intMarketZoneId, '')
	FROM (
		SELECT DISTINCT CASE WHEN intMarketZoneId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intMarketZoneId) END AS intMarketZoneId FROM @#tempInquiryTransaction
	) tbl

	SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS AS strItemId
	INTO #tmpItemId
	FROM [dbo].[fnSplitString](@strItemIds, ',')
	SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS AS strPeriodTo
	INTO #tmpPeriodTo
	FROM [dbo].[fnSplitString](@strPeriodTos, ',')
	SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS AS strLocationId
	INTO #tmpLocationId
	FROM [dbo].[fnSplitString](@strLocationIds, ',')
	SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS AS strZoneId
	INTO #tmpZoneId
	FROM [dbo].[fnSplitString](@strZoneIds, ',')
	
	DECLARE @strEvaluationBy NVARCHAR(50)
		, @strEvaluationByZone NVARCHAR(50)
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT

	SELECT TOP 1 @strEvaluationBy = strEvaluationBy
		, @strEvaluationByZone = strEvaluationByZone
		, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
	FROM tblRKCompanyPreference

	IF @strEvaluationBy = 'Commodity'
	BEGIN
		SET @strItemIds = ''
	END
	
	IF @strEvaluationByZone = 'Location'
	BEGIN
		SET @strZoneIds = ''
	END
	
	IF @strEvaluationByZone = 'Company'
	BEGIN
		SET @strZoneIds = ''
		SET @strLocationIds = ''
	END

	IF @ysnEnterForwardCurveForMarketBasisDifferential = 0
	BEGIN
		SET @strPeriodTos = ''
	END
	
	SELECT bd.intM2MBasisDetailId
		, c.strCommodityCode
		, i.strItemNo
		, strOriginDest = ca.strDescription
		, fm.strFutMarketName
		, strFutureMonth = ''
		, bd.strPeriodTo
		, strLocationName
		, strMarketZoneCode
		, strCurrency
		, strPricingType = CASE WHEN ISNULL(bd.intPricingTypeId, 0) <> 0 THEN  pt.strPricingType ELSE b.strPricingType END
		, strContractInventory
		, strContractType
		, strUnitMeasure
		, bd.intCommodityId
		, bd.intItemId
		, bd.intFutureMarketId
		, bd.intFutureMonthId
		, bd.intCompanyLocationId
		, bd.intMarketZoneId
		, bd.intCurrencyId
		, bd.intPricingTypeId
		, bd.intContractTypeId
		, bd.dblCashOrFuture
		, bd.dblBasisOrDiscount
		, bd.dblRatio
		, bd.intUnitMeasureId
		, i.strMarketValuation
		, intConcurrencyId = 0
	FROM tblRKM2MBasis b
	JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = bd.intCommodityId
	LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
	LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
	LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = bd.intFutureMarketId
	LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = bd.intCompanyLocationId
	LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = bd.intCurrencyId
	LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = bd.intPricingTypeId
	LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = bd.intContractTypeId
	LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = bd.intMarketZoneId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = bd.intUnitMeasureId
	WHERE b.intM2MBasisId = @intM2MBasisId
		AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
		AND b.strPricingType = @strPricingType
		AND (ISNULL(bd.intItemId, 0) = ISNULL(@strItemIds, ISNULL(bd.intItemId, 0)) OR ISNULL(bd.intItemId, 0) IN (SELECT strItemId FROM #tmpItemId))
		AND (ISNULL(bd.strPeriodTo, '') = ISNULL(@strPeriodTos, ISNULL(bd.strPeriodTo, '')) OR ISNULL(bd.strPeriodTo, '') IN (SELECT strPeriodTo FROM #tmpPeriodTo))
		AND (ISNULL(bd.intCompanyLocationId, 0) = ISNULL(ISNULL(@strLocationIds, bd.intCompanyLocationId, 0)) OR ISNULL(bd.intCompanyLocationId, 0) IN (SELECT strLocationId from #tmpLocationId))
		AND (ISNULL(bd.intMarketZoneId, 0) = ISNULL(@strZoneIds, ISNULL(bd.intMarketZoneId, 0)) OR ISNULL(bd.intMarketZoneId, 0) IN (SELECT strZoneId FROM #tmpZoneId))
		OR (bd.strContractInventory = 'Inventory' and b.intM2MBasisId = @intM2MBasisId
			AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
			AND b.strPricingType = @strPricingType)
	ORDER BY i.strMarketValuation
		, fm.strFutMarketName
		, strCommodityCode
		, strItemNo
		, strLocationName
		, CONVERT(DATETIME, '01 ' + strPeriodTo)

	DROP TABLE #tmpItemId
	DROP TABLE #tmpLocationId
	DROP TABLE #tmpPeriodTo
	DROP TABLE #tmpZoneId
END