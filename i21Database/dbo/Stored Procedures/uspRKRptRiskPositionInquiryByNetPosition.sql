CREATE PROC [dbo].[uspRKRptRiskPositionInquiryByNetPosition] @xmlParam NVARCHAR(MAX)
AS

DECLARE @idoc INT,
	@intCommodityId INTEGER,
	@intCompanyLocationId INTEGER,
	@intFutureMarketId INTEGER,
	@intFutureMonthId INTEGER,
	@intUOMId INTEGER,
	@intDecimal INTEGER,
	@intForecastWeeklyConsumption INTEGER = NULL,
	@intForecastWeeklyConsumptionUOMId INTEGER = NULL,
	@intBookId INTEGER = NULL,
	@intSubBookId INTEGER = NULL,
	@strPositionBy NVARCHAR(100) = NULL,
	@dtmPositionAsOf DATETIME = NULL,
	@strReportName NVARCHAR(100) = NULL,
	@strUomType NVARCHAR(100) = NULL

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
	fieldname NVARCHAR(50),
	condition NVARCHAR(20),
	[from] NVARCHAR(50),
	[to] NVARCHAR(50),
	[join] NVARCHAR(10),
	[begingroup] NVARCHAR(50),
	[endgroup] NVARCHAR(50),
	[datatype] NVARCHAR(50)
	)

EXEC sp_xml_preparedocument @idoc OUTPUT,
	@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH ( 
		fieldname NVARCHAR(50),
		condition NVARCHAR(20),
		[from] NVARCHAR(50),
		[to] NVARCHAR(50),
		[join] NVARCHAR(10),
		[begingroup] NVARCHAR(50),
		[endgroup] NVARCHAR(50),
		[datatype] NVARCHAR(50)
		)

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SELECT @intCompanyLocationId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCompanyLocationId'

SELECT @intFutureMarketId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intFutureMarketId'

SELECT @intFutureMonthId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intFutureMonthId'

SELECT @intUOMId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intUOMId'

SELECT @intDecimal = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intDecimal'

SELECT @intForecastWeeklyConsumption = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intForecastWeeklyConsumption'

SELECT @intForecastWeeklyConsumptionUOMId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intForecastWeeklyConsumptionUOMId'

SELECT @intBookId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intBookId'

SELECT @intSubBookId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intSubBookId'

SELECT @strPositionBy = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strPositionBy'

SELECT @dtmPositionAsOf = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmPositionAsOf'

SELECT @strReportName = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strReportName'

SELECT @strUomType = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strUomType'

DECLARE @strCommodityCodeH NVARCHAR(100)
DECLARE @strFutureMarketH NVARCHAR(100)
DECLARE @strFutureMonthH NVARCHAR(100)
DECLARE @strUnitMeasureH NVARCHAR(100)
DECLARE @strLocationH NVARCHAR(100)
DECLARE @strBookH NVARCHAR(100)
DECLARE @strSubBookH NVARCHAR(100)

IF (ISNULL(@xmlParam, '') = '')
BEGIN
	SELECT 0 intRowNumber,
		'' strGroup,
		'' Selection,
		'' PriceStatus,
		'' strFutureMonth,
		'' strAccountNumber,
		0.0 dblNoOfContract,
		0.0 Rank,
		'' strCommodityCode,
		'' strFutureMarket,
		'' strFutureMonth1,
		'' strUnitMeasure,
		'' strLocation,
		'' strBookH,
		'' strSubBookH,
		'' dtmPositionAsOf,
		'' strUomType,
		0 intOrderByHeading,
		'' strBook,
		'' strSubBook,
		0 ysnSubTotalByBook
END

SELECT TOP 1 @strCommodityCodeH = strCommodityCode
FROM tblICCommodity
WHERE intCommodityId = @intCommodityId

SELECT TOP 1 @strFutureMarketH = strFutMarketName
FROM tblRKFutureMarket
WHERE intFutureMarketId = @intFutureMarketId

SELECT TOP 1 @strFutureMonthH = strFutureMonth
FROM tblRKFuturesMonth
WHERE intFutureMonthId = @intFutureMonthId

SELECT TOP 1 @strUnitMeasureH = strUnitMeasure
FROM tblICUnitMeasure
WHERE intUnitMeasureId = @intUOMId

SELECT TOP 1 @strBookH = strBook
FROM tblCTBook
WHERE intBookId = @intBookId

SELECT TOP 1 @strSubBookH = strSubBook
FROM tblCTSubBook
WHERE intSubBookId = @intSubBookId

IF @intCompanyLocationId = 0
	SET @strLocationH = 'All'
ELSE
	SELECT TOP 1 @strLocationH = strLocationName
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intCompanyLocationId

DECLARE @temp AS TABLE (
	intRowNumber INT,
	strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	PriceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	intFutureMonthOrder INT,
	strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	dblNoOfContract DECIMAL(24, 10),
	strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	TransactionDate DATETIME,
	TranType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	CustVendor NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblNoOfLot DECIMAL(24, 10),
	dblQuantity DECIMAL(24, 10),
	intOrderByHeading INT,
	intOrderBySubHeading INT,
	intContractHeaderId INT,
	intFutOptTransactionHeaderId INT,
	strProductType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strProductLine NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strShipmentPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strOrigin NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	intItemId INT,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strCertificationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblHedgedLots DECIMAL(24, 10)
	, dblToBeHedgedLots DECIMAL(24, 10)
	)

DECLARE @intRiskViewId INT
	, @ysnSubTotalByBook BIT
SELECT TOP 1 @intRiskViewId = intRiskViewId
	, @ysnSubTotalByBook = ysnSubTotalByBook
FROM tblRKCompanyPreference


IF (@intRiskViewId = 1)
BEGIN
	INSERT INTO @temp (
		intRowNumber,
		Selection,
		PriceStatus,
		strFutureMonth,
		intFutureMonthOrder,
		strAccountNumber,
		dblNoOfContract,
		strTradeNo,
		TransactionDate,
		TranType,
		CustVendor,
		dblNoOfLot,
		dblQuantity,
		intOrderByHeading,
		intOrderBySubHeading,
		intContractHeaderId,
		intFutOptTransactionHeaderId,
		strProductType,
		strProductLine,
		strShipmentPeriod,
		strLocation,
		strOrigin,
		intItemId,
		strItemNo,
		strItemDescription
		, strGrade
		, strRegion
		, strSeason
		, strClass
		, strCertificationName 
		, strCropYear 
		, dblHedgedLots
		, dblToBeHedgedLots
		)
	EXEC uspRKRiskPositionInquiry @intCommodityId = @intCommodityId,
		@intCompanyLocationId = @intCompanyLocationId,
		@intFutureMarketId = @intFutureMarketId,
		@intFutureMonthId = @intFutureMonthId,
		@intUOMId = @intUOMId,
		@intDecimal = @intDecimal,
		@intForecastWeeklyConsumption = @intForecastWeeklyConsumption,
		@intForecastWeeklyConsumptionUOMId = @intForecastWeeklyConsumptionUOMId,
		@intBookId = @intBookId,
		@intSubBookId = @intSubBookId,
		@strPositionBy = @strPositionBy

	UPDATE @temp
	SET strGroup = CASE WHEN Selection IN ('Physical position / Differential cover', 'Physical position / Basis risk') THEN Selection WHEN Selection = 'Specialities & Low grades' THEN Selection WHEN Selection = 'Total speciality delta fixed' THEN Selection WHEN Selection = 'Terminal position (a. in lots )' THEN Selection WHEN Selection = 'Terminal position (Avg Long Price)' THEN Selection WHEN Selection LIKE ('%Terminal position (b.%') THEN Selection WHEN Selection = 'Delta options' THEN Selection WHEN Selection = 'F&O' THEN '8.' + Selection WHEN Selection LIKE ('%Total F&O(b. in%') THEN Selection WHEN Selection IN ('Outright coverage', 'Net market risk') THEN Selection WHEN Selection IN ('Switch position', 'Futures required') THEN Selection END

	INSERT INTO @temp (
		strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		strAccountNumber,
		dblNoOfContract,
		intOrderByHeading
		)
	SELECT strGroup,
		Selection,
		PriceStatus,
		strFutureMonth = 'Total',
		strAccountNumber,
		SUM(CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal))) dblNoOfContract,
		intOrderByHeading
	FROM @temp
	GROUP BY strGroup,
		Selection,
		PriceStatus,
		strAccountNumber,
		intOrderByHeading
	ORDER BY strGroup,
		PriceStatus

	SELECT strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		strAccountNumber,
		SUM(CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal))) dblNoOfContract,
		CONVERT(NUMERIC(24, 10), CONVERT(NVARCHAR, DENSE_RANK() OVER (
					PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' WHEN ISNULL(strFutureMonth, '') = '' THEN '01/01/1901' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END
					)) + '.1234567890') AS [Rank],
		@strCommodityCodeH strCommodityCode,
		@strFutureMarketH strFutureMarket,
		@strFutureMonthH strFutureMonth1,
		@strUnitMeasureH strUnitMeasure,
		@strLocationH strLocation,
		@strBookH strBookH,
		@strSubBookH strSubBookH,
		@dtmPositionAsOf dtmPositionAsOf,
		intOrderByHeading
	FROM @temp
	WHERE ISNULL(dblNoOfContract, 0) <> 0
	GROUP BY strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		strAccountNumber,
		intOrderByHeading
	ORDER BY intOrderByHeading
END
ELSE
BEGIN
	DECLARE @MonthOrder AS TABLE (
		intRowNumFinal INT,
		intRowNumber1 INT,
		intRowNumber INT,
		strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS,
		intFutureMonthOrder INT,
		strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		dblNoOfContract DECIMAL(24, 10),
		strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		TransactionDate DATETIME,
		TranType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		CustVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		dblNoOfLot DECIMAL(24, 10),
		dblQuantity DECIMAL(24, 10),
		intOrderByHeading INT,
		intContractHeaderId INT,
		intFutOptTransactionHeaderId INT,
		strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strShipmentPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		intItemId INT,
		strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strItemDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS,
		intBookId INT,
		strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		intSubBookId INT,
		strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strCertificationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
		strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @MonthOrder (
		intRowNumFinal,
		intRowNumber,
		strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		intFutureMonthOrder,
		strAccountNumber,
		dblNoOfContract,
		strTradeNo,
		TransactionDate,
		TranType,
		CustVendor,
		dblNoOfLot,
		dblQuantity,
		intOrderByHeading,
		intContractHeaderId,
		intFutOptTransactionHeaderId,
		strProductType,
		strProductLine,
		strShipmentPeriod,
		strLocation,
		strOrigin,
		intItemId,
		strItemNo,
		strItemDescription,
		intBookId,
		strBook,
		intSubBookId,
		strSubBook
		, strCertificationName
		, strCropYear
		)
	EXEC uspRKRiskPositionInquiryBySummary @intCommodityId = @intCommodityId,
		@intCompanyLocationId = @intCompanyLocationId,
		@intFutureMarketId = @intFutureMarketId,
		@intFutureMonthId = @intFutureMonthId,
		@intUOMId = @intUOMId,
		@intDecimal = @intDecimal,
		@intForecastWeeklyConsumption = @intForecastWeeklyConsumption,
		@intForecastWeeklyConsumptionUOMId = @intForecastWeeklyConsumptionUOMId,
		@intBookId = @intBookId,
		@intSubBookId = @intSubBookId,
		@strPositionBy = @strPositionBy,
		@dtmPositionAsOf = @dtmPositionAsOf,
		@strUomType = @strUomType


	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp
	IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
		DROP TABLE #temp1

	SELECT intRowNumber1 intRowNumber,
		strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		strAccountNumber,
		CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) dblNoOfContract,
		strTradeNo,
		TransactionDate,
		TranType,
		CustVendor,
		dblNoOfLot,
		dblQuantity,
		intOrderByHeading,
		intContractHeaderId,
		intFutOptTransactionHeaderId
		,intBookId,intSubBookId,strBook,strSubBook
	INTO #temp
	FROM @MonthOrder
	ORDER BY strGroup,
		PriceStatus,
		CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END

	SELECT row_number() OVER (
			ORDER BY intRowNumber
			) intRowNumFinal,
		intRowNumber,
		strGroup,
		Selection,
		PriceStatus,
		strFutureMonth,
		strAccountNumber,
		CASE WHEN CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) = 0 THEN NULL ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) END dblNoOfContract,
		strTradeNo,
		TransactionDate,
		TranType,
		CustVendor,
		dblNoOfLot,
		dblQuantity,
		intOrderByHeading,
		intContractHeaderId,
		intFutOptTransactionHeaderId,intBookId,intSubBookId,strBook,strSubBook
	INTO #temp1
	FROM #temp
	ORDER BY strGroup,
		PriceStatus,
		CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END

	IF @strReportName = 'Outright Coverage'
		SELECT intRowNumber,
			replace(strGroup, '1.', '') strGroup,
			Selection,
			PriceStatus,
			strFutureMonth,
			strAccountNumber,
			CASE WHEN @strUomType = 'By Lot' AND strAccountNumber <> 'Avg Long Price' THEN (CONVERT(DOUBLE PRECISION, ROUND(dblNoOfLot, @intDecimal))) ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) END dblNoOfContract,
			CONVERT(NUMERIC(24, 10), CONVERT(NVARCHAR, DENSE_RANK() OVER (
						PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END
						)) + '.1234567890') AS [Rank],
			@strCommodityCodeH strCommodityCode,
			@strFutureMarketH strFutureMarket,
			@strFutureMonthH strFutureMonth1,
			@strUnitMeasureH strUnitMeasure,
			@strLocationH strLocation,
			@strBookH strBookH,
			@strSubBookH strSubBookH,
			@dtmPositionAsOf dtmPositionAsOf,
			intOrderByHeading = 1,intBookId,intSubBookId,
			case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strBook,'')='' then '(blank)' else strBook end END strBook,
			case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strSubBook,'')='' then '(blank)' else strSubBook end END strSubBook
			,@ysnSubTotalByBook ysnSubTotalByBook
		FROM #temp1
		WHERE strGroup = '1.Outright Coverage' AND dblNoOfContract <> 0 and Selection = '5.Total - Market coverage'

	ELSE IF @strReportName = 'Futures Required'
		SELECT intRowNumber,
			replace(strGroup, '2.', '') strGroup,
			Selection,
			PriceStatus,
			strFutureMonth,
			strAccountNumber,
			CASE WHEN @strUomType = 'By Lot' AND strAccountNumber <> 'Avg Long Price' THEN (CONVERT(DOUBLE PRECISION, ROUND(dblNoOfLot, @intDecimal))) ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) END dblNoOfContract,
			CONVERT(NUMERIC(24, 10), CONVERT(NVARCHAR, DENSE_RANK() OVER (
						PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END
						)) + '.1234567890') AS [Rank],
			@strCommodityCodeH strCommodityCode,
			@strFutureMarketH strFutureMarket,
			@strFutureMonthH strFutureMonth1,
			@strUnitMeasureH strUnitMeasure,
			@strLocationH strLocation,
			@strBookH strBookH,
			@strSubBookH strSubBookH,
			@dtmPositionAsOf dtmPositionAsOf,
			intOrderByHeading = 2,intBookId,intSubBookId,				
				case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strBook,'')='' then '(blank)' else strBook end END strBook,
				case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strSubBook,'')='' then '(blank)' else strSubBook end END strSubBook
				,@ysnSubTotalByBook ysnSubTotalByBook
		FROM #temp1
		WHERE strGroup = '2.Futures Required' AND dblNoOfContract <> 0 and Selection = '6.Total - Net Position'
	ELSE
	
		SELECT intRowNumber,
			replace(replace(strGroup, '2.', ''),'1.','') strGroup ,
			Selection,
			PriceStatus,
			strFutureMonth,
			strAccountNumber,
			CASE WHEN @strUomType = 'By Lot' AND strAccountNumber <> 'Avg Long Price' THEN (CONVERT(DOUBLE PRECISION, ROUND(dblNoOfLot, @intDecimal))) ELSE CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) END dblNoOfContract,
			CONVERT(NUMERIC(24, 10), CONVERT(NVARCHAR, DENSE_RANK() OVER (
						PARTITION BY NULL ORDER BY CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900' WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END
						)) + '.1234567890') AS [Rank],
			@strCommodityCodeH strCommodityCode,
			@strFutureMarketH strFutureMarket,
			@strFutureMonthH strFutureMonth1,
			@strUnitMeasureH strUnitMeasure,
			@strLocationH strLocation,
			@strBookH strBookH,
			@strSubBookH strSubBookH,
			@dtmPositionAsOf dtmPositionAsOf,
			intOrderByHeading = CASE WHEN strGroup = '1.Outright Coverage' THEN 1 ELSE 2 END,intBookId,intSubBookId,
				case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strBook,'')='' then '(blank)' else strBook end END strBook,
				case when isnull(@ysnSubTotalByBook,0) = 0 then '(blank)' else 
				case when isnull(strSubBook,'')='' then '(blank)' else strSubBook end END strSubBook
				,@ysnSubTotalByBook ysnSubTotalByBook
		FROM #temp1
		WHERE dblNoOfContract <> 0 and Selection  in( '6.Total - Net Position','5.Total - Market coverage')
END
