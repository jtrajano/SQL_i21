CREATE PROCEDURE [dbo].[uspRKRiskPositionInquiryBySummary]
	@intCommodityId INT
	, @intCompanyLocationId INT
	, @intFutureMarketId INT
	, @intFutureMonthId INT
	, @intUOMId INT = NULL
	, @intDecimal INT = NULL
	, @intForecastWeeklyConsumption INT = NULL
	, @intForecastWeeklyConsumptionUOMId INT = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strPositionBy NVARCHAR(100)
	, @dtmPositionAsOf DATETIME
	, @strUomType NVARCHAR(100)

AS

--DECLARE @intCommodityId INT = 1
--	, @intCompanyLocationId INT = 0
--	, @intFutureMarketId INT = 1
--	, @intFutureMonthId INT = 41
--	, @intUOMId INT = 18
--	, @intDecimal INT = 0
--	, @intForecastWeeklyConsumption INT = 5900
--	, @intForecastWeeklyConsumptionUOMId INT = 0
--	, @intBookId INT = 0
--	, @intSubBookId INT = 0
--	, @strPositionBy NVARCHAR(100) = 'Product Type'
--	, @dtmPositionAsOf DATETIME = '2019-10-01'
--	, @strUomType NVARCHAR(100) = 'By Quantity'

	DECLARE @dtmToDate DATETIME

	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

	IF (@intCompanyLocationId = 0)
	BEGIN
		SET @intCompanyLocationId = NULL
	END

	IF (@intBookId = 0)
	BEGIN
		SET @intBookId = NULL
	END

	IF (@intSubBookId = 0)
	BEGIN
		SET @intSubBookId = NULL
	END

	IF ISNULL(@intForecastWeeklyConsumptionUOMId, 0) = 0
	BEGIN
		SET @intForecastWeeklyConsumptionUOMId = @intUOMId
	END

	IF (@intUOMId = 0)
	BEGIN
		SELECT @intUOMId = intUnitMeasureId
		FROM tblICCommodityUnitMeasure
		WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
	END

	DECLARE @strUnitMeasure NVARCHAR(200)
		, @dtmFutureMonthsDate DATETIME
		, @dblContractSize INT
		, @ysnIncludeInventoryHedge BIT
		, @strRiskView NVARCHAR(200)
		, @strFutureMonth NVARCHAR(15)
		, @dblForecastWeeklyConsumption NUMERIC(24, 10)
		, @strParamFutureMonth NVARCHAR(12)

	SELECT @dblContractSize = convert(INT, dblContractSize)
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @intFutureMarketId

	SELECT TOP 1 @dtmFutureMonthsDate = CONVERT(DATETIME, '01 ' + strFutureMonth)
		, @strParamFutureMonth = strFutureMonth
	FROM tblRKFuturesMonth
	WHERE intFutureMonthId = @intFutureMonthId

	SELECT TOP 1 @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUOMId

	DECLARE @intoldUnitMeasureId INT

	SET @intoldUnitMeasureId = @intUOMId

	SELECT @intUOMId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUOMId

	SELECT TOP 1 @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge
		, @strRiskView = strRiskView
	FROM tblRKCompanyPreference

	DECLARE @intForecastWeeklyConsumptionUOMId1 INT

	SELECT @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intForecastWeeklyConsumptionUOMId

	SELECT @dblForecastWeeklyConsumption = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1, @intUOMId, @intForecastWeeklyConsumption), 1)

	DECLARE @ListImported AS TABLE (intRowNumber INT
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract NUMERIC(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblQuantity NUMERIC(24, 10)
		, intOrderByHeading INT
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT)

	---Roll Cost
	DECLARE @RollCost AS TABLE (strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, intCommodityId INT
		, intFutureMonthId INT
		, dblNoOfLot NUMERIC(24, 10)
		, dblQuantity NUMERIC(24, 10)
		, dblWtAvgOpenLongPosition NUMERIC(24, 10)
		, strTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, intBookId INT
		, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intSubBookId INT
		, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS)

	INSERT INTO @RollCost (strFutMarketName
		, strCommodityCode
		, strFutureMonth
		, intFutureMarketId
		, intCommodityId
		, intFutureMonthId
		, dblNoOfLot
		, dblQuantity
		, dblWtAvgOpenLongPosition
		, strTradeNo
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT strFutMarketName
		, strCommodityCode
		, strFutureMonth
		, intFutureMarketId
		, intCommodityId
		, intFutureMonthId
		, dblNoOfLot
		, dblQuantity
		, dblWtAvgOpenLongPosition
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM vyuRKRollCost
	WHERE intCommodityId = @intCommodityId
		AND intFutureMarketId = @intFutureMarketId
		AND ISNULL(intBookId, 0) = ISNULL(@intBookId, ISNULL(intBookId, 0))
		AND ISNULL(intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(intSubBookId, 0))
		AND ISNULL(intLocationId, 0) = ISNULL(@intCompanyLocationId, ISNULL(intLocationId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

	--To Purchase Value
	DECLARE @DemandFinal1 AS TABLE (dblQuantity NUMERIC(24, 10)
		, intUOMId INT
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmPeriod DATETIME
		, intItemId INT
		, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	DECLARE @DemandQty AS TABLE (intRowNumber INT IDENTITY
		, dblQuantity NUMERIC(24, 10)
		, intUOMId INT
		, dtmPeriod DATETIME
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	DECLARE @DemandFinal AS TABLE (intRowNumber INT IDENTITY
		, dblQuantity NUMERIC(24, 10)
		, intUOMId INT
		, dtmPeriod DATETIME
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	IF EXISTS (SELECT TOP 1 1 FROM tblRKStgBlendDemand WHERE dtmImportDate < @dtmToDate)
	BEGIN
		INSERT INTO @DemandQty
		SELECT dblQuantity
			, d.intUOMId
			, dtmPeriod = CONVERT(DATETIME, '01 ' + strPeriod)
			, strPeriod
			, strItemName
			, d.intItemId
			, c.strDescription
		FROM tblRKStgBlendDemand d
		JOIN tblICItem i ON i.intItemId = d.intItemId AND d.dblQuantity > 0
		JOIN tblICCommodityAttribute c ON c.intCommodityId = i.intCommodityId
		JOIN tblRKCommodityMarketMapping m ON m.intCommodityId = c.intCommodityId AND intProductTypeId = intCommodityAttributeId
			AND intCommodityAttributeId IN (
				SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = m.intFutureMarketId
		WHERE m.intCommodityId = @intCommodityId AND fm.intFutureMarketId = @intFutureMarketId
	END
	ELSE
	BEGIN
		INSERT INTO @DemandQty
		SELECT dblQuantity
			, d.intUOMId
			, dtmPeriod = CONVERT(DATETIME, '01 ' + strPeriod)
			, strPeriod
			, strItemName
			, d.intItemId
			, c.strDescription
		FROM tblRKArchBlendDemand d
		JOIN tblICItem i ON i.intItemId = d.intItemId AND d.dblQuantity > 0
		JOIN tblICCommodityAttribute c ON c.intCommodityId = i.intCommodityId
		JOIN tblRKCommodityMarketMapping m ON m.intCommodityId = c.intCommodityId AND intProductTypeId = intCommodityAttributeId
			AND intCommodityAttributeId IN (
				SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = m.intFutureMarketId
		WHERE m.intCommodityId = @intCommodityId AND fm.intFutureMarketId = @intFutureMarketId
			AND d.dtmImportDate = (
				SELECT TOP 1 dtmImportDate tblRKArchBlendDemand
				WHERE dtmImportDate <= @dtmToDate
				ORDER BY dtmImportDate DESC)
	END

	DECLARE @intRowNumber INT
		, @dblQuantity NUMERIC(24, 10)
		, @intUOMId1 INT
		, @dtmPeriod1 DATETIME
		, @strFutureMonth1 NVARCHAR(20)
		, @strItemName NVARCHAR(200)
		, @intItemId INT
		, @strDescription NVARCHAR(200)

	SELECT @intRowNumber = min(intRowNumber)
	FROM @DemandQty

	WHILE @intRowNumber > 0
	BEGIN
		SELECT @strFutureMonth1 = NULL
			, @dtmPeriod1 = NULL
			, @intUOMId1 = NULL
			, @dtmPeriod1 = NULL
			, @strItemName = NULL
			, @intItemId = NULL
			, @strDescription = NULL

		SELECT @dblQuantity = dblQuantity
			, @intUOMId1 = intUOMId
			, @dtmPeriod1 = dtmPeriod
			, @strItemName = strItemName
			, @intItemId = intItemId
			, @strDescription = strDescription
		FROM @DemandQty
		WHERE intRowNumber = @intRowNumber

		SELECT @strFutureMonth1 = strFutureMonth
		FROM tblRKFuturesMonth fm
		JOIN tblRKCommodityMarketMapping mm ON mm.intFutureMarketId = fm.intFutureMarketId
		WHERE @dtmPeriod1 = CONVERT(DATETIME, '01 ' + strFutureMonth) AND fm.intFutureMarketId = @intFutureMarketId AND mm.intCommodityId = @intCommodityId

		IF @strFutureMonth1 IS NULL
			SELECT TOP 1 @strFutureMonth1 = strFutureMonth
			FROM tblRKFuturesMonth fm
			JOIN tblRKCommodityMarketMapping mm ON mm.intFutureMarketId = fm.intFutureMarketId
			WHERE CONVERT(DATETIME, '01 ' + strFutureMonth) > @dtmPeriod1 AND fm.intFutureMarketId = @intFutureMarketId AND mm.intCommodityId = @intCommodityId
			ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth)

		INSERT INTO @DemandFinal1 (dblQuantity
			, intUOMId
			, strPeriod
			, strItemName
			, intItemId
			, strDescription)
		SELECT @dblQuantity
			, @intUOMId1
			, @strFutureMonth1
			, @strItemName
			, @intItemId
			, @strDescription

		SELECT @intRowNumber = min(intRowNumber)
		FROM @DemandQty
		WHERE intRowNumber > @intRowNumber
	END

	INSERT INTO @DemandFinal
	SELECT dblQuantity = SUM(dblQuantity)
		, intUOMId
		, dtmPeriod = CONVERT(DATETIME, '01 ' + strPeriod)
		, strPeriod
		, strItemName
		, intItemId
		, strDescription
	FROM @DemandFinal1
	GROUP BY intUOMId
		, strPeriod
		, strItemName
		, intItemId
		, strDescription
	ORDER BY CONVERT(DATETIME, '01 ' + strPeriod)

	DECLARE @ListFinal AS TABLE (intRowNumber INT
		, strGroup NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract NUMERIC(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblQuantity NUMERIC(24, 10)
		, intOrderByHeading INT
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT
		, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, intBookId INT
		, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intSubBookId INT
		, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS)

	--INSERT INTO @PricedContractList
	SELECT fm.strFutureMonth
		, strAccountNumber = strContractType + ' - ' + CASE WHEN @strPositionBy = 'Product Type' THEN ISNULL(ca.strDescription, '') ELSE ISNULL(cv.strEntityName, '') END COLLATE Latin1_General_CI_AS
		, dblNoOfContract= dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) ELSE dblDetailQuantity END)
		, strTradeNo = LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq) COLLATE Latin1_General_CI_AS
		, TransactionDate = dtmStartDate
		, TranType = strContractType
		, CustVendor = strEntityName
		, dblNoOfLot = dblNoOfLots
		, dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) ELSE dblDetailQuantity END)
		, cv.intContractHeaderId
		, intFutOptTransactionHeaderId = NULL
		, intPricingTypeId
		, cv.strContractType
		, cv.intCommodityId
		, cv.intCompanyLocationId
		, cv.intFutureMarketId
		, dtmFutureMonthsDate = CONVERT(DATETIME, '01 ' + cv.strFutureMonth)
		, ysnExpired
		, ysnDeltaHedge = ISNULL(pl.ysnDeltaHedge, 0)
		, intContractStatusId
		, dblDeltaPercent
		, cv.intContractDetailId
		, um.intCommodityUnitMeasureId
		, dblRatioContractSize = dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ffm.dblContractSize)
		, dblRatioQty
		, intPricingTypeIdHeader
		, ysnMultiplePriceFixation
		, strProductType = ca.strDescription
		, strProductLine = pl.strDescription
		, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), cv.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), cv.dtmEndDate, 106), 8)
		, strLocation = cv.strLocationName
		, strOrigin = origin.strDescription
		, intItemId = ic.intItemId
		, strItemNo = ic.strItemNo
		, strItemDescription = ic.strDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	INTO #PricedContractList
	FROM vyuRKRiskPositionContractDetail cv
	JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
	JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId AND um2.intCommodityId = cv.intCommodityId
	JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
	JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
	JOIN tblICItem ic ON ic.intItemId = cv.intItemId
	LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
	LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
	LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
	LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
	WHERE cv.intCommodityId = @intCommodityId
		AND cv.intFutureMarketId = @intFutureMarketId
		AND cv.intContractStatusId NOT IN (2, 3)
		AND ISNULL(intBookId, 0) = ISNULL(@intBookId, ISNULL(intBookId, 0))
		AND ISNULL(intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(intSubBookId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

	SELECT pf.intContractHeaderId
		, pf.intContractDetailId
		, dblNoOfLots = ISNULL(SUM(pd.dblNoOfLots), 0)
		, dblQuantity = ISNULL(SUM(dblQuantity), 0)
	INTO #tmpLotsQtyByDetail
	FROM tblCTPriceFixation pf
	JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate
	GROUP BY pf.intContractHeaderId
		, pf.intContractDetailId

	SELECT pf.intContractHeaderId
		, dblNoOfLots = ISNULL(SUM(pd.dblNoOfLots), 0)
		, dblQuantity = ISNULL(SUM(dblQuantity), 0)
	INTO #tmpLotsQtyByHeader
	FROM tblCTPriceFixation pf
	JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate
	GROUP BY pf.intContractHeaderId

	SELECT strFutureMonth
		, strAccountNumber
		, dblNoOfContract = 0
		, strTradeNo
		, TransactionDate
		, TranType = strContractType
		, CustVendor
		, dblNoOfLot
		, cv.dblQuantity
		, cv.intContractHeaderId
		, intFutOptTransactionHeaderId = NULL
		, cv.intPricingTypeId
		, cv.strContractType
		, cv.intCommodityId
		, cv.intCompanyLocationId
		, cv.intFutureMarketId
		, dtmFutureMonthsDate
		, ysnExpired
		, dblRatioQty
		, dblFixedLots = CASE WHEN ISNULL(cv.ysnMultiplePriceFixation, 0) = 0 THEN ISNULL((PCDetail.dblNoOfLots), 0) ELSE ISNULL((PCHeader.dblNoOfLots), 0) END
		, dblFixedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, CASE WHEN ISNULL(cv.ysnMultiplePriceFixation, 0) = 0 THEN ISNULL((PCDetail.dblQuantity), 0) ELSE ISNULL((PCHeader.dblQuantity), 0) END)
		, dblDeltaPercent = ISNULL(dblDeltaPercent, 0)
		, intCommodityUnitMeasureId
		, dblRatioContractSize
		, intPricingTypeIdHeader
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	INTO #tmpPriceContractList
	FROM #PricedContractList cv
	JOIN #tmpLotsQtyByDetail PCDetail ON PCDetail.intContractDetailId = cv.intContractDetailId AND PCDetail.intContractHeaderId = cv.intContractHeaderId
	JOIN #tmpLotsQtyByHeader PCHeader ON PCHeader.intContractHeaderId = cv.intContractHeaderId
	WHERE cv.intContractStatusId <> 3 AND ISNULL(ysnDeltaHedge, 0) = 0

	SELECT strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, intPricingTypeId
		, strContractType
		, intCommodityId
		, intCompanyLocationId
		, intFutureMarketId
		, dtmFutureMonthsDate
		, ysnExpired
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	INTO #ContractTransaction
	FROM (
		-- Direct Pricing
		SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty) ELSE dblNoOfContract END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty) ELSE dblQuantity END
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM #PricedContractList cv
		WHERE cv.intPricingTypeId IN (1, 2, 8) AND ysnDeltaHedge = 0
			AND intContractDetailId NOT IN (
				SELECT ISNULL(intContractDetailId, 0)
				FROM tblCTPriceFixation)

		--Parcial Priced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty / dblNoOfLot) * dblFixedLots) ELSE dblFixedQty END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = dblFixedLots
			, dblFixedQty = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty / dblNoOfLot) * dblFixedLots) ELSE dblFixedQty END
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId = 1
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM (
			SELECT strFutureMonth
				, strAccountNumber
				, dblNoOfContract
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
				, intContractHeaderId
				, intFutOptTransactionHeaderId
				, strContractType
				, intCommodityId
				, intCompanyLocationId
				, intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, dblRatioQty
				, dblFixedLots
				, dblFixedQty
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, intPricingTypeIdHeader
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, intBookId
				, strBook
				, intSubBookId
				, strSubBook
			FROM #tmpPriceContractList
		) t
		WHERE dblFixedLots > 0

		--Parcial UnPriced	
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (((dblRatioQty / dblNoOfLot) * ISNULL(dblNoOfLot, 0)))) ELSE dblQuantity - dblFixedQty END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)
			, dblQuantity = CASE WHEN intPricingTypeIdHeader = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, ((dblRatioQty / dblNoOfLot) * ISNULL(dblNoOfLot, 0) - (dblRatioQty / dblNoOfLot) * ISNULL(dblFixedLots, 0))) ELSE dblQuantity - dblFixedQty END
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId = 2
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM (
			SELECT strFutureMonth
				, strAccountNumber
				, dblNoOfContract
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
				, intContractHeaderId
				, intFutOptTransactionHeaderId
				, intPricingTypeId
				, strContractType
				, intCommodityId
				, intCompanyLocationId
				, intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, dblRatioQty
				, dblFixedLots
				, dblFixedQty
				, dblDeltaPercent
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, intPricingTypeIdHeader
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, intBookId
				, strBook
				, intSubBookId
				, strSubBook
			FROM #tmpPriceContractList
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1
	
	DROP TABLE #tmpLotsQtyByDetail
	DROP TABLE #tmpLotsQtyByHeader
	DROP TABLE #tmpPriceContractList

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 1 intRowNumber
		, '1.Outright Coverage'
		, Selection = 'Outright Coverage' COLLATE Latin1_General_CI_AS
		, PriceStatus = '1.Priced / Outright - (Outright position)' COLLATE Latin1_General_CI_AS
		, strFutureMonth = CASE WHEN CONVERT(DATETIME, '01 ' + strFutureMonth) < @dtmFutureMonthsDate THEN 'Previous' ELSE strFutureMonth END COLLATE Latin1_General_CI_AS
		, strAccountNumber
		, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN dblNoOfLot ELSE - (abs(dblNoOfLot)) END
		, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END
		, intOrderByHeading = 1
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM #ContractTransaction
	WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId 
		AND intFutureMarketId = @intFutureMarketId
		AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
		AND ISNULL(dblNoOfContract, 0) <> 0

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 1 intRowNumber
		, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
		, Selection = 'Outright Coverage' COLLATE Latin1_General_CI_AS
		, PriceStatus = '1.Priced / Outright - (Outright position)' COLLATE Latin1_General_CI_AS
		, strFutureMonth = @strParamFutureMonth
		, strAccountNumber
		, dblNoOfLot = SUM(dblNoOfLot)
		, NULL
		, TransactionDate = GETDATE()
		, TranType = 'Inventory' COLLATE Latin1_General_CI_AS
		, NULL
		, 0.0
		, dblQuantity = SUM(dblNoOfLot)
		, 1
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId = NULL
		, strBook = NULL
		, intSubBookId = NULL
		, strSubBook = NULL
	FROM (
		SELECT DISTINCT strAccountNumber = 'Purchase' + ' - ' + ISNULL(c.strDescription, '') COLLATE Latin1_General_CI_AS
			, dblNoOfLot = dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, t.dblQuantity)
			, strProductType = c.strDescription
			, strProductLine = pl.strDescription
			, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), t.dtmDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), t.dtmDate, 106), 8)
			, strLocation = cl.strLocationName
			, strOrigin = origin.strDescription
			, intItemId = ic.intItemId
			, strItemNo = ic.strItemNo
			, strItemDescription = ic.strDescription
		FROM vyuRKGetInventoryValuation t
		JOIN tblICItem ic ON t.intItemId = ic.intItemId
		JOIN tblICCommodityAttribute c ON c.intCommodityAttributeId = ic.intProductTypeId
		LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
		JOIN tblICCommodityProductLine pl ON pl.intCommodityProductLineId = ic.intProductLineId
		JOIN tblRKCommodityMarketMapping m ON m.intCommodityId = c.intCommodityId
			AND m.intFutureMarketId = @intFutureMarketId
			AND ic.intProductTypeId = c.intCommodityAttributeId
			AND c.intCommodityAttributeId IN (
				SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
		JOIN tblICItemLocation il ON il.intItemId = ic.intItemId
		JOIN tblICItemUOM i ON il.intItemId = i.intItemId AND i.ysnStockUnit = 1
		JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = @intCommodityId AND um.intUnitMeasureId = i.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
		WHERE ic.intCommodityId = @intCommodityId
			AND m.intFutureMarketId = @intFutureMarketId
			AND cl.intCompanyLocationId = ISNULL(@intCompanyLocationId, cl.intCompanyLocationId)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), t.dtmCreated, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
	) t2
	GROUP BY strAccountNumber
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription

	SELECT * INTO #tmpMatch
	FROM (
		SELECT intFutOptTransactionId = psd.intLFutOptTransactionId
			, dblMatchQty = ISNULL(SUM(dblMatchQty), 0)
		FROM tblRKMatchFuturesPSDetail psd
		JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
		WHERE h.strType = 'Realize' AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate
		GROUP BY psd.intLFutOptTransactionId

		UNION ALL SELECT intFutOptTransactionId = psd.intSFutOptTransactionId
			, dblMatchQty = ISNULL(SUM(dblMatchQty), 0)
		FROM tblRKMatchFuturesPSDetail psd
		JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
		WHERE h.strType = 'Realize' AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate
		GROUP BY psd.intSFutOptTransactionId
	) t

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT *
	FROM (
		SELECT intRowNumber
			, grpname
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, dblNoOfContract = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, CASE WHEN strBuySell = 'Sell' THEN - abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) ELSE abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) END * @dblContractSize)
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = CASE WHEN strBuySell = 'Sell' THEN - abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) ELSE abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) END
			, dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, CASE WHEN strBuySell = 'Sell' THEN - abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) ELSE abs(ISNULL(Long1 + Sell1, 0) - ISNULL(MatchLong + MatchShort, 0)) END * @dblContractSize)
			, 2 intOrderByHeading
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM (
			SELECT DISTINCT 2 intRowNumber
				, grpname = '1.Outright Coverage' COLLATE Latin1_General_CI_AS
				, Selection = 'Outright Coverage' COLLATE Latin1_General_CI_AS
				, PriceStatus = '2.Terminal Position' COLLATE Latin1_General_CI_AS
				, strFutureMonth
				, strAccountNumber = e.strName + '-' + strAccountNumber
				, strBuySell
				, Long1 = ISNULL(CASE WHEN ft.strBuySell = 'Buy' THEN ISNULL(ft.dblNoOfContract, 0) ELSE NULL END, 0)
				, Sell1 = ISNULL(CASE WHEN ft.strBuySell = 'Sell' THEN ISNULL(ft.dblNoOfContract, 0) ELSE NULL END, 0)
				, MatchLong = ISNULL(CASE WHEN ft.strBuySell = 'Buy' THEN ISNULL(md.dblMatchQty, 0) ELSE NULL END, 0)
				, MatchShort = ISNULL(CASE WHEN ft.strBuySell = 'Sell' THEN ISNULL(md.dblMatchQty, 0) ELSE NULL END, 0)
				, strTradeNo = ft.strInternalTradeNo
				, TransactionDate = ft.dtmFilledDate
				, TranType = strBuySell
				, CustVendor = e.strName
				, um.intCommodityUnitMeasureId
				, intContractHeaderId = NULL
				, ft.intFutOptTransactionHeaderId
				, ft.intBookId
				, book.strBook
				, ft.intSubBookId
				, subBook.strSubBook
			FROM tblRKFutOptTransaction ft
			JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId AND ft.strStatus = 'Filled'
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId AND ft.intInstrumentTypeId IN (1, 3) AND ft.intCommodityId = @intCommodityId AND ft.intFutureMarketId = @intFutureMarketId
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId
			JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
			LEFT JOIN tblCTBook book ON book.intBookId = ft.intBookId
			LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = ft.intSubBookId
			LEFT JOIN #tmpMatch md ON md.intFutOptTransactionId = ft.intFutOptTransactionId
			WHERE ft.intCommodityId = @intCommodityId
				AND ft.intFutureMarketId = @intFutureMarketId
				AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
				AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
				AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) <= @dtmToDate AND CONVERT(DATETIME, '01 ' + strFutureMonth) >= @dtmFutureMonthsDate
		) t
	) t1
	WHERE dblNoOfContract <> 0

	DROP TABLE #tmpMatch

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 4 intRowNumber
		, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
		, 'Market coverage' COLLATE Latin1_General_CI_AS Selection
		, '3.Market coverage' COLLATE Latin1_General_CI_AS PriceStatus
		, strFutureMonth
		, 'Market Coverage' COLLATE Latin1_General_CI_AS strAccountNumber
		, dblNoOfContract = CONVERT(DOUBLE PRECISION, ISNULL(dblNoOfContract, 0.0))
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, 4
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE intRowNumber IN (1, 2) AND strFutureMonth <> 'Previous'

	UNION ALL SELECT 4 intRowNumber
		, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
		, Selection = 'Market coverage' COLLATE Latin1_General_CI_AS
		, PriceStatus = '3.Market coverage' COLLATE Latin1_General_CI_AS
		, @strParamFutureMonth
		, 'Market Coverage' COLLATE Latin1_General_CI_AS strAccountNumber
		, dblNoOfContract = CONVERT(DOUBLE PRECISION, ISNULL(dblNoOfContract, 0.0))
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, 4
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE intRowNumber IN (1, 2) AND strFutureMonth = 'Previous'

	IF (ISNULL(@intForecastWeeklyConsumption, 0) <> 0)
	BEGIN
		INSERT INTO @ListFinal (intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
			, intOrderByHeading
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook)
		SELECT 5 intRowNumber
			, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
			, Selection = 'Market Coverage' COLLATE Latin1_General_CI_AS
			, PriceStatus = '4.Market Coverage(Weeks)' COLLATE Latin1_General_CI_AS
			, strFutureMonth
			, strAccountNumber = 'Market Coverage(Weeks)' COLLATE Latin1_General_CI_AS
			, dblNoOfContract = CASE WHEN ISNULL(@dblForecastWeeklyConsumption, 0) = 0 THEN 0 ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) / @dblForecastWeeklyConsumption END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
			, 5
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM @ListFinal
		WHERE intRowNumber IN (4)
	END

	IF (ISNULL(@intBookId, 0) = 0)
	BEGIN
		INSERT INTO @ListFinal (intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, dblNoOfContract
			, dblNoOfLot
			, dblQuantity
			, strBook
			, strSubBook
			, strAccountNumber)
		SELECT 6 intRowNumber
			, strGroup
			, Selection = '5.Total - Market coverage'
			, PriceStatus = 'Total'
			, strFutureMonth
			, dblNoOfContract = SUM(dblNoOfContract)
			, dblNoOfLot = SUM(dblNoOfLot)
			, dblQuantity = SUM(dblQuantity)
			, strBook = 'Total - Market coverage'
			, strSubBook = 'Total'
			, strAccountNumber = 'Total'
		FROM @ListFinal
		WHERE intRowNumber = 4 
		GROUP BY strGroup
			, strFutureMonth
	END

	---- Futures Required
	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract = ROUND(dblNoOfContract, @intDecimal)
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, 6
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM (
		SELECT DISTINCT 7 intRowNumber
			, strGroup = '2.Futures Required' COLLATE Latin1_General_CI_AS
			, Selection = 'Futures Required' COLLATE Latin1_General_CI_AS
			, PriceStatus = '1.Unpriced - (Balance to be Priced)' COLLATE Latin1_General_CI_AS
			, strFutureMonth = CASE WHEN CONVERT(DATETIME, '01 ' + strFutureMonth) < @dtmFutureMonthsDate THEN 'Previous' ELSE strFutureMonth END COLLATE Latin1_General_CI_AS
			, strAccountNumber
			, dblNoOfContract = (CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END)
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = (CASE WHEN strContractType = 'Purchase' THEN dblNoOfLot ELSE - (abs(dblNoOfLot)) END)
			, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END
			, intContractHeaderId
			, NULL AS intFutOptTransactionHeaderId
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM #ContractTransaction
		WHERE ysnExpired = 0 AND intPricingTypeId <> 1 AND intCommodityId = @intCommodityId AND intFutureMarketId = @intFutureMarketId
		AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId) AND intFutureMarketId = @intFutureMarketId
		) T1

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT DISTINCT 8 intRowNumber
		, '2.Futures Required' COLLATE Latin1_General_CI_AS
		, Selection = 'Futures Required' COLLATE Latin1_General_CI_AS
		, PriceStatus = '2.To Purchase' COLLATE Latin1_General_CI_AS
		, strFutureMonth = CASE WHEN CONVERT(DATETIME, '01 ' + strPeriod) < @dtmFutureMonthsDate THEN 'Previous' ELSE strPeriod END COLLATE Latin1_General_CI_AS
		, strAccountNumber = strDescription
		, dblNoOfContract = dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, u.intUnitMeasureId, @intoldUnitMeasureId, ISNULL(dblQuantity, 0))
		, strItemName
		, dtmPeriod
		, NULL
		, NULL
		, dblNoOfLot = ROUND(dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, u.intUnitMeasureId, @intoldUnitMeasureId, ISNULL(dblQuantity, 0)) / dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, u.intUnitMeasureId, @intoldUnitMeasureId, @dblContractSize), 0)
		, dblQuantity = dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, u.intUnitMeasureId, @intoldUnitMeasureId, ISNULL(dblQuantity, 0))
		, 8
		, NULL
		, NULL
	FROM @DemandFinal cv
	JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = @intFutureMarketId
	JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = @intCommodityId AND um1.intUnitMeasureId = ffm.intUnitMeasureId
	JOIN tblICItemUOM u ON cv.intUOMId = u.intItemUOMId
	ORDER BY dtmPeriod ASC

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 9 intRowNumber
		, '2.Futures Required' COLLATE Latin1_General_CI_AS
		, Selection = 'Futures Required' COLLATE Latin1_General_CI_AS
		, PriceStatus = '3.Terminal position' COLLATE Latin1_General_CI_AS
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, 7
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE intRowNumber IN (2)

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 10 intRowNumber
		, '2.Futures Required' COLLATE Latin1_General_CI_AS
		, 'Futures Required' COLLATE Latin1_General_CI_AS Selection
		, '4.Net Position' COLLATE Latin1_General_CI_AS PriceStatus
		, strFutureMonth
		, 'Net Position' COLLATE Latin1_General_CI_AS
		, SUM(dblNoOfContract1) - SUM(dblNoOfContract)
		, SUM(dblNoOfLot1) - SUM(dblNoOfLot)
		, SUM(dblQuantity1) - SUM(dblQuantity)
		, 9 intOrderByHeading
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM (
		SELECT strFutureMonth= CASE WHEN strFutureMonth = 'Previous' THEN @strParamFutureMonth ELSE strFutureMonth END COLLATE Latin1_General_CI_AS
			, 0 dblNoOfContract1
			, 0 dblNoOfLot1
			, 0 dblQuantity1
			, dblNoOfContract = SUM(dblQuantity)
			, dblNoOfLot = SUM(dblNoOfLot)
			, dblQuantity = SUM(dblQuantity)
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM @ListFinal
		WHERE intRowNumber IN (7, 8)
		GROUP BY strFutureMonth
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		
		UNION ALL SELECT strFutureMonth
			, dblNoOfContract1 = SUM(dblQuantity)
			, dblNoOfLot1 = SUM(dblNoOfLot)
			, dblQuantity1 = SUM(dblQuantity)
			, 0 dblNoOfContract
			, 0 dblNoOfLot
			, 0 dblQuantity
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM @ListFinal
		WHERE intRowNumber IN (9)
		GROUP BY strFutureMonth
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
	) t
	GROUP BY strFutureMonth
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 11 intRowNumber
		, '2.Futures Required' COLLATE Latin1_General_CI_AS
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract = (dblQuantity) / SUM(dblNoOfLot) OVER (PARTITION BY strFutureMonth)
		, strTradeNo
		, TransactionDate = GETDATE()
		, NULL
		, NULL
		, dblNoOfLot
		, dblQuantity
		, 10
		, NULL
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM (
		SELECT DISTINCT Selection = 'Futures Required' COLLATE Latin1_General_CI_AS
			, PriceStatus = '5.Avg Long Price' COLLATE Latin1_General_CI_AS
			, ft.strFutureMonth
			, strAccountNumber = 'Avg Long Price' COLLATE Latin1_General_CI_AS
			, dblNoOfContract = dblWtAvgOpenLongPosition
			, dblNoOfLot
			, dblQuantity * dblNoOfLot dblQuantity
			, strTradeNo
			, intFutOptTransactionHeaderId
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
		FROM @RollCost ft
		WHERE ft.intCommodityId = @intCommodityId
			AND intFutureMarketId = @intFutureMarketId
			AND CONVERT(DATETIME, '01 ' + ft.strFutureMonth) >= CONVERT(DATETIME, '01 ' + @strParamFutureMonth)
	) t

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 12
		, strGroup
		, Selection
		, PriceStatus
		, 'Total' COLLATE Latin1_General_CI_AS
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE strAccountNumber <> 'Avg Long Price'
	ORDER BY intRowNumber
		, CASE WHEN strFutureMonth NOT IN ('Previous', 'Total') THEN CONVERT(DATETIME, '01 ' + strFutureMonth) END
		, intOrderByHeading
		, PriceStatus ASC

	INSERT INTO @ListFinal (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT 12 intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth = 'Total' COLLATE Latin1_General_CI_AS
		, strAccountNumber
		, dblNoOfContract = SUM(dblQuantity) / SUM(dblNoOfLot)
		, '' strTradeNo
		, '' TransactionDate
		, '' TranType
		, '' CustVendor
		, dblNoOfLot = SUM(dblNoOfLot)
		, dblQuantity = SUM(dblQuantity)
		, NULL intOrderByHeading
		, NULL intContractHeaderId
		, NULL intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE strAccountNumber = 'Avg Long Price'
	GROUP BY strGroup
		, Selection
		, PriceStatus
		, strAccountNumber
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook

	IF (ISNULL(@intBookId, 0) = 0)
	BEGIN
		INSERT INTO @ListFinal (intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, dblNoOfContract
			, dblNoOfLot
			, dblQuantity
			, strBook
			, strSubBook
			, strAccountNumber)
		SELECT 6 intRowNumber
			, strGroup
			, Selection = '6.Total - Net Position'
			, PriceStatus = 'Total'
			, strFutureMonth
			, dblNoOfContract = SUM(dblNoOfContract)
			, dblNoOfLot = SUM(dblNoOfLot)
			, dblQuantity = SUM(dblQuantity)
			, strBook = 'Total - Net Position' 
			, strSubBook = 'Total'
			, strAccountNumber = 'Total'
		FROM @ListFinal WHERE intRowNumber IN (10, 12) AND PriceStatus = '4.Net Position'
		GROUP BY strGroup, strFutureMonth
	END

	DECLARE @MonthOrder AS TABLE (intRowNumber1 INT IDENTITY
		, intRowNumber INT
		, strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract NUMERIC(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblQuantity NUMERIC(24, 10)
		, intOrderByHeading INT
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT
		, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, intBookId INT
		, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intSubBookId INT
		, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS)

	DECLARE @MonthList AS TABLE (strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS)

	INSERT INTO @MonthList (strFutureMonth)
	SELECT DISTINCT strFutureMonth
	FROM @ListFinal
	
	INSERT INTO @MonthOrder (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal))
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE strFutureMonth = 'Previous'

	INSERT INTO @MonthOrder (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal))
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE strFutureMonth NOT IN ('Previous', 'Total')
	ORDER BY intRowNumber
		, strBook
		, strSubBook
		, PriceStatus
		, CONVERT(DATETIME, '01 ' + strFutureMonth) ASC

	INSERT INTO @MonthOrder (intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook)
	SELECT intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal))
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @ListFinal
	WHERE strFutureMonth = 'Total'

	IF EXISTS (SELECT DISTINCT strFutureMonth FROM @MonthOrder
				WHERE strFutureMonth NOT IN (
					SELECT DISTINCT strFutureMonth
					FROM @ListFinal
					WHERE intRowNumber = 1))
	BEGIN
		INSERT INTO @MonthOrder (intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
			, intOrderByHeading
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, strProductType
			, strProductLine
			, strShipmentPeriod
			, strLocation
			, strOrigin
			, intItemId
			, strItemNo
			, strItemDescription
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook)
		SELECT DISTINCT intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, b.strFutureMonth
			, strAccountNumber
			, 0
			, strTradeNo = ''
			, TransactionDate = ''
			, TranType
			, CustVendor
			, dblNoOfLot = 0
			, dblQuantity = 0
			, intOrderByHeading
			, intContractHeaderId = NULL
			, intFutOptTransactionHeaderId = NULL
			, strProductType = NULL
			, strProductLine = NULL
			, strShipmentPeriod = ''
			, strLocation = ''
			, strOrigin = NULL
			, intItemId = NULL
			, strItemNo = ''
			, strItemDescription = ''
			, intBookId = intBookId
			, strBook = strBook
			, intSubBookId = intSubBookId
			, strSubBook = strSubBook
		FROM @ListFinal a
		CROSS APPLY (
			SELECT DISTINCT strFutureMonth
			FROM @MonthOrder
		) b
		WHERE intRowNumber = 1
	END

	SELECT intRowNumber1 intRowNumFinal
		, intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract = CASE WHEN @strUomType = 'By Lot' AND PriceStatus = '4.Market Coverage(Weeks)' THEN (CONVERT(DOUBLE PRECISION, ROUND(dblNoOfLot, @intDecimal))) / @intForecastWeeklyConsumption WHEN @strUomType = 'By Lot' AND strAccountNumber <> 'Avg Long Price' THEN (CONVERT(DOUBLE PRECISION, ROUND(dblNoOfLot, @intDecimal))) ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) END
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity = ROUND(dblQuantity, @intDecimal)
		, intOrderByHeading = ISNULL(intOrderByHeading, 0)
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, strProductType
		, strProductLine
		, strShipmentPeriod
		, strLocation
		, strOrigin
		, intItemId
		, strItemNo
		, strItemDescription
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @MonthOrder
	ORDER BY strGroup
		, PriceStatus
		, strBook
		, strSubBook
		, CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END

	DROP TABLE #PricedContractList
	DROP TABLE #ContractTransaction