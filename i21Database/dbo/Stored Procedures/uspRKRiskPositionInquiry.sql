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
					dblNoOfContract  decimal(24,10),
					strTradeNo  nvarchar(200),
					TransactionDate  datetime,
					TranType  nvarchar(50),
					CustVendor nvarchar(50)
					)
					
IF (isnull(@intCompanyLocationId,0) <> 0)
BEGIN
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor)
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor FROM(

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'
			AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
			AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
				
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		 FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 			  
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor from
(
SELECT DISTINCT '2.TERMINAL POSITION (a. in lots )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t


UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
(
SELECT DISTINCT '3.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId

JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t

UNION

SELECT DISTINCT '4.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from (
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t 
UNION
SELECT DISTINCT '5.NET MARKET RISK' as Selection,'NET MARKET RISK' as PriceStatus,strFutureMonth,'Market Risk' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION 
		
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor FROM
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t

UNION

SELECT DISTINCT '6.SWITCH POSITION' as Selection,'SWITCH POSITION' as PriceStatus,strFutureMonth,'SWITCH POSITION' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor FROM
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t
) T
END
ELSE
BEGIN
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor)

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor FROM(

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		where fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'
			AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
			AND intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 			  
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase' 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale' 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor from
(
SELECT DISTINCT '2.TERMINAL POSITION (a. in lots )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId

JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t
UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
(
SELECT DISTINCT '3.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId

JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t

UNION

SELECT DISTINCT '4.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from (
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND  ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t 
UNION
SELECT DISTINCT '5.NET MARKET RISK' as Selection,'NET MARKET RISK' as PriceStatus,strFutureMonth,'Market Risk' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
	
		UNION 
		
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND  ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t 
UNION

SELECT DISTINCT '6.SWITCH POSITION' as Selection,'SWITCH POSITION' as PriceStatus,strFutureMonth,'SWITCH POSITION' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityType as CustVendor
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId <> 1 
			  AND intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else - (ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, 'Futures Broker' as CustVendor
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND   ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t ) T

END
--- switch position update ------- start --------
declare @TotPrevious decimal(24,10)
declare @RowNumber int
SELECT @TotPrevious= sum(dblNoOfContract)/@dblContractSize FROM @List where Selection='1.PHYSICAL POSITION' 
			AND strFutureMonth='(Previous)' and PriceStatus='a. Unpriced - (Balance to be Priced)'

SELECT TOP 1 @RowNumber=intRowNumber FROM @List  WHERE PriceStatus='SWITCH POSITION'
ORDER BY CASE WHEN  strFutureMonth <>'(Previous)' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
UPDATE @List set dblNoOfContract= dblNoOfContract+@TotPrevious where intRowNumber=@RowNumber
--- switch position update ------- end --------
--- Net Market Risk ------- start --------
declare @TotPreviousRisk decimal(24,10)
declare @RowNumberRisk int
SELECT @TotPreviousRisk= sum(dblNoOfContract) FROM @List where Selection='1.PHYSICAL POSITION' 
			AND strFutureMonth='(Previous)' and PriceStatus='b. Priced / Outright - (Outright position)'

SELECT TOP 1 @RowNumberRisk=intRowNumber FROM @List  WHERE PriceStatus='NET MARKET RISK'
ORDER BY CASE WHEN  strFutureMonth <>'(Previous)' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
UPDATE @List set dblNoOfContract= dblNoOfContract+@TotPreviousRisk where intRowNumber=@RowNumberRisk
--- Net Market Risk ------- end --------

SELECT intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,
	   CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor FROM @List  
 ORDER BY CASE WHEN  strFutureMonth <>'(Previous)' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC