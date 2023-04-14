CREATE PROCEDURE [dbo].[uspRKRiskPositionInquiryChart]
	@intCommodityId INTEGER
	, @intCompanyLocationId INTEGER
	, @intFutureMarketId INTEGER
	, @intFutureMonthId INTEGER
	, @intUOMId INTEGER
	, @intDecimal INTEGER
	, @intForecastWeeklyConsumption INTEGER = null
	, @intForecastWeeklyConsumptionUOMId INTEGER = null
	, @intBookId int = NULL
	, @intSubBookId int = NULL
	, @strPositionBy nvarchar(100) = NULL
	, @dtmPositionAsOf datetime = NULL
	, @strUomType nvarchar(100) = NULL
	, @strOriginIds NVARCHAR(500) = NULL

AS

IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
	SET @intForecastWeeklyConsumption = 1
END
IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
	SET @intForecastWeeklyConsumptionUOMId = @intUOMId
END

DECLARE @intRiskViewId INT
SELECT TOP 1 @intRiskViewId = intRiskViewId FROM tblRKCompanyPreference

DECLARE @tblFinalDetail TABLE (intRowNumber INT
	, strGroup NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, PriceStatus NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, strAccountNumber NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, dblNoOfContract DECIMAL(24, 10)
	, strTradeNo NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, TransactionDate DATETIME
	, TranType NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, CustVendor NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, dblNoOfLot DECIMAL(24, 10)
	, dblQuantity DECIMAL(24, 10)
	, intOrderByHeading INT
	, intContractHeaderId INT
	, intFutOptTransactionHeaderId INT)

DECLARE @tblMonthFinal TABLE (intRowNum INT identity(1, 1)
	, strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, dblNetMarketRisk DECIMAL(24, 10)
	, dblPhysicalPosition DECIMAL(24, 10)
	, Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS)

IF @intRiskViewId <> 2
BEGIN
	DECLARE @RiskPositionInquiryTable AS TABLE (intRowNumber INT
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, intFutureMonthOrder INT
		, strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
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
		, strCertificationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblHedgedLots DECIMAL(24, 10)
		, dblToBeHedgedLots DECIMAL(24, 10)
	)
	
	INSERT INTO @RiskPositionInquiryTable 
	EXEC uspRKRiskPositionInquiry @intCommodityId = @intCommodityId
		, @intCompanyLocationId = @intCompanyLocationId
		, @intFutureMarketId = @intFutureMarketId
		, @intFutureMonthId = @intFutureMonthId
		, @intUOMId = @intUOMId
		, @intDecimal = @intDecimal
		, @intForecastWeeklyConsumption=@intForecastWeeklyConsumption
		, @intForecastWeeklyConsumptionUOMId=@intForecastWeeklyConsumptionUOMId
		, @intBookId  = @intBookId
		, @intSubBookId = @intSubBookId
		, @strPositionBy = @strPositionBy
		, @strOriginIds = @strOriginIds
	
	INSERT INTO @tblFinalDetail (intRowNumber
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
	FROM @RiskPositionInquiryTable
	
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutureMonth ASC)) intRowNum
		, ISNULL((select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.Selection = 'Physical position / Basis risk' and t1.strFutureMonth= t.strFutureMonth),0) dblPhysicalPosition
		, ISNULL((select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.strAccountNumber='Market risk' and t1.strFutureMonth= t.strFutureMonth),0) dblNetMarketRisk
		, strFutureMonth
		, '' as Selection
	FROM @tblFinalDetail t WHERE (Selection = 'Physical position / Basis risk' or strAccountNumber='Market risk')  and strFutureMonth <> 'Previous'
	GROUP BY strFutureMonth
	ORDER BY CASE 
				WHEN strFutureMonth ='Total' THEN '01/01/9999'
				WHEN strFutureMonth NOT IN ('Previous', 'Total') THEN CONVERT(DATETIME,REPLACE(strFutureMonth, ' ', ' 1, ')) END
END
ELSE
BEGIN
	DECLARE @RiskPositionInquiryBySummaryTable TABLE(intRowNumFinal INT
		, intRowNumber INT
		, strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, intFutureMonthOrder INT
		, strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, dblNoOfContract DECIMAL(24, 10)
		, strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, TransactionDate DATETIME
		, TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
		, CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
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
		, intBookId INT
		, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intSubBookId INT
		, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCertificationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)

	INSERT INTO @RiskPositionInquiryBySummaryTable(intRowNumFinal
		, intRowNumber
		, strGroup
		, Selection
		, PriceStatus
		, strFutureMonth
		, intFutureMonthOrder
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
		, strCertificationName
		, strCropYear
	)
	EXEC uspRKRiskPositionInquiryBySummary @intCommodityId = @intCommodityId
		, @intCompanyLocationId = @intCompanyLocationId
		, @intFutureMarketId = @intFutureMarketId
		, @intFutureMonthId = @intFutureMonthId
		, @intUOMId = @intUOMId
		, @intDecimal = @intDecimal
		, @intForecastWeeklyConsumption=@intForecastWeeklyConsumption
		, @intForecastWeeklyConsumptionUOMId=@intForecastWeeklyConsumptionUOMId 
		, @intBookId  = @intBookId 
		, @intSubBookId = @intSubBookId
		, @strPositionBy=@strPositionBy
		, @dtmPositionAsOf=@dtmPositionAsOf
		, @strUomType=@strUomType

	INSERT INTO @tblFinalDetail (intRowNumber
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
	FROM @RiskPositionInquiryBySummaryTable
	
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutureMonth ASC)) intRowNum
		, (select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.PriceStatus = '3.Market coverage' and t1.strFutureMonth= t.strFutureMonth) dblPhysicalPosition
		, (select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.PriceStatus='4.Net Position' and t1.strFutureMonth= t.strFutureMonth) dblNetMarketRisk
		, strFutureMonth
		, '' as Selection
	FROM @tblFinalDetail t WHERE PriceStatus in('3.Market coverage','4.Net Position') and strFutureMonth <> 'Previous'
	GROUP BY strFutureMonth
	ORDER BY CASE 
				WHEN strFutureMonth ='Total' THEN '01/01/9999'
				WHEN strFutureMonth NOT IN ('Previous', 'Total') THEN CONVERT(DATETIME,REPLACE(strFutureMonth, ' ', ' 1, ')) END
END