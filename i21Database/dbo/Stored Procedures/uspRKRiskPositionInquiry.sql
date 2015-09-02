CREATE PROC uspRKRiskPositionInquiry
	@intCommodityId INTEGER,
	@intCompanyLocationId INTEGER,
	@intFutureMarketId INTEGER,
	@intFutureMonthId INTEGER,
	@intUOMId INTEGER,
	@intDecimal INTEGER	
AS

DECLARE @strUnitMeasure nvarchar(50)
DECLARE @dtmFutureMonthsDate datetime
DECLARE @dblContractSize int
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket where intFutureMarketId=@intFutureMarketId
select top 1 @dtmFutureMonthsDate=dtmFutureMonthsDate from tblRKFuturesMonth where intFutureMonthId=@intFutureMonthId
SELECT top 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUOMId

DECLARE @List as Table (
					intRowNumber int identity(1,1),
					Selection  nvarchar(200),
					PriceStatus  nvarchar(50),
					strFutureMonth  nvarchar(20),
					strAccountNumber  nvarchar(200),
					dblNoOfContract  decimal(24,10)
					)
					
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract)

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract FROM(

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unfixed - (Balance to be fixed)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		where fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'
			AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
			AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 

		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unfixed - (Balance to be fixed)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		
)T1


UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unfixed - (Balance to be fixed)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 			  
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unfixed - (Balance to be fixed)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Fixed / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Fixed / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Fixed / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		UNION 	
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Fixed / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
)T1

UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract) as dblNoOfContract from
(
SELECT DISTINCT '2.TERMINAL POSITION (a. in lots )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then sum(ft.intNoOfContract) else - sum(ft.intNoOfContract) end as dblNoOfContract
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
GROUP BY ba.strAccountNumber,fm.strFutureMonth,ft.strBuySell
)t
GROUP BY Selection,PriceStatus,strFutureMonth,strAccountNumber

UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,SUM(dblNoOfContract)) as dblNoOfContract from
(
SELECT DISTINCT '3.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then sum(ft.intNoOfContract) else - sum(ft.intNoOfContract) end as dblNoOfContract
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
GROUP BY ba.strAccountNumber,fm.strFutureMonth,ft.strBuySell
)t
GROUP BY Selection,PriceStatus,strFutureMonth,strAccountNumber

UNION

SELECT DISTINCT '4.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,SUM(dblNoOfContract) as dblNoOfContract from (
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,SUM(dblNoOfContract)) as dblNoOfContract from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then sum(ft.intNoOfContract) else - sum(ft.intNoOfContract) end as dblNoOfContract
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY ba.strAccountNumber,fm.strFutureMonth,ft.strBuySell
		)t
		GROUP BY Selection,PriceStatus,strFutureMonth,strAccountNumber
) t GROUP BY strFutureMonth 
UNION
SELECT DISTINCT '5.NET MARKET RISK' as Selection,'NET MARKET RISK' as PriceStatus,strFutureMonth,'Market Risk' as strAccountNumber,SUM(dblNoOfContract) as dblNoOfContract from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		union
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0)) as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		
		UNION 
		
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,SUM(dblNoOfContract)) as dblNoOfContract from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then sum(ft.intNoOfContract) else - sum(ft.intNoOfContract) end as dblNoOfContract
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY ba.strAccountNumber,fm.strFutureMonth,ft.strBuySell
		)t
		GROUP BY Selection,PriceStatus,strFutureMonth,strAccountNumber
) t GROUP BY strFutureMonth 

UNION

SELECT DISTINCT '6.SWITCH POSITION' as Selection,'SWITCH POSITION' as PriceStatus,strFutureMonth,'SWITCH POSITION' as strAccountNumber,SUM(dblNoOfContract) as dblNoOfContract from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		union
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull(SUM(isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY cv.intFutureMarketId,cv.strFutureMonth,intCommodityId,strContractType,strItemNo,cv.intItemId,u.intUnitMeasureId
		UNION
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,SUM(dblNoOfContract)) as dblNoOfContract from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then sum(ft.intNoOfContract) else - sum(ft.intNoOfContract) end as dblNoOfContract
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		GROUP BY ba.strAccountNumber,fm.strFutureMonth,ft.strBuySell
		)t
		GROUP BY Selection,PriceStatus,strFutureMonth,strAccountNumber
) t GROUP BY strFutureMonth 
) T

SELECT intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,
	   CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract FROM @List  
 order by case when  strFutureMonth <>'(Previous)' then convert(datetime,'01 '+strFutureMonth) end asc
