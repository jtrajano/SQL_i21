CREATE PROCEDURE dbo.uspRKGetCoverageEntryDetailReport
--====================================================================
-- These variables are the filter fields on Coverage Report screen. 
-- Kindly fill out with the desired value.
--=====================================================================
	 @BatchName					NVARCHAR(100)	= ''		-- User Input
	,@Commodity					NVARCHAR(100)	= ''
	,@Date						NVARCHAR(50)	= ''		-- This should be in @DateFormat format.
	,@UOMType					NVARCHAR(100)	= ''		-- It can be By Quantity or By Lot. Default is By Quantity
	,@UOM						NVARCHAR(100)	= ''
	,@Book						NVARCHAR(100)	= ''
	,@SubBook					NVARCHAR(100)	= ''
	,@Decimals					INT				= 0			-- It can be 0, 1, 2, 3 or 4. Default is 0.
	,@DateFormat				NVARCHAR(100)	= ''		-- It can be dd/MM/yyyy or MM/dd/yyyy. Default date format is MM/dd/yyyy

AS  
--====================================  
-- Actual data gathering starts here  
--=====================================  
  
BEGIN TRY  
DECLARE @intCommodityId INT  
 , @intUOMId INT = NULL  
 , @intDecimal INT = NULL  
 , @intForecastWeeklyConsumption INT = NULL  
 , @intForecastWeeklyConsumptionUOMId INT = NULL  
 , @intBookId INT = NULL  
 , @intSubBookId INT = NULL  
 , @dtmDate DATETIME  
 , @strUomType NVARCHAR(100)  
 , @ErrorMessage  NVARCHAR(4000)  
    , @ErrorSeverity INT   
    , @ErrorState    INT  
 , @strCustomErrorMsg NVARCHAR(4000) = ''  
  
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = @Commodity  
SELECT @intUOMId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @UOM  
SELECT @intBookId = intBookId FROM tblCTBook WHERE strBook = @Book
SELECT @intSubBookId = intSubBookId FROM tblCTSubBook WHERE strSubBook = @SubBook
SET @intDecimal = @Decimals  
SET @strUomType = @UOMType  
  

  
IF @DateFormat = ''  
BEGIN  
 SET @DateFormat = 'MM/dd/yyyy'  
END  
  
IF @DateFormat = 'dd/MM/yyyy'   
BEGIN  
 SET @dtmDate = CONVERT(DATETIME,@Date,103)  
END  
IF @DateFormat = 'MM/dd/yyyy'   
BEGIN  
 SET @dtmDate = CONVERT(DATETIME,@Date,101)   
END  
  
IF @intUOMId IS NULL AND @strUomType = 'By Lot'  
BEGIN  
 SET @intUOMId = 0  
END  
  

--Parameters validation  
IF @intCommodityId IS NULL  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'Commodity is invalid.' + CHAR(10);  
END  
  

  
IF ISNULL(@dtmDate,'') = ''  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'Date is invalid.' + CHAR(10);  
END  
  

  
IF @strUomType NOT IN ('By Quantity','By Lot') OR @strUomType IS NULL  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'UOM Type is invalid. It is either By Quantity or By Lot only.' + CHAR(10);  
END  
  
IF @intUOMId IS NULL  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'UOM is invalid.' + CHAR(10);  
END  
 
IF @Book <> '' AND @intBookId IS NULL 
BEGIN
	 SET @strCustomErrorMsg = @strCustomErrorMsg + 'Book is invalid.' + CHAR(10);  
END
 
 IF @SubBook <> '' AND @intSubBookId IS NULL 
BEGIN
	 SET @strCustomErrorMsg = @strCustomErrorMsg + 'Sub-Book is invalid.' + CHAR(10);  
END

IF @intDecimal NOT IN (0,1,2,3,4)  OR @intDecimal IS NULL  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'Decimals is invalid. It is either 0, 1, 2, 3 or 4 only.' + CHAR(10);  
END  
  

  
  
IF ISNULL(@strCustomErrorMsg,'') <> ''  
BEGIN  
 RAISERROR ( @strCustomErrorMsg ,16,1)  
END  
  
DECLARE @tmpRawData AS TABLE (
 intProductTypeId INT
, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
, intBookId INT
, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
, intSubBookId INT
, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
, dblOpenContract NUMERIC(24, 10)
, dblInTransit NUMERIC(24, 10)
, dblStock NUMERIC(24, 10)
, dblTotalPhysical NUMERIC(24, 10)
, dblOpenFutures NUMERIC(24, 10)
, dblTotalPosition NUMERIC(24, 10)
, dblMonthsCovered NUMERIC(24, 10)
, dblAveragePrice NUMERIC(24, 10)
, dblTotalOption NUMERIC(24, 10)
, dblOptionsCovered NUMERIC(24, 10)
, dblFuturesM2M NUMERIC(24, 10)
, dblM2MPlus10 NUMERIC(24, 10)
, dblM2MMinus10 NUMERIC(24, 10) 
 )  
  
INSERT INTO @tmpRawData  
EXEC uspRKGetCoverageEntryDetail  
	@dtmDate
	,@intCommodityId
	,@strUomType
	,@intUOMId
	,@intBookId
	,@intSubBookId
	,@intDecimal


--====================================  
-- Actual data gathering ends here  
--=====================================  
  
  
--===========================================================================================================================================================================================================  
--                        Results Ouput  
--===========================================================================================================================================================================================================  
 
select  
	@BatchName			as [Batch Name]
	,@Date				as [Date]
	,@Commodity			as [Commodity]
	,strProductType		as [Product Type]
	,strBook			as [Book]
	,strSubBook			as [SubBook]
	,dblOpenContract	as [Open Contracts]
	,dblInTransit		as [In-Transit]
	,dblStock			as [Stock]
	,dblTotalPhysical	as [Total Physical]
	,dblOpenFutures		as [Open Futures]
	,dblTotalPosition	as [Total Position]
	,dblMonthsCovered	as [Months Covered]
	,dblAveragePrice	as [Avg Price]
	,dblOptionsCovered	as [Options Covered]
	,dblFuturesM2M		as [Futures M2M]
	,dblM2MPlus10		as [Futures M2M +%]
	,dblM2MMinus10		as [Futures M2M -%]

from @tmpRawData   

END TRY  
  
BEGIN CATCH  
  
  SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  
  
    -- return the error inside the CATCH block  
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)  
  
END CATCH