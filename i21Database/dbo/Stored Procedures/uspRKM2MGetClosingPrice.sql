﻿CREATE PROC uspRKM2MGetClosingPrice   
  @intM2MBasisId int  
AS  
  
  
DECLARE @dtmPriceDate DateTime    
SELECT @dtmPriceDate=dtmM2MBasisDate from tblRKM2MBasis where intM2MBasisId=@intM2MBasisId  

SELECT CONVERT(INT,intRowNum) as intRowNum,intFutureMarketId,strFutMarketName,intFutureMonthId,strFutureMonth,dblClosingPrice,intConcurrencyId from (
SELECT ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum,f.intFutureMarketId,fm.intFutureMonthId,f.strFutMarketName,fm.strFutureMonth,  
dbo.fnRKGetLatestClosingPrice(f.intFutureMarketId,fm.intFutureMonthId,@dtmPriceDate) as dblClosingPrice,0 as intConcurrencyId  
FROM tblRKFutureMarket f  
JOIN tblRKFuturesMonth fm on f.intFutureMarketId = fm.intFutureMarketId   
)t
order by strFutMarketName,convert(datetime,'01 '+strFutureMonth) 

