CREATE PROCEDURE [dbo].[uspRKRiskPositionInquiry]
	@intCommodityId INT
	, @intCompanyLocationId INT
	, @intFutureMarketId INT
	, @intFutureMonthId INT
	, @intUOMId INT
	, @intDecimal INT
	, @intForecastWeeklyConsumption INT = NULL
	, @intForecastWeeklyConsumptionUOMId INT = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strPositionBy NVARCHAR(100) = NULL
	, @strOriginIds NVARCHAR(500) = NULL

AS

BEGIN
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
		SET @intForecastWeeklyConsumption = 1
	END

	IF ISNULL(@intForecastWeeklyConsumptionUOMId, 0) = 0
	BEGIN
		SET @intForecastWeeklyConsumptionUOMId = @intUOMId
	END

	DECLARE @ysnSelectAllOrigin BIT = 0

	SELECT intCountryID = CAST(a.Item AS INT)
	INTO #tmpOriginIds
	FROM [dbo].[fnSplitString](@strOriginIds, ',') a
	WHERE @strPositionBy = 'Origin'

	DELETE FROM #tmpOriginIds
	WHERE intCountryID = 0

	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpOriginIds)
	BEGIN
		INSERT INTO #tmpOriginIds 
		SELECT -1
		
		INSERT INTO #tmpOriginIds
		SELECT DISTINCT intCountryID
		FROM tblICCommodityAttribute
		WHERE strType = 'Origin'

		SELECT @ysnSelectAllOrigin = 1
	END

	DECLARE @strUnitMeasure NVARCHAR(MAX)
		, @dtmFutureMonthsDate DATETIME
		, @dblContractSize INT
		, @ysnIncludeInventoryHedge BIT
		, @strFutureMonth NVARCHAR(MAX)
		, @dblForecastWeeklyConsumption NUMERIC(24, 10)
		, @strParamFutureMonth NVARCHAR(MAX)
	
	SELECT TOP 1 @dblContractSize = CONVERT(INT, dblContractSize)
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @intFutureMarketId
	
	SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate
		, @strParamFutureMonth = strFutureMonth
	FROM tblRKFuturesMonth
	WHERE intFutureMonthId = @intFutureMonthId

	SELECT TOP 1 @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUOMId

	SELECT TOP 1 @intUOMId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUOMId

	SELECT TOP 1 @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge
	FROM tblRKCompanyPreference

	DECLARE @intForecastWeeklyConsumptionUOMId1 INT
	
	SELECT TOP 1 @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intForecastWeeklyConsumptionUOMId
	
	SELECT @dblForecastWeeklyConsumption = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1, @intUOMId, @intForecastWeeklyConsumption), 1)

	--    Invoice End
	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24, 10)
		, dblQuantity DECIMAL(24, 10)
		, intOrderByHeading INT
		, intOrderBySubHeading INT
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
		, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCertificationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblHedgedLots DECIMAL(24, 10)
		, dblToBeHedgedLots DECIMAL(24, 10)
	)

	DECLARE @PricedContractList AS TABLE (strFutureMonth NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24, 10)
		, dblQuantity DECIMAL(24, 10)
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT
		, intPricingTypeId INT
		, strContractType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intCompanyLocationId INT
		, intFutureMarketId INT
		, dtmFutureMonthsDate DATETIME
		, ysnExpired BIT
		, ysnDeltaHedge BIT
		, intContractStatusId INT
		, dblDeltaPercent DECIMAL(24, 10)
		, intContractDetailId INT
		, intCommodityUnitMeasureId INT
		, dblRatioContractSize DECIMAL(24, 10)
		, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCertificationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblHedgedLots DECIMAL(24, 10)
		, dblToBeHedgedLots DECIMAL(24, 10)
	)

	INSERT INTO @PricedContractList
	SELECT fm.strFutureMonth
		, strAccountNumber = strContractType + ' - ' + CASE WHEN @strPositionBy = 'Product Type' 
															THEN ISNULL(ca.strDescription, '') 
															WHEN @strPositionBy = 'Origin'
															THEN ISNULL(origin.strDescription, '(Blank)')
															ELSE ISNULL(cv.strEntityName, '') 
															END
		, dblNoOfContract = dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0)
				ELSE (CASE WHEN intContractStatusId = 6 THEN (ISNULL(dblDetailQuantity, 0) - ISNULL(dblBalance, 0)) ELSE dblDetailQuantity END) END)
		, strTradeNo = LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq)
		, TransactionDate = cv.dtmStartDate
		, TranType = strContractType
		, CustVendor = strEntityName
		, dblNoOfLot = dblNoOfLots
		, dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) 
				ELSE (CASE WHEN intContractStatusId = 6 THEN (ISNULL(dblDetailQuantity, 0) - ISNULL(dblBalance, 0)) ELSE dblDetailQuantity END) END)
		, cv.intContractHeaderId
		, intFutOptTransactionHeaderId = NULL
		, intPricingTypeId
		, cv.strContractType
		, cv.intCommodityId
		, cv.intCompanyLocationId
		, cv.intFutureMarketId
		, dtmFutureMonthsDate
		, ysnExpired
		, ysnDeltaHedge = ISNULL(pl.ysnDeltaHedge, 0)
		, intContractStatusId
		, dblDeltaPercent
		, cv.intContractDetailId
		, um.intCommodityUnitMeasureId
		, dblRatioContractSize = dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ffm.dblContractSize)
		, strProductType = ca.strDescription
		, strProductLine = pl.strDescription
		, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), cv.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), cv.dtmEndDate, 106), 8)
		, strLocation = cv.strLocationName
		, strOrigin = origin.strDescription
		, intItemId = ic.intItemId
		, strItemNo = ic.strItemNo
		, strItemDescription = ic.strDescription
		, strGrade = grade.strDescription
		, strRegion = region.strDescription
		, strSeason = season.strDescription
		, strClass = class.strDescription
		--, strCertificationName = certification.strCertificationName
		, strCertificationName = CC.strContractCertifications
		, strCropYear = cropYear.strCropYear
		, cv.dblHedgedLots
		, cv.dblToBeHedgedLots
	FROM vyuRKRiskPositionContractDetail cv
	JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
	JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId AND um2.intCommodityId = cv.intCommodityId
	JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
	JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
	JOIN tblICItem ic ON ic.intItemId = cv.intItemId
	LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
	LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
	LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
	LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
	LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
	LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
	LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
	--LEFT JOIN tblICCertification certification
	--	ON certification.intCertificationId = ic.intCertificationId
	LEFT JOIN tblCTCropYear cropYear
		ON cropYear.intCropYearId = cv.intCropYearId
	OUTER APPLY (
		SELECT strContractCertifications = (LTRIM(STUFF((
			SELECT ', ' + ICC.strCertificationName
			FROM tblCTContractCertification CTC
			JOIN tblICCertification ICC
				ON ICC.intCertificationId = CTC.intCertificationId
			WHERE CTC.intContractDetailId = cv.intContractDetailId
			ORDER BY ICC.strCertificationName
			FOR XML PATH('')), 1, 1, ''))
		) COLLATE Latin1_General_CI_AS
	) CC
	WHERE cv.intCommodityId = @intCommodityId
		AND cv.intFutureMarketId = @intFutureMarketId
		AND cv.intContractStatusId NOT IN (2, 3)
		AND ISNULL(intBookId, 0) = ISNULL(@intBookId, ISNULL(intBookId, 0))
		AND ISNULL(intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(intSubBookId, 0))
		AND (@strPositionBy <> 'Origin'
			OR
			 (@strPositionBy = 'Origin' 
			  AND (ISNULL(origin.intCountryID, 0) = 0 AND -1 IN (SELECT intCountryID FROM #tmpOriginIds)
				  OR origin.intCountryID IN (SELECT intCountryID FROM #tmpOriginIds)
				  )
			 ))

	SELECT *
	INTO #ContractTransaction
	FROM (
		SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot * dblRatioContractSize) ELSE dblNoOfContract END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot * dblRatioContractSize) ELSE dblQuantity END
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM @PricedContractList cv
		WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 0
		
		--Parcial Priced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots * dblRatioContractSize) ELSE dblFixedQty END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = dblFixedLots
			, dblFixedQty = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots * dblRatioContractSize) ELSE dblFixedQty END
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, 1 intPricingTypeId
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT strFutureMonth
				, strAccountNumber
				, dblNoOfContract = 0
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
				, dblFixedLots = ISNULL((SELECT dblNoOfLots = SUM(dblLotsFixed)
										FROM tblCTPriceFixation pf
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, dblFixedQty = ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, SUM(dblQuantity)) dblQuantity
										FROM tblCTPriceFixation pf
										JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass 
				, strCertificationName
				, strCropYear 
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) = 0
		) t WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
		
		--Parcial UnPriced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)) * dblRatioContractSize) ELSE dblQuantity - dblFixedQty END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)
			, dblQuantity = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)) * dblRatioContractSize) ELSE dblQuantity - dblFixedQty END
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT strFutureMonth
				, strAccountNumber
				, dblNoOfContract = 0
				, strTradeNo
				, TransactionDate
				, TranType = strContractType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
				, cv.intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, cv.intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, dblFixedLots = ISNULL((SELECT dblNoOfLots = SUM(dblLotsFixed)
										FROM tblCTPriceFixation pf
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, dblFixedQty = ISNULL((SELECT dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, SUM(pd.dblQuantity))
										FROM tblCTPriceFixation pf
										JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, dblDeltaPercent = ISNULL(dblDeltaPercent,0)
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass 
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) = 0
		) t WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1 WHERE dblNoOfContract <> 0
	
	SELECT *
	INTO #DeltaPrecent
	FROM (
		SELECT strFutureMonth
			, strAccountNumber = strAccountNumber + ' (Delta=' + CONVERT(NVARCHAR, LEFT(dblDeltaPercent, 4)) + '%)'
			, dblNoOfContract = ((CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,dblQuantity * dblRatioContractSize) ELSE dblNoOfContract END) * dblDeltaPercent) / 100
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = (dblNoOfLot * dblDeltaPercent) / 100
			, dblQuantity = ((CASE WHEN intPricingTypeId = 8 THEN dblQuantity * dblRatioContractSize ELSE dblQuantity END) * dblDeltaPercent) / 100
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM @PricedContractList cv
		WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 1
		
		--Parcial Priced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = ((CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots * dblRatioContractSize) ELSE dblFixedQty END) * dblDeltaPercent) / 100
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = (dblFixedLots * dblDeltaPercent) / 100
			, dblFixedQty = ((CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots * dblRatioContractSize) ELSE dblFixedQty END) * dblDeltaPercent) / 100
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT strFutureMonth
				, strAccountNumber = strAccountNumber + ' (Delta=' + CONVERT(NVARCHAR, LEFT(dblDeltaPercent, 4)) + '%)'
				, dblNoOfContract = 0
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
				, dblFixedLots = ISNULL((SELECT dblNoOfLots = SUM(dblLotsFixed)
										FROM tblCTPriceFixation pf
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, dblFixedQty = ISNULL((SELECT dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, SUM(dblQuantity))
										FROM tblCTPriceFixation pf
										JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0)
				, dblDeltaPercent
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass 
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) = 1
		) t WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
		
		--Parcial UnPriced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblNoOfContract = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)) * dblRatioContractSize) ELSE dblQuantity - dblFixedQty END
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)
			, dblQuantity = CASE WHEN intPricingTypeId = 8 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0)) * dblRatioContractSize) ELSE dblQuantity - dblFixedQty END
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass 
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT strFutureMonth
				, strAccountNumber = strAccountNumber + ' (Delta=' + CONVERT(NVARCHAR, LEFT(dblDeltaPercent, 4)) + '%)'
				, dblNoOfContract = 0
				, strTradeNo
				, TransactionDate
				, TranType = strContractType
				, CustVendor
				, dblNoOfLot = (dblNoOfLot * dblDeltaPercent) / 100
				, dblQuantity = (dblQuantity * dblDeltaPercent) / 100
				, cv.intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, dblFixedLots = (ISNULL((SELECT dblNoOfLots = SUM(dblLotsFixed)
										FROM tblCTPriceFixation pf
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) * dblDeltaPercent) / 100
				, dblFixedQty = (ISNULL((SELECT dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, SUM(pd.dblQuantity))
										FROM tblCTPriceFixation pf
										JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
										WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) * dblDeltaPercent) / 100
				, intCommodityUnitMeasureId
				, dblRatioContractSize
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass 
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) = 1
		) t WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1 WHERE dblNoOfContract <> 0
	
	INSERT INTO @List (Selection
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
		, strGrade
		, strRegion 
		, strSeason 
		, strClass
		, strCertificationName
		, strCropYear
		, dblHedgedLots
		, dblToBeHedgedLots
	)
	SELECT Selection
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
		, strGrade
		, strRegion 
		, strSeason 
		, strClass
		, strCertificationName
		, strCropYear
		, dblHedgedLots
		, dblToBeHedgedLots
	FROM (
		SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Physical position / Basis risk'
				, PriceStatus = 'a. Unpriced - (Balance to be Priced)'
				, strFutureMonth = 'Previous'
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #ContractTransaction
			WHERE intPricingTypeId <> 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate
				AND intCommodityId = @intCommodityId AND intFutureMarketId = @intFutureMarketId
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
			
			UNION ALL SELECT DISTINCT Selection = 'Physical position / Basis risk'
				, PriceStatus = 'a. Unpriced - (Balance to be Priced)'
				, strFutureMonth
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #ContractTransaction
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION ALL SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Physical position / Basis risk'
				, PriceStatus = 'b. Priced / Outright - (Outright position)'
				, strFutureMonth = 'Previous'
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #ContractTransaction
			WHERE intPricingTypeId = 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate
				AND intCommodityId = @intCommodityId AND intFutureMarketId = @intFutureMarketId
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
			
			UNION SELECT DISTINCT Selection = 'Physical position / Basis risk'
				, PriceStatus = 'b. Priced / Outright - (Outright position)'
				, strFutureMonth
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #ContractTransaction
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION ALL SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Specialities & Low grades'
				, PriceStatus = 'a. Unfixed'
				, strFutureMonth = 'Previous'
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #DeltaPrecent
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId 
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate
			) T1
			
		UNION ALL SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Specialities & Low grades'
				, PriceStatus = 'b. fixed'
				, strFutureMonth = 'Previous'
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #DeltaPrecent
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId 
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate
			) T1
		
		UNION ALL SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Specialities & Low grades'
				, PriceStatus = 'a. Unfixed'
				, strFutureMonth
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #DeltaPrecent
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId 
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION ALL SELECT *
		FROM (
			SELECT DISTINCT Selection = 'Specialities & Low grades'
				, PriceStatus = 'b. fixed'
				, strFutureMonth
				, strAccountNumber
				, dblNoOfContract = CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (ABS(dblNoOfContract)) END
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = CASE WHEN strContractType = 'Purchase' THEN - (ABS(dblNoOfLot)) ELSE dblNoOfLot END
				, dblQuantity = CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (ABS(dblQuantity)) END
				, intContractHeaderId
				, intFutOptTransactionHeaderId = NULL
				, strProductType
				, strProductLine
				, strShipmentPeriod
				, strLocation
				, strOrigin
				, intItemId
				, strItemNo
				, strItemDescription
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM #DeltaPrecent
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId
				AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION ALL SELECT Selection
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT DISTINCT Selection = 'Terminal position (a. in lots )'
				, PriceStatus = 'Broker Account'
				, fm.strFutureMonth
				, strAccountNumber = e.strName + '-' + strAccountNumber
				, dblNoOfContract = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, strTradeNo = ft.strInternalTradeNo
				, TransactionDate = ft.dtmTransactionDate
				, TranType = strBuySell
				, CustVendor = e.strName
				, dblNoOfLot = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, dblQuantity = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract * @dblContractSize) ELSE - (ft.dblNoOfContract * @dblContractSize) END
				, intContractHeaderId = NULL
				, ft.intFutOptTransactionHeaderId
				, strProductType = ca.strDescription
				, strProductLine = pl.strDescription
				, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
				, strLocation = loc.strLocationName
				, strOrigin = origin.strDescription
				, intItemId = CD.intItemId
				, strItemNo = ic.strItemNo
				, strItemDescription = ic.strDescription
				, strGrade = grade.strDescription
				, strRegion = region.strDescription
				, strSeason = season.strDescription
				, strClass = class.strDescription
				, strCertificationName = certification.strCertificationName
				, strCropYear = cropYear.strCropYear
				, dblHedgedLots = NULL
				, dblToBeHedgedLots = NULL
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId 
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
			LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
			LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
			LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
			LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
			LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
			LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
			LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
			LEFT JOIN tblICCertification certification
				ON certification.intCertificationId = ic.intCertificationId
			LEFT JOIN tblCTCropYear cropYear
				ON cropYear.intCropYearId = CH.intCropYearId
			WHERE ft.intCommodityId = @intCommodityId
				AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
				AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
				AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
				AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
				AND ft.strStatus = 'Filled'
			) t
		
		UNION ALL SELECT Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, dblNoOfContract = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblQuantity)
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT DISTINCT Selection = 'Terminal position (b. in ' + @strUnitMeasure + ' )'
				, PriceStatus = 'Broker Account'
				, strFutureMonth
				, strAccountNumber = e.strName + '-' + strAccountNumber
				, dblNoOfContract = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, strTradeNo = ft.strInternalTradeNo
				, TransactionDate = ft.dtmTransactionDate
				, TranType = strBuySell
				, CustVendor = e.strName
				, dblNoOfLot = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, dblQuantity = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract * @dblContractSize) ELSE - (ft.dblNoOfContract * @dblContractSize) END
				, um.intCommodityUnitMeasureId
				, intContractHeaderId = NULL
				, ft.intFutOptTransactionHeaderId
				, strProductType = ca.strDescription
				, strProductLine = pl.strDescription
				, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
				, strLocation = loc.strLocationName
				, strOrigin = origin.strDescription
				, intItemId = CD.intItemId
				, strItemNo = ic.strItemNo
				, strItemDescription = ic.strDescription
				, strGrade = grade.strDescription
				, strRegion = region.strDescription
				, strSeason = season.strDescription
				, strClass = class.strDescription
				, strCertificationName = certification.strCertificationName
				, strCropYear = cropYear.strCropYear
				, dblHedgedLots = NULL
				, dblToBeHedgedLots = NULL
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
			LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
			LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
			LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
			LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
			LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
			LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
			LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
			LEFT JOIN tblICCertification certification
				ON certification.intCertificationId = ic.intCertificationId
			LEFT JOIN tblCTCropYear cropYear
				ON cropYear.intCropYearId = CH.intCropYearId
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
				AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
				AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
				AND ISNULL(ft.intSubBookId, 0)= ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
				AND ft.strStatus = 'Filled'
			) t
		
		UNION ALL SELECT DISTINCT Selection = 'Delta options'
			, PriceStatus = 'Broker Account'
			, strFutureMonth
			, strAccountNumber = e.strName + '-' + strAccountNumber
			, dblNoOfContract = (CASE WHEN ft.strBuySell = 'Buy'
										THEN (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																		FROM tblRKOptionsMatchPnS l
																		WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
									ELSE - (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																		FROM tblRKOptionsMatchPnS s
																		WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)) END)
								* ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = ft.intFutureMarketId
											AND mm.intOptionMonthId = ft.intOptionMonthId
											AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND ft.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
			, strTradeNo = ft.strInternalTradeNo
			, TransactionDate = ft.dtmTransactionDate
			, TranType = strBuySell
			, CustVendor = e.strName
			, dblNoOfLot = (CASE WHEN ft.strBuySell = 'Buy'
									THEN (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																	FROM tblRKOptionsMatchPnS l
																	WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
								ELSE - (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																	FROM tblRKOptionsMatchPnS s
																	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)) END)
							* ISNULL((SELECT TOP 1 dblDelta
									FROM tblRKFuturesSettlementPrice sp
									INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
									WHERE intFutureMarketId = ft.intFutureMarketId
										AND mm.intOptionMonthId = ft.intOptionMonthId
										AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
										AND ft.dblStrike = mm.dblStrike
									ORDER BY dtmPriceDate DESC), 0)
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta
								FROM tblRKFuturesSettlementPrice sp
								INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
								WHERE intFutureMarketId = ft.intFutureMarketId
									AND mm.intOptionMonthId = ft.intOptionMonthId
									AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
									AND ft.dblStrike = mm.dblStrike
								ORDER BY dtmPriceDate DESC), 0)
			, intContractHeaderId = NULL
			, ft.intFutOptTransactionHeaderId
			, strProductType = ca.strDescription
			, strProductLine = pl.strDescription
			, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
			, strLocation = loc.strLocationName
			, strOrigin = origin.strDescription
			, intItemId = CD.intItemId
			, strItemNo = ic.strItemNo
			, strItemDescription = ic.strDescription
			, strGrade = grade.strDescription
			, strRegion = region.strDescription
			, strSeason = season.strDescription
			, strClass = class.strDescription
			, strCertificationName = certification.strCertificationName
			, strCropYear = cropYear.strCropYear
			, dblHedgedLots = NULL
			, dblToBeHedgedLots = NULL
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
		LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
		LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
		LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
		LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
		LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
		LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
		LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
		LEFT JOIN tblICCertification certification
			ON certification.intCertificationId = ic.intCertificationId
		LEFT JOIN tblCTCropYear cropYear
			ON cropYear.intCropYearId = CH.intCropYearId
		WHERE ft.intCommodityId = @intCommodityId
			AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
			AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
			AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
			AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND ft.strStatus = 'Filled'
	) t
	
	UNION ALL SELECT DISTINCT Selection = 'F&O'
		, PriceStatus = 'F&O'
		, strFutureMonth
		, strAccountNumber = 'F&O'
		, dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
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
		, strGrade
		, strRegion 
		, strSeason 
		, strClass
		, strCertificationName
		, strCropYear
		, dblHedgedLots
		, dblToBeHedgedLots
	FROM (
		SELECT Selection
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT DISTINCT Selection = 'Terminal position (a. in lots )'
				, PriceStatus = 'Broker Account'
				, strFutureMonth
				, strAccountNumber = e.strName + '-' + strAccountNumber
				, dblNoOfContract = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, strTradeNo = ft.strInternalTradeNo
				, TransactionDate = ft.dtmTransactionDate
				, TranType = strBuySell
				, CustVendor = e.strName
				, dblNoOfLot = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
				, dblQuantity = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract * @dblContractSize) ELSE - (ft.dblNoOfContract * @dblContractSize) END
				, intContractHeaderId = NULL
				, ft.intFutOptTransactionHeaderId
				, strProductType = ca.strDescription
				, strProductLine = pl.strDescription
				, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
				, strLocation = loc.strLocationName
				, strOrigin = origin.strDescription
				, intItemId = CD.intItemId
				, strItemNo = ic.strItemNo
				, strItemDescription = ic.strDescription
				, strGrade = grade.strDescription
				, strRegion = region.strDescription
				, strSeason = season.strDescription
				, strClass = class.strDescription
				, strCertificationName = certification.strCertificationName
				, strCropYear = cropYear.strCropYear
				, dblHedgedLots = NULL
				, dblToBeHedgedLots = NULL
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
			LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
			LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
			LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
			LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
			LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
			LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
			LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
			LEFT JOIN tblICCertification certification
				ON certification.intCertificationId = ic.intCertificationId
			LEFT JOIN tblCTCropYear cropYear
				ON cropYear.intCropYearId = CH.intCropYearId
			WHERE ft.intCommodityId = @intCommodityId
				AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
				AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
				AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
				AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
				AND ft.strStatus = 'Filled'
			) t
		
		UNION ALL SELECT DISTINCT Selection = 'Delta options'
			, PriceStatus = 'Broker Account'
			, strFutureMonth
			, strAccountNumber = e.strName + '-' + strAccountNumber
			, dblNoOfContract = (CASE WHEN ft.strBuySell = 'Buy'
										THEN (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																		FROM tblRKOptionsMatchPnS l
																		WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
									ELSE - (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																		FROM tblRKOptionsMatchPnS s
																		WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)) END)
								* ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = ft.intFutureMarketId
											AND mm.intOptionMonthId = ft.intOptionMonthId
											AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND ft.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
			, strTradeNo = ft.strInternalTradeNo
			, TransactionDate = ft.dtmTransactionDate
			, TranType = strBuySell
			, CustVendor = e.strName
			, dblNoOfLot = (CASE WHEN ft.strBuySell = 'Buy'
									THEN (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																	FROM tblRKOptionsMatchPnS l
																	WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
								ELSE - (ft.dblNoOfContract - ISNULL((SELECT SUM(dblMatchQty)
																	FROM tblRKOptionsMatchPnS s
																	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)) END)
							* ISNULL((SELECT TOP 1 dblDelta
									FROM tblRKFuturesSettlementPrice sp
									INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
									WHERE intFutureMarketId = ft.intFutureMarketId
										AND mm.intOptionMonthId = ft.intOptionMonthId
										AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
										AND ft.dblStrike = mm.dblStrike
									ORDER BY dtmPriceDate DESC), 0)
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta
								FROM tblRKFuturesSettlementPrice sp
								INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
								WHERE intFutureMarketId = ft.intFutureMarketId
									AND mm.intOptionMonthId = ft.intOptionMonthId
									AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
									AND ft.dblStrike = mm.dblStrike
								ORDER BY dtmPriceDate DESC), 0)
			, intContractHeaderId = NULL
			, ft.intFutOptTransactionHeaderId
			, strProductType = ca.strDescription
			, strProductLine = pl.strDescription
			, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
			, strLocation = loc.strLocationName
			, strOrigin = origin.strDescription
			, intItemId = CD.intItemId
			, strItemNo = ic.strItemNo
			, strItemDescription = ic.strDescription
			, strGrade = grade.strDescription
			, strRegion = region.strDescription
			, strSeason = season.strDescription
			, strClass = class.strDescription
			, strCertificationName = certification.strCertificationName
			, strCropYear = cropYear.strCropYear
			, dblHedgedLots = NULL
			, dblToBeHedgedLots = NULL
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
		LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
		LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
		LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
		LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
		LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
		LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
		LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
		LEFT JOIN tblICCertification certification
			ON certification.intCertificationId = ic.intCertificationId
		LEFT JOIN tblCTCropYear cropYear
			ON cropYear.intCropYearId = CH.intCropYearId
		WHERE ft.intCommodityId = @intCommodityId
			AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
			AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
			AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
			AND ft.intFutureMarketId = @intFutureMarketId
			AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND ft.strStatus = 'Filled'
		) t
		
		UNION ALL SELECT DISTINCT Selection = 'Total F&O(b. in ' + @strUnitMeasure + ' )'
			, PriceStatus = 'F&O'
			, strFutureMonth
			, strAccountNumber = 'F&O'
			, dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT strFutureMonth
				, dblNoOfContract = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
				, intCommodityUnitMeasureId
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM (
				SELECT DISTINCT Selection = 'Terminal position (b. in ' + @strUnitMeasure + ' )'
					, PriceStatus = 'Broker Account'
					, strFutureMonth
					, strAccountNumber = e.strName + '-' + strAccountNumber
					, dblNoOfContract = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
					, strTradeNo = ft.strInternalTradeNo
					, TransactionDate = ft.dtmTransactionDate
					, TranType = strBuySell
					, CustVendor = e.strName
					, dblNoOfLot = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
					, dblQuantity = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract * @dblContractSize) ELSE - (ft.dblNoOfContract * @dblContractSize) END
					, um.intCommodityUnitMeasureId
					, intContractHeaderId = NULL
					, ft.intFutOptTransactionHeaderId
					, strProductType = ca.strDescription
					, strProductLine = pl.strDescription
					, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
					, strLocation = loc.strLocationName
					, strOrigin = origin.strDescription
					, intItemId = CD.intItemId
					, strItemNo = ic.strItemNo
					, strItemDescription = ic.strDescription
					, strGrade = grade.strDescription
					, strRegion = region.strDescription
					, strSeason = season.strDescription
					, strClass = class.strDescription
					, strCertificationName = certification.strCertificationName
					, strCropYear = cropYear.strCropYear
					, dblHedgedLots = NULL
					, dblToBeHedgedLots = NULL
				FROM tblRKFutOptTransaction ft
				INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
				INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
				INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
				INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
				LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
				LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
				LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
				LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
				LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
				LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
				LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
				LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
				LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
				LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
				LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
				LEFT JOIN tblICCertification certification
					ON certification.intCertificationId = ic.intCertificationId
				LEFT JOIN tblCTCropYear cropYear
					ON cropYear.intCropYearId = CH.intCropYearId
				WHERE ft.intCommodityId = @intCommodityId
					AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
					AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
					AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
					AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
					AND ft.strStatus = 'Filled'
				) t

			UNION ALL SELECT strFutureMonth
				, dblNoOfContract = dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId, @intUOMId, (dblNoOfContract)) * dblDelta * dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, @dblContractSize)
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
				, intCommodityUnitMeasureId
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM (
				SELECT DISTINCT Selection = 'Delta options'
					, PriceStatus = 'Broker Account'
					, strFutureMonth
					, strAccountNumber = e.strName + '-' + strAccountNumber
					, dblNoOfContract = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
					, strTradeNo = ft.strInternalTradeNo
					, TransactionDate = ft.dtmTransactionDate
					, TranType = strBuySell
					, CustVendor = e.strName
					, dblNoOfLot = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract) ELSE - (ft.dblNoOfContract) END
					, dblQuantity = CASE WHEN ft.strBuySell = 'Buy' THEN (ft.dblNoOfContract * @dblContractSize) ELSE - (ft.dblNoOfContract * @dblContractSize) END
					, um.intCommodityUnitMeasureId
					, dblDelta = (SELECT TOP 1 dblDelta
								FROM tblRKFuturesSettlementPrice sp
								INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
								WHERE intFutureMarketId = ft.intFutureMarketId
									AND mm.intOptionMonthId = ft.intOptionMonthId
									AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
									AND ft.dblStrike = mm.dblStrike
								ORDER BY dtmPriceDate DESC)
					, intContractHeaderId = NULL
					, ft.intFutOptTransactionHeaderId
					, strProductType = ca.strDescription
					, strProductLine = pl.strDescription
					, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), CD.dtmStartDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
					, strLocation = loc.strLocationName
					, strOrigin = origin.strDescription
					, intItemId = CD.intItemId
					, strItemNo = ic.strItemNo
					, strItemDescription = ic.strDescription
					, strGrade = grade.strDescription
					, strRegion = region.strDescription
					, strSeason = season.strDescription
					, strClass = class.strDescription
					, strCertificationName = certification.strCertificationName
					, strCropYear = cropYear.strCropYear
					, dblHedgedLots = NULL
					, dblToBeHedgedLots = NULL
				FROM tblRKFutOptTransaction ft
				INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
				INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
				INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
				INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
				LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
				LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ft.intContractDetailId
				LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = CD.intCompanyLocationId
				LEFT JOIN tblICItem ic ON ic.intItemId = CD.intItemId
				LEFT JOIN tblICCommodityProductLine pl ON ic.intProductLineId = pl.intCommodityProductLineId
				LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
				LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
				LEFT JOIN tblICCommodityAttribute grade ON grade.intCommodityAttributeId = ic.intGradeId
				LEFT JOIN tblICCommodityAttribute region ON region.intCommodityAttributeId = ic.intRegionId
				LEFT JOIN tblICCommodityAttribute season ON season.intCommodityAttributeId = ic.intSeasonId
				LEFT JOIN tblICCommodityAttribute class ON class.intCommodityAttributeId = ic.intClassVarietyId
				LEFT JOIN tblICCertification certification
					ON certification.intCertificationId = ic.intCertificationId
				LEFT JOIN tblCTCropYear cropYear
					ON cropYear.intCropYearId = CH.intCropYearId
				WHERE ft.intCommodityId = @intCommodityId
					AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
					AND ISNULL(ft.intBookId, 0) = ISNULL(@intBookId, ISNULL(ft.intBookId, 0))
					AND ISNULL(ft.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId, 0))
					AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
					AND ft.strStatus = 'Filled'
				) t
			) T

		---- Taken inventory Qty ----------
		INSERT INTO @List (Selection
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		)
		SELECT Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, SUM(dblNoOfContract)
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, SUM(dblNoOfLot)
			, SUM(dblQuantity)
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT Selection = 'Net market risk'
				, PriceStatus = 'Net market risk'
				, strFutureMonth
				, strAccountNumber = 'Market Risk'
				, dblNoOfContract = SUM(dblNoOfContract)
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = SUM(dblNoOfLot)
				, dblQuantity = SUM(dblQuantity)
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'b. Priced / Outright - (Outright position)'
			GROUP BY strFutureMonth
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			
			UNION ALL SELECT Selection = 'Net market risk'
				, PriceStatus = 'Net market risk'
				, strFutureMonth
				, strAccountNumber = 'Market Risk'
				, dblNoOfContract = SUM(dblNoOfContract)
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = SUM(dblNoOfLot)
				, dblQuantity = SUM(dblNoOfContract)
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE PriceStatus = 'F&O' AND Selection LIKE ('Total F&O%')
			GROUP BY strFutureMonth
				, strAccountNumber
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			
			UNION ALL SELECT Selection = 'Net market risk'
				, PriceStatus = 'Net market risk'
				, strFutureMonth
				, strAccountNumber = 'Market Risk'
				, dblNoOfContract = SUM(dblNoOfContract)
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot = SUM(dblNoOfLot)
				, dblQuantity = SUM(dblQuantity)
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE PriceStatus = 'b. fixed' AND Selection = ('Specialities & Low grades') 
			GROUP BY strFutureMonth
				, strAccountNumber
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
		) t
		GROUP BY Selection
			, PriceStatus
			, strAccountNumber
			, strFutureMonth
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		
		--- Switch Position ---------
		INSERT INTO @List (Selection
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		)
		SELECT Selection
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM (
			SELECT Selection = 'Switch position'
				, PriceStatus = 'Switch position'
				, strFutureMonth
				, strAccountNumber = 'Switch position'
				, dblNoOfContract = dblNoOfLot
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)' AND strAccountNumber LIKE '%Purchase%'
			
			UNION ALL SELECT Selection = 'Switch position'
				, PriceStatus = 'Switch position'
				, strFutureMonth
				, strAccountNumber = 'Switch position'
				, dblNoOfContract = dblNoOfLot
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)' AND strAccountNumber LIKE '%Sale%'
			
			UNION ALL SELECT Selection = 'Switch position'
				, PriceStatus = 'Switch position'
				, strFutureMonth
				, strAccountNumber = 'Switch position'
				, dblNoOfContract = dblNoOfLot
				, strTradeNo
				, TransactionDate
				, TranType
				, CustVendor
				, dblNoOfLot
				, dblQuantity
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
				, strGrade
				, strRegion 
				, strSeason 
				, strClass
				, strCertificationName
				, strCropYear
				, dblHedgedLots
				, dblToBeHedgedLots
			FROM @List
			WHERE PriceStatus = 'F&O' AND Selection = 'F&O'
		) t
		
		SELECT TOP 1 @strFutureMonth = strFutureMonth
		FROM @List
		WHERE strFutureMonth <> 'Previous'
		ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC
		
		UPDATE @List
		SET strFutureMonth = @strFutureMonth
		WHERE Selection = 'Switch position' AND strFutureMonth = 'Previous'
		
		UPDATE @List
		SET strFutureMonth = @strFutureMonth
		WHERE Selection = 'Net market risk' AND strFutureMonth = 'Previous' 

		UPDATE @List
		SET strFutureMonth = 'Previous'
		WHERE Selection = 'Net market risk' AND strFutureMonth IS NULL

		UPDATE @List
		SET strFutureMonth = 'Previous'
		WHERE Selection = 'Switch position' AND strFutureMonth IS NULL
		
		IF NOT EXISTS (SELECT * FROM tblRKFutOptTransaction ft
						JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
						JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
						JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
						WHERE intCommodityId = @intCommodityId
							AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
							AND ISNULL(intBookId, 0) = ISNULL(@intBookId, ISNULL(intBookId, 0))
							AND ISNULL(intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(intSubBookId, 0))
							AND ft.intFutureMarketId = @intFutureMarketId
							AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
							AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
							AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired))
		BEGIN
			DELETE FROM @List
			WHERE Selection LIKE '%F&O%'
		END
		
		UPDATE @List
		SET intOrderByHeading = 1
		WHERE Selection IN ('Physical position / Differential cover', 'Physical position / Basis risk')
		
		UPDATE @List
		SET intOrderByHeading = 2
		WHERE Selection = 'Specialities & Low grades'
		
		UPDATE @List
		SET intOrderByHeading = 3
		WHERE Selection = 'Total speciality delta fixed'
		
		UPDATE @List
		SET intOrderByHeading = 4
		WHERE Selection = 'Terminal position (a. in lots )'
		
		UPDATE @List
		SET intOrderByHeading = 5
		WHERE Selection = 'Terminal position (Avg Long Price)'
		
		UPDATE @List
		SET intOrderByHeading = 6
		WHERE Selection LIKE ('%Terminal position (b.%')
		
		UPDATE @List
		SET intOrderByHeading = 7
		WHERE Selection = 'Delta options'
		
		UPDATE @List
		SET intOrderByHeading = 8
		WHERE Selection = 'F&O'
		
		UPDATE @List
		SET intOrderByHeading = 9
		WHERE Selection LIKE ('%Total F&O(b. in%')
		
		UPDATE @List
		SET intOrderByHeading = 10
		WHERE Selection IN ('Outright coverage', 'Net market risk')
		
		UPDATE @List
		SET intOrderByHeading = 13
		WHERE Selection IN ('Switch position', 'Futures required')

		UPDATE @List
		SET intOrderBySubHeading = 1
		WHERE PriceStatus = 'a. Unpriced - (Balance to be Priced)'

		UPDATE @List
		SET intOrderBySubHeading = 2
		WHERE PriceStatus = 'b. Priced / Outright - (Outright position)'
		
		-- Commented for RM-3281
		--INSERT INTO @List(Selection
		--	, PriceStatus
		--	, strFutureMonth
		--	, strAccountNumber
		--	, dblNoOfContract
		--	, strTradeNo
		--	, TransactionDate
		--	, TranType
		--	, CustVendor
		--	, dblNoOfLot
		--	, dblQuantity
		--	, intContractHeaderId
		--	, intFutOptTransactionHeaderId
		--	, intOrderByHeading
		--	, strProductType
		--	, strProductLine
		--	, strShipmentPeriod
		--	, strLocation
		--	, strOrigin
		--	, intItemId
		--	, strItemNo
		--	, strItemDescription)
		--SELECT DISTINCT 'Physical position / Basis risk'
		--	, 'a. Unpriced - (Balance to be Priced)'
		--	, strFutureMonth
		--	, NULL
		--	, NULL
		--	, NULL
		--	, GETDATE()
		--	, NULL
		--	, NULL
		--	, NULL
		--	, NULL
		--	, NULL
		--	, NULL
		--	, 1
		--	, strProductType
		--	, strProductLine
		--	, strShipmentPeriod
		--	, strLocation
		--	, strOrigin
		--	, intItemId
		--	, strItemNo
		--	, strItemDescription
		--FROM @List WHERE strFutureMonth
		--NOT IN (SELECT DISTINCT strFutureMonth FROM @List WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)')
		
		SELECT intRowNumber
			, Selection
			, PriceStatus
			, strFutureMonth
			, intFutureMonthOrder = ROW_NUMBER() OVER (ORDER BY CASE WHEN strFutureMonth = 'Previous' THEN CAST('01/01/1900' AS DATE)
																	WHEN strFutureMonth = 'Total' THEN CAST('01/01/9999' AS DATE)
																	ELSE CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, '))
																	END )
			, strAccountNumber
			, dblNoOfContract = CONVERT(DOUBLE PRECISION, ROUND(ISNULL(dblNoOfContract, 0), ISNULL(@intDecimal,0)))
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot = ISNULL(dblNoOfLot,0)
			, dblQuantity = ISNULL(dblQuantity,0)
			, intOrderByHeading
			, intOrderBySubHeading
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
			, strGrade
			, strRegion 
			, strSeason 
			, strClass
			, strCertificationName
			, strCropYear
			, dblHedgedLots
			, dblToBeHedgedLots
		FROM @List
		ORDER BY intOrderByHeading
			, intOrderBySubHeading
			, CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
					WHEN strFutureMonth ='Total' THEN '01/01/9999'
					WHEN strFutureMonth NOT IN ('Previous', 'Total') THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) 
	END

	DROP TABLE #tmpOriginIds
END