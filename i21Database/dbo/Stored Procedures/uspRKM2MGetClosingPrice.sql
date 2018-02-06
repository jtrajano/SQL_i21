CREATE PROC [dbo].[uspRKM2MGetClosingPrice]   
   @dtmPriceDate DateTime ,
   @intCommodityId int= null,
   @strPricingType nvarchar(30),
   @strFutureMonthIds nvarchar(max)
AS  

SELECT CONVERT(INT,intRowNum) as intRowNum,intFutureMarketId,strFutMarketName,intFutureMonthId,strFutureMonth,dblClosingPrice,intFutSettlementPriceMonthId,intConcurrencyId from (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum
		,f.intFutureMarketId
		,fm.intFutureMonthId
		,f.strFutMarketName
		,fm.strFutureMonth
		,dblClosingPrice = (SELECT TOP 1 dblLastSettle
							FROM tblRKFuturesSettlementPrice p
							INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
							WHERE p.intFutureMarketId = f.intFutureMarketId
								AND pm.intFutureMonthId = fm.intFutureMonthId
								AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmPriceDate, 111)
								AND p.strPricingType = @strPricingType
							ORDER BY dtmPriceDate DESC)
		,intFutSettlementPriceMonthId = (SELECT TOP 1 intFutSettlementPriceMonthId
							FROM tblRKFuturesSettlementPrice p
							INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
							WHERE p.intFutureMarketId = f.intFutureMarketId
								AND pm.intFutureMonthId = fm.intFutureMonthId
								AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmPriceDate, 111)
								AND p.strPricingType = @strPricingType
							ORDER BY dtmPriceDate DESC)
		,0 as intConcurrencyId  
FROM tblRKFutureMarket f  
JOIN tblRKFuturesMonth fm on f.intFutureMarketId = fm.intFutureMarketId and  fm.ysnExpired=0
join tblRKCommodityMarketMapping mm on fm.intFutureMarketId=mm.intFutureMarketId 
where mm.intCommodityId  = case when isnull(@intCommodityId,0) = 0 then mm.intCommodityId else @intCommodityId end 
and intFutureMonthId IN(select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](@strFutureMonthIds, ',')) --added this be able to filter by future months (RM-739)
)t where dblClosingPrice > 0
order by strFutMarketName,convert(datetime,'01 '+strFutureMonth)
