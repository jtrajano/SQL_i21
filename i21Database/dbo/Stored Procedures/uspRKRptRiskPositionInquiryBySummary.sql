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
        @intForecastWeeklyConsumptionUOMId INTEGER = NULL   

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

SELECT @intCommodityId = [from]	FROM @temp_xml_table WHERE [fieldname] = 'intCommodityId'	
SELECT @intCompanyLocationId = [from] FROM @temp_xml_table	WHERE [fieldname] = 'intCompanyLocationId'	
SELECT @intFutureMarketId = [from] FROM @temp_xml_table	WHERE [fieldname] = 'intFutureMarketId'
SELECT @intFutureMonthId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intFutureMonthId'
SELECT @intUOMId = [from] FROM @temp_xml_table	WHERE [fieldname] = 'intUOMId'	
SELECT @intDecimal = [from]	FROM @temp_xml_table WHERE [fieldname] = 'intDecimal'	
SELECT @intForecastWeeklyConsumption = [from] FROM @temp_xml_table WHERE [fieldname] = 'intForecastWeeklyConsumption'	
SELECT @intForecastWeeklyConsumptionUOMId = [from]	FROM @temp_xml_table WHERE [fieldname] = 'intForecastWeeklyConsumptionUOMId'

DECLARE @temp as Table (  
     intRowNumber int,
	 strGroup  nvarchar(200) COLLATE Latin1_General_CI_AS, 
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
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


INSERT INTO @temp (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,  
					TranType, CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
Exec uspRKRiskPositionInquiryBySummary  @intCommodityId=@intCommodityId,  
        @intCompanyLocationId=@intCompanyLocationId,  
        @intFutureMarketId = @intFutureMarketId,  
        @intFutureMonthId = @intFutureMonthId,  
        @intUOMId = @intUOMId,  
        @intDecimal = @intDecimal,
        @intForecastWeeklyConsumption  =@intForecastWeeklyConsumption ,
        @intForecastWeeklyConsumptionUOMId =@intForecastWeeklyConsumptionUOMId

SELECT  intRowNumber ,strGroup,Selection ,  
            PriceStatus  ,  
            strFutureMonth ,  
            strAccountNumber ,  
            CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))  dblNoOfContract,
			CONVERT(NVARCHAR,DENSE_RANK() OVER   
			(PARTITION BY strGroup ORDER BY 
			CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900'  WHEN  strFutureMonth ='Total' THEN '01/01/9999' ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ))+ '###!!!' AS [Rank] 
FROM @temp
ORDER BY strGroup,PriceStatus, 
CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900'  WHEN  strFutureMonth ='Total' THEN '01/01/9999' ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END

GO
