CREATE PROCEDURE dbo.uspRKGetCoverageReport
--====================================================================
-- These variables are the date range filter fields to get the generated data of Coverage Report screen. 
-- Kindly fill out with the desired value.
--=====================================================================
	 @FromDate		NVARCHAR(50)	= ''		-- This should be in @DateFormat format.
	,@ToDate		NVARCHAR(50)	= ''		-- This should be in @DateFormat format.
	,@DateFormat	NVARCHAR(100)	= ''		-- It can be dd/MM/yyyy or MM/dd/yyyy. Default date format is MM/dd/yyyy

AS  
--====================================  
-- Actual data gathering starts here  
--=====================================  
  
BEGIN TRY 

DECLARE	@ErrorMessage  NVARCHAR(4000)  
	, @ErrorSeverity INT   
    , @ErrorState    INT  
	, @strCustomErrorMsg NVARCHAR(4000) = ''  

--Validations
IF ISNULL(@FromDate,'') = ''  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'From Date is invalid.' + CHAR(10);  
END  

IF ISNULL(@ToDate,'') = ''  
BEGIN  
 SET @strCustomErrorMsg = @strCustomErrorMsg + 'To Date is invalid.' + CHAR(10);  
END  

IF ISNULL(@strCustomErrorMsg,'') <> ''  
BEGIN  
 RAISERROR ( @strCustomErrorMsg ,16,1)  
END  


--Date formatting
IF @DateFormat = ''  
BEGIN  
 SET @DateFormat = 'MM/dd/yyyy'  
END  
  
IF @DateFormat = 'dd/MM/yyyy'   
BEGIN  
 SET @FromDate = CONVERT(DATETIME,@FromDate,103)
 SET @ToDate = CONVERT(DATETIME,@ToDate,103) 
END  
IF @DateFormat = 'MM/dd/yyyy'   
BEGIN  
 SET @FromDate = CONVERT(DATETIME,@FromDate,101)
 SET @ToDate = CONVERT(DATETIME,@ToDate,103) 
END  


--Data Gathering
SELECT 
	[Batch Name] = CE.strBatchName
	,[Date on which Batch Ran] = CE.dtmDate
	,[Product Type] = CED.strProductType
	,[Book] = CE.strBook
	,[SubBook] = CE.strSubBook
	,[Open Contracts] = CED.dblOpenContract
	,[In-Transit] = CED.dblInTransit
	,[Stock] = CED.dblStock
	,[Total Physical] = CED.dblTotalPhysical
	,[Open Futures] = CED.dblOpenFutures
	,[Total Position] = CED.dblTotalPosition
	,[Monts Covered] = CED.dblMonthsCovered
	,[Avg Price] = CED.dblAveragePrice
	,[Options Covered] = CED.dblOptionsCovered
	,[Futures M2M] = CED.dblFuturesM2M
	,[Futures M2M+%] = CED.dblM2MPlus10
	,[Futures M2M-%] = CED.dblM2MMinus10
FROM vyuRKGetCoverageEntry CE
INNER JOIN vyuRKGetCoverageEntryDetail CED ON CED.intCoverageEntryId = CE.intCoverageEntryId
WHERE CE.dtmDate BETWEEN @FromDate AND @ToDate



END TRY  
  
BEGIN CATCH  
  
  SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  
  
    -- return the error inside the CATCH block  
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)  
  
END CATCH