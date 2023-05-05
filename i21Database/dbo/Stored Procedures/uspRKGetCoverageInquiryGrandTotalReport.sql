CREATE PROCEDURE dbo.uspRKGetCoverageInquiryGrandTotalReport
--====================================================================
-- These variables are the filter fields on Coverage Inquiry screen. 
-- Kindly fill out with the desired value.
--=====================================================================
		@Commodity					NVARCHAR(100)	= ''
		,@Location					NVARCHAR(100)	= ''		-- Set - All -if you want to load it by all locations. Default is - All -
		,@Market					NVARCHAR(100)	= ''
		,@PositionAsOf				NVARCHAR(50)	= ''		-- This should be in @DateFormat format.
		,@SpotMonth					NVARCHAR(100)	= ''
		,@UOMType					NVARCHAR(100)	= ''		-- It can be By Quantity or By Lot. Default is By Quantity
		,@UOM						NVARCHAR(100)	= ''
		,@Book						NVARCHAR(100)	= ''
		,@SubBook					NVARCHAR(100)	= ''
		,@PositionBy				NVARCHAR(100)	= ''		-- It can be Product Type or Vendor/Customer. Default is Product Type
		,@Decimals					INT				= 0			-- It can be 0, 1, 2, 3 or 4. Default is 0.
		,@ForecastWeeklyConsumption	INT				= 0			-- If retain to 0 or null we will automatically get the Forecast Weekly Consumption of the Future Market entered above.
		,@ForecastWeeklyUOM			NVARCHAR(100)	= ''		-- If retain to empty or null we will automatically get the Forecast Weekly UOM of the Future Market entered above. 
		,@DateFormat				NVARCHAR(100)	= ''		-- It can be dd/MM/yyyy or MM/dd/yyyy. Default date format is MM/dd/yyyy


AS
--====================================
-- Actual data gathering starts here
--=====================================

BEGIN TRY
DECLARE @intCommodityId INT
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
	, @ErrorMessage  NVARCHAR(4000)
    , @ErrorSeverity INT 
    , @ErrorState    INT
	, @strCustomErrorMsg NVARCHAR(4000) = ''

SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = @Commodity
SELECT @intCompanyLocationId = intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = @Location
SELECT @intFutureMarketId = intFutureMarketId, @intForecastWeeklyConsumption = intForecastWeeklyConsumption, @intForecastWeeklyConsumptionUOMId = intForecastWeeklyConsumptionUOMId FROM tblRKFutureMarket WHERE strFutMarketName = @Market
SELECT @intFutureMonthId = intFutureMonthId FROM vyuRKGetFutureMonthAndYears WHERE intFutureMarketId = @intFutureMarketId AND strFutureMonthYear = @SpotMonth
SELECT @intUOMId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @UOM
SET @intDecimal = @Decimals
SET @strPositionBy = @PositionBy
SET @strUomType = @UOMType


IF @Location = '- All -'
BEGIN
	SET @intCompanyLocationId = 0
END

IF @DateFormat = ''
BEGIN
	SET @DateFormat = 'MM/dd/yyyy'
END

IF @DateFormat = 'dd/MM/yyyy'	
BEGIN
	SET @dtmPositionAsOf = CONVERT(DATETIME,@PositionAsOf,103)
END
IF @DateFormat = 'MM/dd/yyyy'	
BEGIN
	SET @dtmPositionAsOf = CONVERT(DATETIME,@PositionAsOf,101) 
END

IF @intUOMId IS NULL AND @strUomType = 'By Lot'
BEGIN
	SET @intUOMId = 0
END

IF ISNULL(@ForecastWeeklyConsumption,0) <> 0
BEGIN
	SET @intForecastWeeklyConsumption = @ForecastWeeklyConsumption
END

IF ISNULL(@ForecastWeeklyUOM,'') <> ''
BEGIN
	SELECT @intForecastWeeklyConsumptionUOMId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @ForecastWeeklyUOM
END

--Parameters validation
IF @intCommodityId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Commodity is invalid.' + CHAR(10);
END

IF @intCompanyLocationId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Location is invalid.' + CHAR(10);
END

IF @intFutureMarketId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Market is invalid.' + CHAR(10);
END

IF ISNULL(@dtmPositionAsOf,'') = ''
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Position As Of is invalid.' + CHAR(10);
END

IF @intFutureMonthId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Spot Month is invalid.' + CHAR(10);
END

IF @strUomType NOT IN ('By Quantity','By Lot') OR @strUomType IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'UOM Type is invalid. It is either By Quantity or By Lot only.' + CHAR(10);
END

IF @intUOMId IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'UOM is invalid.' + CHAR(10);
END

IF @strPositionBy NOT IN ('Product Type','Vendor/Customer') OR @strPositionBy IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Position By is invalid. It is either Product Type or Vendor/Customer only.' + CHAR(10);
END

IF @intDecimal NOT IN (0,1,2,3,4)  OR @intDecimal IS NULL
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Decimals is invalid. It is either 0, 1, 2, 3 or 4 only.' + CHAR(10);
END

IF @intForecastWeeklyConsumptionUOMId IS NULL AND @ForecastWeeklyUOM <> ''
BEGIN
	SET @strCustomErrorMsg = @strCustomErrorMsg + 'Forcast Weekly UOM is invalid.' + CHAR(10);
END


IF ISNULL(@strCustomErrorMsg,'') <> ''
BEGIN
	RAISERROR ( @strCustomErrorMsg ,16,1)
END

DECLARE @tmpRawData AS TABLE (intRowNumber1 INT 
		, intRowNumber INT
		, strGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, PriceStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, intFutureMonthOrder INT
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

INSERT INTO @tmpRawData
EXEC uspRKRiskPositionInquiryBySummary
	@intCommodityId
	, @intCompanyLocationId
	, @intFutureMarketId
	, @intFutureMonthId
	, @intUOMId
	, @intDecimal
	, @intForecastWeeklyConsumption
	, @intForecastWeeklyConsumptionUOMId
	, @intBookId
	, @intSubBookId
	, @strPositionBy 
	, @dtmPositionAsOf 
	, @strUomType


select distinct strFutureMonth, dblQuantity = 0.00 
into #tempFutureMonth
from @tmpRawData
where strFutureMonth not in ('Total')
--====================================
-- Actual data gathering ends here
--=====================================


--===========================================================================================================================================================================================================
--																								Results Ouput
--===========================================================================================================================================================================================================



--==================
-- GRAND TOTAL
--==================
SELECT 
	'Description' = replace(replace(strGroup, '2.', ''),'1.','')  
	,'Month' = strFutureMonth
	,'Value' = ROUND(SUM(dblQuantity),@intDecimal)
FROM (

	select 
		 strGroup
		,strFutureMonth
		,dblQuantity =  sum(dblNoOfContract)
	from @tmpRawData
	where strFutureMonth NOT IN ('Previous', 'Total')
	and Selection IN ( '6.Total - Net Position','5.Total - Market coverage')
	group by strGroup,  strFutureMonth

	union all
	select distinct
		 strGroup
		,FM.strFutureMonth
		,FM.dblQuantity 
	from @tmpRawData RD
	CROSS APPLY #tempFutureMonth FM
	where FM.strFutureMonth NOT IN ('Previous', 'Total')
	and Selection IN ( '6.Total - Net Position','5.Total - Market coverage')

	union all
	select
		strGroup 
		,strFutureMonth
		,dblQuantity=  sum(dblNoOfContract)
	from (
		select 
			strGroup 
			, strFutureMonth =  'Total'
			,dblNoOfContract=  sum(dblNoOfContract)
		from @tmpRawData
		where strFutureMonth NOT IN ('Previous', 'Total')
		and Selection IN ( '6.Total - Net Position','5.Total - Market coverage')
		group by strGroup,  strFutureMonth
	) t
	group by strGroup, strFutureMonth

) t
GROUP BY strGroup, strFutureMonth
ORDER BY strGroup,  CASE WHEN strFutureMonth = 'Total' THEN '01/01/9999' ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END


DROP TABLE #tempFutureMonth
END TRY

BEGIN CATCH

	 SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();

    -- return the error inside the CATCH block
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH