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
					CustVendor nvarchar(50),					
					dblNoOfLot decimal(24,10),
					dblQuantity decimal(24,10)					
					)
					
IF (isnull(@intCompanyLocationId,0) <> 0)
BEGIN
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM(

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,
		isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,
		dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId,isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'
			AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
			AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
				
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot,
		-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale' 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 			  
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity 
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase' 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,
		-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale' 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId,isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId <> 1 
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION
SELECT * FROM(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+ic.strItemNo as strAccountNumber,
		dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+ic.strItemNo as strAccountNumber,
		-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId  AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
(
SELECT DISTINCT '4.TERMINAL POSITION (a. in lots )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end as dblQuantity
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t


UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
(
SELECT DISTINCT '5.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t

UNION

SELECT DISTINCT '6.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t 
UNION
SELECT DISTINCT '7.NET MARKET RISK' as Selection,'NET MARKET RISK' as PriceStatus,strFutureMonth,'Market Risk' as strAccountNumber,
		(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM (
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		
		UNION 
		
				SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		
		UNION
		
		SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT '3.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
				ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
				case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
				case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId

		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
		
		UNION
			SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
				strContractType+' - '+ic.strItemNo as strAccountNumber,
				dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
				Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
				strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
				isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId
		JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
		AND ic.intProductLineId=pl.intCommodityProductLineId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
		AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
		AND dtmFutureMonthsDate >= @dtmFutureMonthsDate)t2
		
		UNION
			SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
				strContractType+' - '+ic.strItemNo as strAccountNumber,
				-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
				Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
				strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
				isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId
		JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
		AND ic.intProductLineId=pl.intCommodityProductLineId
		WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
		AND cv.intCommodityId=@intCommodityId  AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
		AND dtmFutureMonthsDate >= @dtmFutureMonthsDate)t3
	
) t

UNION

SELECT DISTINCT '8.SWITCH POSITION' as Selection,'SWITCH POSITION' as PriceStatus,strFutureMonth,'SWITCH POSITION' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,
		 	dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
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
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM(
SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		where fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'
			AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
			AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale' 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 			  
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase' 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION 

SELECT * FROM(
		SELECT  DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'(Previous)' as strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale' 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  AND dtmFutureMonthsDate <= @dtmFutureMonthsDate 
		UNION 	
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, 
		strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId <> 1 
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '2.SPECIALITIES & LOW GRADES' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION
SELECT * FROM(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+ic.strItemNo as strAccountNumber,
		dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1
UNION
SELECT * FROM(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+ic.strItemNo as strAccountNumber,
		-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
		isnull((isnull(dblBalance,0)),0)) as dblQuantity
FROM vyuCTContractDetailView cv
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
JOIN tblICItem ic on ic.intItemId=cv.intItemId
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
AND ic.intProductLineId=pl.intCommodityProductLineId
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
)T1

UNION

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
(
SELECT DISTINCT '4.TERMINAL POSITION (a. in lots )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId

JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t
UNION 

SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
(
SELECT DISTINCT '5.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
			strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEntity e on e.intEntityId=ft.intEntityId

JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId 
and dtmFutureMonthsDate >= @dtmFutureMonthsDate
)t

UNION

SELECT DISTINCT '6.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId
		
		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND  ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
) t 
UNION
SELECT DISTINCT '7.NET MARKET RISK' as Selection,'NET MARKET RISK' as PriceStatus,strFutureMonth,'Market Risk' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM (
		
		SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
			dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		
		UNION 
		
				SELECT DISTINCT '1.PHYSICAL POSITION' as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,
		strContractType+' - '+cv.strItemNo as strAccountNumber,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1 
			  AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		
		union
		
		SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT '3.TERMINAL POSITION (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
				ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
				case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
				case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEntity e on e.intEntityId=ft.intEntityId

		JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
		WHERE  intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId 
		and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		)t
		
		UNION
			SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
				strContractType+' - '+ic.strItemNo as strAccountNumber,
				dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
				Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
				strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
				isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId
		JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
		AND ic.intProductLineId=pl.intCommodityProductLineId
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1 
		AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId 
		AND dtmFutureMonthsDate >= @dtmFutureMonthsDate)t2
		
	UNION
		SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
	strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
	(
	SELECT DISTINCT '3.TOTAL SPECIALITY DELTA FIXED' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,
			strContractType+' - '+ic.strItemNo as strAccountNumber,
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,
			Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
			strContractType as TranType, strEntityName  as CustVendor,-isnull(dblBalance,0)/@dblContractSize as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, 
			isnull((isnull(dblBalance,0)),0)) as dblQuantity
	FROM vyuCTContractDetailView cv
	JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
	JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
	JOIN tblICItem ic on ic.intItemId=cv.intItemId
	JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId 
	AND ic.intProductLineId=pl.intCommodityProductLineId
	WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1 
	AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
	AND dtmFutureMonthsDate >= @dtmFutureMonthsDate)t3

) t

UNION

SELECT DISTINCT '8.SWITCH POSITION' as Selection,'SWITCH POSITION' as PriceStatus,strFutureMonth,'SWITCH POSITION' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (
		SELECT cv.strFutureMonth,dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,isnull(dblBalance,0)/@dblContractSize as dblNoOfLot, 
		dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
			SELECT DISTINCT cv.strFutureMonth,-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0))/@dblContractSize as dblNoOfContract,
		Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,
		strContractType as TranType, strEntityName  as CustVendor,-(isnull(dblBalance,0)/@dblContractSize) as dblNoOfLot, 
			-dbo.fnCTConvertQuantityToTargetItemUOM(cv.intItemId,u.intUnitMeasureId,@intUOMId, isnull((isnull(dblBalance,0)),0)) as dblQuantity
		FROM vyuCTContractDetailView cv
		JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId
		JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId
		JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici		
									JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
									AND ici.intProductLineId=pl.intCommodityProductLineId)	
		WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId <> 1 
			  AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId 
			  and dtmFutureMonthsDate >= @dtmFutureMonthsDate
		UNION
		SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract)) as dblNoOfContract,
		strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from
		(
		SELECT DISTINCT 'FUTURE TERMINAL POSITION (2. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,
					strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,
		ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot, 
		case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity
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
UPDATE @List set dblNoOfContract= dblNoOfContract+isnull(@TotPrevious,0) where intRowNumber=@RowNumber
--- switch position update ------- end --------
--- Net Market Risk ------- start --------
declare @TotPreviousRisk decimal(24,10)
declare @RowNumberRisk int
SELECT @TotPreviousRisk= sum(dblNoOfContract) FROM @List where Selection='1.PHYSICAL POSITION' 
			AND strFutureMonth='(Previous)' and PriceStatus='b. Priced / Outright - (Outright position)'

SELECT TOP 1 @RowNumberRisk=intRowNumber FROM @List  WHERE PriceStatus='NET MARKET RISK'
ORDER BY CASE WHEN  strFutureMonth <>'(Previous)' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
UPDATE @List set dblNoOfContract= dblNoOfContract+isnull(@TotPrevious,0) where intRowNumber=@RowNumberRisk
--- Net Market Risk ------- end --------

SELECT intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,
	   CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM @List  
 ORDER BY CASE WHEN  strFutureMonth <>'(Previous)' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END, Selection ASC