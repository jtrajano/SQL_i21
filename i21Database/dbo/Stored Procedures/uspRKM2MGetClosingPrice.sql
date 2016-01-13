create PROC uspRKM2MGetClosingPrice   
   @dtmPriceDate DateTime ,
  @intCommodityId int
AS  

SELECT CONVERT(INT,intRowNum) as intRowNum,intFutureMarketId,strFutMarketName,intFutureMonthId,strFutureMonth,dblClosingPrice,intConcurrencyId from (
SELECT ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum,f.intFutureMarketId,fm.intFutureMonthId,f.strFutMarketName,fm.strFutureMonth,  
dbo.fnRKGetLatestClosingPrice(f.intFutureMarketId,fm.intFutureMonthId,@dtmPriceDate) as dblClosingPrice,0 as intConcurrencyId  
FROM tblRKFutureMarket f  
JOIN tblRKFuturesMonth fm on f.intFutureMarketId = fm.intFutureMarketId 
join tblRKCommodityMarketMapping mm on fm.intFutureMarketId=mm.intFutureMarketId where mm.intCommodityId  =
case when @intCommodityId = 0 then mm.intCommodityId else @intCommodityId end 
)t where dblClosingPrice > 0
order by strFutMarketName,convert(datetime,'01 '+strFutureMonth) 
