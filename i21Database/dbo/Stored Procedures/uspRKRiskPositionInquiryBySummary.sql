﻿CREATE PROC [dbo].uspRKRiskPositionInquiryBySummary  
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
declare @strParamFutureMonth nvarchar(12)  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate,@strParamFutureMonth=strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  

SELECT TOP 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
select @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

SELECT @intForecastWeeklyConsumptionUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intForecastWeeklyConsumptionUOMId  
SELECT @dblForecastWeeklyConsumption=isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intUOMId,@intForecastWeeklyConsumptionUOMId,@intForecastWeeklyConsumption),1)

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
				     @intFutureMonthId =@intFutureMonthId,          @intUOMId =@intUOMId,          @intDecimal =@intDecimal

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

	 --select  * from @ListImported
INSERT INTO @ListFinal 
SELECT
intRowNumber,'Outright Coverage','Priced / Outright - (Outright position)' Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,isnull(dblNoOfContract,0.0)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection ='Physical position / Differential cover' and PriceStatus='b. Priced / Outright - (Outright position)'
		AND ISNULL(dblNoOfContract,0)<> 0
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC


INSERT INTO @ListFinal
SELECT
intRowNumber,'Outright Coverage','Terminal Position' Selection,'Terminal Position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE    PriceStatus= 'Broker Account' and Selection <> 'Terminal position (a. in lots )'
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,'Outright Coverage','Terminal Position' Selection,'Terminal Position' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE    PriceStatus= 'F&O' and Selection <> 'Terminal position (a. in lots )'
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,'Outright Coverage',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection= CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END 
              and PriceStatus = CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC
--select * from @ListImported
INSERT INTO @ListFinal
SELECT
intRowNumber,'Outright Coverage','Outright coverage(Weeks)' Selection,'Outright coverage(Weeks)' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))/@dblForecastWeeklyConsumption as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection= CASE WHEN @strRiskView='Processor' THEN 'Outright coverage(Weeks)' ELSE 'Net market risk(weeks)' END
	--and PriceStatus= CASE WHEN @strRiskView='Processor' THEN 'xoverage(Weeks)' ELSE 'Net market risk(weeks)' END
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,'Futures Required','Unpriced - (Balance to be Priced)' Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    abs(CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal))) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,abs(dblNoOfLot) dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='a. Unpriced - (Balance to be Priced)'
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC


INSERT INTO @ListFinal
SELECT
intRowNumber,'Futures Required', Selection,'Terminal position ( in lots )' PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE Selection='Terminal position (a. in lots )' --and PriceStatus='F&O'  
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus='To Purchase'
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfLot,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListImported    
    WHERE PriceStatus=case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end 
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

 INSERT INTO @ListFinal
SELECT
intRowNumber,'Terminal position (Avg Long Price)',Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
     CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId FROM @ListImported    
    WHERE Selection='Terminal position (Avg Long Price)'
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

select intRowNumber ,strGroup,Selection ,  
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
				 intFutOptTransactionHeaderId  from @ListFinal