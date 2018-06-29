CREATE PROC [dbo].[uspRKRptRiskPositionInquiryBySummary]  
  @xmlParam NVARCHAR(MAX) 
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
		@intBookId  INTEGER = NULL,
        @intSubBookId  INTEGER = NULL,
        @strPositionBy nvarchar(100) = NULL


IF LTRIM(RTRIM(@xmlParam)) = ''
  SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
  fieldname NVARCHAR(50)
  ,condition NVARCHAR(20)
  ,[from] NVARCHAR(50)
  ,[to] NVARCHAR(50)
  ,[join] NVARCHAR(10)
  ,[begingroup] NVARCHAR(50)
  ,[endgroup] NVARCHAR(50)
  ,[datatype] NVARCHAR(50)
  )

EXEC sp_xml_preparedocument @idoc OUTPUT
  ,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
    fieldname NVARCHAR(50)
   ,condition NVARCHAR(20)
   ,[from] NVARCHAR(50)
   ,[to] NVARCHAR(50)
   ,[join] NVARCHAR(10)
   ,[begingroup] NVARCHAR(50)
   ,[endgroup] NVARCHAR(50)
   ,[datatype] NVARCHAR(50)
   )

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

DECLARE @temp as Table (  
     intRowNumber int,
     strGroup  nvarchar(200) COLLATE Latin1_General_CI_AS, 
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
	 strFutureMonthOrder  nvarchar(20) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(50) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
     intOrderByHeading int,
     intContractHeaderId int ,
     intFutOptTransactionHeaderId int       
     )
DECLARE @strRiskView nvarchar(100)
SELECT TOP 1 @strRiskView = strRiskView from tblRKCompanyPreference
if(@strRiskView='Trader/Elevator') 
BEGIN

INSERT INTO @temp (intRowNumber,Selection,PriceStatus,strFutureMonth,strFutureMonthOrder,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,  
     TranType, CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
Exec uspRKRiskPositionInquiry  @intCommodityId=@intCommodityId,  
        @intCompanyLocationId=@intCompanyLocationId,  
        @intFutureMarketId = @intFutureMarketId,  
        @intFutureMonthId = @intFutureMonthId,  
        @intUOMId = @intUOMId,  
        @intDecimal = @intDecimal,
        @intForecastWeeklyConsumption  =@intForecastWeeklyConsumption ,
        @intForecastWeeklyConsumptionUOMId =@intForecastWeeklyConsumptionUOMId,
		@intBookId=@intBookId,
		@intSubBookId=@intSubBookId,
		@strPositionBy=@strPositionBy
		
UPDATE @temp
SET strGroup =  case when Selection IN ('Physical position / Differential cover', 'Physical position / Basis risk') then '01.'+ Selection
				     when Selection = 'Specialities & Low grades' then  '02.'+ Selection 
					 when Selection = 'Total speciality delta fixed' then  '03.'+ Selection 
					 when Selection = 'Terminal position (a. in lots )' then  '04.'+ Selection 
					 when Selection = 'Terminal position (Avg Long Price)' then  '05.'+ Selection 
					 when Selection LIKE ('%Terminal position (b.%') then  '06.'+ Selection 
					 when Selection = 'Delta options' then  '07.'+ Selection 
					 when Selection = 'F&O' then  '08.'+ Selection 
					 when Selection LIKE ('%Total F&O(b. in%') then  '09.'+ Selection 
					 when Selection IN ('Outright coverage', 'Net market risk') then  '10.'+ Selection 
					 when Selection IN ('Switch position', 'Futures required') then  '11.'+ Selection 
					 end
					 		
SELECT  intRowNumber ,
	strGroup
   ,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
            CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))  dblNoOfContract,
   CONVERT(NUMERIC(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER   
   (PARTITION BY NULL ORDER BY 
   CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900'  WHEN  strFutureMonth ='Total' THEN '01/01/9999' ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '.1234567890') AS [Rank] 
  FROM @temp 

END

ELSE

BEGIN
INSERT INTO @temp (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,  
     TranType, CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
Exec uspRKRiskPositionInquiryBySummary  @intCommodityId=@intCommodityId,  
        @intCompanyLocationId=@intCompanyLocationId,  
        @intFutureMarketId = @intFutureMarketId,  
        @intFutureMonthId = @intFutureMonthId,  
        @intUOMId = @intUOMId,  
        @intDecimal = @intDecimal,
        @intForecastWeeklyConsumption  =@intForecastWeeklyConsumption ,
        @intForecastWeeklyConsumptionUOMId =@intForecastWeeklyConsumptionUOMId,
		@intBookId=@intBookId,
		@intSubBookId=@intSubBookId,
		@strPositionBy=@strPositionBy
		
SELECT  intRowNumber ,strGroup,Selection ,  
            PriceStatus  ,  
            strFutureMonth ,  
            strAccountNumber ,  
            CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))  dblNoOfContract,
   convert(numeric(24,10),CONVERT(NVARCHAR,DENSE_RANK() OVER   
   (PARTITION BY null ORDER BY 
   CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900'  WHEN  strFutureMonth ='Total' THEN '01/01/9999' ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '.1234567890') AS [Rank] 
INTO #temp
FROM @temp where isnull(dblNoOfContract,0) <> 0

SELECT * FROM #temp
ORDER BY strGroup,PriceStatus, 
CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900'  WHEN  strFutureMonth ='Total' THEN '01/01/9999' ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END
END