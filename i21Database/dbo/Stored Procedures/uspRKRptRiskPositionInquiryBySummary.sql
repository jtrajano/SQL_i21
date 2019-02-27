CREATE PROCEDURE [dbo].[uspRKRptRiskPositionInquiryBySummary]
	@xmlParam NVARCHAR(MAX)

AS

DECLARE @idoc INT
	, @intCommodityId INTEGER
	, @intCompanyLocationId INTEGER
	, @intFutureMarketId INTEGER
	, @intFutureMonthId INTEGER
	, @intUOMId INTEGER
	, @intDecimal INTEGER
	, @intForecastWeeklyConsumption INTEGER = NULL
	, @intForecastWeeklyConsumptionUOMId INTEGER = NULL
	, @intBookId INTEGER = NULL
	, @intSubBookId INTEGER = NULL
	, @strPositionBy NVARCHAR(100) = NULL
	, @dtmPositionAsOf datetime=NULL
	, @strReportName NVARCHAR(100)=NULL
	, @strUomType NVARCHAR(100)=NULL

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (fieldname NVARCHAR(50)
	, condition NVARCHAR(20)
	, [from] NVARCHAR(50)
	, [to] NVARCHAR(50)
	, [join] NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup] NVARCHAR(50)
	, [datatype] NVARCHAR(50))

EXEC sp_xml_preparedocument @idoc OUTPUT
	, @xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (fieldname NVARCHAR(50)
	, condition NVARCHAR(20)
	, [from] NVARCHAR(50)
	, [to] NVARCHAR(50)
	, [join] NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup] NVARCHAR(50)
	, [datatype] NVARCHAR(50))

SELECT @intCommodityId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intCommodityId'
SELECT @intCompanyLocationId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intCompanyLocationId'
SELECT @intFutureMarketId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intFutureMarketId'
SELECT @intFutureMonthId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intFutureMonthId'
SELECT @intUOMId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intUOMId'
SELECT @intDecimal = [from] FROM @temp_xml_table WHERE [fieldname] = 'intDecimal'
SELECT @intForecastWeeklyConsumption = [from] FROM @temp_xml_table WHERE [fieldname] = 'intForecastWeeklyConsumption'
SELECT @intForecastWeeklyConsumptionUOMId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intForecastWeeklyConsumptionUOMId'
SELECT @intBookId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intBookId'
SELECT @intSubBookId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intSubBookId'
SELECT @strPositionBy = [from] FROM @temp_xml_table WHERE [fieldname] = 'strPositionBy'
SELECT @dtmPositionAsOf = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmPositionAsOf'
SELECT @strReportName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strReportName'
SELECT @strUomType = [from] FROM @temp_xml_table WHERE [fieldname] = 'strUomType'

IF ISNULL(@intCommodityId, 0) = 0
BEGIN
	SET @intCommodityId = NULL
END
IF ISNULL(@intCompanyLocationId, 0) = 0
BEGIN
	SET @intCompanyLocationId = NULL
END
IF ISNULL(@intFutureMarketId, 0) = 0
BEGIN
	SET @intFutureMarketId = NULL
END
IF ISNULL(@intFutureMonthId, 0) = 0
BEGIN
	SET @intFutureMonthId = NULL
END
IF ISNULL(@intUOMId, 0) = 0
BEGIN
	SET @intUOMId = NULL
END
IF ISNULL(@intBookId, 0) = 0
BEGIN
	SET @intBookId = NULL
END
IF ISNULL(@intSubBookId, 0) = 0
BEGIN
	SET @intSubBookId = NULL
END

DECLARE @strCommodityCodeH NVARCHAR(100)
	, @strFutureMarketH NVARCHAR(100)
	, @strFutureMonthH NVARCHAR(100)
	, @strUnitMeasureH NVARCHAR(100)
	, @strLocationH NVARCHAR(100)
	, @strBookH NVARCHAR(100)
	, @strSubBookH NVARCHAR(100)

IF (ISNULL(@xmlParam ,'') = '')
BEGIN
	SELECT 0 intRowNumber
		, '' strGroup
		, '' Selection
		, '' PriceStatus
		, '' strFutureMonth
		, '' strAccountNumber
		, 0.0 dblNoOfContract
		, 0.0 Rank
		, '' strCommodityCode
		, '' strFutureMarket
		, '' strFutureMonth1
		, '' strUnitMeasure
		, '' strLocation
		, '' strBook
		, '' strSubBook
		, '' dtmPositionAsOf
		, '' strUomType
		, 0 intOrderByHeading
END

SELECT TOP 1 @strCommodityCodeH = strCommodityCode FROM tblICCommodity WHERE intCommodityId=@intCommodityId
SELECT TOP 1 @strFutureMarketH = strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId
SELECT TOP 1 @strFutureMonthH = strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId
SELECT TOP 1 @strUnitMeasureH = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId
SELECT TOP 1 @strBookH = strBook FROM tblCTBook WHERE intBookId=@intBookId
SELECT TOP 1 @strSubBookH = strSubBook FROM tblCTSubBook WHERE intSubBookId=@intSubBookId

IF @intCompanyLocationId = 0
	SET @strLocationH = 'All'
ELSE
	SELECT TOP 1 @strLocationH = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId=@intCompanyLocationId

DECLARE @temp as Table (intRowNumber int
	, strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, PriceStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strAccountNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, dblNoOfContract DECIMAL(24,10)
	, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, TransactionDate datetime
	, TranType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, CustVendor NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, dblNoOfLot DECIMAL(24,10)
	, dblQuantity DECIMAL(24,10)
	, intOrderByHeading int
	, intOrderBySubHeading int
	, intContractHeaderId int
	, intFutOptTransactionHeaderId int
	, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS)

DECLARE @strRiskView NVARCHAR(100)
SELECT TOP 1 @strRiskView = strRiskView FROM tblRKCompanyPreference

IF (@strRiskView = 'Trader/Elevator')
BEGIN
	INSERT INTO @temp (intRowNumber
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
		, strItemDescription)
	Exec uspRKRiskPositionInquiry @intCommodityId = @intCommodityId
		, @intCompanyLocationId = @intCompanyLocationId
		, @intFutureMarketId = @intFutureMarketId
		, @intFutureMonthId = @intFutureMonthId
		, @intUOMId = @intUOMId
		, @intDecimal = @intDecimal
		, @intForecastWeeklyConsumption = @intForecastWeeklyConsumption
		, @intForecastWeeklyConsumptionUOMId = @intForecastWeeklyConsumptionUOMId
		, @intBookId = @intBookId
		, @intSubBookId = @intSubBookId
		, @strPositionBy = @strPositionBy
	
	UPDATE @temp
	SET strGroup = case when Selection IN ('Physical position / Differential cover', 'Physical position / Basis risk') then Selection
						when Selection = 'Specialities & Low grades' then Selection
						when Selection = 'Total speciality delta fixed' then Selection
						when Selection = 'Terminal position (a. in lots )' then Selection
						when Selection = 'Terminal position (Avg Long Price)' then Selection
						when Selection LIKE ('%Terminal position (b.%') then Selection
						when Selection = 'Delta options' then Selection
						when Selection = 'F&O' then '8.'+ Selection
						when Selection LIKE ('%Total F&O(b. in%') then Selection
						when Selection IN ('Outright coverage', 'Net market risk') then Selection
						when Selection IN ('Switch position', 'Futures required') then Selection end
	
	INSERT INTO @temp(strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, dblNoOfContract
		, intOrderByHeading)
	SELECT strGroup
		, Selection
		, PriceStatus
		, strFutureMonth = 'Total'
		, strAccountNumber
		, SUM(CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))) dblNoOfContract
		, intOrderByHeading
	FROM @temp
	GROUP BY strGroup
		, Selection
		, PriceStatus
		, strAccountNumber
		, intOrderByHeading
	ORDER BY strGroup
		, PriceStatus
	
	SELECT strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, SUM(CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))) dblNoOfContract
		, CONVERT(NUMERIC(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER (PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
																									WHEN strFutureMonth ='Total' THEN '01/01/9999'
																									WHEN ISNULL(strFutureMonth, '') = '' THEN '01/01/1901'
																									ELSE CONVERT(DATETIME,'01 '+strFutureMonth)END ))+ '.1234567890') AS [Rank]
		, @strCommodityCodeH strCommodityCode
		, @strFutureMarketH strFutureMarket
		, @strFutureMonthH strFutureMonth1
		, @strUnitMeasureH strUnitMeasure
		, @strLocationH strLocation
		, @strBookH strBook
		, @strSubBookH strSubBook
		, @dtmPositionAsOf dtmPositionAsOf
		, intOrderByHeading
	FROM @temp
	WHERE ISNULL(dblNoOfContract,0) <> 0
	GROUP BY strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, intOrderByHeading
	ORDER BY intOrderByHeading
END
ELSE
BEGIN
	DECLARE @dtmToDate DATETIME
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)
	
	IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
	BEGIN
		SET @intForecastWeeklyConsumptionUOMId = @intUOMId
	END
	
	IF (@intUOMId = 0)
	BEGIN
		SELECT @intUOMId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId and ysnDefault = 1
	END
	
	DECLARE @strUnitMeasure NVARCHAR(200)
		, @dtmFutureMonthsDate datetime
		, @dblContractSize int
		, @ysnIncludeInventoryHedge BIT
	
	DECLARE @strFutureMonth NVARCHAR(15)
		, @dblForecastWeeklyConsumption numeric(24,10)
		, @strParamFutureMonth NVARCHAR(12)
	
	SELECT @dblContractSize = convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId = @intFutureMarketId
	SELECT TOP 1 @dtmFutureMonthsDate = CONVERT(DATETIME, '01 ' + strFutureMonth)
		, @strParamFutureMonth = strFutureMonth
	FROM tblRKFuturesMonth WHERE intFutureMonthId = @intFutureMonthId
	
	SELECT TOP 1 @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUOMId
	
	DECLARE @intoldUnitMeasureId int
	SET @intoldUnitMeasureId = @intUOMId
	SELECT @intUOMId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId and intUnitMeasureId = @intUOMId
	SELECT TOP 1 @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge
		, @strRiskView = strRiskView 
	FROM tblRKCompanyPreference
	
	DECLARE @intForecastWeeklyConsumptionUOMId1 INT
	SELECT @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId and intUnitMeasureId = @intForecastWeeklyConsumptionUOMId
	
	SELECT @dblForecastWeeklyConsumption = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1,@intUOMId,@intForecastWeeklyConsumption),1)
	
	DECLARE @ListImported as Table (intRowNumber int
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24,10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate datetime
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, intOrderByHeading int
		, intContractHeaderId int
		, intFutOptTransactionHeaderId int)
	
	---Roll Cost
	DECLARE @RollCost as Table (strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, intFutureMarketId int
		, intCommodityId int
		, intFutureMonthId int
		, dblNoOfLot numeric(24,10)
		, dblQuantity numeric(24,10)
		, dblWtAvgOpenLongPosition numeric(24,10)
		, strTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId int)
	
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
		, intFutOptTransactionHeaderId)
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
	FROM vyuRKRollCost
	WHERE intCommodityId = @intCommodityId and intFutureMarketId = @intFutureMarketId
		and ISNULL(intBookId, 0) = ISNULL(@intBookId, ISNULL(intBookId, 0))
		and ISNULL(intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(intSubBookId, 0))
		and ISNULL(intLocationId, 0) = ISNULL(@intCompanyLocationId, ISNULL(intLocationId, 0))
		and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate
	
	--To Purchase Value
	DECLARE @DemandFinal1 as Table (dblQuantity numeric(24,10)
		, intUOMId int
		, strPeriod NVARCHAR(200)
		, strItemName NVARCHAR(200)
		, dtmPeriod datetime
		, intItemId int
		, strDescription NVARCHAR(200))
	
	DECLARE @DemandQty as Table (intRowNumber int identity(1,1)
		, dblQuantity numeric(24,10)
		, intUOMId int
		, dtmPeriod datetime
		, strPeriod NVARCHAR(200)
		, strItemName NVARCHAR(200)
		, intItemId int
		, strDescription NVARCHAR(200))
	
	DECLARE @DemandFinal as Table (intRowNumber int identity(1,1)
		, dblQuantity numeric(24,10)
		, intUOMId int
		, dtmPeriod datetime
		, strPeriod NVARCHAR(200)
		, strItemName NVARCHAR(200)
		, intItemId int
		, strDescription NVARCHAR(200))
	
	IF EXISTS(SELECT TOP 1 * FROM tblRKStgBlendDemand WHERE dtmImportDate < @dtmToDate)
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
		JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and  intProductTypeId=intCommodityAttributeId
		AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
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
		JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and  intProductTypeId=intCommodityAttributeId
		AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
		WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId = @intFutureMarketId and d.dtmImportDate = (SELECT TOP 1 dtmImportDate FROM tblRKArchBlendDemand
																													WHERE dtmImportDate <= @dtmToDate ORDER BY dtmImportDate DESC)
	END
	
	DECLARE @intRowNumber INT
		, @dblQuantity numeric(24,10)
		, @intUOMId1 int
		, @dtmPeriod1 datetime
		, @strFutureMonth1 NVARCHAR(20)
		, @strItemName NVARCHAR(200)
		, @intItemId int
		, @strDescription NVARCHAR(200)
	
	SELECT @intRowNumber = min(intRowNumber) FROM @DemandQty
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
		FROM @DemandQty
		WHERE intRowNumber = @intRowNumber
		
		SELECT @strFutureMonth1 = strFutureMonth
		FROM tblRKFuturesMonth fm
		JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId
		WHERE @dtmPeriod1=CONVERT(DATETIME,'01 '+strFutureMonth)
			AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId
		
		IF @strFutureMonth1 IS NULL
		BEGIN
			SELECT top 1 @strFutureMonth1=strFutureMonth FROM tblRKFuturesMonth fm
			JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId
			WHERE CONVERT(DATETIME,'01 '+strFutureMonth) > @dtmPeriod1
				AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId
			ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth)
		END
		
		INSERT INTO @DemandFinal1(dblQuantity,intUOMId,strPeriod,strItemName,intItemId,strDescription)
		SELECT @dblQuantity,@intUOMId1,@strFutureMonth1,@strItemName,@intItemId,@strDescription
		
		SELECT @intRowNumber= min(intRowNumber) FROM @DemandQty WHERE intRowNumber > @intRowNumber
	END
	
	INSERT INTO @DemandFinal
	SELECT sum(dblQuantity) as dblQuantity
		, intUOMId
		, CONVERT(DATETIME, '01 ' + strPeriod) dtmPeriod
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
	-- END
	
	DECLARE @ListFinal as Table (intRowNumber int
		, strGroup NVARCHAR(250)
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24,10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate datetime
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, intOrderByHeading int
		, intContractHeaderId int
		, intFutOptTransactionHeaderId int)
	
	DECLARE @ContractTransaction as Table (strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24,10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate datetime
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, intContractHeaderId int
		, intFutOptTransactionHeaderId int
		, intPricingTypeId int
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intCompanyLocationId int
		, intFutureMarketId int
		, dtmFutureMonthsDate datetime
		, ysnExpired bit)
	
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
		, dblRatioQty DECIMAL(24, 10))
		
	INSERT INTO @PricedContractList
	SELECT fm.strFutureMonth
		, strContractType + ' - ' + case when @strPositionBy= 'Product Type' then ISNULL(ca.strDescription, '') else ISNULL(cv.strEntityName, '') end AS strAccountNumber
		, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN ISNULL(dblBalance, 0) ELSE dblDetailQuantity END) AS dblNoOfContract
		, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + convert(NVARCHAR, intContractSeq) AS strTradeNo
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
	FROM vyuRKRiskPositionContractDetail cv
	JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
	JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId and um2.intCommodityId = cv.intCommodityId
	JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
	JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
	JOIN tblICItem ic ON ic.intItemId = cv.intItemId
	LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
	LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
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
		, ysnExpired)
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
	FROM (
		SELECT strFutureMonth
			, strAccountNumber
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty ) else dblNoOfContract end dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot) else dblQuantity end dblQuantity
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
		FROM @PricedContractList cv
		WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 0
		
		--Parcial Priced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty/dblNoOfLot)* dblFixedLots) else dblFixedQty end AS dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblFixedLots dblNoOfLot
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty/dblNoOfLot)*dblFixedLots) else dblFixedQty end dblFixedQty
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, 1 intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
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
				, intPricingTypeId
				, strContractType
				, intCommodityId
				, intCompanyLocationId
				, intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, dblRatioQty
				, ISNULL((SELECT sum(dblLotsFixed) dblNoOfLots
							FROM tblCTPriceFixation pf
							WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(dblQuantity)) dblQuantity
							FROM tblCTPriceFixation pf
							JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
							WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, intCommodityUnitMeasureId
				, dblRatioContractSize
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) =0
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
		
		--Parcial UnPriced
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (((dblRatioQty/dblNoOfLot)*ISNULL(dblNoOfLot, 0)) - ((dblRatioQty/dblNoOfLot)*ISNULL(dblFixedLots, 0))) ) else dblQuantity - dblFixedQty end AS dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) dblNoOfLot
			, case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,((dblRatioQty/dblNoOfLot)*ISNULL(dblNoOfLot, 0) - (dblRatioQty/dblNoOfLot)*ISNULL(dblFixedLots, 0))) else dblQuantity - dblFixedQty end dblQuantity
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, 2 intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
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
				, ISNULL((SELECT sum(dblLotsFixed) dblNoOfLots
							FROM tblCTPriceFixation pf
							WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(pd.dblQuantity)) dblQuantity
							FROM tblCTPriceFixation pf
							JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
							WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, ISNULL(dblDeltaPercent,0) dblDeltaPercent
				, intCommodityUnitMeasureId
				, dblRatioContractSize
			FROM @PricedContractList cv
			WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND ISNULL(ysnDeltaHedge, 0) =0
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1
	WHERE dblNoOfContract <> 0
	
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
	SELECT 1 intRowNumber,'1.Outright Coverage','Outright Coverage' Selection
		, '1.Priced / Outright - (Outright position)' PriceStatus
		, case when CONVERT(DATETIME,'01 '+strFutureMonth) < @dtmFutureMonthsDate then 'Previous' else strFutureMonth end strFutureMonth
		, strAccountNumber
		, case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity
		, 1 intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @ContractTransaction
	WHERE intPricingTypeId =1 AND intCommodityId=@intCommodityId
		AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
		AND intFutureMarketId = @intFutureMarketId AND ISNULL(dblNoOfContract,0) <> 0
	
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
		, intOrderByHeading)
	SELECT 1 intRowNumber
		, '1.Outright Coverage'
		, 'Outright Coverage' Selection
		, '1.Priced / Outright - (Outright position)' PriceStatus
		, @strParamFutureMonth strFutureMonth
		, strAccountNumber
		, sum(dblNoOfLot) dblNoOfLot
		, null
		, getdate() TransactionDate
		, 'Inventory' TranType
		, null
		, 0.0
		, sum(dblNoOfLot) dblQuantity
		, 1
	FROM (
		SELECT DISTINCT 'Purchase' + ' - ' + ISNULL(c.strDescription,'') as strAccountNumber
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,t.dblQuantity) dblNoOfLot
		FROM vyuRKGetInventoryValuation t
		JOIN tblICItem ic on t.intItemId=ic.intItemId
		JOIN tblICCommodityAttribute c on c.intCommodityAttributeId=ic.intProductTypeId
		JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and m.intFutureMarketId =@intFutureMarketId and ic.intProductTypeId=intCommodityAttributeId
			AND intCommodityAttributeId in (SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
		JOIN tblICItemLocation il on il.intItemId=ic.intItemId
		JOIN tblICItemUOM i on il.intItemId=i.intItemId and i.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure um on um.intCommodityId=@intCommodityId and um.intUnitMeasureId=i.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=il.intLocationId  
		WHERE ic.intCommodityId=@intCommodityId and m.intFutureMarketId=@intFutureMarketId
			AND cl.intCompanyLocationId = ISNULL(@intCompanyLocationId, cl.intCompanyLocationId)
			AND convert(DATETIME, CONVERT(VARCHAR(10), t.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
	)t2
	GROUP BY strAccountNumber
	
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
		FROM (
			SELECT DISTINCT 2 intRowNumber
				, '1.Outright Coverage' grpname
				, 'Outright Coverage' Selection
				, '2.Terminal Position' PriceStatus
				, strFutureMonth
				, e.strName + '-' + strAccountNumber as strAccountNumber
				, strBuySell
				, ISNULL(CASE WHEN ft.strBuySell = 'Buy' THEN ISNULL(ft.intNoOfContract, 0)
							ELSE NULL END, 0) Long1
				, ISNULL(CASE WHEN ft.strBuySell = 'Sell' THEN ISNULL(ft.intNoOfContract, 0)
							ELSE NULL END, 0) Sell1
				, ISNULL((SELECT SUM(dblMatchQty)
							FROM tblRKMatchFuturesPSDetail psd
							JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
							WHERE psd.intLFutOptTransactionId = ft.intFutOptTransactionId AND h.strType = 'Realize'
								AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchLong
				, ISNULL((SELECT sum(dblMatchQty)
							FROM tblRKMatchFuturesPSDetail psd
							JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
							WHERE psd.intSFutOptTransactionId = ft.intFutOptTransactionId AND h.strType = 'Realize'
								AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0) AS MatchShort
				, ft.strInternalTradeNo as strTradeNo
				, ft.dtmFilledDate as TransactionDate
				, strBuySell as TranType
				, e.strName as CustVendor
				, um.intCommodityUnitMeasureId
				, null as intContractHeaderId
				, ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId and ft.strStatus='Filled'
			JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId and ft.intInstrumentTypeId = 1 and ft.intCommodityId=@intCommodityId and ft.intFutureMarketId=@intFutureMarketId
			JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
			JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
			JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
			WHERE ft.intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId
				AND intLocationId = ISNULL(@intCompanyLocationId, intLocationId)
				AND ISNULL(intBookId,0) = ISNULL(@intBookId, ISNULL(intBookId,0))
				AND ISNULL(intSubBookId,0) = ISNULL(@intSubBookId, ISNULL(intSubBookId,0))
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) <= @dtmToDate
				AND CONVERT(DATETIME,'01 '+strFutureMonth) >= @dtmFutureMonthsDate
		)t
	)t1 WHERE dblNoOfContract<>0
	
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
	SELECT 4 intRowNumber
		, '1.Outright Coverage'
		, 'Market coverage' Selection
		, '3.Market coverage' PriceStatus
		, strFutureMonth
		, 'Market Coverage' strAccountNumber
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
	FROM @ListFinal
	WHERE intRowNumber in (1,2) and strFutureMonth <> 'Previous'
	
	UNION ALL SELECT 4 intRowNumber
		, '1.Outright Coverage'
		, 'Market coverage' Selection
		, '3.Market coverage' PriceStatus
		, @strParamFutureMonth
		, 'Market Coverage' strAccountNumber
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
	FROM @ListFinal
	WHERE intRowNumber in (1,2) and strFutureMonth = 'Previous'
	
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
			, intFutOptTransactionHeaderId)
		SELECT 5 intRowNumber
			, '1.Outright Coverage'
			, 'Market Coverage' Selection
			, '4.Market Coverage(Weeks)' PriceStatus
			, strFutureMonth
			, 'Market Coverage(Weeks)' strAccountNumber
			, case when ISNULL(@dblForecastWeeklyConsumption,0)=0 then 0
					else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))/@dblForecastWeeklyConsumption end as dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblNoOfLot
			, dblQuantity
			, 5
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @ListFinal
		WHERE intRowNumber in (4)
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
		, intFutOptTransactionHeaderId)
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
	FROM (
		SELECT DISTINCT 6 intRowNumber
			, '2.Futures Required' strGroup
			, 'Futures Required' Selection
			, '1.Unpriced - (Balance to be Priced)' PriceStatus
			, case when CONVERT(DATETIME,'01 '+strFutureMonth) < @dtmFutureMonthsDate then 'Previous' else strFutureMonth end strFutureMonth
			, strAccountNumber
			, (case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end) as dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, (case when strContractType='Purchase' then dblNoOfLot else -(abs(dblNoOfLot)) end) dblNoOfLot
			, case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity
			, intContractHeaderId
			, NULL as intFutOptTransactionHeaderId
		FROM @ContractTransaction
		WHERE ysnExpired=0 and intPricingTypeId <> 1 AND intCommodityId=@intCommodityId
			AND intCompanyLocationId = ISNULL(@intCompanyLocationId, intCompanyLocationId)
			AND intFutureMarketId = @intFutureMarketId
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
	SELECT DISTINCT 7 intRowNumber
		, '2.Futures Required'
		, 'Futures Required' as Selection
		, '2.To Purchase' as PriceStatus
		, case when CONVERT(DATETIME,'01 '+strPeriod)< @dtmFutureMonthsDate then 'Previous' else strPeriod end as strFutureMonth
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
		, intFutOptTransactionHeaderId)
	SELECT 8 intRowNumber
		, '2.Futures Required'
		, 'Futures Required' Selection
		, '3.Terminal position' PriceStatus
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
		, intOrderByHeading)
	SELECT 9 intRowNumber
		, '2.Futures Required'
		, 'Futures Required' Selection
		, '4.Net Position' PriceStatus
		, strFutureMonth
		, 'Net Position'
		, sum(dblNoOfContract)
		, sum(dblNoOfLot)
		, sum(dblQuantity)
		, 9 intOrderByHeading
	FROM (
		SELECT @strParamFutureMonth strFutureMonth
			, strAccountNumber
			, - abs(dblQuantity) as dblNoOfContract
			, dblNoOfLot
			, dblQuantity
		FROM @ListFinal
		WHERE intRowNumber in(7) and strFutureMonth = 'Previous'
		
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, - abs(dblQuantity) as dblNoOfContract
			, case when dblNoOfLot<0 then abs(dblNoOfLot) else -abs(dblNoOfLot) end dblNoOfLot
			, dblQuantity
		FROM @ListFinal WHERE intRowNumber in(7) and strFutureMonth <> 'Previous'
		
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, - abs(dblQuantity) as dblNoOfContract
			, - abs(dblNoOfLot) dblNoOfLot
			, dblQuantity
		FROM @ListFinal WHERE intRowNumber in(6) and strFutureMonth <> 'Previous'
		
		UNION ALL SELECT @strParamFutureMonth
			, strAccountNumber
			, case when dblQuantity<0 then abs(dblQuantity) else -abs(dblQuantity) end as dblNoOfContract
			, case when dblNoOfLot<0 then abs(dblNoOfLot) else -abs(dblNoOfLot) end dblNoOfLot
			, dblQuantity
		FROM @ListFinal WHERE intRowNumber in(6) and strFutureMonth = 'Previous'
		
		UNION ALL SELECT strFutureMonth
			, strAccountNumber
			, dblQuantity as dblNoOfContract
			, dblNoOfLot
			, dblQuantity
		FROM @ListFinal WHERE intRowNumber in(2)
	)t group by strFutureMonth
	
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
	SELECT 10 intRowNumber
		, '2.Futures Required'
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
	FROM (
		SELECT DISTINCT 'Futures Required' as Selection
			, '5.Avg Long Price' as PriceStatus
			, ft.strFutureMonth
			, 'Avg Long Price' as strAccountNumber
			, dblWtAvgOpenLongPosition as dblNoOfContract
			, dblNoOfLot
			, dblQuantity * dblNoOfLot dblQuantity
			, strTradeNo
			, intFutOptTransactionHeaderId
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
		, intFutOptTransactionHeaderId)
	SELECT 11
		, strGroup
		, Selection
		, PriceStatus
		, 'Total'
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
	FROM @ListFinal WHERE strAccountNumber<> 'Avg Long Price'
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
		, intFutOptTransactionHeaderId)
	SELECT 11 intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, 'Total' strFutureMonth
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
	FROM @ListFinal WHERE strAccountNumber = 'Avg Long Price'
	GROUP BY strGroup
		, Selection
		, PriceStatus
		, strAccountNumber
		
	DECLARE @MonthOrder as Table (intRowNumber1 int identity(1,1)
		, intRowNumber int
		, strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24,10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate datetime
		, TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfLot DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, intOrderByHeading int
		, intContractHeaderId int
		, intFutOptTransactionHeaderId int)
	
	DECLARE @strAccountNumber NVARCHAR(max)
	SELECT TOP 1 @strAccountNumber=strAccountNumber
	FROM @ListFinal
	WHERE strGroup = '1.Outright Coverage'
		and PriceStatus = '1.Priced / Outright - (Outright position)'
	ORDER BY intRowNumber
	
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
		, intFutOptTransactionHeaderId)
	SELECT DISTINCT 0
		, '1.Outright Coverage'
		, 'Outright Coverage'
		, '1.Priced / Outright - (Outright position)'
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
	FROM @ListFinal
	WHERE strFutureMonth NOT IN (SELECT DISTINCT strFutureMonth FROM @ListFinal
								WHERE strGroup = '1.Outright Coverage' and PriceStatus in('1.Priced / Outright - (Outright position)'))
	
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
		, intFutOptTransactionHeaderId)
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
	FROM @ListFinal WHERE strFutureMonth='Previous' and dblNoOfContract<>0
	
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
		, intFutOptTransactionHeaderId)
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
	FROM @ListFinal WHERE strFutureMonth NOT IN('Previous','Total')and dblNoOfContract<>0
	ORDER BY intRowNumber
		, PriceStatus
		, CONVERT(DATETIME,'01 '+strFutureMonth) ASC
		
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
		, intFutOptTransactionHeaderId)
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
	FROM @ListFinal WHERE strFutureMonth='Total' and dblNoOfContract<>0
	
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
	
	SELECT intRowNumber1 intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	INTO #temp
	FROM @MonthOrder
	ORDER BY strGroup
		, PriceStatus
		, CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900' 
				WHEN strFutureMonth ='Total' THEN '01/01/9999'
				ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END
	
	SELECT TOP 1 @strAccountNumber = strAccountNumber
	FROM #temp
	WHERE strGroup = '1.Outright Coverage' and PriceStatus = '1.Priced / Outright - (Outright position)'
	ORDER BY intRowNumber
	
	INSERT INTO #temp
	SELECT DISTINCT '1.Outright Coverage'
		, 'Outright Coverage'
		, '1.Priced / Outright - (Outright position)'
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
	FROM #temp
	WHERE strFutureMonth NOT IN (SELECT DISTINCT strFutureMonth FROM #temp WHERE strGroup = '1.Outright Coverage' AND PriceStatus = '1.Priced / Outright - (Outright position)')
	
	SELECT ROW_NUMBER() OVER(ORDER BY intRowNumber) intRowNumFinal
		, intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, strAccountNumber
		, case when CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))=0 then null else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end dblNoOfContract
		, strTradeNo
		, TransactionDate
		, TranType
		, CustVendor
		, dblNoOfLot
		, dblQuantity
		, intOrderByHeading
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	INTO #temp1
	FROM #temp
	ORDER BY strGroup
		, PriceStatus
		, CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
				WHEN strFutureMonth ='Total' THEN '01/01/9999'
				ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END
	
	IF @strReportName = 'Outright Coverage'
	BEGIN
		SELECT intRowNumber
			, REPLACE(strGroup,'1.','') strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, CASE WHEN @strUomType = 'By Lot' and strAccountNumber <> 'Avg Long Price' then (CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)))
					ELSE CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end dblNoOfContract
			, CONVERT(NUMERIC(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER (PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
																										WHEN strFutureMonth ='Total' THEN '01/01/9999'
																										ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '.1234567890') AS [Rank]
			, @strCommodityCodeH strCommodityCode
			, @strFutureMarketH strFutureMarket
			, @strFutureMonthH strFutureMonth1
			, @strUnitMeasureH strUnitMeasure
			, @strLocationH strLocation
			, @strBookH strBook
			, @strSubBookH strSubBook
			, @dtmPositionAsOf dtmPositionAsOf
			, intOrderByHeading = 1
		FROM #temp1 WHERE strGroup='1.Outright Coverage' and dblNoOfContract <>0
	END
	ELSE IF @strReportName = 'Futures Required'
	BEGIN
		SELECT intRowNumber
			, REPLACE(strGroup,'2.','') strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, case when @strUomType='By Lot' and strAccountNumber <> 'Avg Long Price' then (CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)))
					else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end dblNoOfContract
			, CONVERT(NUMERIC(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER (PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
																										WHEN strFutureMonth ='Total' THEN '01/01/9999'
																										ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '.1234567890') AS [Rank]
			, @strCommodityCodeH strCommodityCode
			, @strFutureMarketH strFutureMarket
			, @strFutureMonthH strFutureMonth1
			, @strUnitMeasureH strUnitMeasure
			, @strLocationH strLocation
			, @strBookH strBook
			, @strSubBookH strSubBook
			, @dtmPositionAsOf dtmPositionAsOf
			, intOrderByHeading = 2
		FROM #temp1
		WHERE strGroup = '2.Futures Required' and dblNoOfContract <>0
	END
	ELSE
	BEGIN
		SELECT intRowNumber
			, strGroup
			, Selection
			, PriceStatus
			, strFutureMonth
			, strAccountNumber
			, case when @strUomType='By Lot' and strAccountNumber <> 'Avg Long Price' then (CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)))
					else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end dblNoOfContract
			, CONVERT(NUMERIC(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER (PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth ='Previous' THEN '01/01/1900'
																										WHEN strFutureMonth ='Total' THEN '01/01/9999'
																										ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '.1234567890') AS [Rank]
			, @strCommodityCodeH strCommodityCode
			, @strFutureMarketH strFutureMarket
			, @strFutureMonthH strFutureMonth1
			, @strUnitMeasureH strUnitMeasure
			, @strLocationH strLocation
			, @strBookH strBook
			, @strSubBookH strSubBook
			, @dtmPositionAsOf dtmPositionAsOf
			, intOrderByHeading = CASE WHEN strGroup = '1.Outright Coverage' THEN 1
										ELSE 2 END
		FROM #temp1
		WHERE dblNoOfContract <>0
	END
END