CREATE PROC [dbo].[uspRKRiskPositionInquiryBySummary]  
        @intCommodityId INTEGER,  
        @intCompanyLocationId INTEGER,  
        @intFutureMarketId INTEGER,  
        @intFutureMonthId INTEGER,  
        @intUOMId INTEGER,  
        @intDecimal INTEGER,
        @intForecastWeeklyConsumption INTEGER = null,
        @intForecastWeeklyConsumptionUOMId INTEGER = null   
AS  

DECLARE @strUnitMeasure nvarchar(50)  
DECLARE @dtmFutureMonthsDate datetime  
DECLARE @dblContractSize int  
DECLARE @ysnIncludeInventoryHedge BIT
DECLARE @strRiskView nvarchar(50) 
DECLARE @strFutureMonth  nvarchar(15) ,@dblForecastWeeklyConsumption numeric(18,6)
declare @intOldUOMId int
set @intOldUOMId =@intUOMId
declare @strParamFutureMonth nvarchar(12)  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate,@strParamFutureMonth=strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  

SELECT TOP 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
select @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

DECLARE @intForecastWeeklyConsumptionUOMId1 int
SELECT @intForecastWeeklyConsumptionUOMId1=intCommodityUnitMeasureId from tblICCommodityUnitMeasure 
                     WHERE intCommodityId=@intCommodityId and intUnitMeasureId=@intForecastWeeklyConsumptionUOMId  

SELECT @dblForecastWeeklyConsumption=isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1,@intUOMId,@intForecastWeeklyConsumption),1)
DECLARE @ListImported as Table (    
        intRowNumber int,
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

INSERT INTO @ListImported
exec uspRKRiskPositionInquiry @intCommodityId =@intCommodityId, @intCompanyLocationId =@intCompanyLocationId, @intFutureMarketId =@intFutureMarketId ,  
                                @intFutureMonthId =@intFutureMonthId,          @intUOMId =@intOldUOMId,          @intDecimal =@intDecimal

DECLARE @ListFinal as Table (  
                            intRowNumber int,
                           strGroup nvarchar(250),
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


INSERT INTO @ListFinal 
--select * from (
SELECT
1 intRowNumber,'Outright Coverage','Priced / Outright - (Outright position)' Selection,'Priced / Outright - (Outright position)' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,isnull(dblNoOfContract,0.0)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection ='Physical position / Differential cover' and PriceStatus='b. Priced / Outright - (Outright position)'
              AND ISNULL(dblNoOfContract,0)<> 0

union
SELECT
2 intRowNumber,'Outright Coverage', Selection,'Terminal Position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus= 'Broker Account' and Selection <> 'Terminal position (a. in lots )'

union

SELECT
3 intRowNumber,'Outright Coverage','Terminal Position' Selection,'Terminal Position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE    PriceStatus= 'F&O' and Selection <> 'Terminal position (a. in lots )'

union

SELECT
4 intRowNumber,'Outright Coverage',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection= CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END 
              and PriceStatus = CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END

union

SELECT
5 intRowNumber,'Outright Coverage','Outright coverage(Weeks)' Selection,'Outright coverage(Weeks)' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))/@dblForecastWeeklyConsumption as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection=CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END

union

SELECT
6 intRowNumber,'Futures Required', Selection,'Terminal position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus= 'Broker Account' and Selection ='Terminal position (b. in '+ @strUnitMeasure +' )'

union

SELECT
7 intRowNumber,'Futures Required','Unpriced - (Balance to be Priced)' Selection,'Unpriced - (Balance to be Priced)' PriceStatus,strFutureMonth,strAccountNumber,  
    abs(CONVERT(DOUBLE PRECISION,ROUND(dblQuantity,@intDecimal))) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,abs(dblNoOfLot) dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='a. Unpriced - (Balance to be Priced)'

union

SELECT
8 intRowNumber,'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblQuantity,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='To Purchase'

union

select intRowNumber,'Futures Required' strGroup,'Futures Required' Selection ,'Futures Required' PriceStatus,strFutureMonth,strAccountNumber, 
dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId 
 from (
SELECT
9 intRowNumber,'Futures Required' strGroup,'Unpriced - (Balance to be Priced)' Selection,'Unpriced - (Balance to be Priced)' PriceStatus,strFutureMonth,strAccountNumber,  
    -abs(CONVERT(DOUBLE PRECISION,ROUND(dblQuantity,@intDecimal))) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,abs(dblNoOfLot) dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='a. Unpriced - (Balance to be Priced)'

union

SELECT
9 intRowNumber,'Futures Required', Selection,'Terminal position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus= 'Broker Account' and Selection ='Terminal position (b. in '+ @strUnitMeasure +' )' 
union

SELECT
9 intRowNumber,'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    -abs(CONVERT(DOUBLE PRECISION,ROUND(dblQuantity,@intDecimal))) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='To Purchase') t

UNION

SELECT
10 intRowNumber,'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor, dblNoOfLot, 
     CONVERT(DOUBLE PRECISION,ROUND(dblQuantity,@intDecimal)) as dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId FROM @ListImported    
    WHERE Selection='Terminal position (Avg Long Price)'--)t

SELECT intRowNumber ,strGroup,Selection ,  
                            PriceStatus  ,  
                            strFutureMonth ,  
                            strAccountNumber ,  
                           CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) dblNoOfContract,  
                            strTradeNo,  
                            TransactionDate  ,  
                            TranType,  
                            CustVendor,       
                            dblNoOfLot ,  
                            dblQuantity ,
                           intOrderByHeading ,
                           intContractHeaderId ,
                           intFutOptTransactionHeaderId  from @ListFinal order by intRowNumber, CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC
GO