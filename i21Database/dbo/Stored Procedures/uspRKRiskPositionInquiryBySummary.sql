﻿CREATE PROCEDURE [dbo].[uspRKRiskPositionInquiryBySummary]
	@intCommodityId INTEGER
	, @intCompanyLocationId INTEGER
	, @intFutureMarketId INTEGER
	, @intFutureMonthId INTEGER
	, @intUOMId INTEGER
	, @intDecimal INTEGER
	, @intForecastWeeklyConsumption INTEGER = NULL
	, @intForecastWeeklyConsumptionUOMId INTEGER = NULL
	, @intBookId int = NULL
	, @intSubBookId int = NULL
	, @strPositionBy nvarchar(100) = NULL
	, @dtmPositionAsOf datetime = NULL
	, @strUomType nvarchar(100) = NULL

AS

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

IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
	SET @intForecastWeeklyConsumptionUOMId = @intUOMId
END
IF (@intUOMId = 0)
BEGIN
	SELECT @intUOMId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId and ysnDefault = 1
END

DECLARE @strUnitMeasure nvarchar(200)
	, @dtmFutureMonthsDate datetime
	, @dblContractSize int
	, @ysnIncludeInventoryHedge BIT
	, @strRiskView nvarchar(200)
	, @strFutureMonth  nvarchar(15)
	, @dblForecastWeeklyConsumption numeric(24,10)
	, @strParamFutureMonth nvarchar(12)

SELECT @dblContractSize = convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId
SELECT TOP 1 @dtmFutureMonthsDate=CONVERT(DATETIME,'01 '+strFutureMonth),@strParamFutureMonth=strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId
SELECT TOP 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId

DECLARE @intoldUnitMeasureId int

SET @intoldUnitMeasureId = @intUOMId
SELECT @intUOMId=intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT TOP 1 @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge, @strRiskView = strRiskView FROM tblRKCompanyPreference

DECLARE @intForecastWeeklyConsumptionUOMId1 INT
SELECT @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId from tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId and intUnitMeasureId = @intForecastWeeklyConsumptionUOMId

SELECT @dblForecastWeeklyConsumption = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1,@intUOMId,@intForecastWeeklyConsumption),1)

DECLARE @ListImported AS TABLE (intRowNumber int
	, Selection nvarchar(200) COLLATE Latin1_General_CI_AS
	, PriceStatus nvarchar(200) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(20) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfContract decimal(24,10)
	, strTradeNo nvarchar(200) COLLATE Latin1_General_CI_AS
	, TransactionDate datetime
	, TranType nvarchar(200) COLLATE Latin1_General_CI_AS
	, CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfLot decimal(24,10)
	, dblQuantity decimal(24,10)
	, intOrderByHeading int
	, intContractHeaderId int
	, intFutOptTransactionHeaderId int)

---Roll Cost
DECLARE @RollCost AS TABLE (strFutMarketName nvarchar(200) COLLATE Latin1_General_CI_AS
	, strCommodityCode nvarchar(200) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(20) COLLATE Latin1_General_CI_AS
	, intFutureMarketId int
	, intCommodityId int
	, intFutureMonthId int
	, dblNoOfLot numeric(24,10)
	, dblQuantity numeric(24,10)
	, dblWtAvgOpenLongPosition  numeric(24,10)
	, strTradeNo nvarchar(100) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId int
	, intBookId INT
	, strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook nvarchar(100) COLLATE Latin1_General_CI_AS)

DECLARE @dtmCurrentDate datetime
SET @dtmCurrentDate = getdate()

INSERT INTO @RollCost(strFutMarketName
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
WHERE intCommodityId = @intCommodityId and intFutureMarketId = @intFutureMarketId
	AND ISNULL(intBookId,0) = ISNULL(@intBookId, ISNULL(intBookId,0))
	AND ISNULL(intSubBookId,0) = ISNULL(@intSubBookId, ISNULL(intSubBookId,0))
	AND ISNULL(intLocationId,0) = ISNULL(@intCompanyLocationId, ISNULL(intLocationId,0))
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

--To Purchase Value
DECLARE @DemandFinal1 AS TABLE (dblQuantity numeric(24,10)
	, intUOMId int
	, strPeriod nvarchar(200) COLLATE Latin1_General_CI_AS
	, strItemName nvarchar(200) COLLATE Latin1_General_CI_AS
	, dtmPeriod datetime
	, intItemId int
	, strDescription nvarchar(200) COLLATE Latin1_General_CI_AS)
	
DECLARE @DemandQty AS TABLE (intRowNumber int identity(1,1)
	, dblQuantity numeric(24,10)
	, intUOMId int
	, dtmPeriod datetime
	, strPeriod nvarchar(200) COLLATE Latin1_General_CI_AS
	, strItemName nvarchar(200) COLLATE Latin1_General_CI_AS
	, intItemId int
	, strDescription nvarchar(200) COLLATE Latin1_General_CI_AS)

DECLARE @DemandFinal AS TABLE (intRowNumber int identity(1,1)
	, dblQuantity numeric(24,10)
	, intUOMId int
	, dtmPeriod datetime
	, strPeriod nvarchar(200) COLLATE Latin1_General_CI_AS
	, strItemName nvarchar(200) COLLATE Latin1_General_CI_AS
	, intItemId int
	, strDescription nvarchar(200) COLLATE Latin1_General_CI_AS)

IF EXISTS(SELECT TOP 1 * FROM tblRKStgBlendDemand WHERE  dtmImportDate < @dtmToDate)
BEGIN
	INSERT INTO @DemandQty
	SELECT dblQuantity
		, d.intUOMId
		, CONVERT(DATETIME, '01 ' + strPeriod) dtmPeriod
		, strPeriod
		, strItemName
		, d.intItemId
		, c.strDescription
	FROM tblRKStgBlendDemand d
	JOIN tblICItem i on i.intItemId=d.intItemId and d.dblQuantity > 0
	JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
	JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and intProductTypeId=intCommodityAttributeId
		AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
	JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
	WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId = @intFutureMarketId 
END
ELSE
BEGIN
	INSERT INTO @DemandQty
	SELECT dblQuantity
		, d.intUOMId
		, CONVERT(DATETIME, '01 ' + strPeriod) dtmPeriod
		, strPeriod
		, strItemName
		, d.intItemId
		, c.strDescription
	FROM tblRKArchBlendDemand d
	JOIN tblICItem i on i.intItemId=d.intItemId and d.dblQuantity > 0
	JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
	JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and intProductTypeId=intCommodityAttributeId
		AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
	JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
	WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId = @intFutureMarketId and d.dtmImportDate = (select top 1 dtmImportDate tblRKArchBlendDemand 
																												where dtmImportDate<=@dtmToDate order by  dtmImportDate desc)
END

DECLARE @intRowNumber INT
DECLARE @dblQuantity numeric(24,10)
DECLARE @intUOMId1 int
DECLARE @dtmPeriod1 datetime
DECLARE @strFutureMonth1 nvarchar(20)
DECLARE @strItemName nvarchar(200)
DECLARE @intItemId int
DECLARE @strDescription nvarchar(200)

SELECT @intRowNumber = min(intRowNumber) from @DemandQty
WHILE @intRowNumber > 0
BEGIN
	SELECT @strFutureMonth1 = null
		, @dtmPeriod1 = null
		, @intUOMId1 = null
		, @dtmPeriod1 = null
		, @strItemName = null
		, @intItemId = null
		, @strDescription = null
	
	SELECT @dblQuantity = dblQuantity
		, @intUOMId1 = intUOMId
		, @dtmPeriod1 = dtmPeriod
		, @strItemName = strItemName
		, @intItemId = intItemId
		, @strDescription = strDescription
	FROM @DemandQty WHERE intRowNumber = @intRowNumber
	
	SELECT @strFutureMonth1 = strFutureMonth
	FROM tblRKFuturesMonth fm
	JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId
	WHERE @dtmPeriod1=CONVERT(DATETIME,'01 '+strFutureMonth)
		AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId
	
	IF @strFutureMonth1 IS NULL
	SELECT top 1 @strFutureMonth1=strFutureMonth FROM tblRKFuturesMonth fm
	JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId
	WHERE CONVERT(DATETIME,'01 '+strFutureMonth) > @dtmPeriod1
		AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId
	order by CONVERT(DATETIME,'01 '+strFutureMonth)
	
	INSERT INTO @DemandFinal1(dblQuantity
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
	
	SELECT @intRowNumber= min(intRowNumber) FROM @DemandQty WHERE intRowNumber > @intRowNumber
END

INSERT INTO @DemandFinal
SELECT SUM(dblQuantity) as dblQuantity
	, intUOMId
	, CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod
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
ORDER BY CONVERT(DATETIME,'01 '+strPeriod)

DECLARE @ListFinal AS TABLE (intRowNumber int
	, strGroup nvarchar(250) COLLATE Latin1_General_CI_AS
	, Selection nvarchar(200) COLLATE Latin1_General_CI_AS
	, PriceStatus nvarchar(200) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(20) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfContract decimal(24,10)
	, strTradeNo nvarchar(200) COLLATE Latin1_General_CI_AS
	, TransactionDate datetime
	, TranType nvarchar(200) COLLATE Latin1_General_CI_AS
	, CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfLot decimal(24,10)
	, dblQuantity decimal(24,10)
	, intOrderByHeading int
	, intContractHeaderId int
	, intFutOptTransactionHeaderId int
	, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, intBookId INT
	, strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook nvarchar(100) COLLATE Latin1_General_CI_AS)  

DECLARE @ContractTransaction AS TABLE (strFutureMonth nvarchar(200) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfContract decimal(24,10)
	, strTradeNo nvarchar(200) COLLATE Latin1_General_CI_AS
	, TransactionDate datetime
	, TranType nvarchar(200) COLLATE Latin1_General_CI_AS
	, CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfLot decimal(24,10)
	, dblQuantity decimal(24,10)
	, intContractHeaderId int
	, intFutOptTransactionHeaderId int
	, intPricingTypeId int
	, strContractType nvarchar(200) COLLATE Latin1_General_CI_AS
	, intCommodityId int
	, intCompanyLocationId int
	, intFutureMarketId int
	, dtmFutureMonthsDate datetime
	, ysnExpired bit
	, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, intBookId INT
	, strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook nvarchar(100) COLLATE Latin1_General_CI_AS)

DECLARE @PricedContractList AS TABLE (strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
	, strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
	, dblNoOfContract DECIMAL(24, 10)
	, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, TransactionDate DATETIME
	, TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	, CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
	, dblNoOfLot DECIMAL(24, 10)
	, dblQuantity DECIMAL(24, 10)
	, intContractHeaderId INT
	, intFutOptTransactionHeaderId INT
	, intPricingTypeId INT
	, strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
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
	, dblRatioQty DECIMAL(24, 10)
	, intPricingTypeIdHeader int
	, ysnMultiplePriceFixation bit
	, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, intBookId INT
	, strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook nvarchar(100) COLLATE Latin1_General_CI_AS)

INSERT INTO @PricedContractList
SELECT fm.strFutureMonth
	, strContractType + ' - ' + case when @strPositionBy= 'Product Type' then ISNULL(ca.strDescription, '') else ISNULL(cv.strEntityName, '') end COLLATE Latin1_General_CI_AS AS strAccountNumber
	, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) ELSE dblDetailQuantity END) AS dblNoOfContract
	, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + convert(NVARCHAR, intContractSeq) COLLATE Latin1_General_CI_AS AS strTradeNo
	, dtmStartDate AS TransactionDate
	, strContractType AS TranType
	, strEntityName AS CustVendor
	, dblNoOfLots AS dblNoOfLot
	, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) ELSE dblDetailQuantity END) AS dblQuantity
	, cv.intContractHeaderId
	, NULL AS intFutOptTransactionHeaderId
	, intPricingTypeId
	, cv.strContractType
	, cv.intCommodityId
	, cv.intCompanyLocationId
	, cv.intFutureMarketId
	, CONVERT(DATETIME,'01 '+cv.strFutureMonth) dtmFutureMonthsDate
	, ysnExpired
	, ISNULL(pl.ysnDeltaHedge, 0) ysnDeltaHedge
	, intContractStatusId
	, dblDeltaPercent
	, cv.intContractDetailId
	, um.intCommodityUnitMeasureId
	, dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,ffm.dblContractSize) dblRatioContractSize
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
FROM vyuRKRiskPositionContractDetail cv
JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId and um2.intCommodityId = cv.intCommodityId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
JOIN tblICItem ic ON ic.intItemId = cv.intItemId
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
WHERE cv.intCommodityId = @intCommodityId AND cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId NOT IN (2, 3)
	and ISNULL(intBookId,0) = ISNULL(@intBookId, ISNULL(intBookId,0))
	and ISNULL(intSubBookId,0) = ISNULL(@intSubBookId, ISNULL(intSubBookId,0))
	and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

INSERT INTO @ContractTransaction (strFutureMonth
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
	, strSubBook)
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
FROM (
	-- Direct Pricing
	SELECT strFutureMonth
		, strAccountNumber
		, case when intPricingTypeIdHeader=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty) else dblNoOfContract end dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, case when intPricingTypeIdHeader=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty) else dblQuantity end dblQuantity
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
	FROM @PricedContractList cv
	WHERE cv.intPricingTypeId in (1,2,8) AND ysnDeltaHedge = 0 and intContractDetailId not in(SELECT ISNULL(intContractDetailId,0) from tblCTPriceFixation)
	
	--Parcial Priced
	UNION ALL SELECT strFutureMonth
		, strAccountNumber
		, case when intPricingTypeIdHeader=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty/dblNoOfLot)* dblFixedLots) else dblFixedQty end AS dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblFixedLots dblNoOfLot
		, case when intPricingTypeIdHeader=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(dblRatioQty/dblNoOfLot)*dblFixedLots) else dblFixedQty end dblFixedQty
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
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM (
		SELECT strFutureMonth
			, strAccountNumber
			, 0 AS dblNoOfContract
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
			, ISNULL((SELECT sum(pd.dblNoOfLots) dblNoOfLots
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId
							AND pf.intContractDetailId = CASE WHEN ISNULL(cv.ysnMultiplePriceFixation,0) = 0 THEN cv.intContractDetailId else pf.intContractDetailId end
							and CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate), 0) dblFixedLots
			, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId
							AND pf.intContractDetailId = CASE WHEN ISNULL(cv.ysnMultiplePriceFixation,0) = 0 THEN cv.intContractDetailId else pf.intContractDetailId end
							and CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate), 0) dblFixedQty,intCommodityUnitMeasureId
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
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3  AND ISNULL(ysnDeltaHedge, 0) =0
			and intContractDetailId in(select ISNULL(intContractDetailId,0) from tblCTPriceFixation)
	) t where dblFixedLots > 0
	
	--Parcial UnPriced
	UNION ALL SELECT strFutureMonth
		, strAccountNumber
		, case when intPricingTypeIdHeader=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(((dblRatioQty/dblNoOfLot)*ISNULL(dblNoOfLot, 0)))) else dblQuantity - dblFixedQty end AS dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) dblNoOfLot
		, case when intPricingTypeIdHeader=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,((dblRatioQty/dblNoOfLot)*ISNULL(dblNoOfLot, 0) - (dblRatioQty/dblNoOfLot)*ISNULL(dblFixedLots, 0))) else dblQuantity - dblFixedQty end dblQuantity
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, 2 intPricingTypeId
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
			, 0 AS dblNoOfContract
			, strTradeNo
			, TransactionDate
			, strContractType AS TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
			, cv.intContractHeaderId
			, NULL AS intFutOptTransactionHeaderId
			, cv.intPricingTypeId
			, cv.strContractType
			, cv.intCommodityId
			, cv.intCompanyLocationId
			, cv.intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, dblRatioQty
			, ISNULL((SELECT sum(pd.dblNoOfLots) dblNoOfLots
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId
							AND pf.intContractDetailId = CASE WHEN ISNULL(cv.ysnMultiplePriceFixation,0) = 0 THEN cv.intContractDetailId else pf.intContractDetailId end
							and CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate), 0) dblFixedLots
			, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(pd.dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId
							AND pf.intContractDetailId = CASE WHEN ISNULL(cv.ysnMultiplePriceFixation,0) = 0 THEN cv.intContractDetailId else pf.intContractDetailId end
							and CONVERT(DATETIME, CONVERT(VARCHAR(10), pd.dtmFixationDate, 110), 110) <= @dtmToDate), 0) dblFixedQty
			, ISNULL(dblDeltaPercent,0) dblDeltaPercent
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
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3  AND ISNULL(ysnDeltaHedge, 0) =0
			and intContractDetailId in(select ISNULL(intContractDetailId,0) from tblCTPriceFixation)
	) t WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
) t1

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
	, '1.Outright Coverage','Outright Coverage' COLLATE Latin1_General_CI_AS Selection
	, '1.Priced / Outright - (Outright position)' COLLATE Latin1_General_CI_AS PriceStatus
	, case when CONVERT(DATETIME,'01 '+strFutureMonth) < @dtmFutureMonthsDate then 'Previous' else strFutureMonth end COLLATE Latin1_General_CI_AS strFutureMonth
	, strAccountNumber
	, case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract
	, strTradeNo
	, TransactionDate
	, TranType
	, CustVendor
	, dblNoOfLot dblNoOfLot
	, case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity
	, 1 intOrderByHeading
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
FROM @ContractTransaction
WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId
	AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
	AND intFutureMarketId=@intFutureMarketId AND ISNULL(dblNoOfContract,0) <> 0

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
	, 'Outright Coverage' COLLATE Latin1_General_CI_AS Selection
	, '1.Priced / Outright - (Outright position)' COLLATE Latin1_General_CI_AS PriceStatus
	, @strParamFutureMonth strFutureMonth
	, strAccountNumber
	, sum(dblNoOfLot) dblNoOfLot
	, null
	, getdate() TransactionDate
	, 'Inventory' COLLATE Latin1_General_CI_AS TranType
	, null
	, 0.0
	, sum(dblNoOfLot) dblQuantity
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
	SELECT DISTINCT 'Purchase' + ' - ' + ISNULL(c.strDescription,'') COLLATE Latin1_General_CI_AS as strAccountNumber
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,t.dblQuantity) dblNoOfLot
		, strProductType = c.strDescription
		, strProductLine = pl.strDescription
		, strShipmentPeriod = RIGHT(CONVERT(VARCHAR(11), t.dtmDate, 106), 8) + ' - ' + RIGHT(CONVERT(VARCHAR(11), t.dtmDate, 106), 8)
		, strLocation = cl.strLocationName
		, strOrigin = origin.strDescription
		, intItemId = ic.intItemId
		, strItemNo = ic.strItemNo
		, strItemDescription = ic.strDescription
	FROM vyuRKGetInventoryValuation t
	JOIN tblICItem ic on t.intItemId=ic.intItemId
	JOIN tblICCommodityAttribute c on c.intCommodityAttributeId=ic.intProductTypeId
	LEFT JOIN tblICCommodityAttribute origin ON origin.intCommodityAttributeId = ic.intOriginId
	JOIN tblICCommodityProductLine pl on pl.intCommodityProductLineId=ic.intProductLineId
	JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and m.intFutureMarketId =@intFutureMarketId and  ic.intProductTypeId= c.intCommodityAttributeId
		AND c.intCommodityAttributeId in (SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
	join tblICItemLocation il on il.intItemId=ic.intItemId
	join tblICItemUOM i on il.intItemId=i.intItemId and i.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure um on um.intCommodityId=@intCommodityId and um.intUnitMeasureId=i.intUnitMeasureId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=il.intLocationId
	WHERE ic.intCommodityId=@intCommodityId  and m.intFutureMarketId=@intFutureMarketId
		AND cl.intCompanyLocationId = ISNULL(@intCompanyLocationId, cl.intCompanyLocationId)
		and convert(DATETIME, CONVERT(VARCHAR(10), t.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
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
SELECT * FROM (
	SELECT intRowNumber
		, grpname
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,case when strBuySell='Sell' then -abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) else abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) end *@dblContractSize) as dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, case when strBuySell='Sell' then -abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) else abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) end as dblNoOfLot
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,case when strBuySell='Sell' then -abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) else abs(ISNULL(Long1+Sell1,0) - ISNULL(MatchLong+MatchShort,0)) end*@dblContractSize) dblQuantity
		, 2 intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM (
		SELECT DISTINCT 2 intRowNumber
			, '1.Outright Coverage' COLLATE Latin1_General_CI_AS grpname
			, 'Outright Coverage' COLLATE Latin1_General_CI_AS Selection
			, '2.Terminal Position' COLLATE Latin1_General_CI_AS PriceStatus
			, strFutureMonth strFutureMonth
			, e.strName + '-' + strAccountNumber as strAccountNumber
			, strBuySell
			, ISNULL(CASE WHEN ft.strBuySell = 'Buy' THEN ISNULL(ft.dblNoOfContract, 0)
						ELSE NULL END, 0) Long1
			, ISNULL(CASE WHEN ft.strBuySell = 'Sell' THEN ISNULL(ft.dblNoOfContract, 0)
						ELSE NULL END, 0) Sell1
			, ISNULL((SELECT SUM(dblMatchQty)
						FROM tblRKMatchFuturesPSDetail psd
						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
						WHERE psd.intLFutOptTransactionId = ft.intFutOptTransactionId
							AND h.strType = 'Realize'
							AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchLong
			, ISNULL((SELECT sum(dblMatchQty)
						FROM tblRKMatchFuturesPSDetail psd
						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
						WHERE psd.intSFutOptTransactionId = ft.intFutOptTransactionId
							AND h.strType = 'Realize'
							AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchShort
			, ft.strInternalTradeNo as strTradeNo
			, ft.dtmFilledDate as TransactionDate
			, strBuySell as TranType
			, e.strName as CustVendor
			, um.intCommodityUnitMeasureId
			, null as intContractHeaderId
			, ft.intFutOptTransactionHeaderId
			, ft.intBookId
			, book.strBook
			, ft.intSubBookId
			, subBook.strSubBook
		FROM tblRKFutOptTransaction ft
		JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId and ft.strStatus='Filled'
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  and ft.intInstrumentTypeId in (1,3)  and ft.intCommodityId=@intCommodityId
			and ft.intFutureMarketId=@intFutureMarketId
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
		JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
		LEFT JOIN tblCTBook book ON book.intBookId = ft.intBookId
		LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = ft.intSubBookId
		WHERE ft.intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId
			AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
			AND ISNULL(ft.intBookId,0) = ISNULL(@intBookId, ISNULL(ft.intBookId,0))
			AND ISNULL(ft.intSubBookId,0) = ISNULL(@intSubBookId, ISNULL(ft.intSubBookId,0))
			and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) <= @dtmToDate
			and CONVERT(DATETIME,'01 '+strFutureMonth) >= @dtmFutureMonthsDate
	)t
)t1 where dblNoOfContract<>0

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
	, CONVERT(DOUBLE PRECISION,ISNULL(dblNoOfContract,0.0)) as dblNoOfContract
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
WHERE intRowNumber in(1,2) and strFutureMonth <> 'Previous'

UNION ALL SELECT 4 intRowNumber
	, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
	, 'Market coverage' COLLATE Latin1_General_CI_AS Selection
	, '3.Market coverage' COLLATE Latin1_General_CI_AS PriceStatus
	, @strParamFutureMonth
	, 'Market Coverage' COLLATE Latin1_General_CI_AS strAccountNumber
	, CONVERT(DOUBLE PRECISION,ISNULL(dblNoOfContract,0.0)) as dblNoOfContract
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
WHERE intRowNumber in(1,2)  and strFutureMonth = 'Previous'

IF (ISNULL(@intForecastWeeklyConsumption,0) <> 0)
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
		, 'Market Coverage' COLLATE Latin1_General_CI_AS Selection
		, '4.Market Coverage(Weeks)' COLLATE Latin1_General_CI_AS PriceStatus
		, strFutureMonth
		, 'Market Coverage(Weeks)' COLLATE Latin1_General_CI_AS strAccountNumber
		, case when ISNULL(@dblForecastWeeklyConsumption,0)=0 then 0 else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))/@dblForecastWeeklyConsumption end as dblNoOfContract
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
	FROM @ListFinal WHERE intRowNumber in(4)
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
	, ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract
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
	SELECT DISTINCT 6 intRowNumber
		, '2.Futures Required' COLLATE Latin1_General_CI_AS strGroup
		, 'Futures Required' COLLATE Latin1_General_CI_AS Selection
		, '1.Unpriced - (Balance to be Priced)' COLLATE Latin1_General_CI_AS PriceStatus
		, case when CONVERT(DATETIME,'01 '+strFutureMonth) < @dtmFutureMonthsDate then 'Previous' else strFutureMonth end COLLATE Latin1_General_CI_AS strFutureMonth
		, strAccountNumber
		, (case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end)  as dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, (case when strContractType='Purchase' then dblNoOfLot else -(abs(dblNoOfLot)) end) dblNoOfLot
		, case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity
		, intContractHeaderId
		, NULL as intFutOptTransactionHeaderId
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
	FROM @ContractTransaction
	WHERE ysnExpired=0 and intPricingTypeId <> 1  AND intCommodityId=@intCommodityId
		AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
		AND intFutureMarketId=@intFutureMarketId
)T1

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
SELECT  DISTINCT 7 intRowNumber
	, '2.Futures Required' COLLATE Latin1_General_CI_AS
	, 'Futures Required' COLLATE Latin1_General_CI_AS as Selection
	, '2.To Purchase' COLLATE Latin1_General_CI_AS as PriceStatus
	, case when  CONVERT(DATETIME,'01 '+strPeriod)< @dtmFutureMonthsDate then 'Previous' else strPeriod end COLLATE Latin1_General_CI_AS as strFutureMonth
	, strDescription as strAccountNumber
	, dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,ISNULL(dblQuantity,0)) as dblNoOfContract
	, strItemName
	, dtmPeriod
	, null
	, null
	, round(dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,ISNULL(dblQuantity,0)) 
              / dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,@dblContractSize),0) as dblNoOfLot
	, dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,ISNULL(dblQuantity,0))as dblQuantity
	, 8
	, null
	, null
FROM @DemandFinal cv
JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=@intFutureMarketId
JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=@intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId
JOIN tblICItemUOM u on cv.intUOMId=u.intItemUOMId
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
SELECT 8 intRowNumber
	, '2.Futures Required' COLLATE Latin1_General_CI_AS
	, 'Futures Required' COLLATE Latin1_General_CI_AS Selection
	, '3.Terminal position' COLLATE Latin1_General_CI_AS PriceStatus
	, strFutureMonth
	, strAccountNumber
	, dblNoOfContract as dblNoOfContract
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
FROM @ListFinal WHERE intRowNumber in(2)

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
SELECT 9 intRowNumber
	, '2.Futures Required' COLLATE Latin1_General_CI_AS
	, 'Futures Required' COLLATE Latin1_General_CI_AS Selection
	, '4.Net Position' COLLATE Latin1_General_CI_AS PriceStatus
	, strFutureMonth
	, 'Net Position' COLLATE Latin1_General_CI_AS
	, sum(dblNoOfContract1)-sum(dblNoOfContract)
	, sum(dblNoOfLot1)-sum(dblNoOfLot)
	, sum(dblQuantity1)-sum(dblQuantity)
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
	SELECT case when strFutureMonth = 'Previous' then @strParamFutureMonth else strFutureMonth end COLLATE Latin1_General_CI_AS strFutureMonth
		, 0 dblNoOfContract1
		, 0 dblNoOfLot1
		, 0 dblQuantity1
		, sum(dblQuantity) as dblNoOfContract
		, sum(dblNoOfLot) dblNoOfLot
		, sum(dblQuantity) dblQuantity
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
	FROM @ListFinal WHERE intRowNumber in(6,7)
	group by strFutureMonth
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
		, sum(dblQuantity) as dblNoOfContract1
		, sum(dblNoOfLot) dblNoOfLot1
		, sum(dblQuantity) dblQuantity1
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
	FROM @ListFinal WHERE intRowNumber in(8)
	group by strFutureMonth
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
)t group by strFutureMonth
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
SELECT 10 intRowNumber
	, '2.Futures Required' COLLATE Latin1_General_CI_AS
	, Selection
	, PriceStatus
	, strFutureMonth
	, strAccountNumber
	, (dblQuantity)/sum(dblNoOfLot) over(PARTITION by strFutureMonth) as dblNoOfContract
	, strTradeNo
	, getdate() TransactionDate
	, null
	, null
	, dblNoOfLot
	, dblQuantity
	, 10
	, null
	, intFutOptTransactionHeaderId
	, intBookId
	, strBook
	, intSubBookId
	, strSubBook
FROM (
	SELECT DISTINCT 'Futures Required' COLLATE Latin1_General_CI_AS as Selection
		, '5.Avg Long Price' COLLATE Latin1_General_CI_AS as PriceStatus
		, ft.strFutureMonth
		, 'Avg Long Price' COLLATE Latin1_General_CI_AS as strAccountNumber
		, dblWtAvgOpenLongPosition as dblNoOfContract
		, dblNoOfLot
		, dblQuantity*dblNoOfLot dblQuantity
		, strTradeNo
		, intFutOptTransactionHeaderId
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
	FROM @RollCost ft
	WHERE ft.intCommodityId=@intCommodityId and intFutureMarketId=@intFutureMarketId
		and CONVERT(DATETIME,'01 '+ ft.strFutureMonth) >= CONVERT(DATETIME,'01 '+ @strParamFutureMonth)
)t

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
SELECT 11
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
FROM @ListFinal where strAccountNumber <> 'Avg Long Price'
ORDER BY intRowNumber
	, CASE WHEN strFutureMonth not in('Previous','Total') THEN CONVERT(DATETIME,'01 '+strFutureMonth) END
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
SELECT 11 intRowNumber
	, strGroup
	, Selection
	, PriceStatus
	, 'Total' COLLATE Latin1_General_CI_AS strFutureMonth
	, strAccountNumber
	, sum(dblQuantity)/sum(dblNoOfLot) dblNoOfContract
	, '' strTradeNo
	, '' TransactionDate
	, '' TranType
	, '' CustVendor
	, sum(dblNoOfLot) dblNoOfLot
	, sum(dblQuantity) dblQuantity
	, null intOrderByHeading
	, null intContractHeaderId
	, null intFutOptTransactionHeaderId
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
FROM @ListFinal where strAccountNumber = 'Avg Long Price'
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

DECLARE @MonthOrder AS TABLE (intRowNumber1 int identity(1,1)
	, intRowNumber int
	, strGroup nvarchar(200) COLLATE Latin1_General_CI_AS
	, Selection nvarchar(200) COLLATE Latin1_General_CI_AS
	, PriceStatus nvarchar(200) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(20) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfContract decimal(24,10)
	, strTradeNo nvarchar(200) COLLATE Latin1_General_CI_AS
	, TransactionDate datetime
	, TranType nvarchar(200) COLLATE Latin1_General_CI_AS
	, CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS
	, dblNoOfLot decimal(24,10)
	, dblQuantity decimal(24,10)
	, intOrderByHeading int
	, intContractHeaderId int
	, intFutOptTransactionHeaderId int
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

DECLARE @strAccountNumber NVARCHAR(MAX)
SELECT TOP 1 @strAccountNumber=strAccountNumber FROM @ListFinal
WHERE strGroup = '1.Outright Coverage' and PriceStatus = '1.Priced / Outright - (Outright position)' order by intRowNumber

DECLARE @MonthList AS TABLE (strFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS)

INSERT INTO @MonthList(strFutureMonth)
SELECT DISTINCT strFutureMonth FROM @ListFinal 
WHERE strGroup = '1.Outright Coverage' and PriceStatus in('1.Priced / Outright - (Outright position)')

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
SELECT DISTINCT 0
	, '1.Outright Coverage' COLLATE Latin1_General_CI_AS
	, 'Outright Coverage' COLLATE Latin1_General_CI_AS
	, '1.Priced / Outright - (Outright position)' COLLATE Latin1_General_CI_AS
	, strFutureMonth
	, @strAccountNumber
	, NULL
	, NULL
	, GETDATE()
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
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
FROM @ListFinal  WHERE strFutureMonth
NOT IN (SELECT DISTINCT strFutureMonth FROM @MonthList)

INSERT INTO @MonthOrder  (intRowNumber
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
	, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))
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
FROM @ListFinal where strFutureMonth='Previous'

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
	, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))
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
FROM @ListFinal where strFutureMonth NOT IN('Previous','Total')
ORDER BY intRowNumber,strBook,strSubBook,PriceStatus,CONVERT(DATETIME,'01 '+strFutureMonth) ASC

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
	, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))
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
FROM @ListFinal where strFutureMonth='Total'

--INSERT INTO @MonthOrder (intRowNumber
--	, strGroup
--	, Selection
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
--	, intOrderByHeading
--	, intContractHeaderId
--	, intFutOptTransactionHeaderId
--	, strProductType
--	, strProductLine
--	, strShipmentPeriod
--	, strLocation
--	, strOrigin
--	, intItemId
--	, strItemNo
--	, strItemDescription
--	, intBookId
--	, strBook
--	, intSubBookId
--	, strSubBook)
--SELECT DISTINCT intRowNumber
--	, strGroup
--	, Selection
--	, PriceStatus
--	, b.strFutureMonth
--	, strAccountNumber
--	, 0--CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))
--	, strTradeNo = ''
--	, TransactionDate = ''
--	, TranType
--	, CustVendor
--	, dblNoOfLot = 0
--	, dblQuantity = 0
--	, intOrderByHeading
--	, intContractHeaderId = null
--	, intFutOptTransactionHeaderId = null
--	, strProductType = null
--	, strProductLine = null
--	, strShipmentPeriod = ''
--	, strLocation = ''
--	, strOrigin = null
--	, intItemId = null
--	, strItemNo = ''
--	, strItemDescription = ''
--	, intBookId = null
--	, strBook = null
--	, intSubBookId = null
--	, strSubBook = null
--FROM @ListFinal a
-- LEFT JOIN (
--SELECT DISTINCT strFutureMonth FROM @ListFinal
--) b ON a.strFutureMonth = b.strFutureMonth
--WHERE intRowNumber = 1

SELECT intRowNumber1 intRowNumFinal
	, intRowNumber
	, strGroup
	, Selection
	, PriceStatus
	, strFutureMonth
	, strAccountNumber
	, case when @strUomType='By Lot' and PriceStatus = '4.Market Coverage(Weeks)' THEN (CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)))/@intForecastWeeklyConsumption
		when @strUomType='By Lot' and strAccountNumber <> 'Avg Long Price' then (CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)))
		else  CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end dblNoOfContract
	, strTradeNo
	, TransactionDate
	, TranType
	, CustVendor
	, dblNoOfLot
	, dblQuantity
	, isnull(intOrderByHeading,0) intOrderByHeading
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
ORDER BY strGroup,
strBook,strSubBook
	, PriceStatus
	, CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
			WHEN strFutureMonth ='Total' THEN '01/01/9999'
			ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END